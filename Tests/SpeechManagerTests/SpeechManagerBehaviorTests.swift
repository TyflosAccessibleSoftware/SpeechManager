import XCTest
import AVFoundation
@testable import SpeechManager

final class SpeechManagerBehaviorTests: XCTestCase {
    private final class DelegateSpy: SpeechManagerDelegate {
        var didStartCount = 0
        var didFinishCount = 0
        var didPauseCount = 0
        var didContinueCount = 0
        var didCancelCount = 0
        var unavailableVoices: [String] = []

        func speechManagerDidStart() { didStartCount += 1 }
        func speechManagerDidFinish() { didFinishCount += 1 }
        func speechManagerDidPause() { didPauseCount += 1 }
        func speechManagerDidContinue() { didContinueCount += 1 }
        func speechManagerDidCancel() { didCancelCount += 1 }
        func speechManager(didRequestUnavailableVoice voice: String) { unavailableVoices.append(voice) }
    }

    private let manager = SpeechManager.shared

    override func setUp() {
        super.setUp()
        manager.stopAndClearQueue()
        manager.delegate = nil
        manager.onSpokenText = nil
        manager.onSpokenTextWithRange = nil
        manager.onUtteranceFinished = nil
        manager.accessibilityVoiceEnabled = false
        manager.muteStatus = false
        manager.isDrainingQueue = false
        manager.lastSpeechConfiguration = SpeechConfiguration()
    }

    override func tearDown() {
        manager.stopAndClearQueue()
        manager.delegate = nil
        manager.onSpokenText = nil
        manager.onSpokenTextWithRange = nil
        manager.onUtteranceFinished = nil
        super.tearDown()
    }

    func testMuteSpeechUpdatesMuteStatus() {
        manager.muteSpeech(true)
        XCTAssertTrue(manager.muteStatus)

        manager.muteSpeech(false)
        XCTAssertFalse(manager.muteStatus)
    }

    func testManageQueueWithNoElementsStopsDrainingMode() {
        manager.isDrainingQueue = true
        manager.queuedText = []

        manager.manageQueue()

        XCTAssertFalse(manager.isDrainingQueue)
    }

    func testStopClearsQueueAndDrainingState() {
        manager.queuedText = [
            SpeechQueueElement(text: "one", configuration: nil),
            SpeechQueueElement(text: "two", configuration: nil)
        ]
        manager.isDrainingQueue = true

        manager.stop()

        XCTAssertTrue(manager.queuedText.isEmpty)
        XCTAssertFalse(manager.isDrainingQueue)
    }

    func testClearQueueRemovesAllQueuedElements() {
        manager.queuedText = [
            SpeechQueueElement(text: "one", configuration: nil),
            SpeechQueueElement(text: "two", configuration: SpeechConfiguration(language: .Spanish))
        ]

        manager.clearQueue()

        XCTAssertTrue(manager.queuedText.isEmpty)
    }

    func testStopAndClearQueueClearsQueueAndDrainingState() {
        manager.queuedText = [SpeechQueueElement(text: "queued", configuration: nil)]
        manager.isDrainingQueue = true

        manager.stopAndClearQueue()

        XCTAssertTrue(manager.queuedText.isEmpty)
        XCTAssertFalse(manager.isDrainingQueue)
    }

    func testDidFinishCallsUtteranceClosureAndDelegateWhenQueueIsEmpty() {
        let delegate = DelegateSpy()
        manager.delegate = delegate

        var finishedText: String?
        manager.onUtteranceFinished = { text, _ in
            finishedText = text
        }

        let utterance = AVSpeechUtterance(string: "final text")
        manager.speechSynthesizer(manager.synthesizer, didFinish: utterance)

        XCTAssertEqual(finishedText, "final text")
        XCTAssertEqual(delegate.didFinishCount, 1)
    }

    func testDidFinishDrainsQueuedItemsInsteadOfFinishingDelegate() {
        let delegate = DelegateSpy()
        manager.delegate = delegate
        manager.accessibilityVoiceEnabled = false
        manager.lastSpeechConfiguration = SpeechConfiguration(rate: 0.8, pitch: 1.1, language: .English)
        manager.queuedText = [
            SpeechQueueElement(text: "next", configuration: nil),
            SpeechQueueElement(text: "later", configuration: SpeechConfiguration(language: .Spanish))
        ]

        let utterance = AVSpeechUtterance(string: "current")
        manager.speechSynthesizer(manager.synthesizer, didFinish: utterance)

        XCTAssertEqual(delegate.didFinishCount, 0)
        XCTAssertEqual(manager.queuedText.map(\.text), ["later"])
        XCTAssertEqual(manager.lastSpeechConfiguration.language, .English)
        XCTAssertEqual(manager.lastSpeechConfiguration.rate, 0.8)
    }

    func testDelegateForwardingForLifecycleCallbacks() {
        let delegate = DelegateSpy()
        manager.delegate = delegate
        let utterance = AVSpeechUtterance(string: "sample")

        manager.speechSynthesizer(manager.synthesizer, didStart: utterance)
        manager.speechSynthesizer(manager.synthesizer, didPause: utterance)
        manager.speechSynthesizer(manager.synthesizer, didContinue: utterance)
        manager.speechSynthesizer(manager.synthesizer, didCancel: utterance)

        XCTAssertEqual(delegate.didStartCount, 1)
        XCTAssertEqual(delegate.didPauseCount, 1)
        XCTAssertEqual(delegate.didContinueCount, 1)
        XCTAssertEqual(delegate.didCancelCount, 1)
    }

    func testWillSpeakRangeInvokesBothCallbacksWithExpectedSlices() {
        var spokenRange: NSRange?
        var spokenText: String?
        var prefixResult: String?
        var suffixResult: String?
        let utterance = AVSpeechUtterance(string: "Hello world")
        let range = NSRange(location: 6, length: 5)

        manager.onSpokenTextWithRange = { value, text, _ in
            spokenRange = value
            spokenText = text
        }
        manager.onSpokenText = { prefix, suffix, _ in
            prefixResult = prefix
            suffixResult = suffix
        }

        manager.speechSynthesizer(
            manager.synthesizer,
            willSpeakRangeOfSpeechString: range,
            utterance: utterance
        )

        XCTAssertEqual(spokenRange, range)
        XCTAssertEqual(spokenText, "Hello world")
        XCTAssertEqual(prefixResult, "Hello ")
        XCTAssertEqual(suffixResult, "world")
    }
}
