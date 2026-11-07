#if os(macOS)
import Foundation
import GrakerCore

enum ProviderFailure: LocalizedError {
    case missingKey, status(Int), unsupportedStream, responseTooLarge, timeout, connection
    var errorDescription: String? {
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
final class ProviderClient {
    private final class RedirectPolicy: NSObject, URLSessionTaskDelegate {
        func urlSession(_ session: URLSession, task: URLSessionTask,
                        willPerformHTTPRedirection response: HTTPURLResponse,
                        newRequest request: URLRequest,
                        completionHandler: @escaping (URLRequest?) -> Void) {
            completionHandler(nil)
        }
    }

    func complete(_ completion: CompletionRequest, configuration: Configuration, key: String,
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
        let session = URLSession(configuration: options, delegate: RedirectPolicy(), delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        do {
            let (bytes, rawResponse) = try await session.bytes(for: request)
            guard let response = rawResponse as? HTTPURLResponse else { throw ProviderFailure.connection }
            guard (200...299).contains(response.statusCode) else { throw ProviderFailure.status(response.statusCode) }
            guard response.value(forHTTPHeaderField: "Content-Type")?.lowercased().contains("text/event-stream") == true else {
                throw ProviderFailure.unsupportedStream
            }
            var decoder = StreamDecoder()
            var result = ""
            for try await line in bytes.lines {
                try Task.checkCancellation()
                guard line.utf8.count < 1_000_000 else { throw ProviderFailure.responseTooLarge }
                let piece = try decoder.receive(line: line)
                if !piece.isEmpty {
                    result += piece
                    guard result.count <= 200_000 else { throw ProviderFailure.responseTooLarge }
                    await onText(result)
                }
                if decoder.isComplete { break }
            }
            result += try decoder.finish()
            try Task.checkCancellation()
            guard !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw GrakerError.emptyResponse }
            return result
        } catch let error as URLError {
            if error.code == .cancelled || Task.isCancelled { throw CancellationError() }
            if error.code == .timedOut { throw ProviderFailure.timeout }
            throw ProviderFailure.connection
        }
    }

    func validate(configuration: Configuration, key: String) async throws {
        let request = CompletionRequest(model: configuration.model, messages: [
            Message(role: "user", content: "Reply with the single word OK.")
        ])
        _ = try await complete(request, configuration: configuration, key: key, onText: { _ in })
    }
}
#endif
