import AVFoundation
import XCTest
@testable import SpeechManager

final class SpeechManagerVoiceAPITests: XCTestCase {
    private let manager = SpeechManager.shared

    func testAvailableLanguagesIsUniqueAndSorted() throws {
        try skipIfNoSpeechVoices()

        let languages = manager.availableLanguages

        XCTAssertEqual(languages, Array(Set(languages)).sorted())
        XCTAssertTrue(languages.allSatisfy { !$0.isEmpty })
    }

    func testInstalledVoicesNotEmpty() throws {
        try skipIfNoSpeechVoices()

        XCTAssertFalse(manager.installedVoices.isEmpty)
    }

    func testAvailableVoicesMatchesInstalledLongNames() throws {
        try skipIfNoSpeechVoices()

        XCTAssertEqual(manager.availableVoices, manager.installedVoices.map(\.longName))
    }

    func testAllVoicesByLanguageGroupsCorrectly() throws {
        try skipIfNoSpeechVoices()

        let grouped = manager.allVoicesByLanguage

        for voice in manager.installedVoices {
            let bucket = grouped[voice.language] ?? []
            XCTAssertTrue(bucket.contains(where: { $0.identifier == voice.identifier }))
        }
    }

    func testAvailableVoicesByLanguageIsFilteredSubset() throws {
        try skipIfNoSpeechVoices()

        let filtered = manager.availableVoicesByLanguage.flatMap { $0.value }
        let installedIDs = Set(manager.installedVoices.map(\.identifier))

        XCTAssertTrue(filtered.allSatisfy { $0.downloadStatus == .available })
        XCTAssertTrue(filtered.allSatisfy { installedIDs.contains($0.identifier) })
    }

    func testGetVoiceById() throws {
        let voice = try requireSpeechVoice()

        let found = manager.getVoiceBy(id: voice.identifier)

        XCTAssertEqual(found?.identifier, voice.identifier)
    }

    func testGetVoiceByLongNameCaseInsensitive() throws {
        let voice = try requireSpeechVoice()

        let found = manager.getVoiceBy(longName: voice.longName.uppercased())

        XCTAssertEqual(found?.identifier, voice.identifier)
    }

    func testGetVoicesByName() throws {
        let voice = try requireSpeechVoice()

        let matches = manager.getVoicesBy(voice.name.uppercased())

        XCTAssertFalse(matches.isEmpty)
        XCTAssertTrue(matches.allSatisfy { $0.name.caseInsensitiveCompare(voice.name) == .orderedSame })
    }

    func testGetVoicesForLanguage() throws {
        let voice = try requireSpeechVoice()

        let matches = manager.getVoicesFor(language: voice.language.uppercased())

        XCTAssertFalse(matches.isEmpty)
        XCTAssertTrue(matches.allSatisfy { $0.language.caseInsensitiveCompare(voice.language) == .orderedSame })
    }

    func testFindVoiceMatching() throws {
        let voice = try requireSpeechVoice()
        let fragment = String(voice.name.prefix(min(3, voice.name.count)))

        let found = manager.findVoice(matching: fragment)

        XCTAssertNotNil(found)
        XCTAssertTrue(
            found?.name.localizedCaseInsensitiveContains(fragment) == true
            || found?.longName.localizedCaseInsensitiveContains(fragment) == true
        )
    }

    func testDefaultVoiceValuesAreCoherent() throws {
        try skipIfNoSpeechVoices()

        let utterance = AVSpeechUtterance(string: "Sample text")

        XCTAssertEqual(manager.defaultVoiceLanguage, utterance.voice?.language ?? "")
        XCTAssertEqual(manager.defaultVoiceName, utterance.voice?.name ?? "")
        XCTAssertEqual(manager.defaultVoiceLongName, utterance.voice?.longName ?? "")
        XCTAssertEqual(manager.defaultVoiceVolume, utterance.volume)
        XCTAssertEqual(manager.defaultVoiceRate, utterance.rate)
        XCTAssertEqual(manager.defaultVoicepitchMultiplier, utterance.pitchMultiplier)
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

    private func skipIfNoSpeechVoices() throws {
#if os(watchOS)
        throw XCTSkip("System voice enumeration is skipped in watchOS tests.")
#else
        try XCTSkipIf(
            AVSpeechSynthesisVoice.speechVoices().isEmpty,
            "No AVSpeechSynthesisVoice entries are available in this test environment."
        )
#endif
    }
}
