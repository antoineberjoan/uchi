import Foundation

public struct Change: Codable, Equatable, Identifiable, Sendable {
    public let original: String
    public let replacement: String
    public let reason: String
    public var id: String { original + "\u{0}" + replacement + "\u{0}" + reason }
}

public struct Revision: Codable, Equatable, Sendable {
    public let text: String
    public let explanation: String
    public let changes: [Change]

    public static func parse(_ response: String, source: String) throws -> Revision {
        var value = response.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("```"), value.hasSuffix("```"), let newline = value.firstIndex(of: "\n") {
            value = String(value[value.index(after: newline)...].dropLast(3)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let whitespace = SourceWhitespace(source: source)
        guard let data = value.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(Revision.self, from: data) else {
            throw GrakerError.invalidRevision
        }
        let text = decoded.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty,
              !decoded.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              decoded.changes.allSatisfy({ change in
                  !change.reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                  !(change.original.isEmpty && change.replacement.isEmpty) &&
                  (change.original.isEmpty || whitespace.text.contains(change.original)) &&
                  (change.replacement.isEmpty || text.contains(change.replacement))
              }), !decoded.changes.isEmpty || text == whitespace.text else {
            throw GrakerError.invalidRevision
        }
        return Revision(text: whitespace.apply(to: text), explanation: decoded.explanation, changes: decoded.changes)
    }
}
