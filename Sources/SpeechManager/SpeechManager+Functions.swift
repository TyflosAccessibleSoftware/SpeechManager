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
        utterance.prefersAssistiveTechnologySettings = withAccessibilitySettings
        if !withAccessibilitySettings {
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
        if accessibilityVoiceEnabled {
            speakWithScreenReader(text)
        } else {
            synthesizer.speak(utterance)
        }
        saveSpeechConfiguration(
            volume: volume,
            rate: rate,
            pitch: pitch,
            language: language,
            voiceName: voiceName,
            alone: alone,
            withAccessibilitySettings: withAccessibilitySettings,
            preDelay: preDelay,
            postDelay: postDelay
        )
    }
    
    public func speakEnqueued(_ text: String, configuration: SpeechConfiguration? = nil) {
        let newElement = SpeechQueueElement(text: text, configuration: configuration)
        queuedText.append(newElement)
        if !isSpeaking {
            manageQueue()
        }
    }
    
    internal func manageQueue() {
        guard let nextElement = queuedText.first else { return }
        queuedText.remove(at: 0)
        speak(nextElement.text, settings: nextElement.configuration ?? lastSpeechConfiguration)
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
    
    private func saveSpeechConfiguration(
        volume : Float,
        rate : Float,
        pitch : Float,
        language : SpeechLanguage,
        voiceName: String?,
        alone: Bool,
        withAccessibilitySettings: Bool,
        preDelay: Double,
        postDelay: Double
    ) {
        lastSpeechConfiguration = SpeechConfiguration(
            volume: volume,
            rate: rate,
            pitch: pitch,
            language: language,
            voiceName: voiceName,
            alone: alone,
            withAccessibilitySettings: withAccessibilitySettings,
            preDelay: preDelay,
            postDelay: postDelay
        )
    }
}
