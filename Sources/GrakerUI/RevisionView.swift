import SwiftUI
import GrakerCore
import GrakerDesign

/// Texte révisé, avec chaque passage modifié surligné à sa place.
/// Un clic sur un passage affiche le changement et sa raison sous le texte.
struct RevisionView: View {
    let revision: Revision
    @State private var selectedChangeIndex: Int?
    private static let changeScheme = "graker-change"

    var body: some View {
        let layout = RevisionLayout(revision: revision)
        VStack(alignment: .leading, spacing: Tokens.spaceSection) {
            // Pas de sélection de texte ici : elle gênerait le clic sur les passages. Copier reste disponible.
            Text(makeText(layout))
                .tint(Tokens.text)
                .lineSpacing(Tokens.sizeLineSpacing)
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.openURL, OpenURLAction { url in
                    guard url.scheme == Self.changeScheme, let index = Int(url.host ?? ""),
                          revision.changes.indices.contains(index) else { return .discarded }
                    selectedChangeIndex = selectedChangeIndex == index ? nil : index
                    return .handled
                })
                .accessibilityHint("Activez un passage surligné pour lire la raison du changement.")
            if let selectedChangeIndex, revision.changes.indices.contains(selectedChangeIndex) {
                changeCard(revision.changes[selectedChangeIndex])
            }
            if !layout.unplacedChangeIndices.isEmpty {
                VStack(alignment: .leading, spacing: Tokens.spaceInline) {
                    ForEach(layout.unplacedChangeIndices, id: \.self) { index in changeCard(revision.changes[index]) }
                }
            }
            Text(revision.explanation)
                .font(Tokens.fontLabel)
                .textSelection(.enabled)
                .padding(Tokens.spaceSection)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Tokens.variantExplanationText)
                .background(Tokens.variantExplanationBackground, in: RoundedRectangle(cornerRadius: Tokens.radiusCard))
        }
        .onChange(of: revision) { _, _ in selectedChangeIndex = nil }
    }

    private func makeText(_ layout: RevisionLayout) -> AttributedString {
        var text = AttributedString()
        for passage in layout.passages {
            var piece = AttributedString(passage.text)
            if let index = passage.changeIndex {
                piece.link = URL(string: "\(Self.changeScheme)://\(index)")
                piece.backgroundColor = Tokens.success.opacity(Tokens.opacityTint)
                piece.underlineStyle = Text.LineStyle.single
                if index == selectedChangeIndex { piece.inlinePresentationIntent = .stronglyEmphasized }
            }
            text += piece
        }
        return text
    }

    private func changeCard(_ change: Change) -> some View {
        VStack(alignment: .leading, spacing: Tokens.spaceInline) {
            Text(describe(change))
            Divider().overlay(Tokens.border)
            Text(change.reason).foregroundStyle(Tokens.textMuted).textSelection(.enabled)
        }
        .font(Tokens.fontLabel)
        .padding(Tokens.spaceSection)
        .frame(maxWidth: Tokens.sizeExplanation, alignment: .leading)
        .background(Tokens.surface, in: RoundedRectangle(cornerRadius: Tokens.radiusCard))
        .overlay(RoundedRectangle(cornerRadius: Tokens.radiusCard).strokeBorder(Tokens.border, lineWidth: Tokens.sizeBorder))
        .accessibilityElement(children: .combine)
    }

    private func describe(_ change: Change) -> AttributedString {
        var removed = AttributedString(change.original)
        removed.strikethroughStyle = Text.LineStyle.single
        removed.backgroundColor = Tokens.danger.opacity(Tokens.opacityTint)
        var added = AttributedString(change.replacement)
        added.backgroundColor = Tokens.success.opacity(Tokens.opacityTint)
        if change.original.isEmpty { return added }
        if change.replacement.isEmpty { return removed }
        return removed + AttributedString(" ") + added
    }
}