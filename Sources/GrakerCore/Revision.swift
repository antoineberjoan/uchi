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
        guard let data = value.data(using: .utf8),
              let revision = try? JSONDecoder().decode(Revision.self, from: data),
              !revision.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !revision.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              revision.changes.allSatisfy({ change in
                  !change.reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                  !(change.original.isEmpty && change.replacement.isEmpty) &&
                  (change.original.isEmpty || source.contains(change.original)) &&
                  (change.replacement.isEmpty || revision.text.contains(change.replacement))
              }), !revision.changes.isEmpty || revision.text == source else {
            throw GrakerError.invalidRevision
        }
        return revision
    }
}
