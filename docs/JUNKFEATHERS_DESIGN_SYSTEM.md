# Junkfeathers Tech — Device Interface Design System

**Status:** Active company-wide visual standard  
**Version:** 1.1  
**Last revised:** July 10, 2026 — portrait lock, top-toast rule, machine shell pattern, and in-app brand-placement rule added  
**Reference implementation:** Orpheus Deck Android interface  
**Applies to:** Every user-facing Junkfeathers Tech Flutter app unless Jonathan approves a documented product-specific exception

> Junkfeathers Tech apps should feel like related physical machines made by the same strange workshop. They do not need identical layouts, but they share the same typography, geometry, border logic, control behavior, startup identity, and visual restraint.

---

## 1. Authority and Use

This file is the visual source of truth for new Junkfeathers Tech applications.

Every app repository must contain a current copy at:

```text
docs/JUNKFEATHERS_DESIGN_SYSTEM.md
```

Authority for visual questions:

1. Jonathan's newest direct instruction
2. Approved app current-version blueprint
3. Approved app master blueprint and `docs/DECISIONS.md`
4. This Junkfeathers Tech design system
5. Project AI coding instructions
6. Existing implementation details

An app may deviate when its device metaphor genuinely requires it, but the deviation must be named, justified, and approved. Cursor may not invent a new font, corner style, color system, card language, or interaction treatment merely because a Flutter component defaults to it.

---

## 1A. Brand Presence Rule

The **Junkfeathers Tech** brand name belongs primarily to the shared startup splash.

Inside the application machine itself:

- Use the **product name** as the main identity.
- Use a **model name or machine designation** when helpful.
- Do **not** repeat `JUNKFEATHERS TECH` across the main machine header, chrome, or routine screen furniture unless Jonathan explicitly approves a product-specific exception.
- Example: a Local Agora machine header may say `AGORA MK-I` or another approved model identifier rather than `JUNKFEATHERS TECH // ...`.

The goal is for the splash to establish the workshop brand, while the machine face establishes the specific device.

## 2. What Was Extracted From Orpheus Deck

The Orpheus Deck source establishes the reusable company baseline:

- Flutter generic font family: `monospace`
- No custom font files in the current Orpheus `pubspec.yaml`
- Black scaffold and surface
- White primary text, outlines, and active state
- Gray opacity steps for secondary, disabled, locked, and structural information
- Square containers and controls with no corner radius
- Major panels outlined at 3 px
- Standard controls and dialogs outlined at 2 px
- Secondary controls and separators outlined at 1 px
- Pressed or active controls invert from black/white to white/black
- Very short press animation, approximately 50 ms
- Compact spacing based mainly on 4, 8, 12, 16, 24, and 48 px increments
- Device labels use bold monospace, restrained all caps, and deliberate letter spacing
- No shadows, glossy cards, gradients, glassmorphism, or decorative rounded surfaces

The goal is not to copy the Orpheus cassette layout. The goal is to preserve the same workshop DNA.

---

## 3. Permanent Visual DNA

Every Junkfeathers Tech app begins with these defaults:

- Near-black or pure-black device field
- Monochrome-first interface
- White or bone-white operational text and line work
- Square hardware-panel geometry
- Compact, deliberate spacing
- Visible control states
- Minimal color
- No fake web-card layout
- No generic Material-demo appearance
- No rounded social-media language
- No decorative clutter that competes with the core task

The app should look like a focused object, instrument, terminal, receiver, deck, calculator, recorder, or field machine—not a website placed inside a phone.

---

## 4. Canonical Typography

### Current company font rule

Use the same family token as Orpheus Deck:

```dart
fontFamily: 'monospace'
```

This is the canonical Junkfeathers font family until Jonathan explicitly approves a bundled replacement for the entire product family.

Rules:

- Do not substitute a different custom font per app.
- Do not add `google_fonts` merely to make one app look different.
- Do not use the platform's ordinary proportional UI font for visible product controls.
- Define the family once in theme/tokens and reuse it everywhere.
- A future bundled font migration must be deliberate, licensed, tested, and applied consistently across active products.
- App logos or rare decorative title art may use custom vector lettering only when approved; ordinary UI remains monospace.

### Type scale derived from Orpheus Deck

| Role | Size | Weight | Letter spacing | Typical use |
|---|---:|---|---:|---|
| Device title | 18–20 | `w900` or bold | 2.0 | App/deck name |
| Critical numeric display | 28–32 | `w900` | 3.0–4.0 | Timer, BPM, counter, primary reading |
| Primary device button | 14 | bold | 1.0 | Main full-width actions |
| Standard control label | 10–12 | bold | 0.6–1.0 | Buttons, tracks, sections, state labels |
| Supporting copy | 10–12 | normal | 0–0.5 | Help, explanations, empty states |
| Micro metadata | 7–9 | normal or bold | 0.4–0.5 | Engine, version, technical status |

Supporting copy should generally use line height `1.25–1.4`.

Use tabular figures for timers, counters, prices, measurements, BPM, and aligned numeric readouts when supported.

### Copy casing

- Operational controls and machine states may use ALL CAPS.
- Explanatory text should use readable sentence case when all caps would slow comprehension.
- Mythic or machine vocabulary must include plain-language support.
- Do not use all caps as a substitute for hierarchy.

---

## 5. Core Palette

Canonical Flutter values:

| Token | Value | Purpose |
|---|---|---|
| `jfBlack` | `Colors.black` | Scaffold, panels, controls |
| `jfWhite` | `Colors.white` | Primary text, active outlines, active fill |
| `jfWhite70` | `Colors.white70` | Strong secondary outlines/text |
| `jfWhite54` | `Colors.white54` | Secondary labels, inactive controls |
| `jfWhite38` | `Colors.white38` | Locked, disabled, tertiary information |
| `jfWhite24` | `Colors.white24` | Dividers, subtle filled fields |
| `jfWhite12` | `Colors.white12` | Very quiet structure |

Rules:

- White is the default accent.
- Product-specific color is optional, never automatic.
- A product may add one restrained signal color for warnings, armed states, uncertainty, or a distinct functional role after approval.
- Essential state may not rely on color alone.
- Avoid rainbow categories, purple AI gradients, neon marketing palettes, and color used merely to make the screen feel busy.

---

## 6. Geometry and Border Hierarchy

### Square by default

All ordinary panels, buttons, dialogs, fields, cards, toasts, and control faces use square geometry.

```dart
borderRadius: BorderRadius.zero
```

or omit `borderRadius` entirely.

Rounded geometry is allowed only when the physical metaphor requires it—for example, a reel, dial, knob, LED, round arm switch, waveform point, or circular meter.

### Border hierarchy

| Width | Use |
|---:|---|
| 3 px | Major device shell, transport panel, hero module |
| 2 px | Primary controls, dialogs, main list frame, active control |
| 1 px | Secondary controls, compact switches, fields, dividers |

Do not give every element the same visual weight. Border hierarchy is part of navigation.

### No fake elevation

- No shadows by default
- No card elevation
- No glossy effects
- No beveled Material buttons unless deliberately drawn as hardware
- No glassmorphism
- No floating rounded chips

Depth should come from framing, spacing, inversion, line weight, and functional grouping.

---

## 7. Spacing and Layout Rhythm

Use a compact 4 px rhythm:

```text
4  /  8  /  12  /  16  /  24  /  48
```

Reference use:

- 4 px: label-to-state, icon-to-label, tiny metadata gap
- 8 px: common control gap, row separation
- 10–12 px: panel separation and internal device padding
- 16 px: action grouping and full-width button separation
- 24 px: landing-screen outer padding
- 48 px: major hero-to-action separation when needed

Orpheus-derived defaults:

- Dense main device screen outer padding: approximately 8 px
- Home/landing screen outer padding: approximately 24 px
- Major panel internal padding: approximately 12 px
- Standard row padding: approximately 12 px horizontal / 8 px vertical

Responsive layouts may change dimensions, but should preserve the same density and hierarchy.

### Portrait orientation rule

Junkfeathers Tech mobile applications are **portrait-only by default**.

- Do not support device rotation unless Jonathan explicitly approves a named landscape use case.
- A temporary debug convenience does not change this standard.
- If a product later earns landscape support, document it in that product blueprint and decisions file.

### Keyboard behavior rule

Input flows should behave like the improved Local Agora Pass 02A pattern:

- Use **keyboard-inset-aware**, scrollable, full-screen layouts for text entry and small-form interaction.
- Keep the active field, supporting guidance, and primary action reachable when the keyboard opens.
- Prefer this pattern over cramped dialogs or layouts where the keyboard hides the action the user needs next.
- When a product still needs a full-screen input route, preserve the same keyboard-safe behavior.


---

## 8. Control Sizes and Touch Targets

Reference visible control faces from Orpheus:

| Tier | Visible size | Example |
|---|---|---|
| Micro | about 24×20 | Mute/Solo-style switch |
| Small | about 28×18 to 36×36 | FX, clear, arm, compact mode |
| Transport | about 70×60 | Play/Stop/Record/main machine action |
| Full-width action | flexible width, 16 px vertical padding | Start, resume, settings, scan |

Accessibility rule:

A visible hardware face may be smaller than 44×44, but the actual semantic/tap target should be at least approximately 44×44 through padding, parent hit area, or another accessible treatment wherever layout permits.

Do not enlarge every visible control into a generic pill. Preserve the device face while making the hit target usable.

---

## 9. Control State Language

### Default / idle

- Black fill
- White or white70 border
- White text/icon

### Pressed or active

- White fill
- Black text/icon
- Stronger 2–3 px border
- Immediate visual change
- Short animation around 50 ms when animation is appropriate

### Locked or disabled

- Black fill
- `white38` border and text
- Still explain why it is unavailable
- A locked paid control remains visible and opens the appropriate explanation or Pro surface; it must not behave like a dead control

### Secondary or inactive

- Black fill
- `white54` border/text

### Destructive

- Do not rely on red alone.
- Use explicit labels such as `CLEAR`, `DELETE`, or `RESET`.
- Require confirmation when the action is not easily recoverable.

### State honesty

- No fake loading percentages
- No decorative blinking that implies work not occurring
- No state change without visible confirmation
- Use text, shape, inversion, iconography, or status labels in addition to color

---

## 10. Required Reusable Flutter Layer

Every new app must define a centralized design layer before broad UI construction.

Recommended structure:

```text
lib/design/
├── junkfeathers_theme.dart
├── junkfeathers_tokens.dart
├── jf_device_button.dart
├── jf_panel.dart
├── jf_oled_dialog.dart
├── jf_oled_toast.dart
├── jf_section_label.dart
└── jf_numeric_display.dart
```

Names may be adapted, but the responsibilities must remain centralized.

Recommended token groups:

- `JfColors`
- `JfTypography`
- `JfSpacing`
- `JfBorders`
- `JfMotion`
- `JfControlSizes`

Do not repeat raw text styles and border definitions across dozens of widgets. Product-specific components should be built on the shared tokens.

### Theme baseline

```dart
ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    secondary: Colors.white,
    surface: Colors.black,
  ),
)
```

App-specific theme additions may extend this baseline but should not replace it casually.

---

## 11. Buttons

### Full-width device action

Orpheus reference behavior:

- Full available width
- 16 px vertical padding
- 2 px white70 border at rest
- White text on black
- Pressed state: white fill, black text, 3 px border
- 14 px bold monospace label
- 1 px letter spacing
- Approximately 50 ms state animation
- Square corners

### Transport or primary machine button

Orpheus reference behavior:

- Approximately 70×60 visible face when space permits
- 2 px white border
- 24 px functional icon
- 10 px bold monospace label
- 1 px letter spacing
- Active state inverts white/black
- Square corners

### Text and dialog buttons

Text-only controls may omit a full box when clearly subordinate, but must retain monospace typography, strong focus indication, and sufficient tap area.

Do not use default rounded `ElevatedButton`, pill-shaped filters, or generic Material call-to-action styling without explicitly restyling them into the device system.

---

## 12. Panels, Lists, Fields, Dialogs, and Toasts

### Panels

- Black fill
- Square outline
- 3 px for hero/device shell, 2 px for major content region, 1 px for secondary module
- Use `white24` 1 px separators for dense lists

### Input fields

- Square outline or underlined hardware-style value
- Monospace input and hint text
- Clear focus state
- Keyboard-safe full-screen route for naming, BPM, detailed text, or other cramped input
- Never depend on a tiny dialog that becomes unusable when the keyboard opens

### Dialogs

Orpheus reference:

```dart
AlertDialog(
  backgroundColor: Colors.black,
  shape: Border.all(color: Colors.white, width: 2),
)
```

- Square 2 px white frame
- Monospace title and body
- No rounded Material card shape
- Scroll when content may exceed the screen
- Preserve readable margins on small Android devices

### OLED toast/status panel

**Placement rule:** Default OLED toast and transient status notices appear near the **top** of the machine, not the bottom, unless a product-specific interaction clearly needs another position.

Reusable reference:

- Black panel
- 2 px white border
- Maximum width around 440 px
- Horizontal padding around 14 px
- Vertical padding around 10 px
- Centered bold monospace text around 11 px
- Letter spacing around 0.6
- Line height around 1.25
- Short duration around 2.3 seconds for ordinary confirmations

Critical errors that require action should not disappear only as a transient toast.

---

## 13. Icons, Graphics, and Device Metaphor

- Functional monochrome Material icons are acceptable when paired with clear labels.
- Decorative emoji are not primary interface icons.
- Custom painting is encouraged for the app's defining physical metaphor: cassette, reels, meters, birds, receiver, calculator, terminal, synth, or other artifact.
- Custom decoration must not reduce legibility or touch clarity.
- The hero screen should explain the product visually before the user opens help.
- Each app may arrange controls differently; the common workshop language remains typography, line weight, square geometry, inversion, density, and restraint.

---

## 14. Motion, Glitch, and Haptics

- Normal control feedback should be immediate and brief.
- The shared Junkfeathers splash owns the full glitch identity.
- Do not apply constant glitching to ordinary content.
- No flashing effects that reduce accessibility or imply instability.
- Prefer state inversion, short mechanical transitions, or meter motion tied to real activity.
- Support reduced-motion behavior.
- Haptics may reinforce button presses, detents, mode changes, or destructive confirmation when useful, but must be consistent and may not substitute for visible feedback.

Permanent splash timing remains:

- Reveal/glitch-in: 990 ms
- Clean hold: 1000 ms
- Hide/glitch-out: 880 ms
- Total: 2870 ms

---

## 15. Responsive and Accessible Use

Android physical hardware is the first visual truth.

Required checks:

- Small phone width
- Typical phone width
- Large accessibility text
- Portrait layout unless the product explicitly supports landscape
- Keyboard-open state
- Screen reader labels for custom controls
- Visible focus for web/keyboard use
- Minimum usable tap targets
- Contrast in dim and bright environments
- State understandable without color

Web and future iOS layouts should preserve the machine identity without blindly stretching a phone panel across a desktop screen.

---

## 16. Foundation and Prototype Screens Are Not Exempt

A feasibility spike may use a minimal screen, but any screen shown to Jonathan or included in an APK must use the canonical font, black field, square geometry, and basic token system.

Do not use an arbitrary font, default rounded Flutter button, or colorful sample screen merely because the feature is temporary. Temporary screens often become the starting point for later work and create visual drift.

A backend-only spike may omit final visual construction. A visible shell may not omit the company baseline.

---

## 17. Required Design Pass and Approval Gate

Before broad feature wiring, create a design-system or component-gallery pass that demonstrates:

- Device title
- Numeric display
- Primary full-width button
- Transport/primary machine button
- Small switch/control
- Locked and disabled states
- Panel hierarchy at 3/2/1 px
- Text input
- Dialog
- Toast/status panel
- Loading, empty, error, and offline states

Cursor must provide:

- Fresh APK
- Screenshots or screen recording when helpful
- Exact token/component files changed
- Phone-test script
- Visual compliance checklist

Jonathan approves or rejects:

- Font match
- Square corners
- Border hierarchy
- Button density
- Pressed/active inversion
- Readability
- Device metaphor
- Overall family resemblance to Orpheus Deck

Feature wiring should not advance until the visual shell is approved, except when a feasibility spike must precede design.

---

## 18. Visual Compliance Checklist

Before a visible pass is approved:

- [ ] UI uses the canonical `monospace` token
- [ ] No accidental proportional font remains in product UI
- [ ] Ordinary controls and panels have square corners
- [ ] Major/standard/secondary borders use a deliberate 3/2/1 px hierarchy
- [ ] Active and pressed controls visibly invert or otherwise use the approved state language
- [ ] Locked controls explain themselves and are not dead
- [ ] No generic rounded Material-demo components remain
- [ ] No gradients, glass cards, or unnecessary shadows remain
- [ ] Spacing follows the compact 4 px rhythm
- [ ] Labels remain readable on Jonathan's Android phone
- [ ] Large text does not clip critical actions
- [ ] Core states are understandable without color
- [ ] Product-specific visual exceptions are recorded in `docs/DECISIONS.md`

---

## 19. Change Control

This file is a company standard. A single app may not silently redefine it.

When Jonathan approves a company-wide visual change:

1. Update this document first.
2. Update the company app blueprint and AI instructions.
3. Decide whether existing apps should migrate immediately or during their next visual pass.
4. Record the migration decision.
5. Test on a physical Android phone before declaring the new rule complete.

The correct goal is family resemblance, not forced cloning.
