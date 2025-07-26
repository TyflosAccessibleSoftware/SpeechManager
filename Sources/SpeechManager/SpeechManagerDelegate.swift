import Foundation

public protocol SpeechManagerDelegate: AnyObject {
    func speechManagerDidStart()
    func speechManagerDidFinish()
    func speechManagerDidPause()
    func speechManagerDidContinue()
    func speechManagerDidCancel()
    func speechManager(didRequestUnavailableVoice voice: String)
}

public extension SpeechManagerDelegate {
    func speechManagerDidStart() {}
    func speechManagerDidFinish() {}
    func speechManagerDidPause() {}
    func speechManagerDidContinue() {}
    func speechManagerDidCancel() {}
    func speechManager(didRequestUnavailableVoice voice: String) {}
}
