import Foundation

/// Un morceau du texte révisé. Un passage modifié renvoie à son changement.
public struct RevisionPassage: Equatable, Identifiable, Sendable {
    public let id: Int
    public let text: String
    public let changeIndex: Int?
}

/// Place chaque changement dans le texte révisé, pour le surligner à sa place.
/// Un changement sans passage visible reste listé à part : rien ne disparaît.
public struct RevisionLayout: Equatable, Sendable {
    public let passages: [RevisionPassage]
    /// Suppressions, et remplacements introuvables ou déjà couverts par un autre changement.
    public let unplacedChangeIndices: [Int]

    public init(revision: Revision) {
        let text = revision.text
        var placed: [(range: Range<String.Index>, changeIndex: Int)] = []
        var unplaced: [Int] = []
        var cursor = text.startIndex
        for (changeIndex, change) in revision.changes.enumerated() {
            // Les changements suivent en général l'ordre du texte : chercher d'abord après le précédent.
            let areas = [cursor..<text.endIndex, text.startIndex..<text.endIndex]
            let found = change.replacement.isEmpty ? nil : areas.lazy.compactMap { area in
                RevisionLayout.findFreeRange(of: change.replacement, in: text, area: area,
                                             taken: placed.map(\.range))
            }.first
            if let found {
                placed.append((found, changeIndex))
                cursor = found.upperBound
            } else {
                unplaced.append(changeIndex)
            }
        }
        var passages: [RevisionPassage] = []
        var position = text.startIndex
        for item in placed.sorted(by: { $0.range.lowerBound < $1.range.lowerBound }) {
            if position < item.range.lowerBound {
                passages.append(RevisionPassage(id: passages.count, text: String(text[position..<item.range.lowerBound]),
                                                changeIndex: nil))
            }
            passages.append(RevisionPassage(id: passages.count, text: String(text[item.range]),
                                            changeIndex: item.changeIndex))
            position = item.range.upperBound
        }
        if position < text.endIndex {
            passages.append(RevisionPassage(id: passages.count, text: String(text[position...]), changeIndex: nil))
        }
        self.passages = passages
        unplacedChangeIndices = unplaced
    }

    private static func findFreeRange(of fragment: String, in text: String, area: Range<String.Index>,
                                      taken: [Range<String.Index>]) -> Range<String.Index>? {
        var start = area.lowerBound
        while start < area.upperBound,
              let range = text.range(of: fragment, options: .literal, range: start..<area.upperBound) {
            if !taken.contains(where: { $0.overlaps(range) }) { return range }
            start = text.index(after: range.lowerBound)
        }
        return nil
    }
}
