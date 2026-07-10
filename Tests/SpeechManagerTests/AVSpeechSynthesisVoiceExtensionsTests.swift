import Testing
import AVFoundation
@testable import SpeechManager

struct AVSpeechSynthesisVoiceExtensionsTests {
    
    @Test("AVSpeechSynthesisVoice.longName: includes name and language",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func longNameContainsNameAndLanguage() throws {
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        
        let ln = voice.longName
        #expect(ln.contains(voice.name))
        #expect(ln.contains("(\(voice.language))"))
    }
    
    @Test("AVSpeechSynthesisVoice.voices(forLanguage:): returns only that language",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func voicesForLanguageFiltersCorrectly() throws {
        let anyVoice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        let lang = anyVoice.language
        
        let voices = AVSpeechSynthesisVoice.voices(forLanguage: lang)
        #expect(voices.isEmpty == false)
        #expect(voices.allSatisfy { $0.language == lang })
    }
    
    @Test("AVSpeechSynthesisVoice.voice(matchingName:): finds by longName",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func voiceMatchingByLongName() throws {
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        
        let found = AVSpeechSynthesisVoice.voice(matchingName: voice.longName)
        #expect(found?.identifier == voice.identifier)
    }
    
    @Test("AVSpeechSynthesisVoice.voice(matchingName:): finds by name",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func voiceMatchingByName() throws {
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        
        let found = AVSpeechSynthesisVoice.voice(matchingName: voice.name)
        #expect(found != nil)
        #expect(found!.name.caseInsensitiveCompare(voice.name) == .orderedSame
                || found!.longName.caseInsensitiveCompare(voice.name) == .orderedSame)
    }
    
    @Test("AVSpeechSynthesisVoice.isInstalledForAVSpeech: true for voices listed by speechVoices()",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func installedFlagIsTrueForListedVoices() throws {
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        #expect(voice.isInstalledForAVSpeech == true)
    }
    
    @Test("AVSpeechSynthesisVoice.downloadStatus: consistent with audioFileSettings",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func downloadStatusIsConsistentWithSettings() throws {
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        let settings = voice.audioFileSettings
        
        let status = voice.downloadStatus
        
        if settings.isEmpty {
            #expect(status == .needsDownload)
        } else if let footprint = settings["AVVoiceAssetFootprint"] as? String,
                  footprint == "AVVoiceAssetFootprintNotRequired" {
            #expect(status == .available)
        } else {
            #expect(status == .needsDownload)
        }
    }
}
