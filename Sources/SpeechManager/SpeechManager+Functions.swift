import AVFoundation
#if os(macOS)
import AppKit
#elseif os(watchOS)
import UIKit
#else
import UIKit
#endif

extension SpeechManager {
    
    public func muteSpeech(_ value : Bool) {
        self.muteStatus = value
    }
    
    public func speak(_ text: String, settings: SpeechConfiguration) {
        self.speak(text,
                   volume: settings.volume,
                   rate: settings.rate,
                   pitch: settings.pitch,
                   language: settings.language,
                   voiceName: settings.voiceName,
                   alone: settings.alone,
                   withAccessibilitySettings: settings.withAccessibilitySettings,
                   preDelay: settings.preDelay,
                   postDelay: settings.postDelay)
    }
    
    public func speak(
        _ text : String,
        volume : Float = 1.0,
        rate : Float = 0.5,
        pitch : Float = 1.0,
        language : SpeechLanguage = .unknown,
        voiceName: String? = nil,
        alone: Bool = false,
        withAccessibilitySettings: Bool = false,
        preDelay: Double = 0.0,
        postDelay: Double = 0.0
    ) {
        let utterance = AVSpeechUtterance(string: text)
        if alone {
            muteScreenReaderVoice = true
            timeToUnmuteVoiceOver = maxTimeToUnmuteVoiceOver
        } else {
            muteScreenReaderVoice = false
            timeToUnmuteVoiceOver = 0
        }
        if self.muteStatus {
            utterance.volume = 0
        } else {
            utterance.volume = volume
        }
        utterance.preUtteranceDelay = preDelay
        utterance.postUtteranceDelay = postDelay
#if !os(watchOS)
        if withAccessibilitySettings {
            utterance.prefersAssistiveTechnologySettings = true
        } else {
            utterance.prefersAssistiveTechnologySettings = false
            utterance.rate = rate
            utterance.pitchMultiplier = pitch
        }
#endif
        if let nameForVoice = voiceName {
            if let voice = getVoiceBy(nameForVoice) {
                utterance.voice = voice
            }
        } else if language != .unknown {
            utterance.voice = AVSpeechSynthesisVoice(language: "\(language.rawValue)")
        }
        if synthesizer.isSpeaking{
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        if stopAccessibilityVoiceOnSpeakEvent {
            stopWithScreenReader()
        }
        if accessibilityVoiceEnabled == true {
            speakWithScreenReader(text)
        } else {
            synthesizer.speak(utterance)
        }
    }
    
    public func stop() {
        if accessibilityVoiceEnabled == true {
            stopWithScreenReader()
        } else {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    public func resume() {
        synthesizer.continueSpeaking()
    }
    
    public func pause() {
        synthesizer.pauseSpeaking(at: .word)
    }
}
