import AVFoundation
import Combine

/// Service for text-to-speech functionality
@MainActor
class SpeechService: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    /// Whether speech is currently active
    @Published var isSpeaking = false

    /// All available voices on the device
    @Published var availableVoices: [AVSpeechSynthesisVoice] = []

    override init() {
        super.init()
        synthesizer.delegate = self
        loadAvailableVoices()
    }

    /// Load all available voices from the system
    private func loadAvailableVoices() {
        availableVoices = AVSpeechSynthesisVoice.speechVoices()
    }

    /// Speak the given text with the specified settings
    func speak(text: String, voiceId: String?, rate: Float) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        guard !text.isEmpty else { return }

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate

        // Set voice if specified
        if let voiceId = voiceId,
           let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
            utterance.voice = voice
        }

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Stop speaking
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}
