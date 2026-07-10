import XCTest
@testable import SpeechManager

final class SpeechConfigurationTests: XCTestCase {
    func testDefaultValues() {
        let configuration = SpeechConfiguration()

        XCTAssertEqual(configuration.volume, 1.0)
        XCTAssertEqual(configuration.rate, 0.5)
        XCTAssertEqual(configuration.pitch, 1.0)
        XCTAssertEqual(configuration.language, .unknown)
        XCTAssertNil(configuration.voiceId)
        XCTAssertNil(configuration.voiceName)
        XCTAssertFalse(configuration.alone)
        XCTAssertFalse(configuration.withAccessibilitySettings)
        XCTAssertEqual(configuration.preDelay, 0.0)
        XCTAssertEqual(configuration.postDelay, 0.0)
        XCTAssertEqual(configuration.punctuationVerbosity, .none)
        XCTAssertEqual(configuration.textFormat, .plainText)
    }

    func testInitPreservesCustomValues() {
        let configuration = SpeechConfiguration(
            volume: 0.2,
            rate: 0.9,
            pitch: 1.5,
            language: .Spanish,
            voiceId: "voice.id",
            voiceName: "foo",
            alone: true,
            withAccessibilitySettings: true,
            preDelay: 0.3,
            postDelay: 0.7,
            punctuationVerbosity: .all,
            textFormat: .ssml
        )

        XCTAssertEqual(configuration.volume, 0.2)
        XCTAssertEqual(configuration.rate, 0.9)
        XCTAssertEqual(configuration.pitch, 1.5)
        XCTAssertEqual(configuration.language, .Spanish)
        XCTAssertEqual(configuration.voiceId, "voice.id")
        XCTAssertEqual(configuration.voiceName, "foo")
        XCTAssertTrue(configuration.alone)
        XCTAssertTrue(configuration.withAccessibilitySettings)
        XCTAssertEqual(configuration.preDelay, 0.3)
        XCTAssertEqual(configuration.postDelay, 0.7)
        XCTAssertEqual(configuration.punctuationVerbosity, .all)
        XCTAssertEqual(configuration.textFormat, .ssml)
    }
}
