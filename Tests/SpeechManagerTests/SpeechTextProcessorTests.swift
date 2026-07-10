import XCTest
@testable import SpeechManager

final class SpeechTextProcessorTests: XCTestCase {
    func testPunctuationVerbosityNonePreservesOriginalText() {
        let result = SpeechTextProcessor.processedText(
            from: "Hello, world! user@example.com #1",
            punctuationVerbosity: .none,
            language: .English
        )

        XCTAssertEqual(result, "Hello, world! user@example.com #1")
    }

    func testPunctuationVerbositySomeVerbalizesSymbolsButKeepsSentencePunctuation() {
        let result = SpeechTextProcessor.processedText(
            from: "Email: user@example.com!",
            punctuationVerbosity: .some,
            language: .English
        )

        XCTAssertEqual(result, "Email: user at sign example.com!")
    }

    func testPunctuationVerbosityAllVerbalizesSentencePunctuation() {
        let result = SpeechTextProcessor.processedText(
            from: "Hello, world!",
            punctuationVerbosity: .all,
            language: .English
        )

        XCTAssertEqual(result, "Hello comma world exclamation mark")
    }

    func testSSMLFallbackTextExtractsReadableContent() {
        let result = SpeechTextProcessor.plainText(
            fromSSML: "<speak>Hello <break time=\"200ms\"/>world &amp; team.</speak>"
        )

        XCTAssertEqual(result, "Hello world & team.")
    }
}
