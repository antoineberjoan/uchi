import SwiftUI
import GrakerCore
import GrakerDesign

private enum SettingsPage: String, CaseIterable, Identifiable {
    case general, provider, shortcuts, keyboard, about
    var id: String { rawValue }
    var title: String {
        switch self {
        case .general: return "Général"
        case .provider: return "Fournisseur IA"
        case .shortcuts: return "Raccourcis"
        case .keyboard: return "Clavier iOS"
        case .about: return "À propos"
        }
    }
    var symbol: String {
        switch self {
        case .general: return "gearshape"
        case .provider: return "sparkles"
        case .shortcuts: return "keyboard"
        case .keyboard: return "keyboard.badge.ellipsis"
        case .about: return "info.circle"
        }
    }
}

struct SettingsView: View {
    @ObservedObject var model: EditorModel
    @State private var page: SettingsPage? = .provider
    @State private var draft = Configuration()
    @State private var key = ""
    @State private var isValidating = false
    @State private var isMessageError = false
    @State private var message: String?
    @State private var validationTask: Task<Void, Never>?
    @State private var validationID = UUID()

    private var availablePages: [SettingsPage] {
#if os(macOS)
        SettingsPage.allCases.filter { $0 != .keyboard }
#else
        SettingsPage.allCases.filter { $0 != .shortcuts }
#endif
    }

    var body: some View {
        NavigationSplitView {
            List(availablePages, selection: $page) { page in
                Label(page.title, systemImage: page.symbol).tag(page)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(Tokens.sizeSidebar)
        } detail: {
            VStack(alignment: .leading, spacing: Tokens.spaceSection) {
                Text((page ?? .general).title).font(Tokens.fontHeading.weight(Tokens.weightTitle))
                switch page ?? .general {
                case .general: generalPage
                case .provider: providerPage
                case .shortcuts: shortcutsPage
#if os(iOS)
                case .keyboard: keyboardPage
#endif
                case .about: aboutPage
                }
                if let message {
                    Label(message, systemImage: isMessageError ? "exclamationmark.circle" : "checkmark.circle")
                        .foregroundStyle(isMessageError ? Tokens.danger : Tokens.success)
                        .font(Tokens.fontLabel)
                        .textSelection(.enabled)
                }
                Spacer(minLength: Tokens.spaceCompact)
            }
            .padding(Tokens.spacePanel)
        }
#if os(macOS)
        .frame(width: Tokens.sizeSettingsWidth, height: Tokens.sizeSettingsHeight)
#endif
        .font(Tokens.fontLabel)
        .foregroundStyle(Tokens.text)
        .tint(Tokens.accent)
        .background(Tokens.background)
        .onAppear {
            draft = model.configuration
            model.activateSettings()
            loadKey()
        }
        .onDisappear { cancelValidation(); key = "" }
        .onChange(of: page) { _, _ in
            cancelValidation()
            message = nil
        }
    }

#if os(iOS)
    private var keyboardPage: some View {
        VStack(alignment: .leading, spacing: Tokens.spaceSection) {
            Text("Activez le clavier imi dans Réglages → Général → Clavier → Claviers → Ajouter. Choisissez « imi », puis autorisez l’accès complet pour les appels au fournisseur.")
                .foregroundStyle(Tokens.textMuted)
            Text("Configurez d’abord le fournisseur et la clé dans cette app. Le clavier lit les mêmes réglages.")
                .foregroundStyle(Tokens.textMuted)
            Text("Sélectionnez du texte dans Mail ou un commentaire, basculez sur le clavier imi, puis Corriger, Reformuler ou Traduire.")
                .foregroundStyle(Tokens.textMuted)
        }
    }
#endif

    private var generalPage: some View {
        VStack(alignment: .leading, spacing: Tokens.spaceSection) {
            GroupBox {
                VStack(spacing: 0) {
                    settingsRow("Langue de traduction", systemImage: "globe") {
                        TextField("Langue", text: $draft.targetLanguage).multilineTextAlignment(.trailing)
                    }
                    Divider()
                    settingsRow("Scène", systemImage: "text.bubble") {
                        Picker("Scène", selection: $draft.scene) {
                            ForEach(GrakerCore.Scene.allCases) { scene in Text(scene.title).tag(scene) }
                        }
                        .labelsHidden()
                        .fixedSize()
                    }
                    Divider()
                    settingsRow("Explications", systemImage: "text.quote") {
                        TextField("Langue", text: $draft.explanationLanguage).multilineTextAlignment(.trailing)
                    }
#if os(macOS)
                    Divider()
                    settingsRow(model.hasAccessibilityPermission ? "Accès à la sélection accordé" : "Accès à la sélection requis", systemImage: "accessibility") {
                        Image(systemName: model.hasAccessibilityPermission ? "checkmark.circle.fill" : "exclamationmark.circle")
                            .foregroundStyle(model.hasAccessibilityPermission ? Tokens.success : Tokens.danger)
                    }
#endif
                }
            }
            Text("Le style décontracté conserve les contractions et les phrases courtes. Le style formel convient aux courriels et documents.")
                .foregroundStyle(Tokens.textMuted)
            Button("Enregistrer") {
                do { try model.saveGeneral(draft); showMessage("Préférences enregistrées.") }
                catch { showMessage(error.localizedDescription, isError: true) }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var providerPage: some View {
        VStack(alignment: .leading, spacing: Tokens.spaceSection) {
            GroupBox {
                VStack(alignment: .leading, spacing: Tokens.spaceSection) {
                    Picker("Fournisseur", selection: $draft.provider) {
                        ForEach(Provider.allCases) { provider in Text(provider.title).tag(provider) }
                    }
                    .onChange(of: draft.provider) { _, _ in
                        message = nil
                        loadKey()
                    }
                    TextField("Adresse de base", text: $draft.endpoint)
                        .textContentType(.URL)
                        .disabled(draft.provider != .custom)
                        .onChange(of: draft.endpoint) { _, endpoint in
                            // Une adresse en cours de saisie ne lit pas le trousseau : la clé reste liée à l'adresse enregistrée.
                            if endpoint == model.configuration.readProfile(for: draft.provider).endpoint { loadKey() }
                            else { key = "" }
                        }
                    SecureField("Clé API", text: $key)
                        .accessibilityLabel("Clé API, enregistrée dans le trousseau macOS")
                    TextField("Modèle", text: $draft.model)
                        .autocorrectionDisabled()
                }
                .textFieldStyle(.roundedBorder)
                .padding(Tokens.spaceInline)
                .disabled(isValidating)
            }
            Text("Destination : \(draft.endpoint)")
                .font(Tokens.fontCaption)
                .foregroundStyle(Tokens.textMuted).textSelection(.enabled)
            Text("Votre clé reste dans le trousseau. Vos textes vont directement à ce fournisseur. Ses frais API restent à votre charge.")
                .foregroundStyle(Tokens.textMuted)
            HStack(spacing: Tokens.spaceInline) {
                if isValidating {
                    ProgressView().controlSize(.small)
                    Text("Vérification du fournisseur…")
                    Button("Annuler") { cancelValidation() }
                } else {
                    Button("Valider et enregistrer") { validateProvider() }
                        .buttonStyle(.borderedProminent)
                        .disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !draft.isLoopback)
                }
            }
            Text("La validation envoie « Reply with the single word OK. » au modèle affiché. L’adresse attend une base compatible OpenAI, sans /chat/completions final.")
                .font(Tokens.fontCaption).foregroundStyle(Tokens.textMuted)
        }
    }

    private var shortcutsPage: some View {
        VStack(alignment: .leading, spacing: Tokens.spaceSection) {
            GroupBox {
                VStack(spacing: Tokens.spaceSection) {
                    shortcutPicker("Corriger la sélection", key: $draft.correctionKey)
                    shortcutPicker("Reformuler la sélection", key: $draft.rephrasingKey)
                    shortcutPicker("Traduire la sélection", key: $draft.translationKey)
                }
                .padding(Tokens.spaceInline)
            }
            HStack {
                Button("Enregistrer") {
                    do { try model.saveShortcuts(draft); showMessage("Raccourcis activés.") }
                    catch { showMessage(error.localizedDescription, isError: true) }
                }
                .buttonStyle(.borderedProminent)
                Button("Rétablir les lettres G, R et T") {
                    let defaults = Configuration()
                    draft.correctionKey = defaults.correctionKey
                    draft.rephrasingKey = defaults.rephrasingKey
                    draft.translationKey = defaults.translationKey
                }
            }
            if let error = model.shortcutError { Text(error).foregroundStyle(Tokens.danger) }
            Divider()
            Text("Lire et remplacer une sélection demande votre autorisation Accessibilité. La saisie dans le panneau fonctionne sans cette autorisation.")
                .foregroundStyle(Tokens.textMuted)
            Button("Autoriser l’accès à la sélection…") { model.requestAccessibilityPermission() }
                .buttonStyle(.bordered)
        }
    }

    private var aboutPage: some View {
        VStack(alignment: .leading, spacing: Tokens.spaceSection) {
            Text("imi")
                .font(Tokens.fontHeading.weight(Tokens.weightTitle))
            Text("Le sens. Corriger, reformuler et traduire sans quitter l’application.")
            Text("Marque : encre, brume, surligneur. Le logo porte le jaune vif ; les boutons utilisent la nuance d’accent qui reste lisible.")
                .foregroundStyle(Tokens.textMuted)
            Text("Aucun compte, aucune télémétrie, aucun serveur intermédiaire. Les clés restent dans le trousseau.")
                .foregroundStyle(Tokens.textMuted)
            Link("Référence de comportement", destination: URL(string: "https://graker.fehey.com/")!)
            Text("imi n’est pas l’application Graker. Pas de mise à jour automatique.")
                .font(Tokens.fontCaption).foregroundStyle(Tokens.textMuted)
        }
    }

    private func settingsRow<Trailing: View>(_ title: String, systemImage: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            trailing()
        }
        .padding(Tokens.spaceInline)
    }

    private func shortcutPicker(_ title: String, key: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("⇧⌘").foregroundStyle(Tokens.textMuted)
            Picker(title, selection: key) {
                ForEach(Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init), id: \.self) { letter in Text(letter).tag(letter) }
            }
            .labelsHidden().fixedSize()
        }
    }

    private func loadKey() {
        do { key = try model.loadKey(for: draft) }
        catch { key = ""; showMessage(error.localizedDescription, isError: true) }
    }

    private func validateProvider() {
        let identifier = UUID()
        validationID = identifier
        let configuration = draft
        let candidateKey = key
        isValidating = true
        message = nil
        validationTask = Task {
            do {
                try await model.validateAndSaveProvider(configuration, key: candidateKey)
                try Task.checkCancellation()
                guard validationID == identifier else { return }
                showMessage("Connexion validée. Clé enregistrée dans le trousseau.")
            } catch {
                guard validationID == identifier else { return }
                if !Task.isCancelled { showMessage(error.localizedDescription, isError: true) }
            }
            guard validationID == identifier else { return }
            isValidating = false
            validationTask = nil
        }
    }

    private func cancelValidation() {
        validationTask?.cancel()
        validationTask = nil
        validationID = UUID()
        isValidating = false
    }

    private func showMessage(_ text: String, isError: Bool = false) {
        message = text
        isMessageError = isError
    }
}