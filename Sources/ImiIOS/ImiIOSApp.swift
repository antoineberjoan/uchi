#if os(iOS)
import SwiftUI
import ImiUI

@main
struct ImiIOSApp: App {
    @StateObject private var model = EditorModel()

    var body: some Scene {
        WindowGroup {
            SettingsView(model: model)
        }
    }
}
#endif
