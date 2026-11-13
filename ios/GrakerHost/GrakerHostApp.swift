import GrakerUI
import SwiftUI

@main
struct GrakerHostApp: App {
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
