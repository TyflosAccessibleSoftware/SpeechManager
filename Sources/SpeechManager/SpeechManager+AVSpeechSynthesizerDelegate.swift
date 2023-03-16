import AVFoundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension SpeechManager {
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if delegate != nil {
            delegate!.speechManagerDidFinish()
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        if delegate != nil {
            delegate!.speechManagerDidStart()
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        if delegate != nil {
            delegate!.speechManagerDidCancel()
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        if delegate != nil {
            delegate!.speechManagerDidPause()
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        if delegate != nil {
            delegate!.speechManagerDidContinue()
        }
    }
}
