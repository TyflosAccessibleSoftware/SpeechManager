import Foundation

public struct SpeechConfiguration {
    var volume: Float = 1.0
    var rate: Float = 0.5
    var pitch: Float = 1.0
    var language: SpeechLanguage = .unknown
    var voiceName: String? = nil
    var alone: Bool = false
    var withAccessibilitySettings: Bool = false
    var preDelay: Double = 0.0
    var postDelay: Double = 0.0
}
