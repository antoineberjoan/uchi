#if os(macOS)
import SwiftUI
import GrakerCore

struct MenuView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Button("Corriger la sélection", systemImage: Mode.correction.symbol) { model.processSelection(mode: .correction) }
            .keyboardShortcut(KeyEquivalent(Character(model.configuration.correctionKey.lowercased())), modifiers: [.command, .shift])
        Button("Reformuler la sélection", systemImage: Mode.rephrasing.symbol) { model.processSelection(mode: .rephrasing) }
            .keyboardShortcut(KeyEquivalent(Character(model.configuration.rephrasingKey.lowercased())), modifiers: [.command, .shift])
        Button("Traduire la sélection", systemImage: Mode.translation.symbol) { model.processSelection(mode: .translation) }
            .keyboardShortcut(KeyEquivalent(Character(model.configuration.translationKey.lowercased())), modifiers: [.command, .shift])
        Divider()
        Button("Traduire le presse-papiers", systemImage: "clipboard") { model.processClipboard() }
            .keyboardShortcut("1")
        Button("Ouvrir la traduction", systemImage: "character.bubble") { model.present(mode: .translation) }
            .keyboardShortcut("2")
        Button("Ouvrir la correction", systemImage: "text.badge.checkmark") { model.present(mode: .correction) }
            .keyboardShortcut("3")
        Button("Ouvrir la reformulation", systemImage: Mode.rephrasing.symbol) { model.present(mode: .rephrasing) }
            .keyboardShortcut("4")
        Menu("Récents", systemImage: "clock") {
            if model.recentResults.isEmpty { Text("Aucun résultat dans cette session") }
            ForEach(model.recentResults) { recent in
                Button {
                    model.reopen(recent)
                } label: {
                    Label(String(recent.source.prefix(60)).replacingOccurrences(of: "\n", with: " "), systemImage: recent.mode.symbol)
                }
            }
        }
        Divider()
        SettingsLink { Label("Réglages…", systemImage: "gearshape") }
            .keyboardShortcut(",")
        if let error = model.shortcutError { Text(error) }
        Button("Quitter Graker Local") { model.quit() }.keyboardShortcut("q")
    }
}
#endif
