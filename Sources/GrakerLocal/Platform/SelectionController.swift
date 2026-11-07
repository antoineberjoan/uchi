#if os(macOS)
import AppKit
import ApplicationServices
import GrakerCore

struct SelectionSnapshot {
    let application: NSRunningApplication
    let element: AXUIElement
    let range: CFRange
    let text: String
    let anchor: CGRect?
}

enum SelectionFailure: LocalizedError {
    case permission, unavailable, empty, protected, changed, replacement
    var errorDescription: String? {
        switch self {
        case .permission: return "Autorisez Graker Local dans Réglages Système → Confidentialité et sécurité → Accessibilité, puis resélectionnez le texte."
        case .unavailable: return "Cette application ne fournit pas sa sélection. Copiez le texte, puis utilisez Traduire le presse-papiers ou collez-le ici."
        case .empty: return "Sélectionnez d’abord un texte dans l’application d’origine."
        case .protected: return "Ce champ est protégé. Son contenu n’est pas lu."
        case .changed: return "La sélection d’origine a changé. Resélectionnez le texte et relancez, ou copiez le résultat."
        case .replacement: return "Cette application refuse le remplacement direct. Utilisez Copier, puis collez le résultat dans votre document."
        }
    }
}

@MainActor
final class SelectionController {
    var hasPermission: Bool { AXIsProcessTrusted() }

    func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    func capture() throws -> SelectionSnapshot {
        guard hasPermission else { throw SelectionFailure.permission }
        guard let application = NSWorkspace.shared.frontmostApplication,
              application.processIdentifier != ProcessInfo.processInfo.processIdentifier else { throw SelectionFailure.empty }
        let system = AXUIElementCreateSystemWide()
        AXUIElementSetMessagingTimeout(system, 1.5)
        guard let focused = copyAttribute(system, name: kAXFocusedUIElementAttribute),
              CFGetTypeID(focused) == AXUIElementGetTypeID() else { throw SelectionFailure.unavailable }
        let element = focused as! AXUIElement
        AXUIElementSetMessagingTimeout(element, 1.5)
        if let subrole = copyAttribute(element, name: kAXSubroleAttribute) as? String,
           subrole == kAXSecureTextFieldSubrole { throw SelectionFailure.protected }
        guard let text = copyAttribute(element, name: kAXSelectedTextAttribute) as? String,
              let range = readRange(element) else { throw SelectionFailure.unavailable }
        guard !text.isEmpty else { throw SelectionFailure.empty }
        var anchor: CGRect?
        var parameter = range
        if let rangeValue = AXValueCreate(.cfRange, &parameter) {
            var rawBounds: CFTypeRef?
            if AXUIElementCopyParameterizedAttributeValue(element, kAXBoundsForRangeParameterizedAttribute as CFString,
                                                         rangeValue, &rawBounds) == .success,
               let rawBounds, CFGetTypeID(rawBounds) == AXValueGetTypeID() {
                let bounds = rawBounds as! AXValue
                var rect = CGRect.zero
                if AXValueGetType(bounds) == .cgRect, AXValueGetValue(bounds, .cgRect, &rect),
                   !rect.isEmpty, let primary = NSScreen.screens.first {
                    anchor = PanelPlacement.convertAccessibilityRect(rect, desktopTop: primary.frame.maxY)
                }
            }
        }
        return SelectionSnapshot(application: application, element: element, range: range, text: text, anchor: anchor)
    }

    func replace(_ snapshot: SelectionSnapshot, with text: String) throws {
        guard hasPermission else { throw SelectionFailure.permission }
        guard !snapshot.application.isTerminated,
              let range = readRange(snapshot.element), range.location == snapshot.range.location,
              range.length == snapshot.range.length,
              copyAttribute(snapshot.element, name: kAXSelectedTextAttribute) as? String == snapshot.text else {
            throw SelectionFailure.changed
        }
        var canSet = DarwinBoolean(false)
        guard AXUIElementIsAttributeSettable(snapshot.element, kAXSelectedTextAttribute as CFString, &canSet) == .success,
              canSet.boolValue else { throw SelectionFailure.replacement }
        let status = AXUIElementSetAttributeValue(snapshot.element, kAXSelectedTextAttribute as CFString, text as CFString)
        guard status == .success else { throw SelectionFailure.replacement }
        snapshot.application.activate(options: [])
    }

    private func readRange(_ element: AXUIElement) -> CFRange? {
        guard let raw = copyAttribute(element, name: kAXSelectedTextRangeAttribute),
              CFGetTypeID(raw) == AXValueGetTypeID() else { return nil }
        let value = raw as! AXValue
        var range = CFRange()
        guard AXValueGetType(value) == .cfRange, AXValueGetValue(value, .cfRange, &range) else { return nil }
        return range
    }

    private func copyAttribute(_ element: AXUIElement, name: String) -> CFTypeRef? {
        var value: CFTypeRef?
        return AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success ? value : nil
    }
}
#endif
