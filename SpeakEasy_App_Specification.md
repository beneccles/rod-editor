# SpeakEasy: iPad Accessibility Text Editor

## Product Specification Document

**Version:** 0.1  
**Platform:** Native iPadOS  
**Primary User:** Individual with motor tremors affecting typing accuracy who uses this app as their voice

---

## Purpose

SpeakEasy exists to give a voice to someone who cannot speak. The user can type, but hand tremors cause frequent typos and missed keys. This app transforms imperfect keyboard input into clear, accurate messages—preserving the user's intended meaning and dignity. The corrected text can be shown to others or spoken aloud via text-to-speech.

---

## Design Principles

1. **Dignity first** — The user is intelligent; their hands just shake. Never patronize.
2. **Tolerance for error** — Assume every tap might land slightly off-target.
3. **No rushing** — No timeouts, no auto-dismiss, no penalties for taking time.
4. **Predictable layout** — Elements never move or reflow unexpectedly.
5. **Clear communication** — This app IS the user's voice. Accuracy matters.

---

## Core Features

### 1. Text Editor

A full-screen text input area optimized for use with tremoring hands.

**Requirements:**
- Large text input field occupying majority of screen
- Minimum default font size of 20pt, adjustable up to 40pt
- High contrast color schemes
- Support for system Dynamic Type
- Auto-save draft every 10 seconds
- No character limit
- Standard iOS keyboard with no modifications (user is familiar with it)
- Support for external Bluetooth keyboards

**Keyboard Optimization Notes:**
- The standard iOS keyboard is used because the user already knows it
- Key repeat delay should respect system accessibility settings
- No custom keyboard—this maintains familiarity and reduces learning curve

### 2. Check Button → Variation Selection Modal

A single button that processes text through Apple Intelligence and presents three interpretation options.

**"Check" Button:**
- Prominently placed, minimum 100x80pt touch target
- Label: "Check" with checkmark SF Symbol
- Disabled state when editor is empty

**Variation Selection Modal:**

When "Check" is tapped, a modal overlay appears with three AI-generated interpretations of what the user meant to type.

```
┌─────────────────────────────────────────────────────────┐
│                                                    [X]  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │                                                   │  │
│  │  "I would like a glass of water please"          │  │
│  │                                                   │  │
│  │                              [ Use This ]         │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │                                                   │  │
│  │  "I would like a glass of water, please."        │  │
│  │                                                   │  │
│  │                              [ Use This ]         │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │                                                   │  │
│  │  "I'd like a glass of water please"              │  │
│  │                                                   │  │
│  │                              [ Use This ]         │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│              [ Try Again ]                              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Modal Requirements:**
- Modal covers full screen with semi-transparent background
- Modal does NOT dismiss on background tap (intentional—prevents accidental dismissal)
- Modal ONLY closes via: selecting a variation, tapping X close button, or tapping "Try Again"
- Close button (X) is minimum 60x60pt, positioned top-right with padding from edge
- Each variation displayed in a clearly bounded card
- Each card has its own "Use This" button (minimum 88x60pt)
- "Try Again" button at bottom requests three new variations
- All text in modal uses minimum 18pt font
- Variations should differ meaningfully (not just punctuation changes):
  - Variation 1: Direct correction (closest to literal input)
  - Variation 2: Slightly refined phrasing
  - Variation 3: Alternative interpretation if input was ambiguous
- Loading state shown while AI processes
- If AI fails, show error message with "Try Again" button

**Selection Behavior:**
- Tapping "Use This" closes modal and replaces editor text with selected variation
- Tapping X closes modal and returns to editor with original text unchanged
- Tapping "Try Again" shows loading state, then displays three new variations

### 3. Clear Button

Resets the editor for a new message.

**Requirements:**
- Minimum 88x80pt touch target
- Label: "Clear" with X or trash SF Symbol
- Requires confirmation dialog before clearing
- Confirmation dialog buttons are large (minimum 88x60pt) and well-spaced
- Confirmation text: "Clear your message?"
- Buttons: "Keep Writing" (secondary) / "Clear" (destructive, red)

### 4. Speak Button

Reads the current message aloud using iOS text-to-speech.

**Requirements:**
- Minimum 100x80pt touch target
- Label: "Speak" with speaker SF Symbol
- Uses AVSpeechSynthesizer
- When tapped while speaking: stops speech
- Visual state change while speaking (e.g., button shows "Stop" with different icon)
- Speech uses user's saved voice preference

### 5. Voice Settings

User can select their preferred voice for text-to-speech.

**Requirements:**
- Accessible from Settings screen (gear icon)
- Lists all voices installed on device, grouped by language
- Each voice can be previewed with a "Play Sample" button
- Speech rate slider (0.5x – 2.0x)
- Selected voice persists across app sessions

---

## Screen Layout

### Main Editor Screen

```
┌─────────────────────────────────────────────────────────┐
│  SpeakEasy                                    [⚙ gear]  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │                                                   │  │
│  │  i woudl like a glasss of wster plese            │  │
│  │  _                                               │  │
│  │                                                   │  │
│  │                                                   │  │
│  │                                                   │  │
│  │                                                   │  │
│  │                                                   │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐         │
│   │          │    │          │    │          │         │
│   │  Clear   │    │  Check   │    │  Speak   │         │
│   │          │    │    ✓     │    │    🔊    │         │
│   └──────────┘    └──────────┘    └──────────┘         │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│               [ iOS Keyboard ]                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Button Bar Specifications

| Button | Min Size | Position | Icon | State |
|--------|----------|----------|------|-------|
| Clear | 88x80pt | Left | xmark.circle | Always enabled |
| Check | 100x80pt | Center | checkmark.circle | Disabled when empty |
| Speak | 100x80pt | Right | speaker.wave.2 | Disabled when empty; shows speaker.slash when speaking |

- Buttons are evenly spaced with minimum 20pt gaps
- Button bar has fixed position (never obscured by keyboard)
- Button bar background has subtle contrast from editor area

---

## Accessibility Requirements

### Motor Accessibility (Primary Focus)

- All touch targets minimum 88pt, primary actions 100pt
- Generous spacing (20pt+) between interactive elements prevents mis-taps
- No drag gestures required anywhere in app
- No swipe gestures required for core functionality
- No hold-to-activate interactions (single tap only)
- No time-limited interactions
- Modals don't dismiss on accidental background taps
- Full support for Switch Control
- Full support for AssistiveTouch
- Support for external keyboards and adaptive switches
- Keyboard shortcuts for all primary actions when external keyboard connected:
  - ⌘ + Enter = Check
  - ⌘ + Delete = Clear (with confirmation)
  - ⌘ + S = Speak

### Visual Accessibility

- Full VoiceOver support (for caregivers or others who may use it)
- Support for Bold Text system setting
- Support for Increase Contrast system setting
- Support for Reduce Motion (no animations that could distract)
- Minimum 4.5:1 contrast ratio for all text
- Minimum 3:1 contrast ratio for interactive element boundaries

### Cognitive Accessibility

- Consistent, unchanging layout
- Three buttons, three actions—nothing hidden
- Plain language throughout
- No jargon or technical terms in UI

---

## Technical Specifications

### Platform Requirements

- iPadOS 18.1 or later (required for Apple Intelligence)
- Compatible devices: iPad Pro (M1+), iPad Air (M1+), iPad mini (A17 Pro+)

### Frameworks

| Feature | Framework |
|---------|-----------|
| UI | SwiftUI |
| Text Correction | Apple Intelligence Writing Tools API |
| Text-to-Speech | AVFoundation (AVSpeechSynthesizer) |
| Data Persistence | UserDefaults (preferences), FileManager (draft) |
| Accessibility | SwiftUI accessibility modifiers |

### Apple Intelligence Integration

To generate three variations, the app will:

1. Send user's input to Apple Intelligence with a prompt requesting three interpretations
2. Parse response into three distinct options
3. If API returns fewer than three meaningfully different options, the app will:
   - Show what's available
   - Allow "Try Again" to request more

**Prompt Strategy:**
```
Given this text typed by someone with hand tremors, provide exactly 3 
interpretations of what they likely meant to say. Each interpretation 
should be a complete, corrected sentence. Make the variations meaningfully 
different—not just punctuation changes. If the intent is clear, vary the 
formality or phrasing. Return as JSON array.

Input: "[user's typed text]"
```

**Fallback:**
If Apple Intelligence is unavailable, show message: "Text checking requires an iPad with Apple Intelligence (M1 chip or newer with iPadOS 18.1+)."

### Data Storage

- Current draft: Saved to local file every 10 seconds
- Preferences: UserDefaults
  - Selected voice identifier
  - Speech rate
  - Font size
  - Color theme
- No cloud sync
- No accounts
- No analytics

---

## Settings Screen

```
┌─────────────────────────────────────────────────────────┐
│  [← Back]              Settings                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  DISPLAY                                                │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Text Size                            [====●===]  │  │
│  │  Theme                          [ Light ▼ ]       │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  VOICE                                                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Voice                         [ Samantha ▼ ]     │  │
│  │  Speed                            [===●=====]     │  │
│  │                                                   │  │
│  │  [ ▶ Test Voice ]                                 │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  ABOUT                                                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Version 1.0                                      │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Error States

| Scenario | Message | Action |
|----------|---------|--------|
| Apple Intelligence unavailable | "Text checking requires an iPad with Apple Intelligence." | Show device requirements |
| Check fails (network/processing) | "Couldn't check your text. Please try again." | Show "Try Again" button |
| Empty editor + Check tapped | Button is disabled (no error needed) | — |
| Empty editor + Speak tapped | Button is disabled (no error needed) | — |
| TTS fails | "Couldn't speak text. Check Settings > Accessibility > Spoken Content." | Link to system settings |

---

## User Flow: Complete Interaction

1. User opens app → Editor shown (with any saved draft)
2. User types message using standard iOS keyboard
3. User taps "Check"
4. Modal appears with three variations
5. User reviews options, taps "Use This" on preferred one
6. Modal closes, editor now shows corrected text
7. User taps "Speak" to communicate message aloud
8. User shows iPad screen or lets speech play for listener
9. User taps "Clear" when done
10. Confirmation appears, user confirms
11. Editor clears, ready for next message

---

## Out of Scope (Version 1.0)

- Voice Control (user cannot speak)
- iCloud sync
- Message history/favorites
- Share sheet integration
- Custom keyboards
- Siri integration
- Widget

---

## Success Criteria

- User can compose and correct a message without frustration
- No accidental dismissals or data loss
- App can be operated with tremoring hands
- Text-to-speech works reliably as user's voice
- User feels respected, not patronized

---

## Notes for Development (Claude Code)

1. **SwiftUI preferred** for declarative UI and built-in accessibility support
2. **Modal implementation**: Use `.interactiveDismissDisabled(true)` to prevent swipe-to-dismiss
3. **Apple Intelligence API**: May need to use `UIWritingToolsCoordinator` or explore generating variations via on-device ML
4. **Test with Switch Control** enabled to verify all interactions work
5. **Test with Increase Contrast** and **Bold Text** enabled
6. **Consider**: Slight delay before button activation to prevent tremor-caused double-taps

---

*Ready for implementation handoff to Claude Code*
