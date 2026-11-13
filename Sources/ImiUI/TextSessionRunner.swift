import Foundation
import ImiCore
import ImiPlatform

public struct TextSessionOutput: Sendable {
    public let text: String
    public let revision: Revision?
}

/// Exécution d’une requête texte (app et clavier).
public enum TextSessionRunner {
    public static func run(
        source: String,
        mode: Mode,
        configuration: Configuration,
        refinement: String = "",
        previousResult: String = "",
        keys: KeyStore = KeyStore(),
        client: ProviderClient = ProviderClient(),
        onPartial: (@MainActor (String) -> Void)? = nil
    ) async throws -> TextSessionOutput {
        let request = try RequestFactory.makeRequest(
            source: source,
            mode: mode,
            configuration: configuration,
            refinement: refinement,
            previousResult: previousResult
        )
        let key = try keys.read(account: configuration.makeKeyAccount()) ?? ""
        let response = try await client.complete(request, configuration: configuration, key: key) { partial in
            if let onPartial, !mode.hasRevision { await onPartial(partial) }
        }
        try Task.checkCancellation()
        if mode.hasRevision {
            let parsed = try Revision.parse(response, source: source)
            return TextSessionOutput(text: parsed.text, revision: parsed)
        }
        return TextSessionOutput(text: SourceWhitespace(source: source).apply(to: response), revision: nil)
    }
}
