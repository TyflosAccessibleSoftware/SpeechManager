import Foundation

public struct SpeechConfiguration: Sendable {
    public var volume: Float
    public var rate: Float
    public var pitch: Float
    public var language: SpeechLanguage
    public var voiceId: String?
    public var voiceName: String?
    public var alone: Bool
    public var withAccessibilitySettings: Bool
    public var preDelay: Double
    public var postDelay: Double
    public var punctuationVerbosity: SpeechPunctuationVerbosity
    public var textFormat: SpeechTextFormat
    
    public init(
        volume: Float = 1.0,
        rate: Float = 0.5,
        pitch: Float = 1.0,
        language: SpeechLanguage = .unknown,
        voiceId: String? = nil,
        voiceName: String? = nil,
        alone: Bool = false,
        withAccessibilitySettings: Bool = false,
        preDelay: Double = 0.0,
        postDelay: Double = 0.0,
        punctuationVerbosity: SpeechPunctuationVerbosity = .none,
        textFormat: SpeechTextFormat = .plainText
    ) {
        self.volume = volume
        self.rate = rate
        self.pitch = pitch
        self.language = language
        self.voiceId = voiceId
        self.voiceName = voiceName
        self.alone = alone
        self.withAccessibilitySettings = withAccessibilitySettings
        self.preDelay = preDelay
        self.postDelay = postDelay
        self.punctuationVerbosity = punctuationVerbosity
        self.textFormat = textFormat
    }
}
