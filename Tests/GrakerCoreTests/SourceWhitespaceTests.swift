import XCTest
@testable import GrakerCore

final class SourceWhitespaceTests: XCTestCase {
    func testSeparatesLeadingAndTrailingBlanks() {
        let whitespace = SourceWhitespace(source: "  \n\tBonjour à tous \n\n")
        XCTAssertEqual(whitespace.leading, "  \n\t")
        XCTAssertEqual(whitespace.text, "Bonjour à tous")
        XCTAssertEqual(whitespace.trailing, " \n\n")
    }

    func testKeepsInnerLineBreaks() {
        XCTAssertEqual(SourceWhitespace(source: "Un.\n\nDeux.\n").text, "Un.\n\nDeux.")
    }

    func testRestoresSourceBlanksAroundResult() {
        let whitespace = SourceWhitespace(source: "Hello.\n")
        XCTAssertEqual(whitespace.apply(to: "\n  Bonjour.  \n"), "Bonjour.\n")
    }

    func testTreatsBlankSourceAsLeadingOnly() {
        let whitespace = SourceWhitespace(source: " \n ")
        XCTAssertEqual(whitespace.leading, " \n ")
        XCTAssertEqual(whitespace.text, "")
        XCTAssertEqual(whitespace.trailing, "")
    }
}
