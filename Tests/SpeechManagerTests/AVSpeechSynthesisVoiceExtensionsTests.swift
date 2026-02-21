import Testing
import AVFoundation
@testable import SpeechManager

struct AVSpeechSynthesisVoiceExtensionsTests {
    
    @Test("AVSpeechSynthesisVoice.longName: incluye name e idioma",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func longNameContainsNameAndLanguage() throws {
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        
        let ln = voice.longName
        #expect(ln.contains(voice.name))
        #expect(ln.contains("(\(voice.language))"))
    }
    
    @Test("AVSpeechSynthesisVoice.voices(forLanguage:): devuelve solo ese idioma",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func voicesForLanguageFiltersCorrectly() throws {
        let anyVoice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        let lang = anyVoice.language
        
        let voices = AVSpeechSynthesisVoice.voices(forLanguage: lang)
        #expect(voices.isEmpty == false)
        #expect(voices.allSatisfy { $0.language == lang })
    }
    
    @Test("AVSpeechSynthesisVoice.voice(matchingName:): encuentra por longName",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func voiceMatchingByLongName() throws {
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        
        let found = AVSpeechSynthesisVoice.voice(matchingName: voice.longName)
        #expect(found?.identifier == voice.identifier)
    }
    
    @Test("AVSpeechSynthesisVoice.voice(matchingName:): encuentra por name (si hay match único al principio)",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func voiceMatchingByName() throws {
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        
        let found = AVSpeechSynthesisVoice.voice(matchingName: voice.name)
        #expect(found != nil)
        #expect(found!.name.caseInsensitiveCompare(voice.name) == .orderedSame
                || found!.longName.caseInsensitiveCompare(voice.name) == .orderedSame)
    }
    
    @Test("AVSpeechSynthesisVoice.isInstalledForAVSpeech: true para voces listadas por speechVoices()",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func installedFlagIsTrueForListedVoices() throws {
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        #expect(voice.isInstalledForAVSpeech == true)
    }
    
    @Test("AVSpeechSynthesisVoice.downloadStatus: coherencia con audioFileSettings (propiedad computada)",
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
