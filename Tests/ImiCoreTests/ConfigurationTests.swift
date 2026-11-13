import XCTest
@testable import ImiCore

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

    func testEachProviderKeepsItsOwnEndpointAndModel() throws {
        var configuration = Configuration()
        XCTAssertEqual(configuration.model, "gemini-3.1-flash-lite")
        configuration.model = "gemini-choisi"
        configuration.provider = .custom
        configuration.endpoint = "http://localhost:11434/v1"
        configuration.model = "llama"
        configuration.provider = .deepseek
        XCTAssertEqual(configuration.model, "deepseek-chat")
        configuration.provider = .gemini
        XCTAssertEqual(configuration.model, "gemini-choisi")
        XCTAssertEqual(configuration.endpoint, Provider.gemini.defaultProfile.endpoint)
        XCTAssertEqual(configuration.readProfile(for: .custom),
                       ProviderProfile(endpoint: "http://localhost:11434/v1", model: "llama"))
        let data = try JSONEncoder().encode(configuration)
        XCTAssertTrue(String(decoding: data, as: UTF8.self).contains(#""custom":{"#))
        XCTAssertEqual(try JSONDecoder().decode(Configuration.self, from: data), configuration)
    }

    func testEveryModeHasItsOwnDefaultShortcut() throws {
        let configuration = Configuration()
        XCTAssertEqual(configuration.shortcutKeys, [.correction: "G", .rephrasing: "R", .translation: "T"])
        XCTAssertNoThrow(try configuration.validate())
    }
}
