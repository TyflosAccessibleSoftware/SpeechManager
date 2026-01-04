import Foundation

public struct SpeechConfiguration: Sendable {
    public var volume: Float
    public var rate: Float
    public var pitch: Float
    public var language: SpeechLanguage
    public var voiceName: String?
    public var alone: Bool
    public var withAccessibilitySettings: Bool
    public var preDelay: Double
    public var postDelay: Double
    
    public init(
        volume: Float = 1.0,
        rate: Float = 0.5,
        pitch: Float = 1.0,
        language: SpeechLanguage = .unknown,
        voiceName: String? = nil,
        alone: Bool = false,
        withAccessibilitySettings: Bool = false,
        preDelay: Double = 0.0,
        postDelay: Double = 0.0
    ) {
        self.volume = volume
        self.rate = rate
        self.pitch = pitch
        self.language = language
        self.voiceName = voiceName
        self.alone = alone
        self.withAccessibilitySettings = withAccessibilitySettings
        self.preDelay = preDelay
        self.postDelay = postDelay
    }
}
