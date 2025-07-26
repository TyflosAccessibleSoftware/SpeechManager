import AVFoundation

public extension AVSpeechSynthesisVoice {
    
    enum VoiceDownloadStatus {
        case available
        case needsDownload
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
