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

#else
import UIKit
#endif

extension SpeechManager {
    public func stopWithScreenReader() {
        if accessibilityVoiceEnabled == false {
            screenReaderSpeak("   ")
        }
    }
    
#if os(macOS)
    
    internal func screenReaderSpeak(_ text: String) {
        if let mainWindow = NSApp.mainWindow {
            NSAccessibility.post(
                element: mainWindow as   Any,
                notification: .announcementRequested,
                userInfo: [
                    .announcement:
                        "\(text)",
                    .priority: NSAccessibilityPriorityLevel.high.rawValue
                ]
            )
        }
    }
    
#elseif os(watchOS)
    
    internal func screenReaderSpeak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        synthesizer.speak(utterance)
    }
    
#else
    
    internal func screenReaderSpeak(_ text: String) {
        UIAccessibility.post(notification: .announcement, argument: text)
    }
    
#endif
    
    public func speakWithScreenReader(_ text: String, delay: Int = 0) {
        if delay > 0 {
            stopWithScreenReader()
            muteScreenReaderVoice = true
            let seconds = Double(delay) / 1000.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
                guard let self else { return }
                self.muteScreenReaderVoice = false
                self.screenReaderSpeak(text)
            }
        } else {
            screenReaderSpeak(text)
        }
    }
}
