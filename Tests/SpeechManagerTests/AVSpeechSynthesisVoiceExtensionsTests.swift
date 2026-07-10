import AVFoundation
import XCTest
@testable import SpeechManager

final class AVSpeechSynthesisVoiceExtensionsTests: XCTestCase {
    func testLongNameContainsNameAndLanguage() throws {
        let voice = try requireSpeechVoice()

        let longName = voice.longName
        XCTAssertTrue(longName.contains(voice.name))
        XCTAssertTrue(longName.contains("(\(voice.language))"))
    }

    func testVoicesForLanguageFiltersCorrectly() throws {
        let voice = try requireSpeechVoice()
        let language = voice.language

        let voices = AVSpeechSynthesisVoice.voices(forLanguage: language)

        XCTAssertFalse(voices.isEmpty)
        XCTAssertTrue(voices.allSatisfy { $0.language == language })
    }

    func testVoiceMatchingByLongName() throws {
        let voice = try requireSpeechVoice()

        let found = AVSpeechSynthesisVoice.voice(matchingName: voice.longName)

        XCTAssertEqual(found?.identifier, voice.identifier)
    }

    func testVoiceMatchingByName() throws {
        let voice = try requireSpeechVoice()

        let found = AVSpeechSynthesisVoice.voice(matchingName: voice.name)

        XCTAssertNotNil(found)
        XCTAssertTrue(
            found?.name.caseInsensitiveCompare(voice.name) == .orderedSame
            || found?.longName.caseInsensitiveCompare(voice.name) == .orderedSame
        )
    }

    func testInstalledFlagIsTrueForListedVoices() throws {
        let voice = try requireSpeechVoice()

        XCTAssertTrue(voice.isInstalledForAVSpeech)
    }

    func testDownloadStatusIsConsistentWithSettings() throws {
        let voice = try requireSpeechVoice()
#if os(watchOS)
        throw XCTSkip("Voice asset settings are not exercised in watchOS tests.")
#else
        let settings = voice.audioFileSettings

        let status = voice.downloadStatus

        if settings.isEmpty {
            XCTAssertEqual(status, .needsDownload)
        } else if let footprint = settings["AVVoiceAssetFootprint"] as? String,
                  footprint == "AVVoiceAssetFootprintNotRequired" {
            XCTAssertEqual(status, .available)
        } else {
            XCTAssertEqual(status, .needsDownload)
        }
#endif
    }

    private func requireSpeechVoice() throws -> AVSpeechSynthesisVoice {
#if os(watchOS)
        throw XCTSkip("System voice enumeration is skipped in watchOS tests.")
#else
        let voices = AVSpeechSynthesisVoice.speechVoices()
        try XCTSkipIf(voices.isEmpty, "No AVSpeechSynthesisVoice entries are available in this test environment.")
        return try XCTUnwrap(voices.first)
#endif
    }
}
