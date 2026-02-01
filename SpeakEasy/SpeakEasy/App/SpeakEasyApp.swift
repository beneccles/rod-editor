import SwiftUI

@main
struct SpeakEasyApp: App {
    @StateObject private var storageService = StorageService()
    @StateObject private var speechService = SpeechService()
    @State private var textCorrectionService = TextCorrectionService()
    @State private var settings = AppSettings.default

    init() {
        // Load settings on app launch
        let service = StorageService()
        _settings = State(initialValue: service.loadSettings())
    }

    var body: some Scene {
        WindowGroup {
            EditorView(
                storageService: storageService,
                textCorrectionService: textCorrectionService,
                speechService: speechService,
                settings: settings
            )
        }
    }
}
