import XCTest
@testable import SpeechManager

final class SpeechManagerTests: XCTestCase {
    private final class DelegateSpy: SpeechManagerDelegate {
        var didFinishCount = 0
        private let finished: XCTestExpectation
        
        init(finished: XCTestExpectation) {
            self.finished = finished
        }
        
        func speechManagerDidFinish() {
            didFinishCount += 1
            finished.fulfill()
        }
    }
    
    
    
    func testSpeak_simple() {
        let speech = SpeechManager.shared
        speech.accessibilityVoiceEnabled = false
        
        let finishedExpectation = expectation(description: "SpeechManager delegate didFinish called")
        let spy = DelegateSpy(finished: finishedExpectation)
        speech.delegate = spy
        
        DispatchQueue.main.async {
            speech.speak(
                "Hello world!",
                rate: 0.6,
                preDelay: 0.0,
                postDelay: 0.0
            )
        }
        
        // Assert
        wait(for: [finishedExpectation], timeout: 5.0)
        
        speech.stopAndClearQueue()
        speech.delegate = nil
    }
    
    func testSpeak_with_qewe() async {
        let speech = SpeechManager.shared
        speech.accessibilityVoiceEnabled = false
        speech.stopAndClearQueue()
        
        defer {
            speech.stopAndClearQueue()
            speech.delegate = nil
            speech.onSpokenText = nil
            speech.onSpokenTextWithRange = nil
        }
        let expected = ["One", "Two", "Three", "four", "five"]
        var finishedUtterances: [String] = []
        let allUtterancesFinished = expectation(description: "All enqueued utterances finished")
        allUtterancesFinished.expectedFulfillmentCount = expected.count
        let finishedExpectation = expectation(description: "Delegate didFinish called once at end")
        let spy = DelegateSpy(finished: finishedExpectation)
        speech.delegate = spy
        speech.onUtteranceFinished = { text, utterance in
            finishedUtterances.append(text)
            allUtterancesFinished.fulfill()
        }
        await MainActor.run {
            expected.forEach { speech.speakEnqueued($0) }
        }
        await fulfillment(of: [allUtterancesFinished, finishedExpectation], timeout: 10.0)
        // Assert
        XCTAssertEqual(finishedUtterances, expected, "The order is not the same. Result = \(finishedUtterances)")
        XCTAssertEqual(spy.didFinishCount, 1, "More than one call to didFinish")
        XCTAssertTrue(speech.queuedText.isEmpty, "The quewe is not empty")
    }
}
