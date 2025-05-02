//  SpeechManager.swift
//
//  Copyright (c) 2023 Jonathan Chacón
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import AVFoundation
#if os(macOS)
import AppKit
#elseif os(watchOS)
import UIKit
#else
import UIKit
#endif

public final class SpeechManager : NSObject, AVSpeechSynthesizerDelegate {
    public static let shared = SpeechManager()
    public var delegate : SpeechManagerDelegate? = nil
    public var muteStatus : Bool = false
    internal var voiceTimerService: Bool = true
    internal let synthesizer = AVSpeechSynthesizer()
    internal var muteScreenReaderVoice: Bool = false
    internal let maxTimeToUnmuteVoiceOver: Int = 10
    internal var timeToUnmuteVoiceOver: Int = 0
    public var isSpeaking: Bool { get {
        synthesizer.isSpeaking
    }
    }
    
    public var isPaused: Bool { get {
        synthesizer.isPaused
    }
    }
    
    public var availableLanguages: [String] {
        get {
            let voices = AVSpeechSynthesisVoice.speechVoices()
            var listOfLanguages: Set<String> = []
            for voice in voices {
                listOfLanguages.insert(voice.language)
            }
            return Array(listOfLanguages)
        }
    }
    
    public var availableVoices: [String] {
        get {
            let voices = AVSpeechSynthesisVoice.speechVoices()
            var listOfVoices: [String] = []
            for voice in voices {
                listOfVoices.append(voice.longName)
            }
            return listOfVoices
        }
    }
    
    public var availableVoicesByLanguage: [String:[AVSpeechSynthesisVoice]] {
        get {
            var voicesByLanguage: [String:[AVSpeechSynthesisVoice]] = [String:[AVSpeechSynthesisVoice]]()
            let voices = AVSpeechSynthesisVoice.speechVoices()
            for voice in voices {
                if var voicesForLanguage = voicesByLanguage[voice.language] {
                    voicesForLanguage.append(voice)
                    voicesByLanguage[voice.language] = voicesForLanguage
                } else {
                    voicesByLanguage[voice.language] = [voice]
                }
            }
            return voicesByLanguage
        }
    }
    
    public func getVoiceBy(_ longName: String)-> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if voice.longName.lowercased() == longName.lowercased() {
                return voice
            }
        }
        return nil
    }
    
    public func getVoicesBy(_ name: String)-> [AVSpeechSynthesisVoice] {
        var result: [AVSpeechSynthesisVoice] = []
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if voice.name.lowercased() == name.lowercased() {
                result.append(voice)
            }
        }
        return result
    }
    
    public func getVoicesFor(language: String)-> [AVSpeechSynthesisVoice] {
        var result: [AVSpeechSynthesisVoice] = []
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if voice.language.lowercased() == language.lowercased() {
                result.append(voice)
            }
        }
        return result
    }
    
    public var defaultVoiceLanguage: String {
        let utterance = AVSpeechUtterance(string: "Sample text")
        return utterance.voice?.language ?? ""
    }
    
    public var defaultVoiceName: String {
        let utterance = AVSpeechUtterance(string: "Sample text")
        return utterance.voice?.name ?? ""
    }
    
    public var defaultVoiceLongName: String {
        let utterance = AVSpeechUtterance(string: "Sample text")
        return utterance.voice?.longName ?? ""
    }
    
    // Use VoiceOver speech engine
    public var accessibilityVoiceEnabled : Bool = false
    // Stop VoiceOver speech engine when speak function starts
    public var stopAccessibilityVoiceOnSpeakEvent : Bool = false
    
    private override init() {
        super.init()
        self.synthesizer.delegate = self
        startVoiceTimerService()
    }
    
    deinit {
        stopVoiceTimerService()
    }
    
    public func muteSpeech(_ value : Bool) {
        self.muteStatus = value
    }
    
    public func speak(_ text : String,
                      volume : Float = 1.0,
                      rate : Float = 0.5,
                      pitch : Float = 1.0, language :
                      SpeechLanguage = .unknown,
                      voiceName: String? = nil,
                      alone: Bool = false,
                      withAccessibilitySettings: Bool = false) {
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
