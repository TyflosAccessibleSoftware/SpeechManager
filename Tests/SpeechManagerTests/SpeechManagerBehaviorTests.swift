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
        manager.onFinishedSpokenText = nil
        manager.onFinishedSpokenTextWithRange = nil
        manager.onUtteranceFinished = nil
        manager.onSpeechManagerError = nil
        manager.accessibilityVoiceEnabled = false
        manager.muteStatus = false
        manager.isDrainingQueue = false
        manager.lastSpeechConfiguration = SpeechConfiguration()
        manager.pendingFinishedRanges = [:]
    }

    override func tearDown() {
        manager.stopAndClearQueue()
        manager.delegate = nil
        manager.onSpokenText = nil
        manager.onSpokenTextWithRange = nil
        manager.onFinishedSpokenText = nil
        manager.onFinishedSpokenTextWithRange = nil
        manager.onUtteranceFinished = nil
        manager.onSpeechManagerError = nil
        manager.pendingFinishedRanges = [:]
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

    func testSpeakSSMLEnqueuedStoresSSMLConfiguration() {
        manager.isDrainingQueue = true
        let configuration = SpeechConfiguration(language: .Spanish, punctuationVerbosity: .all)

        manager.speakSSMLEnqueued("<speak>Hello</speak>", configuration: configuration)

        XCTAssertEqual(manager.queuedText.count, 1)
        XCTAssertEqual(manager.queuedText.first?.text, "<speak>Hello</speak>")
        XCTAssertEqual(manager.queuedText.first?.configuration?.textFormat, .ssml)
        XCTAssertEqual(manager.queuedText.first?.configuration?.language, .Spanish)
        XCTAssertEqual(manager.queuedText.first?.configuration?.punctuationVerbosity, .all)
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

    func testWillSpeakRangeCompletesPreviousRangeWhenNextRangeStarts() {
        var finishedRange: NSRange?
        var finishedText: String?
        var completedPrefix: String?
        var remainingSuffix: String?
        let utterance = AVSpeechUtterance(string: "Hello world")

        manager.onFinishedSpokenTextWithRange = { range, text, _ in
            finishedRange = range
            finishedText = text
        }
        manager.onFinishedSpokenText = { prefix, suffix, _ in
            completedPrefix = prefix
            remainingSuffix = suffix
        }

        manager.speechSynthesizer(
            manager.synthesizer,
            willSpeakRangeOfSpeechString: NSRange(location: 0, length: 5),
            utterance: utterance
        )
        manager.speechSynthesizer(
            manager.synthesizer,
            willSpeakRangeOfSpeechString: NSRange(location: 6, length: 5),
            utterance: utterance
        )

        XCTAssertEqual(finishedRange, NSRange(location: 0, length: 5))
        XCTAssertEqual(finishedText, "Hello world")
        XCTAssertEqual(completedPrefix, "Hello")
        XCTAssertEqual(remainingSuffix, " world")
    }

    func testDidFinishFlushesLastPendingRange() {
        var finishedRanges: [NSRange] = []
        let utterance = AVSpeechUtterance(string: "Hello world")
        manager.onFinishedSpokenTextWithRange = { range, _, _ in
            finishedRanges.append(range)
        }

        manager.speechSynthesizer(
            manager.synthesizer,
            willSpeakRangeOfSpeechString: NSRange(location: 0, length: 5),
            utterance: utterance
        )
        manager.speechSynthesizer(
            manager.synthesizer,
            willSpeakRangeOfSpeechString: NSRange(location: 6, length: 5),
            utterance: utterance
        )
        manager.speechSynthesizer(manager.synthesizer, didFinish: utterance)

        XCTAssertEqual(finishedRanges, [
            NSRange(location: 0, length: 5),
            NSRange(location: 6, length: 5)
        ])
    }

    func testMakeUtteranceAppliesPlainTextPunctuationVerbosity() {
        let utterance = manager.makeUtterance(
            from: "Hello, world!",
            textFormat: .plainText,
            punctuationVerbosity: .all,
            language: .English
        )

        XCTAssertEqual(utterance.speechString, "Hello comma world exclamation mark")
    }
}
