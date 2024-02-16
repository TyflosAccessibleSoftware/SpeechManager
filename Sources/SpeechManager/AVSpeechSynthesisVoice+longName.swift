import AVFoundation

extension AVSpeechSynthesisVoice {
    var longName: String {
        get {
            "\(self.name) \(( self.identifier.localizedCaseInsensitiveContains("compact") ? "compact " : ""))(\(self.language))"
        }
    }
}
