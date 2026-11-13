import SwiftUI
import GrakerCore
import GrakerDesign

struct EditorView: View {
    @ObservedObject var model: EditorModel
    var showsPanelChrome = true
    @Environment(\.openSettings) private var openSettings
    @FocusState private var isRefinementFocused: Bool

    var body: some View {
        VStack(spacing: Tokens.spaceCompact) {
            header
            Divider().overlay(Tokens.border)
            sourceEditor
            toolbar
            Divider().overlay(Tokens.border)
            output
            if let error = model.errorMessage { message(error, symbol: "exclamationmark.circle", color: Tokens.danger) }
            if model.errorMessage != nil && !model.hasAccessibilityPermission {
                Button("Autoriser l’accès à la sélection…") { model.requestAccessibilityPermission() }
                    .buttonStyle(.bordered)
            }
            if let notice = model.notice { message(notice, symbol: "info.circle", color: Tokens.textMuted) }
            if model.hasCompleted { refinement }
        }
        .padding(Tokens.spaceInline)
        .foregroundStyle(Tokens.text)
        .font(Tokens.fontBody)
        .tint(Tokens.accent)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Tokens.radiusPanel))
        .overlay(RoundedRectangle(cornerRadius: Tokens.radiusPanel).strokeBorder(Tokens.border, lineWidth: Tokens.sizeBorder))
        .clipShape(RoundedRectangle(cornerRadius: Tokens.radiusPanel))
        .modifier(EditorDismissAction { model.dismiss() })
    }

    private var header: some View {
        HStack(spacing: Tokens.spaceInline) {
            if showsPanelChrome {
                Button { model.isPinned.toggle() } label: {
                    Image(systemName: model.isPinned ? "pin.fill" : "pin")
                        .foregroundStyle(model.isPinned ? Tokens.accent : Tokens.textMuted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(model.isPinned ? "Désépingler le panneau" : "Garder le panneau au-dessus")
            }
            Text("imi").font(Tokens.fontLabel.weight(Tokens.weightTitle))
            Spacer()
            if showsPanelChrome {
                Button { model.toggleWidth() } label: {
                    Image(systemName: model.configuration.isPanelWide ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                }
                .help(model.configuration.isPanelWide ? "Réduire le panneau" : "Élargir le panneau")
                .accessibilityLabel(model.configuration.isPanelWide ? "Réduire le panneau" : "Élargir le panneau")
            } else {
                Button { openSettings() } label: { Image(systemName: "gearshape") }
                    .help("Réglages").accessibilityLabel("Réglages")
            }
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, Tokens.spaceInline)
        .frame(minHeight: Tokens.sizeButton)
    }

    private var sourceEditor: some View {
        ZStack(alignment: .topLeading) {
            if model.source.isEmpty {
#if os(iOS)
                Text("Écrivez ou collez du texte ici, ou utilisez le clavier imi dans une autre app.")
#else
                Text("Sélectionnez un texte et pressez ⇧⌘\(model.configuration.correctionKey), ou écrivez ici.")
#endif
                    .foregroundStyle(Tokens.textMuted)
                    .padding(Tokens.spaceInline)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $model.source)
                .font(Tokens.fontBody)
                .scrollContentBackground(.hidden)
                .accessibilityLabel("Texte à corriger ou à traduire")
                // Entrée lance, ⇧Entrée va à la ligne. Taper à la main ne lance rien.
                .onKeyPress(.return, phases: .down) { press in
                    guard !press.modifiers.contains(.shift) else { return .ignored }
                    if model.canRun { model.run() }
                    return .handled
                }
                // Un collage dans la saisie lance, comme dans Graker.
                .onChange(of: model.source) { old, new in
                    guard new != model.programmaticSource, InputChange.isPaste(from: old, to: new) else { return }
                    model.run()
                }
                .padding(Tokens.spaceCompact)
        }
        .frame(height: Tokens.sizeEditorHeight)
        .background(Tokens.input.opacity(Tokens.opacityDisabled), in: RoundedRectangle(cornerRadius: Tokens.radiusControl))
        .padding(.horizontal, Tokens.spaceInline)
    }

    private var toolbar: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Tokens.spaceInline) { modePicker; providerMenu; Spacer(); runButton }
            VStack(alignment: .leading, spacing: Tokens.spaceInline) {
                modePicker
                HStack { providerMenu; Spacer(); runButton }
            }
        }
        .padding(.horizontal, Tokens.spaceInline)
        .padding(.vertical, Tokens.spaceCompact)
    }

    private var modePicker: some View {
        HStack(spacing: Tokens.spaceCompact) {
            ForEach(Mode.allCases) { mode in
                Button { model.setMode(mode) } label: {
                    Image(systemName: mode.symbol)
                        .frame(width: Tokens.sizeButton, height: Tokens.sizeButton)
                        .background(model.mode == mode ? Tokens.selection : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mode.title)
                .help(mode.title)
            }
        }
    }

    private var providerMenu: some View {
        Menu {
            ForEach(Provider.allCases) { provider in
                Button { model.selectProvider(provider) } label: {
                    let title = "\(provider.title) · \(model.configuration.readProfile(for: provider).model)"
                    if provider == model.configuration.provider { Label(title, systemImage: "checkmark") } else { Text(title) }
                }
            }
            Divider()
            Button("Réglages du fournisseur…", systemImage: "gearshape") { openSettings() }
        } label: {
            Text(model.configuration.provider.title).lineLimit(1)
        }
        .fixedSize()
        .help("Modèle : \(model.configuration.model). Changer de fournisseur ou ouvrir ses réglages.")
        .font(Tokens.fontLabel)
    }

    @ViewBuilder
    private var runButton: some View {
        if model.isRunning {
            Button("Annuler", systemImage: "stop.fill") { model.cancel() }.buttonStyle(.bordered)
        } else {
            Button { model.run() } label: {
                HStack(spacing: Tokens.spaceCompact) { Text(model.mode.title); Text("↵").font(Tokens.fontCaption) }
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return, modifiers: .command)
            .help("\(model.mode.title) · Retour (⇧Retour : nouvelle ligne)")
            .disabled(!model.canRun)
        }
    }

    private var output: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.spaceSection) {
                if model.isRunning {
                    HStack(spacing: Tokens.spaceInline) {
                        ProgressView().controlSize(.small)
                        Text(progressTitle)
                            .foregroundStyle(Tokens.textMuted).font(Tokens.fontLabel)
                        Spacer()
                    }
                }
                if !model.result.isEmpty {
                    HStack {
                        Label(resultTitle, systemImage: model.mode.symbol)
                            .foregroundStyle(Tokens.success)
                            .font(Tokens.fontLabel.weight(Tokens.weightLabel))
                        Spacer()
                        if model.hasCompleted {
                            Button { model.copyResult() } label: { Image(systemName: "square.on.square") }
                                .help("Copier le résultat").accessibilityLabel("Copier le résultat")
                            Button("Remplacer", systemImage: "checkmark") { model.replaceSelection() }
                                .disabled(!model.canReplace)
                                .help(model.canReplace ? "Remplacer la sélection d’origine" : "Disponible pour une sélection capturée et encore valide")
                        }
                    }
                    .buttonStyle(.borderless)
                    if let revision = model.revision {
                        RevisionView(revision: revision)
                    } else {
                        Text(makeReadableText(model.result))
                            .textSelection(.enabled)
                            .lineSpacing(Tokens.sizeLineSpacing)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else if !model.isRunning {
                    VStack(alignment: .leading, spacing: Tokens.spaceInline) {
                        Text("Vos mots, plus clairs.").font(Tokens.fontTitle.weight(Tokens.weightLabel))
                        Text("Corrigez une phrase ou traduisez un passage. Le résultat reste ici jusqu’à votre prochaine action.")
                            .foregroundStyle(Tokens.textMuted)
                        Button("Coller et \(model.mode.title.lowercased())", systemImage: "clipboard") { model.pasteAndRun() }
                            .buttonStyle(.bordered)
                        Text("Le texte est envoyé à \(model.configuration.provider.title), avec votre clé. Configurez le fournisseur dans les réglages.")
                            .font(Tokens.fontCaption).foregroundStyle(Tokens.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(Tokens.spaceSection)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: .infinity)
    }

    private var progressTitle: String {
        switch model.mode {
        case .correction: return "Vérification du texte…"
        case .rephrasing: return "Reformulation en cours…"
        case .translation: return "Traduction en cours…"
        }
    }

    private var resultTitle: String {
        switch model.mode {
        case .correction: return "Texte corrigé"
        case .rephrasing: return "Texte reformulé"
        case .translation: return "Traduction"
        }
    }

    private var refinement: some View {
        HStack(spacing: Tokens.spaceInline) {
            TextField("Que souhaitez-vous ajuster ?", text: $model.refinement)
                .textFieldStyle(.plain)
                .focused($isRefinementFocused)
                .onSubmit { model.run(isRefinement: true) }
                .accessibilityLabel("Instruction d’affinage du résultat")
            Button { model.run(isRefinement: true) } label: { Image(systemName: "return") }
                .buttonStyle(.borderless)
                .accessibilityLabel("Affiner le résultat")
                .disabled(model.isRunning || model.refinement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, Tokens.spaceSection)
        .frame(minHeight: Tokens.sizeRefinement)
        .background(Tokens.surface, in: RoundedRectangle(cornerRadius: Tokens.radiusControl))
    }

    private func message(_ text: String, symbol: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: Tokens.spaceInline) {
            Image(systemName: symbol)
            Text(text).textSelection(.enabled)
            Spacer(minLength: Tokens.spaceCompact)
        }
        .font(Tokens.fontCaption)
        .foregroundStyle(color)
        .padding(.horizontal, Tokens.spaceSection)
        .padding(.vertical, Tokens.spaceInline)
        .accessibilityElement(children: .combine)
    }

    private func makeReadableText(_ value: String) -> AttributedString {
        // Les retours à la ligne restent visibles pendant le flux. Les blocs Markdown
        // complexes sont conservés textuellement si le moteur natif ne les rend pas.
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        do { return try AttributedString(markdown: value, options: options) }
        catch { return AttributedString(value) }
    }
}

private struct EditorDismissAction: ViewModifier {
    let action: () -> Void
    func body(content: Content) -> some View {
#if os(macOS)
        content.onExitCommand(perform: action)
#else
        content
#endif
    }
}
