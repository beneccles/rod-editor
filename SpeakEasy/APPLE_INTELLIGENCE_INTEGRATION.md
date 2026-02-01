# Apple Intelligence Integration Guide

## Research Summary

After researching Apple Intelligence APIs, I found **two approaches** for text correction:

### 1. Writing Tools API (Built-in UI)
- **What it is**: System-level text editing features accessible via context menus
- **How it works**: Users select text → access Writing Tools → choose proofreading/rewriting
- **Pros**: Zero implementation needed for standard text fields, automatic UI
- **Cons**: Not programmatically invocable, requires user to manually trigger
- **Availability**: iOS 18.1+, iPadOS 18.1+

### 2. Foundation Models Framework (Programmatic)
- **What it is**: Direct API access to the on-device language model powering Apple Intelligence
- **How it works**: Send prompts to ~3B parameter LLM, receive generated text
- **Pros**: Full programmatic control, can generate multiple variations on demand
- **Cons**: Requires iOS 26+/iPadOS 26+ (not available in iOS 18.1)
- **Availability**: iOS 26+, iPadOS 26+ (released WWDC 2025)

## Recommended Approach for SpeakEasy

**Use Foundation Models Framework** because:
1. We need to programmatically generate variations when "Check" button is tapped
2. We need exactly 3 variations returned at once
3. We need custom prompt engineering to match our use case (tremor-corrected text)
4. Writing Tools doesn't support programmatic triggering

## Implementation Plan

### Step 1: Update Deployment Target
Update `project.pbxproj` to require iPadOS 26.0:
```
IPHONEOS_DEPLOYMENT_TARGET = 26.0;
```

Update `Info.plist` to require iPadOS 26:
```xml
<key>MinimumOSVersion</key>
<string>26.0</string>
```

### Step 2: Import Framework
```swift
import FoundationModels
```

### Step 3: Update TextCorrectionService

Replace the mock implementation with real Foundation Models API:

```swift
import Foundation
import FoundationModels

@MainActor
class TextCorrectionService {
    private let session: LanguageModelSession

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
        // Initialize session with instructions optimized for tremor correction
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

    func generateVariations(for text: String) async throws -> [TextVariation] {
        // Check if Foundation Models is available
        guard await checkAvailability() else {
            throw CorrectionError.appleIntelligenceUnavailable
        }

        let prompt = """
        Input text (typed with tremoring hands): "\(text)"

        Provide 3 corrected variations as specified in your instructions.
        Format as:
        1. [variation 1]
        2. [variation 2]
        3. [variation 3]
        """

        do {
            let response = try await session.respond(to: prompt)
            let variations = parseVariations(from: response.content)

            guard variations.count == 3 else {
                throw CorrectionError.processingFailed
            }

            return variations
        } catch {
            throw CorrectionError.processingFailed
        }
    }

    private func checkAvailability() async -> Bool {
        // Foundation Models requires:
        // - Apple Intelligence-capable device (M1+ iPad)
        // - Apple Intelligence enabled in Settings
        // - Sufficient battery
        // - Not in Game Mode

        // This check would use system APIs to verify availability
        // For now, we'll assume it's available if the framework imports
        return true
    }

    private func parseVariations(from response: String) -> [TextVariation] {
        // Parse the numbered list response
        let lines = response.components(separatedBy: .newlines)
        var variations: [TextVariation] = []

        for line in lines {
            // Match lines starting with "1. ", "2. ", "3. "
            if let match = line.range(of: #"^\d+\.\s+"#, options: .regularExpression) {
                let text = String(line[match.upperBound...]).trimmingCharacters(in: .whitespaces)
                if !text.isEmpty {
                    variations.append(TextVariation(correctedText: text))
                }
            }
        }

        return variations
    }
}
```

### Step 4: Alternative - Guided Generation for Structured Output

For more reliable parsing, use `@Generable` to get structured responses:

```swift
@Generable
struct CorrectionResponse {
    @Guide(description: "Direct correction of typos, staying closest to original input")
    let directCorrection: String

    @Guide(description: "Refined phrasing with improved grammar and punctuation")
    let refinedPhrasing: String

    @Guide(description: "Alternative interpretation if meaning is ambiguous")
    let alternativeInterpretation: String
}

func generateVariations(for text: String) async throws -> [TextVariation] {
    guard await checkAvailability() else {
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
        throw CorrectionError.processingFailed
    }
}
```

### Step 5: Add Streaming Support (Optional)

For better UX, stream partial variations as they generate:

```swift
func streamVariations(for text: String) -> AsyncThrowingStream<TextVariation, Error> {
    AsyncThrowingStream { continuation in
        Task {
            do {
                let prompt = "Correct this text: \"\(text)\""
                let stream = session.streamResponse(
                    to: prompt,
                    generating: CorrectionResponse.self
                )

                for try await partial in stream {
                    // Emit variations as they become available
                    if let direct = partial.directCorrection {
                        continuation.yield(TextVariation(correctedText: direct))
                    }
                    // ... handle other fields
                }

                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}
```

## Device & OS Requirements

### Updated Requirements (Foundation Models)
- **iPadOS 26.0+** (not 18.1 as originally spec'd)
- **Compatible devices**: iPad Pro (M1+), iPad Air (M1+), iPad mini (A17 Pro+)
- **Apple Intelligence enabled** in Settings > Apple Intelligence & Siri
- **Sufficient battery** (low power mode may disable)
- **Not in Game Mode**

### Testing
- **Cannot test in Simulator**: Must use physical device with Apple Intelligence
- **Xcode 26+** required for Foundation Models framework

## Migration Path

### Phase 1: Keep Mock (Current)
- Ship with mock variations for iOS 18.1+ users
- Works in simulator, no physical device needed

### Phase 2: Add Foundation Models (Future)
- Update deployment target to iPadOS 26.0
- Implement real API with fallback to mock for older devices
- Requires physical M1+ iPad for testing

### Hybrid Approach
```swift
func generateVariations(for text: String) async throws -> [TextVariation] {
    if #available(iOS 26.0, *) {
        // Use Foundation Models on iOS 26+
        return try await generateWithFoundationModels(text)
    } else {
        // Fall back to mock on iOS 18.1-25.x
        return await generateMockVariations(text)
    }
}
```

## Performance Considerations

1. **On-device processing**: No network required, fast and private
2. **Session prewarming**: Call `session.prewarm(promptPrefix:)` for faster first response
3. **Token limits**: Default max 200 tokens, adjust via `GenerationOptions.maximumResponseTokens`
4. **Battery impact**: LLM inference is compute-intensive

## Privacy

- All processing happens on-device
- No data sent to Apple servers
- User's text never leaves the iPad
- Aligns perfectly with SpeakEasy's privacy-first design

## Sources

- [Foundation Models Documentation](https://developer.apple.com/documentation/FoundationModels)
- [Generating content with Foundation Models](https://developer.apple.com/documentation/FoundationModels/generating-content-and-performing-tasks-with-foundation-models)
- [Ultimate Guide to Foundation Models](https://azamsharp.com/2025/06/18/the-ultimate-guide-to-the-foundation-models-framework.html)
- [Exploring Foundation Models Framework](https://www.createwithswift.com/exploring-the-foundation-models-framework/)
- [Writing Tools in SwiftUI](https://www.hackingwithswift.com/quick-start/swiftui/how-to-adjust-apple-intelligence-writing-tools-for-text-views)
- [Apple Intelligence Developer Portal](https://developer.apple.com/apple-intelligence/)
