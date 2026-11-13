#if os(macOS)
import Carbon
import Foundation
import GrakerCore

enum ShortcutFailure: LocalizedError {
    case registration(Bool)
    var errorDescription: String? {
        switch self {
        case .registration(true): return "Ce raccourci est déjà utilisé. Les anciens raccourcis restent actifs. Choisissez une autre lettre."
        case .registration(false): return "Les raccourcis globaux n’ont pas pu être activés. Choisissez d’autres lettres ; les commandes du menu restent disponibles."
        }
    }
}

final class ShortcutController {
    /// L'identifiant d'un raccourci est la position de son mode dans `Mode.allCases`, plus un.
    var onShortcut: (@MainActor (Mode) -> Void)?
    var onError: (@MainActor (String) -> Void)?
    private var handler: EventHandlerRef?
    private var layoutObserver: NSObjectProtocol?
    private var references: [EventHotKeyRef] = []
    private var current: Configuration?
    private let signature: OSType = 0x47524B4C

    init() {
        var kind = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, context in
            guard let event, let context else { return OSStatus(eventNotHandledErr) }
            var identifier = EventHotKeyID()
            let status = GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                                           nil, MemoryLayout<EventHotKeyID>.size, nil, &identifier)
            guard status == noErr else { return status }
            let controller = Unmanaged<ShortcutController>.fromOpaque(context).takeUnretainedValue()
            guard identifier.signature == controller.signature else { return OSStatus(eventNotHandledErr) }
            let index = Int(identifier.id) - 1
            guard Mode.allCases.indices.contains(index) else { return OSStatus(eventNotHandledErr) }
            let mode = Mode.allCases[index]
            Task { @MainActor in controller.onShortcut?(mode) }
            return noErr
        }, 1, &kind, Unmanaged.passUnretained(self).toOpaque(), &handler)
        layoutObserver = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String), object: nil, queue: .main
        ) { [weak self] _ in
            guard let self, let current = self.current else { return }
            do { try self.register(current, isForced: true) }
            catch {
                let message = error.localizedDescription
                Task { @MainActor in self.onError?(message) }
            }
        }
    }

    func register(_ configuration: Configuration, isForced: Bool = false) throws {
        _ = try configuration.validate()
        guard handler != nil else { throw ShortcutFailure.registration(false) }
        if !isForced, current?.shortcutKeys == configuration.shortcutKeys,
           references.count == Mode.allCases.count { return }
        let previous = current
        unregister()
        do {
            try registerKeys(configuration)
            current = configuration
        } catch {
            unregister()
            if let previous {
                do {
                    try registerKeys(previous)
                    current = previous
                } catch {
                    unregister()
                    current = nil
                    throw ShortcutFailure.registration(false)
                }
                throw ShortcutFailure.registration(true)
            }
            throw ShortcutFailure.registration(false)
        }
    }

    private func registerKeys(_ configuration: Configuration) throws {
        for (offset, mode) in Mode.allCases.enumerated() {
            guard let key = configuration.shortcutKeys[mode], let code = resolveKeyCode(key) else {
                throw ShortcutFailure.registration(false)
            }
            var reference: EventHotKeyRef?
            let identifier = EventHotKeyID(signature: signature, id: UInt32(offset + 1))
            let status = RegisterEventHotKey(code, UInt32(cmdKey | shiftKey), identifier,
                                             GetApplicationEventTarget(), 0, &reference)
            guard status == noErr, let reference else { throw ShortcutFailure.registration(false) }
            references.append(reference)
        }
    }

    private func unregister() {
        for reference in references { UnregisterEventHotKey(reference) }
        references.removeAll()
    }

    /// Résout la lettre dans la disposition active, au lieu de supposer un clavier US.
    private func resolveKeyCode(_ letter: String) -> UInt32? {
        guard let source = TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue(),
              let rawData = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else { return nil }
        let data = Unmanaged<CFData>.fromOpaque(rawData).takeUnretainedValue()
        guard let bytes = CFDataGetBytePtr(data) else { return nil }
        let layout = UnsafeRawPointer(bytes).assumingMemoryBound(to: UCKeyboardLayout.self)
        for code in UInt16(0)..<128 {
            var deadKeyState: UInt32 = 0
            var characters = [UniChar](repeating: 0, count: 8)
            var length = 0
            let status = UCKeyTranslate(layout, code, UInt16(kUCKeyActionDisplay), 0,
                                        UInt32(LMGetKbdType()), OptionBits(kUCKeyTranslateNoDeadKeysMask),
                                        &deadKeyState, characters.count, &length, &characters)
            if status == noErr, length > 0,
               String(utf16CodeUnits: characters, count: Int(length)).uppercased() == letter { return UInt32(code) }
        }
        return nil
    }

    deinit {
        unregister()
        if let handler { RemoveEventHandler(handler) }
        if let layoutObserver { DistributedNotificationCenter.default().removeObserver(layoutObserver) }
    }
}
#endif
