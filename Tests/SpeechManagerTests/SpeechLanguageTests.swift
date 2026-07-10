import Testing
@testable import SpeechManager

struct SpeechLanguageTests {

    @Test("SpeechLanguage: unknown rawValue is empty")
    func unknownIsEmpty() {
        #expect(SpeechLanguage.unknown.rawValue == "")
    }

    @Test("SpeechLanguage: known rawValues smoke test")
    func knownRawValues() {
        #expect(SpeechLanguage.Spanish.rawValue == "es-ES")
        #expect(SpeechLanguage.English.rawValue == "en-US")
        #expect(SpeechLanguage.French.rawValue == "fr-FR")
        #expect(SpeechLanguage.PortugueseBrazil.rawValue == "pt-BR")
    }
}
