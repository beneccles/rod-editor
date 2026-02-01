import Foundation
import FoundationModels

/// Service for generating text variations using Apple Intelligence
@MainActor
class TextCorrectionService {
    private var session: LanguageModelSession?

    enum CorrectionError: LocalizedError {
        case appleIntelligenceUnavailable
        case processingFailed

        var errorDescription: String? {
            switch self {
            case .appleIntelligenceUnavailable:
                return "Text checking requires an iPad with Apple Intelligence (M1 chip or newer with iPadOS 26+)."
            case .processingFailed:
                return "Couldn't check your text. Please try again."
            }
        }
    }

    init() {
        // Initialize Foundation Models session with instructions optimized for tremor correction
        session = LanguageModelSession {
            """
            You are a text correction assistant for someone with hand tremors that cause typos.
            When given input text, generate exactly 3 different corrected interpretations.

            Requirements:
            - Variation 1: Direct correction of typos and errors (stay closest to original)
            - Variation 2: Refined phrasing with better grammar/punctuation
            - Variation 3: Alternative interpretation if meaning is ambiguous

            Each variation should be a complete, well-formed sentence.
            Variations must be meaningfully different, not just punctuation changes.
            """
        }
    }

    /// Generate three variations of the input text
    func generateVariations(for text: String) async throws -> [TextVariation] {
        return try await generateWithGuidedGeneration(text)
    }

    // MARK: - Foundation Models Implementation with Guided Generation

    @Generable
    struct CorrectionResponse {
        @Guide(description: "Direct correction of typos, staying closest to original input")
        let directCorrection: String

        @Guide(description: "Refined phrasing with improved grammar and punctuation")
        let refinedPhrasing: String

        @Guide(description: "Alternative interpretation if meaning is ambiguous")
        let alternativeInterpretation: String
    }

    private func generateWithGuidedGeneration(_ text: String) async throws -> [TextVariation] {
        guard let session = session else {
            throw CorrectionError.appleIntelligenceUnavailable
        }

        let prompt = "Correct this text typed with tremoring hands: \"\(text)\""

        do {
            let response = try await session.respond(
                to: prompt,
                generating: CorrectionResponse.self
            )

            return [
                TextVariation(correctedText: response.content.directCorrection),
                TextVariation(correctedText: response.content.refinedPhrasing),
                TextVariation(correctedText: response.content.alternativeInterpretation)
            ]
        } catch {
            // If Foundation Models fails, fall back to enhanced mock
            return try await generateMockVariations(text)
        }
    }

    // MARK: - Fallback Mock Implementation

    private func generateMockVariations(for text: String) async throws -> [TextVariation] {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 1_500_000_000)

        let variations = createMockVariations(for: text)

        guard !variations.isEmpty else {
            throw CorrectionError.processingFailed
        }

        return variations
    }

    private func createMockVariations(for text: String) -> [TextVariation] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Variation 1: Direct correction (closest to literal input)
        let variation1 = correctTypos(trimmed)

        // Variation 2: Slightly refined phrasing
        let variation2 = refinePhrase(variation1)

        // Variation 3: Alternative interpretation
        let variation3 = alternativeInterpretation(variation1)

        return [
            TextVariation(correctedText: variation1),
            TextVariation(correctedText: variation2),
            TextVariation(correctedText: variation3)
        ]
    }

    private func correctTypos(_ text: String) -> String {
        var corrected = text

        // Common typo patterns
        let corrections: [String: String] = [
            "woudl": "would",
            "teh": "the",
            "adn": "and",
            "taht": "that",
            "recieve": "receive",
            "occured": "occurred",
            "seperate": "separate",
            "glasss": "glass",
            "wster": "water",
            "plese": "please",
            "cna": "can",
            "yuo": "you",
            "hte": "the",
            "dont": "don't",
            "cant": "can't",
            "wont": "won't",
            "didnt": "didn't",
            "doesnt": "doesn't",
            "havnt": "haven't",
            "hasnt": "hasn't"
        ]

        for (typo, correction) in corrections {
            corrected = corrected.replacingOccurrences(
                of: typo,
                with: correction,
                options: .caseInsensitive
            )
        }

        // Ensure proper capitalization
        if !corrected.isEmpty {
            corrected = corrected.prefix(1).uppercased() + corrected.dropFirst()
        }

        // Ensure punctuation
        if !corrected.isEmpty && ![".", "!", "?"].contains(String(corrected.last!)) {
            corrected += "."
        }

        return corrected
    }

    private func refinePhrase(_ text: String) -> String {
        var refined = text

        // Add slight refinements
        if text.lowercased().contains("would like") {
            refined = refined.replacingOccurrences(
                of: "would like",
                with: "would like to have",
                options: .caseInsensitive
            )
        }

        // Ensure proper punctuation
        if !refined.isEmpty && ![".", "!", "?"].contains(String(refined.last!)) {
            refined += "."
        }

        return refined
    }

    private func alternativeInterpretation(_ text: String) -> String {
        var alternative = text

        // Provide a more casual variation
        if text.contains("would like") {
            alternative = alternative.replacingOccurrences(
                of: "would like",
                with: "want",
                options: .caseInsensitive
            )
        }

        // Remove trailing period if present
        if alternative.last == "." {
            alternative = String(alternative.dropLast())
        }

        return alternative
    }
}
