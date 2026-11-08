#if os(macOS)
import AppKit
import SwiftUI
import GrakerCore

struct RecentResult: Identifiable {
    let id = UUID()
    let source: String
    let mode: Mode
    let result: String
    let revision: Revision?
}

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var configuration = Configuration()
    @Published var source = "" {
        didSet {
            guard source != oldValue else { return }
            invalidateResult()
            selection = nil
        }
    }
    @Published private(set) var mode: Mode = .correction
    @Published var refinement = ""
    @Published private(set) var result = ""
    @Published private(set) var revision: Revision?
    @Published private(set) var isRunning = false
    @Published private(set) var hasCompleted = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var notice: String?
    @Published private(set) var recentResults: [RecentResult] = []
    @Published private(set) var shortcutError: String?
    @Published var isPinned = true { didSet { panelController?.setPinned(isPinned) } }

    private let preferences = PreferencesStore()
    private let keys = KeyStore()
    private let client = ProviderClient()
    private let selections = SelectionController()
    private let shortcuts = ShortcutController()
    private var panelController: PanelController?
    private var selection: SelectionSnapshot?
    private var task: Task<Void, Never>?
    private var requestID = UUID()

    var canReplace: Bool { selection != nil && hasCompleted && !isRunning }
    var hasAccessibilityPermission: Bool { selections.hasPermission }

    init() {
        do { configuration = try preferences.load() }
        catch { errorMessage = "Les préférences enregistrées sont illisibles. Vérifiez et enregistrez à nouveau les réglages." }
    }

    func start() {
        shortcuts.onShortcut = { [weak self] mode in self?.processSelection(mode: mode) }
        shortcuts.onError = { [weak self] message in self?.shortcutError = message }
        do { try shortcuts.register(configuration) }
        catch { shortcutError = error.localizedDescription }
        if UserDefaults.standard.data(forKey: "configuration") == nil { present() }
    }

    func present(mode: Mode? = nil) {
        if let mode { setMode(mode) }
        if panelController == nil { panelController = PanelController(model: self) }
        panelController?.show(anchor: selection?.anchor)
    }

    func dismiss() { cancel(); panelController?.hide() }
    func quit() { cancel(); NSApp.terminate(nil) }
    func activateSettings() { NSApp.activate(ignoringOtherApps: true) }
    func requestAccessibilityPermission() { selections.requestPermission() }

    func setMode(_ mode: Mode) {
        guard self.mode != mode else { return }
        invalidateResult()
        self.mode = mode
    }

    func processSelection(mode: Mode) {
        cancel()
        do {
            let snapshot = try selections.capture()
            source = snapshot.text
            setMode(mode)
            selection = snapshot
            present()
            run()
        } catch {
            selection = nil
            present(mode: mode)
            errorMessage = error.localizedDescription
        }
    }

    func processClipboard() {
        guard let text = NSPasteboard.general.string(forType: .string), !text.isEmpty else {
            present(mode: .translation)
            errorMessage = "Le presse-papiers ne contient aucun texte. Copiez un texte, puis réessayez."
            return
        }
        source = text
        selection = nil
        present(mode: .translation)
        run()
    }

    func pasteAndRun() {
        guard let text = NSPasteboard.general.string(forType: .string), !text.isEmpty else {
            errorMessage = "Le presse-papiers ne contient aucun texte."
            return
        }
        source = text
        selection = nil
        run()
    }

    func run(isRefinement: Bool = false) {
        if isRefinement && refinement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return }
        task?.cancel()
        let identifier = UUID()
        requestID = identifier
        let original = source
        let selectedMode = mode
        let selectedConfiguration = configuration
        let instruction = isRefinement ? refinement : ""
        let previous = isRefinement ? result : ""
        errorMessage = nil
        notice = nil
        result = ""
        revision = nil
        hasCompleted = false
        isRunning = true
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let request = try RequestFactory.makeRequest(source: original, mode: selectedMode,
                                                            configuration: selectedConfiguration,
                                                            refinement: instruction, previousResult: previous)
                let key = try keys.read(account: selectedConfiguration.makeKeyAccount()) ?? ""
                let response = try await client.complete(request, configuration: selectedConfiguration, key: key) { [weak self] partial in
                    guard let self, self.requestID == identifier else { return }
                    if !selectedMode.hasRevision { self.result = partial }
                }
                try Task.checkCancellation()
                guard requestID == identifier else { return }
                if selectedMode.hasRevision {
                    let parsed = try Revision.parse(response, source: original)
                    revision = parsed
                    result = parsed.text
                } else { result = SourceWhitespace(source: original).apply(to: response) }
                hasCompleted = true
                isRunning = false
                refinement = ""
                recentResults.insert(RecentResult(source: original, mode: selectedMode, result: result, revision: revision), at: 0)
                if recentResults.count > 10 { recentResults.removeLast(recentResults.count - 10) }
                task = nil
            } catch {
                guard requestID == identifier else { return }
                isRunning = false
                hasCompleted = false
                result = ""
                revision = nil
                task = nil
                if error is CancellationError || Task.isCancelled { notice = "Requête annulée. Votre texte est conservé." }
                else { errorMessage = error.localizedDescription }
            }
        }
    }

    func cancel() {
        guard isRunning else { return }
        task?.cancel()
        task = nil
        requestID = UUID()
        isRunning = false
        hasCompleted = false
        result = ""
        revision = nil
        notice = "Requête annulée. Votre texte est conservé."
    }

    private func invalidateResult() {
        cancel()
        result = ""
        revision = nil
        hasCompleted = false
        errorMessage = nil
        notice = nil
        refinement = ""
    }

    func copyResult() {
        guard hasCompleted else { return }
        NSPasteboard.general.clearContents()
        if NSPasteboard.general.setString(result, forType: .string) { notice = "Résultat copié." }
        else { errorMessage = "Le presse-papiers n’a pas accepté le texte. Réessayez." }
    }

    func replaceSelection() {
        guard canReplace, let selection else { return }
        do {
            try selections.replace(selection, with: result)
            self.selection = nil
            panelController?.hide()
        } catch { errorMessage = error.localizedDescription }
    }

    func reopen(_ recent: RecentResult) {
        source = recent.source
        setMode(recent.mode)
        selection = nil
        result = recent.result
        revision = recent.revision
        hasCompleted = true
        errorMessage = nil
        notice = "Résultat récent. Copiez-le pour l’utiliser dans votre document."
        present()
    }

    func toggleWidth() {
        var next = configuration
        next.isPanelWide.toggle()
        do {
            try preferences.save(next)
            configuration = next
            panelController?.resize()
        } catch { errorMessage = error.localizedDescription }
    }

    /// Change de fournisseur sans ouvrir les réglages. Une clé absente reste une erreur visible au lancement.
    func selectProvider(_ provider: Provider) {
        guard provider != configuration.provider else { return }
        var next = configuration
        next.provider = provider
        do {
            try preferences.save(next)
            configuration = next
        } catch { errorMessage = error.localizedDescription }
    }

    func loadKey(for configuration: Configuration) throws -> String {
        try keys.read(account: configuration.makeKeyAccount()) ?? ""
    }

    func validateAndSaveProvider(_ draft: Configuration, key: String) async throws {
        var next = configuration
        next.provider = draft.provider
        next.endpoint = draft.endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        next.model = draft.model.trimmingCharacters(in: .whitespacesAndNewlines)
        _ = try next.validate()
        let cleanedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        try await client.validate(configuration: next, key: cleanedKey)
        try Task.checkCancellation()
        try keys.save(cleanedKey, account: next.makeKeyAccount())
        try preferences.save(next)
        configuration = next
    }

    func saveGeneral(_ draft: Configuration) throws {
        var next = configuration
        next.scene = draft.scene
        next.targetLanguage = draft.targetLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        next.explanationLanguage = draft.explanationLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        try preferences.save(next)
        configuration = next
    }

    func saveShortcuts(_ draft: Configuration) throws {
        var next = configuration
        next.correctionKey = draft.correctionKey
        next.rephrasingKey = draft.rephrasingKey
        next.translationKey = draft.translationKey
        try shortcuts.register(next)
        do { try preferences.save(next) }
        catch {
            do { try shortcuts.register(configuration) }
            catch { shortcutError = error.localizedDescription }
            throw error
        }
        configuration = next
        shortcutError = nil
    }
}
#endif
