#if os(macOS)
import AppKit
import SwiftUI
import GrakerCore
import GrakerUI

@MainActor
final class MacEditorModel: EditorModel {
    private let selections = SelectionController()
    private let shortcuts = ShortcutController()
    private var panelController: PanelController?
    private var selection: SelectionSnapshot?

    override var canReplace: Bool { selection != nil && hasCompleted && !isRunning }
    override var hasAccessibilityPermission: Bool { selections.hasPermission }

    override func onPinnedChanged(_ pinned: Bool) {
        panelController?.setPinned(pinned)
    }

    override func start() {
        shortcuts.onShortcut = { [weak self] mode in self?.processSelection(mode: mode) }
        shortcuts.onError = { [weak self] message in self?.shortcutError = message }
        do { try shortcuts.register(configuration) }
        catch { shortcutError = error.localizedDescription }
        if UserDefaults.standard.data(forKey: "configuration") == nil { present() }
    }

    override func present(mode: Mode? = nil) {
        if let mode { setMode(mode) }
        if panelController == nil { panelController = PanelController(model: self) }
        panelController?.show(anchor: selection?.anchor)
    }

    override func dismiss() {
        cancel()
        panelController?.hide()
    }

    override func quit() {
        cancel()
        NSApp.terminate(nil)
    }

    override func activateSettings() {
        NSApp.activate(ignoringOtherApps: true)
    }

    override func requestAccessibilityPermission() {
        selections.requestPermission()
    }

    override func processSelection(mode: Mode) {
        cancel()
        do {
            let snapshot = try selections.capture()
            applySource(snapshot.text)
            setMode(mode)
            selection = snapshot
            present()
            run()
        } catch {
            selection = nil
            present(mode: mode)
            errorMessage = error.localizedDescription
        }
    }

    override func processClipboard() {
        selection = nil
        super.processClipboard()
    }

    override func pasteAndRun() {
        selection = nil
        super.pasteAndRun()
    }

    override func replaceSelection() {
        guard canReplace, let selection else { return }
        do {
            try selections.replace(selection, with: result)
            self.selection = nil
            panelController?.hide()
        } catch { errorMessage = error.localizedDescription }
    }

    override func toggleWidth() {
        var next = configuration
        next.isPanelWide.toggle()
        do {
            try saveConfiguration(next)
            panelController?.resize()
        } catch { errorMessage = error.localizedDescription }
    }

    override func saveShortcuts(_ draft: Configuration) throws {
        var next = configuration
        next.correctionKey = draft.correctionKey
        next.rephrasingKey = draft.rephrasingKey
        next.translationKey = draft.translationKey
        try shortcuts.register(next)
        do {
            try saveConfiguration(next)
        } catch {
            do { try shortcuts.register(configuration) }
            catch { shortcutError = error.localizedDescription }
            throw error
        }
        shortcutError = nil
    }

    override func clearCapturedSelection() {
        selection = nil
    }
}
#endif
