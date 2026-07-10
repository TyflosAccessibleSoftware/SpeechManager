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
                   voiceId: settings.voiceId,
                   voiceName: settings.voiceName,
                   alone: settings.alone,
                   withAccessibilitySettings: settings.withAccessibilitySettings,
                   preDelay: settings.preDelay,
                   postDelay: settings.postDelay,
                   punctuationVerbosity: settings.punctuationVerbosity,
                   textFormat: settings.textFormat)
    }
    
    public func speak(
        _ text : String,
        volume : Float = 1.0,
        rate : Float = 0.5,
        pitch : Float = 1.0,
        language : SpeechLanguage = .unknown,
        voice: AVSpeechSynthesisVoice? = nil,
        voiceId: String? = nil,
        voiceName: String? = nil,
        alone: Bool = false,
        withAccessibilitySettings: Bool = false,
        preDelay: Double = 0.0,
        postDelay: Double = 0.0,
        punctuationVerbosity: SpeechPunctuationVerbosity = .none,
        textFormat: SpeechTextFormat = .plainText
    ) {
        var requestedVoice: AVSpeechSynthesisVoice?
        if let voice = voice {
            requestedVoice = voice
        } else if let voiceId = voiceId, let voice = getVoiceBy(id: voiceId) {
            requestedVoice = voice
        } else if let nameForVoice = voiceName, let voice = getVoiceBy(longName: nameForVoice) {
            requestedVoice = voice
        } else if language != .unknown {
            requestedVoice = AVSpeechSynthesisVoice(language: "\(language.rawValue)")
        }
        if let voiceToUse = requestedVoice {
            if !voiceToUse.isInstalledForAVSpeech {
                delegate?.speechManager(didRequestUnavailableVoice: voiceToUse.longName)
                requestedVoice = nil
            }
        }

        let utterance = makeUtterance(
            from: text,
            textFormat: textFormat,
            punctuationVerbosity: punctuationVerbosity,
            language: language
        )
        configure(
            utterance,
            volume: volume,
            rate: rate,
            pitch: pitch,
            voice: requestedVoice,
            withAccessibilitySettings: withAccessibilitySettings,
            preDelay: preDelay,
            postDelay: postDelay,
            textFormat: textFormat
        )
        
        
        if alone {
            stopWithScreenReader()
        }
        if accessibilityVoiceEnabled {
            let screenReaderText = textForScreenReader(
                from: text,
                textFormat: textFormat,
                punctuationVerbosity: punctuationVerbosity,
                language: language
            )
            speakWithScreenReader(screenReaderText)
        } else {
            synthesizer.speak(utterance)
        }
        saveSpeechConfiguration(
            volume: volume,
            rate: rate,
            pitch: pitch,
            language: language,
            voiceId: voiceId,
            voiceName: voiceName,
            alone: alone,
            withAccessibilitySettings: withAccessibilitySettings,
            preDelay: preDelay,
            postDelay: postDelay,
            punctuationVerbosity: punctuationVerbosity,
            textFormat: textFormat
        )
    }

    public func speakSSML(_ ssml: String, settings: SpeechConfiguration = SpeechConfiguration()) {
        var ssmlSettings = settings
        ssmlSettings.textFormat = .ssml
        speak(ssml, settings: ssmlSettings)
    }
    
    public func speakEnqueued(_ text: String, configuration: SpeechConfiguration? = nil) {
        let newElement = SpeechQueueElement(text: text, configuration: configuration)
        queuedText.append(newElement)
        guard !isDrainingQueue else { return }
        isDrainingQueue = true
            manageQueue()
    }

    public func speakSSMLEnqueued(_ ssml: String, configuration: SpeechConfiguration? = nil) {
        var ssmlConfiguration = configuration ?? lastSpeechConfiguration
        ssmlConfiguration.textFormat = .ssml
        speakEnqueued(ssml, configuration: ssmlConfiguration)
    }
    
    internal func manageQueue() {
        guard let nextElement = queuedText.first else {
            isDrainingQueue = false
            return
        }
        queuedText.remove(at: 0)
        speak(nextElement.text, settings: nextElement.configuration ?? lastSpeechConfiguration)
    }
    
    public func stop() {
        isDrainingQueue = false
        clearQueue()
        pendingFinishedRanges.removeAll()
        if accessibilityVoiceEnabled == true {
            stopWithScreenReader()
        } else {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    public func resume() {
        synthesizer.continueSpeaking()
    }
    
    public func pause(immediate: Bool = true) {
        synthesizer.pauseSpeaking(at: immediate ? .immediate : .word)
    }

    @available(*, deprecated, renamed: "pause(immediate:)")
    public func pause(inmediate: Bool = true) {
        pause(immediate: inmediate)
    }
    
    public func clearQueue() {
        queuedText.removeAll()
    }
    
    public func stopAndClearQueue() {
        clearQueue()
        stop()
    }
    
    private func saveSpeechConfiguration(
        volume : Float,
        rate : Float,
        pitch : Float,
        language : SpeechLanguage,
        voiceId: String?,
        voiceName: String?,
        alone: Bool,
        withAccessibilitySettings: Bool,
        preDelay: Double,
        postDelay: Double,
        punctuationVerbosity: SpeechPunctuationVerbosity,
        textFormat: SpeechTextFormat
    ) {
        lastSpeechConfiguration = SpeechConfiguration(
            volume: volume,
            rate: rate,
            pitch: pitch,
            language: language,
            voiceId: voiceId,
            voiceName: voiceName,
            alone: alone,
            withAccessibilitySettings: withAccessibilitySettings,
            preDelay: preDelay,
            postDelay: postDelay,
            punctuationVerbosity: punctuationVerbosity,
            textFormat: textFormat
        )
    }

    internal func makeUtterance(
        from text: String,
        textFormat: SpeechTextFormat,
        punctuationVerbosity: SpeechPunctuationVerbosity,
        language: SpeechLanguage
    ) -> AVSpeechUtterance {
        switch textFormat {
        case .plainText:
            return AVSpeechUtterance(
                string: SpeechTextProcessor.processedText(
                    from: text,
                    punctuationVerbosity: punctuationVerbosity,
                    language: language
                )
            )
        case .ssml:
            if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
                if let utterance = AVSpeechUtterance(ssmlRepresentation: text) {
                    return utterance
                }
                report(.invalidSSML)
            } else {
                report(.ssmlUnavailable)
            }
            let fallbackText = SpeechTextProcessor.plainText(fromSSML: text)
            return AVSpeechUtterance(
                string: SpeechTextProcessor.processedText(
                    from: fallbackText,
                    punctuationVerbosity: punctuationVerbosity,
                    language: language
                )
            )
        }
    }

    private func configure(
        _ utterance: AVSpeechUtterance,
        volume: Float,
        rate: Float,
        pitch: Float,
        voice: AVSpeechSynthesisVoice?,
        withAccessibilitySettings: Bool,
        preDelay: Double,
        postDelay: Double,
        textFormat: SpeechTextFormat
    ) {
        utterance.volume = muteStatus ? 0 : volume
        utterance.preUtteranceDelay = preDelay
        utterance.postUtteranceDelay = postDelay
#if !os(watchOS)
        utterance.prefersAssistiveTechnologySettings = withAccessibilitySettings
        if !withAccessibilitySettings && textFormat == .plainText {
            utterance.rate = rate
            utterance.pitchMultiplier = pitch
        }
#endif
        if let voice {
            utterance.voice = voice
        }
    }

    private func textForScreenReader(
        from text: String,
        textFormat: SpeechTextFormat,
        punctuationVerbosity: SpeechPunctuationVerbosity,
        language: SpeechLanguage
    ) -> String {
        let plainText = textFormat == .ssml ? SpeechTextProcessor.plainText(fromSSML: text) : text
        return SpeechTextProcessor.processedText(
            from: plainText,
            punctuationVerbosity: punctuationVerbosity,
            language: language
        )
    }

    private func report(_ error: SpeechManagerError) {
        onSpeechManagerError?(error)
        delegate?.speechManager(didFailWith: error)
    }
}
