import SwiftUI

@main
struct SpeakEasyApp: App {
    @StateObject private var storageService = StorageService()
    @StateObject private var speechService = SpeechService()
    @StateObject private var settingsManager = SettingsManager()
    @State private var textCorrectionService = TextCorrectionService()

    var body: some Scene {
        WindowGroup {
            EditorView(
                storageService: storageService,
                textCorrectionService: textCorrectionService,
                speechService: speechService,
                settingsManager: settingsManager
            )
        }
    }
}
