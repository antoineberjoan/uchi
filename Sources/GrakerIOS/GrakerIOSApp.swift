#if os(iOS)
import SwiftUI
import GrakerUI

@main
struct GrakerIOSApp: App {
    @StateObject private var model = EditorModel()

    var body: some Scene {
        WindowGroup {
            EditorView(model: model, showsPanelChrome: false)
        }
        Settings {
            SettingsView(model: model)
        }
    }
}
#endif
