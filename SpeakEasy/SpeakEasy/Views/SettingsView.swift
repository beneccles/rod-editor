import SwiftUI
import AVFoundation

/// Settings screen for customizing app preferences
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SettingsViewModel

    init(storageService: StorageService, speechService: SpeechService, initialSettings: AppSettings) {
        self._viewModel = StateObject(wrappedValue: SettingsViewModel(
            storageService: storageService,
            speechService: speechService,
            initialSettings: initialSettings
        ))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("DISPLAY") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Text Size")
                            .font(.headline)
                        HStack {
                            Text("20pt")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Slider(value: $viewModel.settings.fontSize, in: 20...40, step: 1)
                            Text("40pt")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text("\(Int(viewModel.settings.fontSize))pt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)

                    Picker("Theme", selection: $viewModel.settings.colorScheme) {
                        ForEach(ColorSchemePreference.allCases, id: \.self) { scheme in
                            Text(scheme.rawValue).tag(scheme)
                        }
                    }
                }

                Section("VOICE") {
                    Picker("Voice", selection: $viewModel.settings.selectedVoiceId) {
                        Text("Default").tag(String?.none)
                        ForEach(groupedVoices.keys.sorted(), id: \.self) { language in
                            Section(header: Text(language)) {
                                ForEach(groupedVoices[language] ?? [], id: \.identifier) { voice in
                                    Text(voice.name).tag(String?.some(voice.identifier))
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Speed")
                            .font(.headline)
                        HStack {
                            Text("0.5x")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Slider(value: $viewModel.settings.speechRate, in: 0.5...2.0, step: 0.1)
                            Text("2.0x")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(String(format: "%.1fx", viewModel.settings.speechRate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)

                    Button(action: {
                        if viewModel.isTestingSpeech {
                            viewModel.stopTestVoice()
                        } else {
                            viewModel.testVoice()
                        }
                    }) {
                        HStack {
                            Image(systemName: viewModel.isTestingSpeech ? "stop.fill" : "play.fill")
                            Text(viewModel.isTestingSpeech ? "Stop Test" : "Test Voice")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(viewModel.isTestingSpeech ? "Stop testing voice" : "Test voice")
                }

                Section("ABOUT") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        viewModel.saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var groupedVoices: [String: [AVSpeechSynthesisVoice]] {
        Dictionary(grouping: viewModel.availableVoices) { voice in
            Locale.current.localizedString(forLanguageCode: voice.language) ?? voice.language
        }
    }
}
