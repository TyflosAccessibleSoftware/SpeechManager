import Testing
@testable import SpeechManager

struct SpeechConfigurationTests {

    @Test("SpeechConfiguration: valores por defecto")
    func defaults() {
        let c = SpeechConfiguration()

        #expect(c.volume == 1.0)
        #expect(c.rate == 0.5)
        #expect(c.pitch == 1.0)
        #expect(c.language == .unknown)
        #expect(c.voiceName == nil)
        #expect(c.alone == false)
        #expect(c.withAccessibilitySettings == false)
        #expect(c.preDelay == 0.0)
        #expect(c.postDelay == 0.0)
    }

    @Test("SpeechConfiguration: init preserva valores custom")
    func customInit() {
        let c = SpeechConfiguration(
            volume: 0.2,
            rate: 0.9,
            pitch: 1.5,
            language: .Spanish,
            voiceName: "foo",
            alone: true,
            withAccessibilitySettings: true,
            preDelay: 0.3,
            postDelay: 0.7
        )

        #expect(c.volume == 0.2)
        #expect(c.rate == 0.9)
        #expect(c.pitch == 1.5)
        #expect(c.language == .Spanish)
        #expect(c.voiceName == "foo")
        #expect(c.alone == true)
        #expect(c.withAccessibilitySettings == true)
        #expect(c.preDelay == 0.3)
        #expect(c.postDelay == 0.7)
    }
}
