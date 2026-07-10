import XCTest
@testable import SpeechManager

final class SpeechLanguageTests: XCTestCase {
    func testUnknownRawValueIsEmpty() {
        XCTAssertEqual(SpeechLanguage.unknown.rawValue, "")
    }

    func testKnownRawValues() {
        XCTAssertEqual(SpeechLanguage.Spanish.rawValue, "es-ES")
        XCTAssertEqual(SpeechLanguage.English.rawValue, "en-US")
        XCTAssertEqual(SpeechLanguage.French.rawValue, "fr-FR")
        XCTAssertEqual(SpeechLanguage.PortugueseBrazil.rawValue, "pt-BR")
    }
}
