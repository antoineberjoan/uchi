import SwiftUI
import GrakerCore
import GrakerPlatform

public struct RecentResult: Identifiable, Sendable {
    public let id = UUID()
    public let source: String
    public let mode: Mode
    public let result: String
    public let revision: Revision?
}

/// État partagé de l’éditeur : réseau, préférences et historique. Les effets système restent dans les coquilles plateforme.
@MainActor
open class EditorModel: ObservableObject {
    @Published public private(set) var configuration = Configuration()
    @Published public var source = "" {
        didSet {
            guard source != oldValue else { return }
            invalidateResult()
            clearCapturedSelection()
        }
    }
    @Published public private(set) var mode: Mode = .correction
    @Published public var refinement = ""
    @Published public private(set) var result = ""
    @Published public private(set) var revision: Revision?
    @Published public private(set) var isRunning = false
    @Published public private(set) var hasCompleted = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var notice: String?
    @Published public private(set) var recentResults: [RecentResult] = []
    @Published public var isPinned = true {
        didSet { onPinnedChanged(isPinned) }
    }

    private let preferences = PreferencesStore()

    func saveConfiguration(_ configuration: Configuration) throws {
        try preferences.save(configuration)
        self.configuration = configuration
    }
    private let keys = KeyStore()
    private let client = ProviderClient()
    private var task: Task<Void, Never>?
    private var requestID = UUID()

  /// Dernier texte placé par le code : jamais traité comme une frappe ou un collage.
    public private(set) var programmaticSource: String?

    public var canRun: Bool { !isRunning && !source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    open var canReplace: Bool { false }
    open var hasAccessibilityPermission: Bool { false }
    @Published public var shortcutError: String?

    public init() {
        do { configuration = try preferences.load() }
        catch { errorMessage = "Les préférences enregistrées sont illisibles. Vérifiez et enregistrez à nouveau les réglages." }
    }

    open func onPinnedChanged(_ pinned: Bool) {}
    open func start() {}
    open func present(mode: Mode? = nil) { if let mode { setMode(mode) } }
    open func dismiss() { cancel() }
    open func quit() { cancel() }
    open func activateSettings() {}
    open func requestAccessibilityPermission() {}

    public func setMode(_ mode: Mode) {
        guard self.mode != mode else { return }
        invalidateResult()
        self.mode = mode
    }

    public func processClipboard() {
        guard let text = Pasteboard.readString(), !text.isEmpty else {
            present(mode: .translation)
            errorMessage = "Le presse-papiers ne contient aucun texte. Copiez un texte, puis réessayez."
            return
        }
        applySource(text)
        present(mode: .translation)
        run()
    }

    public func pasteAndRun() {
        guard let text = Pasteboard.readString(), !text.isEmpty else {
            errorMessage = "Le presse-papiers ne contient aucun texte."
            return
        }
        applySource(text)
        run()
    }

    public func run(isRefinement: Bool = false) {
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
                let output = try await TextSessionRunner.run(
                    source: original,
                    mode: selectedMode,
                    configuration: selectedConfiguration,
                    refinement: instruction,
                    previousResult: previous,
                    keys: keys,
                    client: client
                ) { [weak self] partial in
                    guard let self, self.requestID == identifier else { return }
                    self.result = partial
                }
                try Task.checkCancellation()
                guard requestID == identifier else { return }
                revision = output.revision
                result = output.text
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

    public func cancel() {
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

    public func copyResult() {
        guard hasCompleted else { return }
        if Pasteboard.writeString(result) { notice = "Résultat copié." }
        else { errorMessage = "Le presse-papiers n’a pas accepté le texte. Réessayez." }
    }

    open func replaceSelection() {}

    public func reopen(_ recent: RecentResult) {
        applySource(recent.source)
        setMode(recent.mode)
        result = recent.result
        revision = recent.revision
        hasCompleted = true
        errorMessage = nil
        notice = "Résultat récent. Copiez-le pour l’utiliser dans votre document."
        present()
    }

    open func toggleWidth() {
        var next = configuration
        next.isPanelWide.toggle()
        do {
            try preferences.save(next)
            configuration = next
        } catch { errorMessage = error.localizedDescription }
    }

    public func selectProvider(_ provider: Provider) {
        guard provider != configuration.provider else { return }
        var next = configuration
        next.provider = provider
        do {
            try preferences.save(next)
            configuration = next
        } catch { errorMessage = error.localizedDescription }
    }

    public func loadKey(for configuration: Configuration) throws -> String {
        try keys.read(account: configuration.makeKeyAccount()) ?? ""
    }

    public func validateAndSaveProvider(_ draft: Configuration, key: String) async throws {
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

    public func saveGeneral(_ draft: Configuration) throws {
        var next = configuration
        next.scene = draft.scene
        next.targetLanguage = draft.targetLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        next.explanationLanguage = draft.explanationLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        try preferences.save(next)
        configuration = next
    }

    open func saveShortcuts(_ draft: Configuration) throws {
        var next = configuration
        next.correctionKey = draft.correctionKey
        next.rephrasingKey = draft.rephrasingKey
        next.translationKey = draft.translationKey
        try preferences.save(next)
        configuration = next
    }

    open func processSelection(mode: Mode) {
        setMode(mode)
        errorMessage = "La capture de sélection n’est disponible que sur macOS."
        present(mode: mode)
    }

    public func applySource(_ text: String) {
        programmaticSource = text
        source = text
    }

    open func clearCapturedSelection() {}
}
