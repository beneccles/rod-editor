import Foundation
import Combine

/// Service for persisting drafts and settings
@MainActor
class StorageService: ObservableObject {
    private let settingsKey = "SpeakEasySettings"
    private let draftFileName = "draft.txt"

    /// Load saved settings from UserDefaults
    func loadSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    /// Save settings to UserDefaults
    func saveSettings(_ settings: AppSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }

    /// Load draft text from file
    func loadDraft() -> String {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return ""
        }

        let draftURL = documentsDirectory.appendingPathComponent(draftFileName)

        guard FileManager.default.fileExists(atPath: draftURL.path),
              let text = try? String(contentsOf: draftURL, encoding: .utf8) else {
            return ""
        }

        return text
    }

    /// Save draft text to file asynchronously
    func saveDraft(_ text: String) async {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let draftURL = documentsDirectory.appendingPathComponent(draftFileName)

        do {
            try text.write(to: draftURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save draft: \(error.localizedDescription)")
        }
    }

    /// Clear the saved draft
    func clearDraft() async {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let draftURL = documentsDirectory.appendingPathComponent(draftFileName)

        if FileManager.default.fileExists(atPath: draftURL.path) {
            try? FileManager.default.removeItem(at: draftURL)
        }
    }
}
