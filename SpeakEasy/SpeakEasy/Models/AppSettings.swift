import Foundation
import SwiftUI

/// User preferences and settings for the SpeakEasy app
struct AppSettings: Codable {
    /// Font size for the text editor (20-40pt)
    var fontSize: CGFloat = 20.0

    /// Preferred color scheme (light/dark/system)
    var colorScheme: ColorSchemePreference = .system

    /// Selected voice identifier for text-to-speech
    var selectedVoiceId: String?

    /// Speech rate (0.5x - 2.0x)
    var speechRate: Float = 1.0

    /// Default settings
    static var `default`: AppSettings {
        AppSettings()
    }
}

/// Color scheme preference that's Codable
enum ColorSchemePreference: String, Codable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var uiColorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
