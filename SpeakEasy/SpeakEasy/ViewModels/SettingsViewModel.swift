import Foundation
import AVFoundation

/// ViewModel for the settings screen
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    private let storageService: StorageService
    private let speechService: SpeechService

    init(storageService: StorageService, speechService: SpeechService, initialSettings: AppSettings) {
        self.storageService = storageService
        self.speechService = speechService
        self.settings = initialSettings
    }

    var availableVoices: [AVSpeechSynthesisVoice] {
        speechService.availableVoices
    }

    func saveSettings() {
        storageService.saveSettings(settings)
    }

    func testVoice() {
        let testText = "Hello, this is how I will sound."
        speechService.speak(
            text: testText,
            voiceId: settings.selectedVoiceId,
            rate: settings.speechRate
        )
    }

    func stopTestVoice() {
        speechService.stop()
    }

    var isTestingSpeech: Bool {
        speechService.isSpeaking
    }
}
