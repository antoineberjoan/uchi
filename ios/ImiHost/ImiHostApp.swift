import ImiUI
import SwiftUI

@main
struct ImiHostApp: App {
    @StateObject private var model = EditorModel()

    var body: some Scene {
        WindowGroup {
            SettingsView(model: model)
        }
    }
}
