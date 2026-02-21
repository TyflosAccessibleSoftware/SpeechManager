import Testing
import AVFoundation
@testable import SpeechManager

struct SpeechManagerVoiceAPITests {
    
    @Test("SpeechManager.availableLanguages: set único + ordenado",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func availableLanguagesIsUniqueAndSorted() {
        let mgr = SpeechManager.shared
        let langs = mgr.availableLanguages
        
        #expect(langs == Array(Set(langs)).sorted())
        #expect(langs.allSatisfy { !$0.isEmpty })
    }
    
    @Test("SpeechManager.installedVoices: no vacío si speechVoices() no vacío",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func installedVoicesNotEmpty() {
        let mgr = SpeechManager.shared
        #expect(mgr.installedVoices.isEmpty == false)
    }
    
    @Test("SpeechManager.availableVoices == installedVoices.longName",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func availableVoicesMatchesInstalledLongNames() {
        let mgr = SpeechManager.shared
        #expect(mgr.availableVoices == mgr.installedVoices.map(\.longName))
    }
    
    @Test("SpeechManager.allVoicesByLanguage agrupa correctamente",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func allVoicesByLanguageGroupsCorrectly() {
        let mgr = SpeechManager.shared
        let grouped = mgr.allVoicesByLanguage
        
        for v in mgr.installedVoices {
            let bucket = grouped[v.language] ?? []
            #expect(bucket.contains(where: { $0.identifier == v.identifier }))
        }
    }
    
    @Test("SpeechManager.availableVoicesByLanguage: subset de installedVoices con downloadStatus == .available",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func availableVoicesByLanguageIsFilteredSubset() {
        let mgr = SpeechManager.shared
        let filtered = mgr.availableVoicesByLanguage.flatMap { $0.value }
        
        #expect(filtered.allSatisfy { $0.downloadStatus == .available })
        
        let installedIDs = Set(mgr.installedVoices.map(\.identifier))
        #expect(filtered.allSatisfy { installedIDs.contains($0.identifier) })
    }
    
    @Test("getVoiceBy(id:) devuelve la voz correcta",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func getVoiceById() throws {
        let mgr = SpeechManager.shared
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        
        let found = mgr.getVoiceBy(id: voice.identifier)
        #expect(found?.identifier == voice.identifier)
    }
    
    @Test("getVoiceBy(longName:) es case-insensitive",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func getVoiceByLongNameCaseInsensitive() throws {
        let mgr = SpeechManager.shared
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        
        let query = voice.longName.uppercased()
        let found = mgr.getVoiceBy(longName: query)
        #expect(found?.identifier == voice.identifier)
    }
    
    @Test("findVoice(matching:) encuentra por name o longName",
          .enabled(if: !AVSpeechSynthesisVoice.speechVoices().isEmpty))
    func findVoiceMatching() throws {
        let mgr = SpeechManager.shared
        let voice = try #require(AVSpeechSynthesisVoice.speechVoices().first)
        
        let fragment = String(voice.name.prefix(min(3, voice.name.count)))
        let found = mgr.findVoice(matching: fragment)
        
        #expect(found != nil)
        #expect(found!.name.localizedCaseInsensitiveContains(fragment)
                || found!.longName.localizedCaseInsensitiveContains(fragment))
    }
}
