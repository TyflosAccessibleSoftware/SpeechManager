import Testing
@testable import SpeechManager

struct SpeechLanguageTests {

    @Test("SpeechLanguage: rawValue de unknown es vacío")
    func unknownIsEmpty() {
        #expect(SpeechLanguage.unknown.rawValue == "")
    }

    @Test("SpeechLanguage: rawValues conocidos (smoke test)")
    func knownRawValues() {
        #expect(SpeechLanguage.Spanish.rawValue == "es-ES")
        #expect(SpeechLanguage.English.rawValue == "en-US")
        #expect(SpeechLanguage.French.rawValue == "fr-FR")
        #expect(SpeechLanguage.PortugueseBrazil.rawValue == "pt-BR")
    }
}
