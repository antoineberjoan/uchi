#if os(macOS)
import SwiftUI
import AppKit
import GrakerUI

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
struct GrakerLocalApp: App {
    @NSApplicationDelegateAdaptor(ApplicationDelegate.self) private var delegate
    var body: some SwiftUI.Scene {
        MenuBarExtra("Graker Local", systemImage: "text.badge.checkmark") {
            MenuView(model: delegate.model)
        }
        .menuBarExtraStyle(.menu)
        Settings { SettingsView(model: delegate.model) }
    }
}
#else
@main
struct UnsupportedPlatform {
    static func main() { fatalError("Graker Local nécessite macOS 15 ou plus.") }
}
#endif
