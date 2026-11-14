#if os(macOS)
import Foundation
import XCTest
import ImiCore
@testable import ImiPlatform

/// Faux fournisseur : renvoie une réponse HTTP fixe, en morceaux d'octets choisis par le test.
private final class StubProviderProtocol: URLProtocol {
    struct Reply {
        var status = 200
        var contentType = "text/event-stream"
        var chunks: [Data]
    }
    static var reply = Reply(chunks: [])

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() {}
    override func startLoading() {
        let reply = Self.reply
        let response = HTTPURLResponse(url: request.url!, statusCode: reply.status, httpVersion: "HTTP/1.1",
                                       headerFields: ["Content-Type": reply.contentType])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        for chunk in reply.chunks { client?.urlProtocol(self, didLoad: chunk) }
        client?.urlProtocolDidFinishLoading(self)
    }
}

final class ProviderClientTests: XCTestCase {
    private let client = ProviderClient(protocolClasses: [StubProviderProtocol.self])
    private let request = CompletionRequest(model: "stub", messages: [Message(role: "user", content: "Hello")])

    // Forme des événements vérifiée dans l'exemple officiel OpenAI cité dans Documentation/Network.md.
    private let stream = """
    data: {"choices":[{"index":0,"delta":{"role":"assistant","content":""},"finish_reason":null}]}

    data: {"choices":[{"index":0,"delta":{"content":"Bonjour 🐈"},"finish_reason":null}]}

    data: {"choices":[{"index":0,"delta":{"content":" à tous"},"finish_reason":null}]}

    data: {"choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

    data: [DONE]


    """

    private func split(_ text: String, every size: Int) -> [Data] {
        let bytes = Array(text.utf8)
        return stride(from: 0, to: bytes.count, by: size).map { Data(bytes[$0..<min($0 + size, bytes.count)]) }
    }

    private func complete(key: String = "cle-de-test") async throws -> String {
        try await client.complete(request, configuration: Configuration(), key: key, onText: { _ in })
    }

    func testReadsStreamSplitAtAwkwardPlaces() async throws {
        // 7 octets : coupe au milieu des lignes, des fins de ligne et de l'émoji.
        for size in [1, 7, 1000] {
            StubProviderProtocol.reply = .init(chunks: split(stream, every: size))
            let result = try await complete()
            XCTAssertEqual(result, "Bonjour 🐈 à tous", "morceaux de \(size) octets")
        }
    }

    func testReadsStreamWithCarriageReturnLineEndings() async throws {
        StubProviderProtocol.reply = .init(chunks: split(stream.replacingOccurrences(of: "\n", with: "\r\n"), every: 5))
        let result = try await complete()
        XCTAssertEqual(result, "Bonjour 🐈 à tous")
    }

    func testStreamCutBeforeTheEndIsAnError() async {
        // Trois événements complets sur cinq : la connexion s'arrête avant `finish_reason` et `[DONE]`.
        let cut = stream.components(separatedBy: "\n\n").prefix(3).joined(separator: "\n\n") + "\n\n"
        StubProviderProtocol.reply = .init(chunks: split(cut, every: 9))
        do {
            _ = try await complete()
            XCTFail("Un flux coupé ne doit pas réussir.")
        } catch { XCTAssertEqual(error as? ImiError, .incompleteStream) }
    }

    func testHTTPFailureIsAVisibleError() async {
        StubProviderProtocol.reply = .init(status: 401, contentType: "application/json", chunks: [Data("{}".utf8)])
        do {
            _ = try await complete()
            XCTFail("Un refus HTTP ne doit pas réussir.")
        } catch {
            guard case ProviderFailure.status(401)? = error as? ProviderFailure else { return XCTFail("\(error)") }
        }
    }

    func testAnswerThatIsNotAStreamIsAnError() async {
        StubProviderProtocol.reply = .init(contentType: "application/json", chunks: [Data("{\"choices\":[]}".utf8)])
        do {
            _ = try await complete()
            XCTFail("Une réponse JSON simple ne doit pas réussir.")
        } catch {
            guard case ProviderFailure.unsupportedStream? = error as? ProviderFailure else { return XCTFail("\(error)") }
        }
    }

    func testMissingKeyIsAnErrorBeforeAnyRequest() async {
        StubProviderProtocol.reply = .init(chunks: split(stream, every: 100))
        do {
            _ = try await complete(key: " ")
            XCTFail("Sans clé, la requête ne doit pas partir.")
        } catch {
            guard case ProviderFailure.missingKey? = error as? ProviderFailure else { return XCTFail("\(error)") }
        }
    }
}
#endif
