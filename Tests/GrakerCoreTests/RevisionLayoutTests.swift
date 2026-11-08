import XCTest
@testable import GrakerCore

final class RevisionLayoutTests: XCTestCase {
    private func makeRevision(_ text: String, _ changes: [(String, String)]) -> Revision {
        Revision(text: text, explanation: "Explication.",
                 changes: changes.map { Change(original: $0.0, replacement: $0.1, reason: "Raison.") })
    }

    private func describe(_ layout: RevisionLayout) -> [String] {
        layout.passages.map { passage in passage.changeIndex.map { "[\($0):\(passage.text)]" } ?? passage.text }
    }

    func testHighlightsReplacementAtItsPlace() {
        let layout = RevisionLayout(revision: makeRevision("Haha, enjoy~\n\nYou are not the last one.",
                                                          [("You not", "You are not")]))
        XCTAssertEqual(describe(layout), ["Haha, enjoy~\n\n", "[0:You are not]", " the last one."])
        XCTAssertEqual(layout.unplacedChangeIndices, [])
    }

    func testRepeatedWordsGoToSuccessiveOccurrences() {
        let layout = RevisionLayout(revision: makeRevision("I saw the cat and the dog.", [("a", "the"), ("a", "the")]))
        XCTAssertEqual(describe(layout), ["I saw ", "[0:the]", " cat and ", "[1:the]", " dog."])
    }

    func testFindsChangeListedBeforeAnEarlierPassage() {
        let layout = RevisionLayout(revision: makeRevision("I am here. She is there.", [("She are", "She is"), ("I is", "I am")]))
        XCTAssertEqual(describe(layout), ["[1:I am]", " here. ", "[0:She is]", " there."])
    }

    func testKeepsDeletionsAndMissingFragmentsAside() {
        let layout = RevisionLayout(revision: makeRevision("Hello.", [("very ", ""), ("Helo", "Hello"), ("x", "Hello")]))
        XCTAssertEqual(describe(layout), ["[1:Hello]", "."])
        XCTAssertEqual(layout.unplacedChangeIndices, [0, 2])
    }

    func testPassagesRebuildTheWholeText() {
        let text = "  Un. Deux, trois. Un.\n"
        let layout = RevisionLayout(revision: makeRevision(text, [("1", "Un"), ("2", "Deux"), ("1", "Un")]))
        XCTAssertEqual(layout.passages.map(\.text).joined(), text)
        XCTAssertEqual(layout.passages.map(\.id), Array(layout.passages.indices))
        XCTAssertEqual(describe(RevisionLayout(revision: makeRevision("Rien.", []))), ["Rien."])
    }
}
