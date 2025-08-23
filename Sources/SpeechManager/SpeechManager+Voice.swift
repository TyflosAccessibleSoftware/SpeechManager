import AVFoundation
#if os(macOS)
import AppKit
#elseif os(watchOS)
import UIKit
#else
import UIKit
#endif

extension SpeechManager {
    public var availableLanguages: [String] {
        get {
            let voices = AVSpeechSynthesisVoice.speechVoices()
            var listOfLanguages: Set<String> = []
            for voice in voices {
                listOfLanguages.insert(voice.language)
            }
            return Array(listOfLanguages)
        }
    }
    
    public var availableVoices: [String] {
        get {
            let voices = AVSpeechSynthesisVoice.speechVoices()
            var listOfVoices: [String] = []
            for voice in voices {
                if voice.downloadStatus == .available {
                    listOfVoices.append(voice.longName)
                }
            }
            return listOfVoices
        }
    }
    
    public var availableVoicesByLanguage: [String:[AVSpeechSynthesisVoice]] {
        get {
            var voicesByLanguage: [String:[AVSpeechSynthesisVoice]] = [String:[AVSpeechSynthesisVoice]]()
            let voices = AVSpeechSynthesisVoice.speechVoices()
            for voice in voices {
                if var voicesForLanguage = voicesByLanguage[voice.language] {
                    if voice.downloadStatus == .available {
                        voicesForLanguage.append(voice)
                    }
                    voicesByLanguage[voice.language] = voicesForLanguage
                } else {
                    voicesByLanguage[voice.language] = [voice]
                }
            }
            return voicesByLanguage
        }
    }
    
    public func getVoiceBy(_ longName: String)-> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if voice.longName.lowercased() == longName.lowercased() {
                return voice
            }
        }
        return nil
    }
    
    public func getVoicesBy(_ name: String)-> [AVSpeechSynthesisVoice] {
        var result: [AVSpeechSynthesisVoice] = []
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if voice.name.lowercased() == name.lowercased() {
                result.append(voice)
            }
        }
        return result
    }
    
    public func getVoicesFor(language: String)-> [AVSpeechSynthesisVoice] {
        var result: [AVSpeechSynthesisVoice] = []
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if voice.language.lowercased() == language.lowercased() {
                result.append(voice)
            }
        }
        return result
    }
    
    public func findVoice(matching query: String) -> AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice.speechVoices().first {
            $0.name.localizedCaseInsensitiveContains(query) || $0.longName.localizedCaseInsensitiveContains(query)
        }
    }
    
    public var defaultVoiceLanguage: String {
        let utterance = AVSpeechUtterance(string: "Sample text")
        return utterance.voice?.language ?? ""
    }
    
    public var defaultVoiceName: String {
        let utterance = AVSpeechUtterance(string: "Sample text")
        return utterance.voice?.name ?? ""
    }
    
    public var defaultVoiceLongName: String {
        let utterance = AVSpeechUtterance(string: "Sample text")
        return utterance.voice?.longName ?? ""
    }
    
    public var defaultVoiceVolume: Float {
        let utterance = AVSpeechUtterance(string: "Sample text")
        return utterance.volume
    }
    
    public var defaultVoiceRate: Float {
        let utterance = AVSpeechUtterance(string: "Sample text")
        return utterance.rate
    }
    
    public var defaultVoicepitchMultiplier: Float {
        let utterance = AVSpeechUtterance(string: "Sample text")
        return utterance.pitchMultiplier
    }
}
