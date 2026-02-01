# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SpeakEasy** is a native iPadOS accessibility text editor designed for individuals with motor tremors affecting typing accuracy. The app serves as a communication tool by transforming imperfect keyboard input into clear, accurate messages using Apple Intelligence, which can then be displayed or spoken aloud via text-to-speech.

**Platform:** iPadOS 26.0+ (requires Foundation Models framework)
**Compatible Devices:** iPad Pro (M1+), iPad Air (M1+), iPad mini (A17 Pro+)

## Core Architecture Principles

### Design Philosophy
1. **Dignity first** — The user is intelligent; their hands shake. Never patronize
2. **Tolerance for error** — Assume every tap might land slightly off-target
3. **No rushing** — No timeouts, no auto-dismiss, no penalties for taking time
4. **Predictable layout** — Elements never move or reflow unexpectedly
5. **Clear communication** — This app IS the user's voice; accuracy matters

### Technical Stack
- **UI Framework:** SwiftUI (preferred for declarative UI and built-in accessibility)
- **Text Correction:** Foundation Models framework (FoundationModels) with guided generation
- **Text-to-Speech:** AVFoundation (AVSpeechSynthesizer)
- **Data Persistence:** UserDefaults (preferences), FileManager (draft auto-save)
- **Accessibility:** SwiftUI accessibility modifiers, full Switch Control and AssistiveTouch support

## Key Architectural Decisions

### Accessibility Requirements (Primary Focus)
All UI decisions prioritize users with motor tremors:
- **Touch targets:** Minimum 88pt for all interactive elements, 100pt for primary actions
- **Spacing:** Minimum 20pt between interactive elements to prevent mis-taps
- **No complex gestures:** No drag, swipe-to-dismiss, or hold interactions
- **No time limits:** No timeouts or auto-dismiss anywhere
- **Modal behavior:** Modals use `.interactiveDismissDisabled(true)` to prevent accidental dismissal
- **Button activation:** Consider slight delay before activation to prevent tremor-caused double-taps

### Apple Intelligence Integration
The core feature uses **Foundation Models framework** to generate three variations of corrected text:

**Implementation:**
- Uses `LanguageModelSession` with custom system prompt optimized for tremor correction
- Guided generation with `@Generable` struct ensures structured 3-variation response
- On-device processing (~3B parameter LLM) - no network required, completely private
- Graceful fallback to mock variations if Foundation Models unavailable

**Variation Strategy:**
1. Variation 1: Direct correction (closest to literal input)
2. Variation 2: Refined phrasing with better grammar/punctuation
3. Variation 3: Alternative interpretation if input was ambiguous

**Error Handling:**
- Check for Apple Intelligence availability before calling API
- Fall back to enhanced mock if API fails or device doesn't support it
- Never crash - always return 3 variations

### Data Persistence Strategy
- **Auto-save:** Draft text saved to local file every 10 seconds
- **Preferences stored in UserDefaults:**
  - Selected voice identifier
  - Speech rate
  - Font size
  - Color theme
- **No cloud sync, accounts, or analytics**

## Application Structure

### Main Screen Components
1. **Text Editor** — Full-screen text input area
   - Minimum 20pt font (adjustable to 40pt)
   - High contrast color schemes
   - Support for Dynamic Type
   - Standard iOS keyboard (no custom keyboard)
   - External Bluetooth keyboard support

2. **Button Bar** (fixed position, never obscured by keyboard)
   - **Clear Button** (88x80pt) — Requires confirmation dialog
   - **Check Button** (100x80pt) — Disabled when empty, opens variation modal
   - **Speak Button** (100x80pt) — Disabled when empty, toggles to Stop while speaking

3. **Variation Selection Modal**
   - Full-screen semi-transparent overlay
   - Three variation cards, each with "Use This" button (88x60pt)
   - Close button (X) in top-right (60x60pt)
   - "Try Again" button at bottom
   - Minimum 18pt font for all text
   - Does NOT dismiss on background tap

### Settings Screen
- Text size slider
- Theme selector (Light/Dark)
- Voice picker (lists all device voices, grouped by language)
- Speech rate slider (0.5x – 2.0x)
- "Test Voice" button for preview
- All settings persist across sessions

### Keyboard Shortcuts (External Keyboard)
- ⌘ + Enter = Check
- ⌘ + Delete = Clear (with confirmation)
- ⌘ + S = Speak

## Testing Requirements

When implementing features, verify with:
1. **Switch Control enabled** — All interactions must work
2. **Increase Contrast enabled** — UI must maintain 4.5:1 text contrast, 3:1 for interactive boundaries
3. **Bold Text enabled** — Layout must accommodate bolder text
4. **Reduce Motion enabled** — No animations that could distract
5. **VoiceOver** — Full support (for caregivers)

## Development Constraints

### Avoid Over-Engineering
- Simple, focused solutions only
- No features beyond the specification
- No custom keyboards (user knows standard iOS keyboard)
- No drag gestures or complex interactions

### Out of Scope for v1.0
- Voice Control (user cannot speak)
- iCloud sync
- Message history/favorites
- Share sheet integration
- Siri integration
- Widget

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Apple Intelligence unavailable | Show device requirements message |
| Check fails (network/processing) | "Couldn't check your text. Please try again." with retry button |
| TTS fails | Link to Settings > Accessibility > Spoken Content |
| Empty editor | Disable Check and Speak buttons (no error message) |

## User Flow Reference

Complete interaction path:
1. User opens app → Editor shown (with saved draft if exists)
2. User types message → Auto-saves every 10 seconds
3. User taps Check → Modal with three variations appears
4. User selects variation → Editor updates with corrected text
5. User taps Speak → Message spoken aloud
6. User taps Clear → Confirmation dialog → Editor clears

## File Organization Expectations

When implementing, organize as follows:
- Views in dedicated Views/ directory (EditorView, VariationModal, SettingsView)
- ViewModels in ViewModels/ directory
- Services in Services/ directory (AppleIntelligenceService, SpeechService, StorageService)
- Models in Models/ directory (Draft, Settings)
- Accessibility utilities in Accessibility/ directory

## Critical Implementation Notes

1. **Modal dismissal:** Always use `.interactiveDismissDisabled(true)` on modals
2. **Button sizes:** Verify all touch targets meet minimum sizes in spec
3. **Loading states:** Show clear loading indicators during AI processing
4. **Auto-save:** Implement non-blocking 10-second auto-save timer
5. **Error recovery:** All errors should be recoverable without losing user's text
6. **Confirmation dialogs:** Clear button requires destructive-style confirmation
7. **Voice state:** Speak button must visually change to "Stop" while speaking
