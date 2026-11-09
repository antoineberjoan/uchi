import Foundation

/// Sépare la source de ses blancs de début et de fin.
/// Le modèle reçoit le texte sans ces blancs ; le résultat les retrouve.
/// Exemple : un triple-clic sélectionne un paragraphe avec son retour à la ligne final.
public struct SourceWhitespace: Equatable, Sendable {
    public let leading: String
    public let text: String
    public let trailing: String

    public init(source: String) {
        let scalars = source.unicodeScalars
        let blanks = CharacterSet.whitespacesAndNewlines
        guard let first = scalars.firstIndex(where: { !blanks.contains($0) }),
              let last = scalars.lastIndex(where: { !blanks.contains($0) }) else {
            leading = source
            text = ""
            trailing = ""
            return
        }
        leading = String(scalars[..<first])
        text = String(scalars[first...last])
        trailing = String(scalars[scalars.index(after: last)...])
    }

    /// Remplace les blancs qui entourent le résultat par ceux de la source.
    public func apply(to result: String) -> String {
        leading + result.trimmingCharacters(in: .whitespacesAndNewlines) + trailing
    }
}
