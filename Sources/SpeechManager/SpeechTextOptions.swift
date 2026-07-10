import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public enum SpeechPunctuationVerbosity: Equatable, Sendable {
    case none
    case some
    case all
}

public enum SpeechTextFormat: Equatable, Sendable {
    case plainText
    case ssml
}

public enum SpeechManagerError: Error, Equatable, Sendable {
    case ssmlUnavailable
    case invalidSSML
}

enum SpeechTextProcessor {
    static func processedText(
        from text: String,
        punctuationVerbosity: SpeechPunctuationVerbosity,
        language: SpeechLanguage
    ) -> String {
        switch punctuationVerbosity {
        case .none:
            return text
        case .some:
            return verbalizingSomePunctuation(in: text, language: language)
        case .all:
            return verbalizingAllPunctuation(in: text, language: language)
        }
    }

    static func plainText(fromSSML ssml: String) -> String {
        let data = Data("<speech-manager-root>\(ssml)</speech-manager-root>".utf8)
        let parser = SpeechSSMLPlainTextParser(data: data)
        parser.parse()
        let parsed = parser.result
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return parsed.isEmpty ? strippingXMLTags(from: ssml) : parsed
    }

    private static func verbalizingSomePunctuation(in text: String, language: SpeechLanguage) -> String {
        verbalizingPunctuation(in: text, language: language, includeNaturalSentenceMarks: false)
    }

    private static func verbalizingAllPunctuation(in text: String, language: SpeechLanguage) -> String {
        verbalizingPunctuation(in: text, language: language, includeNaturalSentenceMarks: true)
    }

    private static func verbalizingPunctuation(
        in text: String,
        language: SpeechLanguage,
        includeNaturalSentenceMarks: Bool
    ) -> String {
        let names = punctuationNames(for: language)
        let naturalSentenceMarks = Set([".", ",", ";", ":", "?", "!", "¿", "¡"])
        let pieces = text.map { character -> String in
            let key = String(character)
            guard let name = names[key] else { return key }
            if !includeNaturalSentenceMarks && naturalSentenceMarks.contains(key) {
                return key
            }
            return " \(name) "
        }
        return normalizedSpacing(String(pieces.joined()))
    }

    private static func normalizedSpacing(_ text: String) -> String {
        text.replacingOccurrences(of: #"[ \t]{2,}"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #" *\n *"#, with: "\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func strippingXMLTags(from text: String) -> String {
        text.replacingOccurrences(of: #"<[^>]+>"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"&amp;"#, with: "&", options: .regularExpression)
            .replacingOccurrences(of: #"&lt;"#, with: "<", options: .regularExpression)
            .replacingOccurrences(of: #"&gt;"#, with: ">", options: .regularExpression)
            .replacingOccurrences(of: #"&quot;"#, with: "\"", options: .regularExpression)
            .replacingOccurrences(of: #"&apos;"#, with: "'", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func punctuationNames(for language: SpeechLanguage) -> [String: String] {
        return englishPunctuationNames
    }

    private static let englishPunctuationNames: [String: String] = [
        ".": "period",
        ",": "comma",
        ";": "semicolon",
        ":": "colon",
        "?": "question mark",
        "!": "exclamation mark",
        "¿": "inverted question mark",
        "¡": "inverted exclamation mark",
        "\"": "quote",
        "'": "apostrophe",
        "(": "left parenthesis",
        ")": "right parenthesis",
        "[": "left bracket",
        "]": "right bracket",
        "{": "left brace",
        "}": "right brace",
        "<": "less than",
        ">": "greater than",
        "/": "slash",
        "\\": "backslash",
        "|": "vertical bar",
        "-": "dash",
        "_": "underscore",
        "*": "asterisk",
        "+": "plus",
        "=": "equals",
        "@": "at sign",
        "#": "number sign",
        "$": "dollar sign",
        "%": "percent",
        "&": "ampersand",
        "~": "tilde",
        "`": "backtick",
        "^": "caret"
    ]

}

private final class SpeechSSMLPlainTextParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    private(set) var result = ""

    init(data: Data) {
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
    }

    func parse() {
        parser.parse()
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        result += string
    }
}
