import XCTest
@testable import GrakerCore

final class InputChangeTests: XCTestCase {
    func testTypingOneCharacterIsNotAPaste() {
        XCTAssertFalse(InputChange.isPaste(from: "Hell", to: "Hello"))
        XCTAssertFalse(InputChange.isPaste(from: "Hello", to: "Hell"))
    }

    func testInsertingSeveralCharactersAtOnceIsAPaste() {
        XCTAssertTrue(InputChange.isPaste(from: "", to: "I has went to the shop."))
        XCTAssertTrue(InputChange.isPaste(from: "Hi. ", to: "Hi. You not alone."))
    }

    func testPastingOnlyBlanksDoesNotRun() {
        XCTAssertFalse(InputChange.isPaste(from: "", to: " \n\n "))
    }
}
