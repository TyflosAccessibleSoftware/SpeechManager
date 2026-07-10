import Foundation

public protocol SpeechManagerDelegate: AnyObject {
    func speechManagerDidStart()
    func speechManagerDidFinish()
    func speechManagerDidPause()
    func speechManagerDidContinue()
    func speechManagerDidCancel()
    func speechManager(didRequestUnavailableVoice voice: String)
    func speechManager(didFailWith error: SpeechManagerError)
    func speechManager(didFinishSpeakingRange range: NSRange, in text: String)
}

public extension SpeechManagerDelegate {
    func speechManagerDidStart() {}
    func speechManagerDidFinish() {}
    func speechManagerDidPause() {}
    func speechManagerDidContinue() {}
    func speechManagerDidCancel() {}
    func speechManager(didRequestUnavailableVoice voice: String) {}
    func speechManager(didFailWith error: SpeechManagerError) {}
    func speechManager(didFinishSpeakingRange range: NSRange, in text: String) {}
}
