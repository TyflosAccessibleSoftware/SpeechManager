import AVFoundation
import XCTest
@testable import SpeechManager

final class SpeechManagerTests: XCTestCase {
    private final class DelegateSpy: SpeechManagerDelegate {
        var didFinishCount = 0

        func speechManagerDidFinish() {
            didFinishCount += 1
        }
    }

    private let speech = SpeechManager.shared

    override func setUp() {
        super.setUp()
        resetSpeechManager()
    }

    override func tearDown() {
        resetSpeechManager()
        super.tearDown()
    }

    func testSpeakStoresLastConfigurationWithoutUsingRealSynthesizer() {
        speech.accessibilityVoiceEnabled = true

        speech.speak(
            "Hello world!",
            volume: 0.7,
            rate: 0.6,
            pitch: 1.2,
            language: .English,
            voiceId: "voice.id",
            voiceName: "voice name",
            alone: true,
            withAccessibilitySettings: false,
            preDelay: 0.1,
            postDelay: 0.2,
            punctuationVerbosity: .all,
            textFormat: .plainText
        )

        XCTAssertEqual(speech.lastSpeechConfiguration.volume, 0.7)
        XCTAssertEqual(speech.lastSpeechConfiguration.rate, 0.6)
        XCTAssertEqual(speech.lastSpeechConfiguration.pitch, 1.2)
        XCTAssertEqual(speech.lastSpeechConfiguration.language, .English)
        XCTAssertEqual(speech.lastSpeechConfiguration.voiceId, "voice.id")
        XCTAssertEqual(speech.lastSpeechConfiguration.voiceName, "voice name")
        XCTAssertEqual(speech.lastSpeechConfiguration.alone, true)
        XCTAssertEqual(speech.lastSpeechConfiguration.withAccessibilitySettings, false)
        XCTAssertEqual(speech.lastSpeechConfiguration.preDelay, 0.1)
        XCTAssertEqual(speech.lastSpeechConfiguration.postDelay, 0.2)
        XCTAssertEqual(speech.lastSpeechConfiguration.punctuationVerbosity, .all)
        XCTAssertEqual(speech.lastSpeechConfiguration.textFormat, .plainText)
    }

    func testSpeakWithQueueDrainsInOrderWhenUtterancesFinish() {
        speech.accessibilityVoiceEnabled = true
        let expected = ["One", "Two", "Three", "four", "five"]
        var finishedUtterances: [String] = []
        let spy = DelegateSpy()
        speech.delegate = spy
        speech.onUtteranceFinished = { text, _ in
            finishedUtterances.append(text)
        }

        expected.forEach { speech.speakEnqueued($0) }
        expected.forEach {
            speech.speechSynthesizer(speech.synthesizer, didFinish: AVSpeechUtterance(string: $0))
        }

        XCTAssertEqual(finishedUtterances, expected)
        XCTAssertEqual(spy.didFinishCount, 1)
        XCTAssertTrue(speech.queuedText.isEmpty)
        XCTAssertFalse(speech.isDrainingQueue)
    }

    private func resetSpeechManager() {
        speech.stopAndClearQueue()
        speech.delegate = nil
        speech.onSpokenText = nil
        speech.onSpokenTextWithRange = nil
        speech.onFinishedSpokenText = nil
        speech.onFinishedSpokenTextWithRange = nil
        speech.onUtteranceFinished = nil
        speech.onSpeechManagerError = nil
        speech.accessibilityVoiceEnabled = false
        speech.muteStatus = false
        speech.isDrainingQueue = false
        speech.lastSpeechConfiguration = SpeechConfiguration()
        speech.pendingFinishedRanges = [:]
    }
}
