import XCTest
@testable import ImiCore

final class RevisionTests: XCTestCase {
    func testDecodesCompleteCorrectionWithExplanation() throws {
        let response = #"{"text":"You are not alone.","explanation":"Ajout du verbe.","changes":[{"original":"You not","replacement":"You are not","reason":"Le verbe est nécessaire."}]}"#
        let revision = try Revision.parse(response, source: "You not alone.")
        XCTAssertEqual(revision.text, "You are not alone.")
        XCTAssertEqual(revision.changes.count, 1)
    }

    func testAcceptsNoChangeOnlyWhenSourceIsPreserved() throws {
        let valid = #"{"text":"Hello.","explanation":"La phrase est correcte.","changes":[]}"#
        XCTAssertEqual(try Revision.parse(valid, source: "Hello.").text, "Hello.")
        XCTAssertThrowsError(try Revision.parse(valid, source: "Different text"))
    }

    func testRejectsHallucinatedFragmentsAndMissingFields() {
        for response in [#"{"text":"Hello.","explanation":"OK","changes":[{"original":"Not in source","replacement":"Hello","reason":"Reason"}]}"#,
                         #"{"text":"Hello.","explanation":"","changes":[]}"#, #"{"text":"Hello."}"#,
                         "Here is the answer: Hello."] {
            XCTAssertThrowsError(try Revision.parse(response, source: "Hello."))
        }
    }

    func testKeepsSelectionBlanksWhenModelTrimsThem() throws {
        let unchanged = #"{"text":"Hello.","explanation":"La phrase est correcte.","changes":[]}"#
        XCTAssertEqual(try Revision.parse(unchanged, source: "Hello.\n").text, "Hello.\n")
        let corrected = #"{"text":"You are not alone.","explanation":"Ajout du verbe.","changes":[{"original":"You not","replacement":"You are not","reason":"Le verbe est nécessaire."}]}"#
        XCTAssertEqual(try Revision.parse(corrected, source: "  You not alone.\n").text, "  You are not alone.\n")
    }

    func testUnwrapsJSONFenceWithoutDroppingNewlinesInsideText() throws {
        let response = "```json\n{\"text\":\"A\\nB\",\"explanation\":\"Correct.\",\"changes\":[]}\n```"
        XCTAssertEqual(try Revision.parse(response, source: "A\nB").text, "A\nB")
    }
}
