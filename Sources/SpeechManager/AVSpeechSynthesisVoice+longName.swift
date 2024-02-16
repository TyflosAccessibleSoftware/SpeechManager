import AVFoundation

extension AVSpeechSynthesisVoice {
    public var longName: String {
        get {
            "\(self.name) \(( self.identifier.localizedCaseInsensitiveContains("compact") ? "compact " : ""))(\(self.language))"
        }
    }
}
