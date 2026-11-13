#if os(iOS)
import SwiftUI
import ImiUI

@main
struct ImiIOSApp: App {
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
