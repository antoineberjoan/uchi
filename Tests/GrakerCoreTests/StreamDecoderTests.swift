import XCTest
@testable import GrakerCore

final class StreamDecoderTests: XCTestCase {
    // Forme des deltas vérifiée dans l'exemple officiel OpenAI cité dans Documentation/Network.md.
    private func receive(_ payload: String, decoder: inout StreamDecoder) throws -> String {
        _ = try decoder.receive(line: "data: " + payload)
        return try decoder.receive(line: "")
    }

    func testHandlesInitialRoleTextUnicodeUsageAndTerminalEvents() throws {
        var decoder = StreamDecoder()
        XCTAssertEqual(try receive(#"{"choices":[{"index":0,"delta":{"role":"assistant","content":""},"finish_reason":null}]}"#, decoder: &decoder), "")
        var result = try receive(#"{"choices":[{"index":0,"delta":{"content":"Bonjour 🐈\n"},"finish_reason":null}]}"#, decoder: &decoder)
        result += try receive(#"{"choices":[{"index":0,"delta":{"content":"à tous"},"finish_reason":null}]}"#, decoder: &decoder)
        _ = try receive(#"{"choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}"#, decoder: &decoder)
        _ = try receive(#"{"choices":[],"usage":{"completion_tokens":4}}"#, decoder: &decoder)
        _ = try receive("[DONE]", decoder: &decoder)
        result += try decoder.finish()
        XCTAssertEqual(result, "Bonjour 🐈\nà tous")
        XCTAssertTrue(decoder.isComplete)
    }

    func testNetworkEOFDoesNotAuthorizePartialResult() throws {
        var decoder = StreamDecoder()
        _ = try receive(#"{"choices":[{"delta":{"content":"Partial"}}]}"#, decoder: &decoder)
        XCTAssertThrowsError(try decoder.finish()) { XCTAssertEqual($0 as? GrakerError, .incompleteStream) }
    }

    func testDoneWithoutModelFinishIsIncomplete() throws {
        var decoder = StreamDecoder()
        _ = try receive("[DONE]", decoder: &decoder)
        XCTAssertThrowsError(try decoder.finish())
    }

    func testFlushesLastEventWithoutFinalBlankLine() throws {
        var decoder = StreamDecoder()
        _ = try receive(#"{"choices":[{"delta":{},"finish_reason":"stop"}]}"#, decoder: &decoder)
        _ = try decoder.receive(line: "data: [DONE]")
        XCTAssertEqual(try decoder.finish(), "")
    }

    func testRejectsTruncationRefusalAndMalformedData() {
        for payload in [#"{"choices":[{"delta":{},"finish_reason":"length"}]}"#,
                        #"{"choices":[{"delta":{"refusal":"No"}}]}"#,
                        #"{"choices":[{"delta":{},"finish_reason":"tool_calls"}]}"#,
                        #"{"error":{"message":"Rejected"}}"#, "not JSON"] {
            var decoder = StreamDecoder()
            XCTAssertThrowsError(try receive(payload, decoder: &decoder))
        }
    }

    func testSSECommentsAreIgnoredAndMultilineDataIsJoined() throws {
        var decoder = StreamDecoder()
        _ = try decoder.receive(line: ": keepalive")
        _ = try decoder.receive(line: "data: {\"choices\": [")
        _ = try decoder.receive(line: "data: {\"delta\":{\"content\":\"OK\"}}]}")
        XCTAssertEqual(try decoder.receive(line: ""), "OK")
    }
}
