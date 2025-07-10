import Foundation

public protocol SpeechManagerDelegate {
    func speechManagerDidStart()
    func speechManagerDidFinish()
    func speechManagerDidPause()
    func speechManagerDidContinue()
    func speechManagerDidCancel()
}

public extension SpeechManagerDelegate {
    func speechManagerDidStart() {}
    func speechManagerDidFinish() {}
    func speechManagerDidPause() {}
    func speechManagerDidContinue() {}
    func speechManagerDidCancel() {}
}
