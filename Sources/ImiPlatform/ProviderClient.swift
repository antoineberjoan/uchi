import Foundation
import ImiCore

public enum ProviderFailure: LocalizedError {
    case missingKey, status(Int), unsupportedStream, responseTooLarge, timeout, connection
    public var errorDescription: String? {
        switch self {
        case .missingKey: return "Ajoutez votre clé dans Réglages → Fournisseur IA."
        case .status(401), .status(403): return "Le fournisseur refuse cette clé ou ce modèle. Vérifiez les réglages et les droits de votre compte."
        case .status(404): return "Adresse ou modèle introuvable. Vérifiez l’adresse de base et le nom du modèle."
        case .status(429): return "Le fournisseur limite les requêtes ou le crédit est épuisé. Vérifiez votre compte, puis réessayez."
        case .status(let code): return "Le fournisseur a refusé la requête (HTTP \(code)). Vérifiez sa disponibilité et la compatibilité du modèle."
        case .unsupportedStream: return "Cette adresse ne renvoie pas de flux Chat Completions. Vérifiez le fournisseur et l’adresse de base."
        case .responseTooLarge: return "La réponse dépasse la limite de lecture. Réduisez le texte, puis relancez."
        case .timeout: return "Le modèle n’a pas terminé en quatre minutes. Réduisez le texte ou choisissez un modèle plus rapide."
        case .connection: return "Connexion au fournisseur impossible. Vérifiez l’adresse et votre connexion, puis réessayez."
        }
    }
}

/// Transport éphémère, sans cache ni cookies. Aucune redirection n'emporte la clé.
public final class ProviderClient: @unchecked Sendable {
    private let protocolClasses: [AnyClass]

    public init(protocolClasses: [AnyClass] = []) { self.protocolClasses = protocolClasses }

    private final class RedirectPolicy: NSObject, URLSessionTaskDelegate {
        func urlSession(_ session: URLSession, task: URLSessionTask,
                        willPerformHTTPRedirection response: HTTPURLResponse,
                        newRequest request: URLRequest,
                        completionHandler: @escaping (URLRequest?) -> Void) {
            completionHandler(nil)
        }
    }

    public func complete(_ completion: CompletionRequest, configuration: Configuration, key: String,
                         onText: @escaping @MainActor (String) -> Void) async throws -> String {
        let url = try configuration.makeCompletionURL()
        guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || configuration.isLoopback else {
            throw ProviderFailure.missingKey
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 240
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        if !key.isEmpty { request.setValue("Bearer " + key, forHTTPHeaderField: "Authorization") }
        request.httpBody = try JSONEncoder().encode(completion)

        let options = URLSessionConfiguration.ephemeral
        options.timeoutIntervalForRequest = 240
        options.timeoutIntervalForResource = 240
        options.urlCache = nil
        options.httpShouldSetCookies = false
        if !protocolClasses.isEmpty { options.protocolClasses = protocolClasses }
        let session = URLSession(configuration: options, delegate: RedirectPolicy(), delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        do {
            let (bytes, rawResponse) = try await session.bytes(for: request)
            guard let response = rawResponse as? HTTPURLResponse else { throw ProviderFailure.connection }
            guard (200...299).contains(response.statusCode) else { throw ProviderFailure.status(response.statusCode) }
            guard response.value(forHTTPHeaderField: "Content-Type")?.lowercased().contains("text/event-stream") == true else {
                throw ProviderFailure.unsupportedStream
            }
            var lines = LineDecoder()
            var decoder = StreamDecoder()
            var result = ""
            var resultCharacterCount = 0
            let clock = ContinuousClock()
            var lastDelivery = clock.now
            for try await byte in bytes {
                guard let line = lines.receive(byte) else {
                    guard lines.pendingByteCount < 1_000_000 else { throw ProviderFailure.responseTooLarge }
                    continue
                }
                try Task.checkCancellation()
                let piece = try decoder.receive(line: line)
                if !piece.isEmpty {
                    result += piece
                    resultCharacterCount += piece.count
                    guard resultCharacterCount <= 200_000 else { throw ProviderFailure.responseTooLarge }
                    if clock.now - lastDelivery >= .milliseconds(80) {
                        lastDelivery = clock.now
                        await onText(result)
                    }
                }
                if decoder.isComplete { break }
            }
            if let line = lines.finish() { result += try decoder.receive(line: line) }
            result += try decoder.finish()
            guard result.count <= 200_000 else { throw ProviderFailure.responseTooLarge }
            try Task.checkCancellation()
            guard !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ImiError.emptyResponse }
            return result
        } catch let error as URLError {
            if error.code == .cancelled || Task.isCancelled { throw CancellationError() }
            if error.code == .timedOut { throw ProviderFailure.timeout }
            throw ProviderFailure.connection
        }
    }

    public func validate(configuration: Configuration, key: String) async throws {
        let request = CompletionRequest(model: configuration.model, messages: [
            Message(role: "user", content: "Reply with the single word OK."),
        ])
        _ = try await complete(request, configuration: configuration, key: key, onText: { _ in })
    }
}
