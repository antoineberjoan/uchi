import Foundation

public enum GrakerError: LocalizedError, Equatable {
    case configuration(String)
    case emptyText
    case textTooLong
    case invalidRevision
    case malformedStream
    case incompleteStream
    case truncatedResponse
    case refusedResponse
    case emptyResponse

    public var errorDescription: String? {
        switch self {
        case .configuration(let message): return message
        case .emptyText: return "Saisissez ou sélectionnez un texte à traiter."
        case .textTooLong: return "Le texte dépasse 50 000 caractères. Traitez-le en plusieurs parties."
        case .invalidRevision: return "Le modèle n’a pas renvoyé une correction exploitable. Relancez ou choisissez un autre modèle."
        case .malformedStream: return "Le fournisseur a envoyé une réponse illisible. Vérifiez sa compatibilité avec Chat Completions."
        case .incompleteStream: return "La connexion s’est arrêtée avant la fin. Le résultat partiel ne peut pas remplacer votre texte."
        case .truncatedResponse: return "Le modèle a coupé sa réponse. Réduisez le texte ou choisissez un autre modèle."
        case .refusedResponse: return "Le fournisseur a refusé de traiter ce texte. Aucun remplacement n’a été effectué."
        case .emptyResponse: return "Le fournisseur n’a renvoyé aucun texte. Vérifiez le modèle choisi."
        }
    }
}

public enum Provider: String, CaseIterable, Codable, Identifiable, Sendable {
    case gemini, deepseek, custom
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .gemini: return "Google Gemini"
        case .deepseek: return "DeepSeek"
        case .custom: return "Compatible OpenAI"
        }
    }
    public var endpoint: String {
        switch self {
        case .gemini: return "https://generativelanguage.googleapis.com/v1beta/openai"
        case .deepseek: return "https://api.deepseek.com"
        case .custom: return "https://api.openai.com/v1"
        }
    }
    public var model: String {
        switch self {
        case .gemini: return "gemini-2.5-flash"
        case .deepseek: return "deepseek-chat"
        case .custom: return "gpt-4.1-mini"
        }
    }
}

public enum Mode: String, Codable, CaseIterable, Identifiable, Sendable {
    case correction, rephrasing, translation
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .correction: return "Corriger"
        case .rephrasing: return "Reformuler"
        case .translation: return "Traduire"
        }
    }
    public var symbol: String {
        switch self {
        case .correction: return "text.badge.checkmark"
        case .rephrasing: return "wand.and.stars"
        case .translation: return "character.bubble"
        }
    }
    /// La correction et la reformulation renvoient une révision expliquée ; la traduction, un texte.
    public var hasRevision: Bool { self != .translation }
}

public enum Scene: String, CaseIterable, Codable, Identifiable, Sendable {
    case standard, casual, formal
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .standard: return "Standard"
        case .casual: return "Décontracté"
        case .formal: return "Formel"
        }
    }
}

public struct Configuration: Codable, Equatable, Sendable {
    public var provider: Provider
    public var endpoint: String
    public var model: String
    public var scene: Scene
    public var targetLanguage: String
    public var explanationLanguage: String
    public var isPanelWide: Bool
    public var correctionKey: String
    public var rephrasingKey: String
    public var translationKey: String

    public init(provider: Provider = .gemini, endpoint: String = Provider.gemini.endpoint,
                model: String = Provider.gemini.model, scene: Scene = .standard,
                targetLanguage: String = "Français", explanationLanguage: String = "Français",
                isPanelWide: Bool = false, correctionKey: String = "G", rephrasingKey: String = "R",
                translationKey: String = "T") {
        self.provider = provider
        self.endpoint = endpoint
        self.model = model
        self.scene = scene
        self.targetLanguage = targetLanguage
        self.explanationLanguage = explanationLanguage
        self.isPanelWide = isPanelWide
        self.correctionKey = correctionKey
        self.rephrasingKey = rephrasingKey
        self.translationKey = translationKey
    }

    /// Lettre du raccourci global ⇧⌘ de chaque mode.
    public var shortcutKeys: [Mode: String] {
        Dictionary(uniqueKeysWithValues: Mode.allCases.map { mode in
            switch mode {
            case .correction: return (mode, correctionKey)
            case .rephrasing: return (mode, rephrasingKey)
            case .translation: return (mode, translationKey)
            }
        })
    }

    public func validate() throws -> URL {
        guard let parts = URLComponents(string: endpoint.trimmingCharacters(in: .whitespacesAndNewlines)),
              let url = parts.url, let host = parts.host?.lowercased(), !host.isEmpty,
              parts.user == nil, parts.password == nil, parts.query == nil, parts.fragment == nil,
              parts.scheme == "https" || (parts.scheme == "http" && ["localhost", "127.0.0.1", "::1", "[::1]"].contains(host)) else {
            throw GrakerError.configuration("Utilisez une adresse HTTPS sans identifiant, paramètre ni fragment. HTTP est réservé à localhost.")
        }
        guard !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !targetLanguage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !explanationLanguage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GrakerError.configuration("Renseignez le modèle et les langues dans les réglages.")
        }
        let keys = Array(shortcutKeys.values)
        guard keys.allSatisfy({ $0.range(of: "^[A-Z]$", options: .regularExpression) != nil }),
              Set(keys).count == keys.count else {
            throw GrakerError.configuration("Choisissez trois lettres de raccourci différentes, de A à Z.")
        }
        return url
    }

    public var isLoopback: Bool {
        guard let host = URLComponents(string: endpoint)?.host?.lowercased() else { return false }
        return ["localhost", "127.0.0.1", "::1", "[::1]"].contains(host)
    }

    public func makeKeyAccount() throws -> String {
        let url = try validate()
        return provider.rawValue + ":" + url.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    public func makeCompletionURL() throws -> URL {
        let base = try validate()
        return base.appendingPathComponent("chat/completions")
    }
}
