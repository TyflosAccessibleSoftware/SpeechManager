import AVFoundation

public extension AVSpeechSynthesisVoice {
    var longName: String {
        "\(name) \(identifier.localizedCaseInsensitiveContains("compact") ? "compact " : "") (\(language))"
    }
    
    static func voices(forLanguage language: String) -> [AVSpeechSynthesisVoice] {
        speechVoices().filter { $0.language == language }
    }
    
    static func voice(matchingName name: String) -> AVSpeechSynthesisVoice? {
        speechVoices().first { $0.longName.caseInsensitiveCompare(name) == .orderedSame || $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }
}
