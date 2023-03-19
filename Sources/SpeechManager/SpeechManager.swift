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
#else
import UIKit
#endif

public let speech = SpeechManager.shared
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
    
    public func speak(_ text : String, volume : Float = 1.0, rate : Float = 0.5, pitch : Float = 1.0, language : SpeechLanguage = .unknown, alone: Bool = false) {
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
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        if language != .unknown {
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
}
