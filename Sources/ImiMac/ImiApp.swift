#if os(macOS)
import SwiftUI
import AppKit
import ImiUI

@MainActor
final class ApplicationDelegate: NSObject, NSApplicationDelegate {
    let model = MacEditorModel()
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        model.start()
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

@main
@MainActor
struct ImiApp: App {
    @NSApplicationDelegateAdaptor(ApplicationDelegate.self) private var delegate
    var body: some SwiftUI.Scene {
        MenuBarExtra("imi", systemImage: "text.badge.checkmark") {
            MenuView(model: delegate.model)
        }
        .menuBarExtraStyle(.menu)
        Settings { SettingsView(model: delegate.model) }
    }
}
#else
@main
struct UnsupportedPlatform {
    static func main() { fatalError("imi nécessite macOS 15 ou plus.") }
}
#endif
