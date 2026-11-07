import Foundation

/// Un décodeur par requête ; la fin du transport ne remplace jamais la fin SSE.
public struct StreamDecoder {
    private var dataLines: [String] = []
    public private(set) var isComplete = false
    public private(set) var hasFinished = false

    public init() {}

    public mutating func receive(line: String) throws -> String {
        guard !isComplete else { return "" }
        if line.isEmpty { return try flushEvent() }
        if line.hasPrefix("data:") {
            var value = String(line.dropFirst(5))
            if value.hasPrefix(" ") { value.removeFirst() }
            dataLines.append(value)
        } else if line == "event: error" {
            throw GrakerError.malformedStream
        }
        return ""
    }

    public mutating func finish() throws -> String {
        let value = try flushEvent()
        guard isComplete && hasFinished else { throw GrakerError.incompleteStream }
        return value
    }

    private mutating func flushEvent() throws -> String {
        guard !dataLines.isEmpty else { return "" }
        let value = dataLines.joined(separator: "\n")
        dataLines.removeAll(keepingCapacity: true)
        if value == "[DONE]" { isComplete = true; return "" }
        guard let data = value.data(using: .utf8), let chunk = try? JSONDecoder().decode(Chunk.self, from: data),
              chunk.error == nil, let choices = chunk.choices else { throw GrakerError.malformedStream }
        var text = ""
        for choice in choices {
            guard choice.index == nil || choice.index == 0 else { continue }
            if let refusal = choice.delta?.refusal, !refusal.isEmpty { throw GrakerError.refusedResponse }
            if hasFinished, !(choice.delta?.content ?? "").isEmpty { throw GrakerError.malformedStream }
            if let reason = choice.finishReason {
                switch reason {
                case "stop": hasFinished = true
                case "length": throw GrakerError.truncatedResponse
                case "content_filter": throw GrakerError.refusedResponse
                default: throw GrakerError.malformedStream
                }
            }
            text += choice.delta?.content ?? ""
        }
        return text
    }

    private struct Chunk: Decodable {
        let choices: [Choice]?
        let error: ProviderError?
    }
    private struct ProviderError: Decodable { let message: String? }
    private struct Choice: Decodable {
        let index: Int?
        let delta: Delta?
        let finishReason: String?
        enum CodingKeys: String, CodingKey { case index, delta; case finishReason = "finish_reason" }
    }
    private struct Delta: Decodable { let content: String?; let refusal: String? }
}
