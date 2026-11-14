import XCTest
@testable import ImiCore

final class LineDecoderTests: XCTestCase {
    private func decodeLines(_ text: String) -> [String] {
        var decoder = LineDecoder()
        var lines = text.utf8.compactMap { decoder.receive($0) }
        if let last = decoder.finish() { lines.append(last) }
        return lines
    }

    func testKeepsEmptyLinesThatCloseEvents() {
        XCTAssertEqual(decodeLines("data: a\n\ndata: b\n\n"), ["data: a", "", "data: b", ""])
    }

    func testAcceptsCarriageReturnLineEndings() {
        XCTAssertEqual(decodeLines("a\r\n\r\nb\rc\r\r"), ["a", "", "b", "c", ""])
    }

    func testKeepsMultibyteCharactersReceivedByteByByte() {
        XCTAssertEqual(decodeLines("data: Bonjour 🐈 à tous\n"), ["data: Bonjour 🐈 à tous"])
    }

    func testReturnsLastLineWithoutTerminatorOnce() {
        var decoder = LineDecoder()
        for byte in "data: [DONE]".utf8 { XCTAssertNil(decoder.receive(byte)) }
        XCTAssertEqual(decoder.pendingByteCount, 12)
        XCTAssertEqual(decoder.finish(), "data: [DONE]")
        XCTAssertNil(decoder.finish())
    }

    // Forme des événements vérifiée dans l'exemple officiel OpenAI cité dans Documentation/Network.md.
    private let stream = """
    data: {"choices":[{"index":0,"delta":{"role":"assistant","content":""},"finish_reason":null}]}

    data: {"choices":[{"index":0,"delta":{"content":"Bonjour"},"finish_reason":null}]}

    data: {"choices":[{"index":0,"delta":{"content":" à tous"},"finish_reason":null}]}

    data: {"choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

    data: [DONE]


    """

    func testDecodesCompleteStreamWithStreamDecoder() throws {
        for text in [stream, stream.replacingOccurrences(of: "\n", with: "\r\n")] {
            var decoder = StreamDecoder()
            var result = ""
            for line in decodeLines(text) { result += try decoder.receive(line: line) }
            result += try decoder.finish()
            XCTAssertEqual(result, "Bonjour à tous")
        }
    }

    /// `URLSession.AsyncBytes.lines` saute les lignes vides : le flux devient illisible.
    func testDroppingEmptyLinesMergesEventsIntoUnreadableData() {
        var decoder = StreamDecoder()
        XCTAssertThrowsError(try {
            for line in decodeLines(stream) where !line.isEmpty { _ = try decoder.receive(line: line) }
            _ = try decoder.finish()
        }()) { XCTAssertEqual($0 as? ImiError, .malformedStream) }
    }
}
