import XCTest
@testable import GrakerCore

final class ConfigurationTests: XCTestCase {
    func testRejectsUnsafeOrAmbiguousEndpoints() {
        for endpoint in ["http://example.com/v1", "https://key@example.com", "https://example.com?key=secret",
                         "https://example.com/#secret", "file:///tmp/api", "not an address"] {
            var configuration = Configuration()
            configuration.endpoint = endpoint
            XCTAssertThrowsError(try configuration.validate(), endpoint)
        }
    }

    func testAllowsExplicitLoopbackWithoutRemoteHTTP() throws {
        var configuration = Configuration()
        configuration.endpoint = "http://127.0.0.1:11434/v1"
        XCTAssertTrue(configuration.isLoopback)
        XCTAssertEqual(try configuration.makeCompletionURL().absoluteString, "http://127.0.0.1:11434/v1/chat/completions")
    }

    func testKeyAccountChangesWhenDestinationChanges() throws {
        let first = Configuration()
        var second = first
        second.endpoint = "https://another.example/v1"
        XCTAssertNotEqual(try first.makeKeyAccount(), try second.makeKeyAccount())
    }

    func testTrailingSlashDoesNotCreateDuplicateKeyAccount() throws {
        let first = Configuration()
        var second = first
        second.endpoint += "/"
        XCTAssertEqual(try first.makeKeyAccount(), try second.makeKeyAccount())
    }

    func testRejectsEmptyModelLanguageAndConflictingShortcuts() {
        var configuration = Configuration()
        configuration.model = " "
        XCTAssertThrowsError(try configuration.validate())
        configuration = Configuration()
        configuration.targetLanguage = ""
        XCTAssertThrowsError(try configuration.validate())
        configuration = Configuration()
        configuration.translationKey = configuration.correctionKey
        XCTAssertThrowsError(try configuration.validate())
        configuration.translationKey = "1"
        XCTAssertThrowsError(try configuration.validate())
        configuration = Configuration()
        configuration.rephrasingKey = configuration.translationKey
        XCTAssertThrowsError(try configuration.validate())
    }

    func testEveryModeHasItsOwnDefaultShortcut() throws {
        let configuration = Configuration()
        XCTAssertEqual(configuration.shortcutKeys, [.correction: "G", .rephrasing: "R", .translation: "T"])
        XCTAssertNoThrow(try configuration.validate())
    }
}
