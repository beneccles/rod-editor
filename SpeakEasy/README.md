# SpeakEasy - iPad Accessibility Text Editor

An iPad app designed for individuals with motor tremors affecting typing accuracy. Uses Apple Intelligence to transform imperfect keyboard input into clear, accurate messages.

## Opening the Project

1. Open Xcode (15.0 or later required)
2. Select "Open a project or file"
3. Navigate to this `SpeakEasy` directory
4. Select `SpeakEasy.xcodeproj`

## Building and Running

1. In Xcode, select an iPad simulator (iPad Pro M1+ recommended)
2. Set the target to "Any iOS Device (arm64)" or an iPad simulator
3. Press ⌘+R to build and run

**Important:** The project is configured for **iPadOS 26.0+** and iPad-only deployment.

### Testing Apple Intelligence
- **Foundation Models framework requires a physical iPad** with M1+ chip
- Cannot be tested in simulator
- Must have Apple Intelligence enabled in Settings > Apple Intelligence & Siri
- Device must have sufficient battery (low power mode may disable AI)
- If Foundation Models is unavailable, the app gracefully falls back to mock variations

## Features Implemented

### Core Functionality
- **Text Editor**: Large, accessible text input with configurable font size (20-40pt)
- **Auto-save**: Drafts saved every 10 seconds to local storage
- **Check Button**: Generates 3 AI variations of your text (currently using mock service)
- **Speak Button**: Text-to-speech with customizable voice and speed
- **Clear Button**: Clears text with confirmation dialog

### Accessibility
- All buttons meet minimum touch target sizes:
  - Primary actions (Check, Speak): 100x80pt
  - Secondary actions (Clear): 88x80pt
  - Close buttons: 60x60pt
- Generous 20pt spacing between interactive elements
- VoiceOver labels on all interactive elements
- External keyboard shortcuts:
  - ⌘ + Return: Check text
  - ⌘ + Delete: Clear (with confirmation)
  - ⌘ + S: Speak

### Settings
- Font size adjustment (20-40pt)
- Color scheme (Light/Dark/System)
- Voice selection with preview
- Speech rate control (0.5x - 2.0x)
- All settings persist across sessions

### UI Design
- Follows Apple's design language
- Standard iOS colors (.blue, .red for destructive, system grays)
- Native SwiftUI components
- SF Symbols for all icons

## Implementation Notes

### Apple Intelligence Integration
The `TextCorrectionService` uses **Foundation Models framework** for real-time AI text correction:

**Primary Implementation:**
- Uses `@Generable` guided generation for structured responses
- Sends prompts optimized for tremor-corrected text
- Returns exactly 3 variations using on-device LLM (~3B parameters)

**Fallback:**
- If Foundation Models is unavailable (device doesn't support it, AI disabled, low battery, etc.)
- Gracefully falls back to enhanced mock variations
- No crash, always returns 3 variations

**Variations Generated:**
- Variation 1: Direct correction (closest to literal input)
- Variation 2: Refined phrasing with better grammar/punctuation
- Variation 3: Alternative interpretation if meaning is ambiguous

### Architecture
```
SpeakEasy/
├── App/                    # App entry point and configuration
├── Models/                 # Data structures
├── Services/               # Business logic services
│   ├── StorageService      # Persistence (drafts, settings)
│   ├── SpeechService       # Text-to-speech
│   └── TextCorrectionService # AI variations (mock)
├── ViewModels/             # MVVM view models
├── Views/                  # SwiftUI views
│   ├── EditorView          # Main screen
│   ├── VariationModalView  # AI variations modal
│   ├── SettingsView        # Settings screen
│   └── Components/         # Reusable components
```

## Testing Checklist

### Basic Functionality
- [ ] Type text in editor
- [ ] Tap Check → modal appears with 3 variations
- [ ] Select a variation → text updates
- [ ] Tap Speak → text is spoken aloud
- [ ] Tap Clear → confirmation appears → text clears
- [ ] Wait 10 seconds after typing → draft auto-saves
- [ ] Close and reopen app → draft is restored

### Settings
- [ ] Adjust font size → editor text updates
- [ ] Change theme → UI updates
- [ ] Select different voice → Test Voice button plays sample
- [ ] Adjust speech rate → affects playback speed

### Accessibility
- [ ] Enable VoiceOver → all buttons are labeled correctly
- [ ] Enable Increase Contrast → text remains readable
- [ ] Enable Bold Text → layout doesn't break
- [ ] Try swiping to dismiss modal → should NOT dismiss
- [ ] Test keyboard shortcuts (⌘+Return, ⌘+Delete, ⌘+S)

### Error Handling
- [ ] Tap Check with empty editor → button is disabled
- [ ] Tap Speak with empty editor → button is disabled

## Next Steps

1. ✅ **Apple Intelligence Integration**: COMPLETE - Uses Foundation Models framework
   - See `APPLE_INTELLIGENCE_INTEGRATION.md` for implementation details
   - Guided generation approach with `@Generable` structs
   - Graceful fallback to mock if unavailable
2. **Physical Device Testing**: Test on actual M1+ iPad with Apple Intelligence enabled
3. **Prompt Optimization**: Refine prompts based on real-world usage with tremor patterns
4. **Switch Control Testing**: Verify full compatibility with Switch Control
5. **User Testing**: Test with actual users to refine accessibility features
6. **App Store Preparation**: Add app icon, screenshots, privacy policy

## License

See LICENSE file in repository root.
