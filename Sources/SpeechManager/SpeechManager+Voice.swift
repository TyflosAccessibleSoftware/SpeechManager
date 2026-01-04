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
        let voices = AVSpeechSynthesisVoice.speechVoices()
        return Array(Set(voices.map(\.language))).sorted()
    }
    
    public var installedVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .sorted {
                if $0.language != $1.language { return $0.language < $1.language }
                if $0.quality != $1.quality { return $0.quality.rawValue > $1.quality.rawValue }
                return $0.longName.localizedCaseInsensitiveCompare($1.longName) == .orderedAscending
            }
    }
    
    public var availableVoices: [String] {
        installedVoices.map(\.longName)
    }
    
    public var allVoicesByLanguage: [String:[AVSpeechSynthesisVoice]] {
        Dictionary(grouping: installedVoices, by: \.language)
    }
    
    public var availableVoicesByLanguage: [String:[AVSpeechSynthesisVoice]] {
        get {
            var voicesByLanguage: [String:[AVSpeechSynthesisVoice]] = [String:[AVSpeechSynthesisVoice]]()
            let voices = installedVoices
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
