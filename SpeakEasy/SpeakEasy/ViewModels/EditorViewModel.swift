import Foundation
import Combine

/// ViewModel for the main editor screen
@MainActor
class EditorViewModel: ObservableObject {
    @Published var currentText: String = "" {
        didSet {
            scheduleAutoSave()
        }
    }

    @Published var isCheckingText = false
    @Published var variations: [TextVariation] = []
    @Published var showingVariationModal = false
    @Published var showingClearConfirmation = false
    @Published var errorMessage: String?

    private let storageService: StorageService
    private let textCorrectionService: TextCorrectionService
    private let speechService: SpeechService
    private let settingsManager: SettingsManager
    private var autoSaveTask: Task<Void, Never>?

    init(
        storageService: StorageService,
        textCorrectionService: TextCorrectionService,
        speechService: SpeechService,
        settingsManager: SettingsManager
    ) {
        self.storageService = storageService
        self.textCorrectionService = textCorrectionService
        self.speechService = speechService
        self.settingsManager = settingsManager

        // Load saved draft
        self.currentText = storageService.loadDraft()
    }

    var isTextEmpty: Bool {
        currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isSpeaking: Bool {
        speechService.isSpeaking
    }

    // MARK: - Actions

    func checkText() {
        guard !isTextEmpty else { return }

        isCheckingText = true
        errorMessage = nil

        Task {
            do {
                variations = try await textCorrectionService.generateVariations(for: currentText)
                showingVariationModal = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isCheckingText = false
        }
    }

    func selectVariation(_ variation: TextVariation) {
        currentText = variation.correctedText
        showingVariationModal = false
        variations = []
    }

    func retryVariations() {
        checkText()
    }

    func showClearConfirmation() {
        showingClearConfirmation = true
    }

    func clearText() {
        currentText = ""
        showingClearConfirmation = false

        Task {
            await storageService.clearDraft()
        }
    }

    func speak() {
        guard !isTextEmpty else { return }

        if speechService.isSpeaking {
            speechService.stop()
        } else {
            speechService.speak(
                text: currentText,
                voiceId: settingsManager.settings.selectedVoiceId,
                rate: settingsManager.settings.speechRate
            )
        }
    }

    // MARK: - Auto-save

    private func scheduleAutoSave() {
        // Cancel previous auto-save task
        autoSaveTask?.cancel()

        // Schedule new auto-save task (10 seconds)
        autoSaveTask = Task {
            try? await Task.sleep(nanoseconds: 10_000_000_000)

            if !Task.isCancelled {
                await storageService.saveDraft(currentText)
            }
        }
    }
}
