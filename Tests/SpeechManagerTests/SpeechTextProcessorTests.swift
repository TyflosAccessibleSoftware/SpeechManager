import Testing
@testable import SpeechManager

struct SpeechTextProcessorTests {
    @Test("Punctuation verbosity none preserves the original text")
    func punctuationNone() {
        let result = SpeechTextProcessor.processedText(
            from: "Hello, world! user@example.com #1",
            punctuationVerbosity: .none,
            language: .English
        )

        #expect(result == "Hello, world! user@example.com #1")
    }

    @Test("Punctuation verbosity some verbalizes symbols but keeps sentence punctuation")
    func punctuationSome() {
        let result = SpeechTextProcessor.processedText(
            from: "Email: user@example.com!",
            punctuationVerbosity: .some,
            language: .English
        )

        #expect(result == "Email: user at sign example.com!")
    }

    @Test("Punctuation verbosity all verbalizes sentence punctuation too")
    func punctuationAll() {
        let result = SpeechTextProcessor.processedText(
            from: "Hello, world!",
            punctuationVerbosity: .all,
            language: .English
        )

        #expect(result == "Hello comma world exclamation mark")
    }

    @Test("SSML fallback text extracts readable content")
    func ssmlPlainTextFallback() {
        let result = SpeechTextProcessor.plainText(
            fromSSML: "<speak>Hello <break time=\"200ms\"/>world &amp; team.</speak>"
        )

        #expect(result == "Hello world & team.")
    }
}
