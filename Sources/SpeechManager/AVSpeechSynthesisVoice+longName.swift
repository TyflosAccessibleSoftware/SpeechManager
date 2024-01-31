import AVFoundation

extension AVSpeechSynthesisVoice {
    var longName: String {
        get {
            "\(self.name) (\(self.language))"
        }
    }
}
