import SwiftUI

/// Main editor screen with text input and action buttons
struct EditorView: View {
    @StateObject private var viewModel: EditorViewModel
    @State private var showingSettings = false
    let settings: AppSettings

    init(
        storageService: StorageService,
        textCorrectionService: TextCorrectionService,
        speechService: SpeechService,
        settings: AppSettings
    ) {
        self.settings = settings
        self._viewModel = StateObject(wrappedValue: EditorViewModel(
            storageService: storageService,
            textCorrectionService: textCorrectionService,
            speechService: speechService,
            settings: settings
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("SpeakEasy")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Settings")
            }
            .padding()
            .background(Color(.systemBackground))

            Divider()

            // Text Editor
            TextEditor(text: $viewModel.currentText)
                .font(.system(size: settings.fontSize))
                .padding()
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
                .accessibilityLabel("Message editor")
                .accessibilityHint("Type your message here")

            Divider()

            // Button Bar
            HStack(spacing: 20) {
                AccessibleButton(
                    label: "Clear",
                    systemImage: "xmark.circle",
                    action: viewModel.showClearConfirmation,
                    size: .secondary,
                    isDestructive: true
                )
                .keyboardShortcut(.delete, modifiers: .command)

                AccessibleButton(
                    label: "Check",
                    systemImage: viewModel.isCheckingText ? "hourglass" : "checkmark.circle",
                    action: viewModel.checkText,
                    size: .primary,
                    isDisabled: viewModel.isTextEmpty || viewModel.isCheckingText
                )
                .keyboardShortcut(.return, modifiers: .command)

                AccessibleButton(
                    label: viewModel.isSpeaking ? "Stop" : "Speak",
                    systemImage: viewModel.isSpeaking ? "speaker.slash" : "speaker.wave.2",
                    action: viewModel.speak,
                    size: .primary,
                    isDisabled: viewModel.isTextEmpty
                )
                .keyboardShortcut("s", modifiers: .command)
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(
                storageService: StorageService(),
                speechService: SpeechService(),
                initialSettings: settings
            )
        }
        .sheet(isPresented: $viewModel.showingVariationModal) {
            VariationModalView(
                variations: viewModel.variations,
                isLoading: viewModel.isCheckingText,
                errorMessage: viewModel.errorMessage,
                onSelectVariation: viewModel.selectVariation,
                onTryAgain: viewModel.retryVariations,
                onClose: { viewModel.showingVariationModal = false }
            )
        }
        .alert("Clear your message?", isPresented: $viewModel.showingClearConfirmation) {
            Button("Keep Writing", role: .cancel) {}
            Button("Clear", role: .destructive, action: viewModel.clearText)
        }
        .preferredColorScheme(settings.colorScheme.uiColorScheme)
    }
}
