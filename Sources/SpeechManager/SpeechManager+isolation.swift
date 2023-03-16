import Foundation


extension SpeechManager {
    public func startVoiceTimerService() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            if self.synthesizer.isSpeaking && self.muteScreenReaderVoice {
                self.stopWithScreenReader()
            } else if self.timeToUnmuteVoiceOver > 0 {
                self.timeToUnmuteVoiceOver -= 1
                self.stopWithScreenReader()
            }
            if self.voiceTimerService == false {
                timer.invalidate()
            }
        })
    }
    
    public func stopVoiceTimerService() {
        voiceTimerService = false
    }
}
