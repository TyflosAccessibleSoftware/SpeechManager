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
    public weak var delegate: SpeechManagerDelegate?
    public var muteStatus : Bool = false
    
    public var onSpokenText: ((String,String)->Void)?
    public var onSpokenTextWithRange: ((NSRange,String)->Void)?
    
    internal var voiceTimerService: Bool = true
    internal var voiceTimer: Timer?
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
    
    // Use VoiceOver speech engine
    public var accessibilityVoiceEnabled : Bool = false
    
    // Stop VoiceOver speech engine when speak function starts
    public var stopAccessibilityVoiceOnSpeakEvent : Bool = false
    
    internal var queuedText: [SpeechQueueElement] = []
    internal var lastSpeechConfiguration = SpeechConfiguration()
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        startVoiceTimerService()
    }
    
    deinit {
        stopVoiceTimerService()
    }
}
