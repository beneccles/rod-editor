import Foundation

/// Represents a single AI-generated text variation
struct TextVariation: Identifiable {
    let id: UUID
    let correctedText: String

    init(id: UUID = UUID(), correctedText: String) {
        self.id = id
        self.correctedText = correctedText
    }
}
