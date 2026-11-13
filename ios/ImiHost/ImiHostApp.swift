import ImiUI
import SwiftUI

@main
struct ImiHostApp: App {
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
