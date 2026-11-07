#if os(macOS)
import AppKit
import SwiftUI
import GrakerCore

private final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class PanelController: NSObject, NSWindowDelegate {
    private let panel: FloatingPanel
    private weak var model: AppModel?
    private var anchor: CGRect?

    init(model: AppModel) {
        self.model = model
        panel = FloatingPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel, .resizable],
                              backing: .buffered, defer: false)
        super.init()
        panel.delegate = self
        panel.title = "Graker Local"
        panel.isFloatingPanel = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: EditorView(model: model))
    }

    func show(anchor: CGRect? = nil) {
        self.anchor = anchor
        resize()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func resize() {
        guard let model else { return }
        let screen = anchor.flatMap { rect in NSScreen.screens.first { $0.frame.intersects(rect) } } ?? NSScreen.main
        guard let screen else { return }
        let frame = screen.visibleFrame
        let width = min(model.configuration.isPanelWide ? Tokens.sizePanelWide : Tokens.sizePanelCompact,
                        frame.width - Tokens.spacePanel * 2)
        let height = min(Tokens.sizePanelHeight, frame.height * Tokens.ratioScreenHeight)
        let size = CGSize(width: width, height: height)
        panel.minSize = CGSize(width: min(Tokens.sizePanelCompact, width), height: min(Tokens.sizePanelMinimum, height))
        panel.maxSize = CGSize(width: frame.width, height: frame.height)
        panel.setFrame(CGRect(origin: PanelPlacement.position(selection: anchor, screen: frame, size: size,
                                                              margin: Tokens.spaceInline), size: size), display: true)
        panel.level = model.isPinned ? .floating : .normal
    }

    func setPinned(_ isPinned: Bool) { panel.level = isPinned ? .floating : .normal }
    func hide() { panel.orderOut(nil) }
    func windowWillClose(_ notification: Notification) { model?.cancel() }
}
#endif
