import AVFoundation
#if os(macOS)
import AppKit
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
        NSAccessibility.post(
            element: NSApp.mainWindow as   Any,
            notification: .announcementRequested,
            userInfo: [
                .announcement:
                    "\(text)",
                .priority: NSAccessibilityPriorityLevel.high.rawValue
            ]
        )
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
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay/1000)) {
                self.muteScreenReaderVoice = false
                self.screenReaderSpeak(text)
            }
        } else {
            screenReaderSpeak(text)
        }
    }
}
