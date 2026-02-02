import Foundation
import AVFoundation

/// ViewModel for the settings screen
@MainActor
class SettingsViewModel: ObservableObject {
    private let settingsManager: SettingsManager
    private let storageService: StorageService
    private let speechService: SpeechService

    init(storageService: StorageService, speechService: SpeechService, settingsManager: SettingsManager) {
        self.storageService = storageService
        self.speechService = speechService
        self.settingsManager = settingsManager
    }

    var availableVoices: [AVSpeechSynthesisVoice] {
        speechService.availableVoices
    }

    func saveSettings() {
        settingsManager.saveSettings()
    }

    func testVoice() {
        let testText = "Hello, this is how I will sound."
        speechService.speak(
            text: testText,
            voiceId: settingsManager.settings.selectedVoiceId,
            rate: settingsManager.settings.speechRate
        )
    }

    func stopTestVoice() {
        speechService.stop()
    }

    var isTestingSpeech: Bool {
        speechService.isSpeaking
    }
}
