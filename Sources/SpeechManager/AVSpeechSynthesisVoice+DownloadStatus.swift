import AVFoundation

public extension AVSpeechSynthesisVoice {
    
    enum VoiceDownloadStatus {
        case available
        case needsDownload
    }
    
    var isInstalledForAVSpeech: Bool {
            AVSpeechSynthesisVoice.speechVoices().contains { $0.identifier == self.identifier }
        }
    
    var downloadStatus: VoiceDownloadStatus {
        let settings = self.audioFileSettings
        if settings.isEmpty {
            return .needsDownload
        }
        if let footprint = settings["AVVoiceAssetFootprint"] as? String, footprint == "AVVoiceAssetFootprintNotRequired" {
            return .available
        }
        return .available
    }
}
