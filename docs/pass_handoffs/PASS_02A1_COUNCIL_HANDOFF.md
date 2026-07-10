# THE LOCAL AGORA — PASS 02A.1 COUNCIL HANDOFF

## 1. Pass identity
- Objective: Apply Jonathan’s Pass 02A physical-review refinements and ship machine-shell Stage 1 (branding, portrait lock, top OLED toasts, keyboard preservation, 01–04 shell + signal coil).
- Status: COMPLETE — awaiting physical Android review of the refined APK
- Branch: `pass-02a1-machine-shell-refinement`
- Commit: (branch tip at handoff close — see git log)
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
Pass 02A.1 records Physical Test 02A as **PASS WITH APPROVED REFINEMENTS**, normalizes governing blueprint filenames, removes routine in-app Junkfeathers Tech chrome in favor of `AGORA MK-I`, locks portrait orientation, moves OLED toasts to the top edge, preserves the approved keyboard-inset scroll pattern, and reorganizes Scan Control into a four-level civic machine with a Stage 1 `JfSignalCoil` visual. No Firebase, live Keryx, paid Gemini, maps, or secondary coding agents were used.

## 3. Documentation normalization
- Files found (pre-normalize): Drive-title master + contest blueprints; `LOCAL_AGORA_AI_CODING_INSTRUCTIONS.md`; deleted canonical `MASTER_BLUEPRINT.md` / `DEV_CONTEST_V0.1_BLUEPRINT.md` / `AI_CODING_INSTRUCTIONS.md`; new `FOUNDER_TOOL_ACCESS.md`; updated `DECISIONS.md` + `JUNKFEATHERS_DESIGN_SYSTEM.md`; deleted `.docx` duplicates
- Files renamed:
  - `LOCAL_AGORA_AI_CODING_INSTRUCTIONS.md` → `AI_CODING_INSTRUCTIONS.md`
  - `docs/The Local Agora - Master Blueprint & Developer Notes.md` → `docs/MASTER_BLUEPRINT.md`
  - `docs/The Local Agora - DEV Passion Challenge V0.1 Build Blueprint.md` → `docs/DEV_CONTEST_V0.1_BLUEPRINT.md`
- Duplicates removed: Drive-title `.md` names eliminated; `.docx` blueprint copies remain deleted
- Content-preservation result: Newest approved Drive content retained under canonical names; founder-tool-access and Pass 02A visual refinements preserved

## 4. Physical Test 02A record
Recorded in `docs/pass_handoffs/PASS_02A_COUNCIL_HANDOFF.md`:
- Overall: **PASS WITH APPROVED REFINEMENTS**
- Font, square geometry, borders, selections, pressed state, validation, readiness notice, debug gallery, large text, keyboard, force-close: passed
- Rotation worked but is no longer desired → portrait-only in 02A.1
- Refinements listed in §1 objective executed in this pass

## 5. Acceptance criteria

| Criterion | Status | Evidence |
|---|---|---|
| 1. Governing files were read | PASS | Pre-code reading + normalization |
| 2. Founder tool-access profile was read | PASS | `docs/FOUNDER_TOOL_ACCESS.md` |
| 3. Blueprint filenames were normalized safely | PASS | Canonical names restored |
| 4. No active duplicate master blueprint remains | PASS | Only `docs/MASTER_BLUEPRINT.md` |
| 5. No active duplicate current-build blueprint remains | PASS | Only `docs/DEV_CONTEST_V0.1_BLUEPRINT.md` |
| 6. Pass 02A physical test was recorded | PASS | Added to Pass 02A handoff |
| 7. In-app Junkfeathers Tech header was removed | PASS | Old header absent; regression test |
| 8. `AGORA MK-I` appears | PASS | Status strip + tests |
| 9. Junkfeathers Tech splash specification remains intact | PASS | `JunkfeathersSplashSpec.brandName` |
| 10. Portrait-only behavior was implemented | PASS | `main.dart` + AndroidManifest + iOS Info.plist |
| 11. Top OLED informational toast works | PASS | Valid scan → top toast |
| 12. Top OLED warning toast works | PASS | Empty location → top warning |
| 13. Empty validation remains persistently understandable | PASS | Inline field error retained |
| 14. Approved keyboard behavior was preserved | PASS | `viewInsets` + scroll padding |
| 15. Keyboard regression test passes | PASS | Widget test with FakeViewPadding |
| 16. `01` status/spec strip exists | PASS | `JfMachineStatusStrip` |
| 17. `02` main display exists | PASS | Framed display panel |
| 18. `03` signal-coil art panel exists | PASS | `JfSignalCoil` |
| 19. `04` controls level exists | PASS | Field + selectors + actions |
| 20. Signal visual respects reduced motion | PASS | `forceStatic` / `disableAnimations` |
| 21. No fake network, AI, or event data exists | PASS | Honest readiness toast only |
| 22. Existing time selection still works | PASS | Exclusive selection tests |
| 23. Existing category selection still works | PASS | Exclusive selection tests |
| 24. Debug component gallery remains debug-only | PASS | `kDebugMode` gate |
| 25. No Firebase work occurred | PASS | No packages / init |
| 26. No paid Gemini calls occurred | PASS | Spike not run |
| 27. No map work occurred | PASS | pubspec guard |
| 28. Flutter analysis passes | PASS | No issues found |
| 29. Flutter tests pass | PASS | 23 tests |
| 30. Debug APK builds and exists | PASS | See §15 |
| 31. Flutter web builds | PASS | `build/web` |
| 32. Council handoff is complete | PASS | This document |
| 33. Smallest next pass is identified | PASS | See §20 |

## 6. In-app branding correction
- Removed: `JUNKFEATHERS TECH // CIVIC RECEIVER 01`
- Added: `AGORA MK-I` via status strip identity
- Product title `THE LOCAL AGORA` retained in display level
- Splash brand name unchanged in `lib/brand/junkfeathers_splash_spec.dart`

## 7. Portrait-orientation implementation
- `lib/main.dart`: `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])` when `!kIsWeb`
- `android/app/src/main/AndroidManifest.xml`: `android:screenOrientation="portrait"`
- `ios/Runner/Info.plist`: portrait-only arrays (phone + iPad keys)
- Web: no fake phone orientation lock

## 8. Top OLED toast implementation
- `lib/design/jf_oled_toast.dart` rewritten as top Overlay toast (not bottom SnackBar)
- Below safe-area padding; square; 2 px border; amber for warnings
- Empty location: top warning + focus field + persistent inline error
- Valid location: top info `SCAN CONTROL READY` + next-pass Keryx copy (no dialog, no network)

## 9. Keyboard behavior preservation
- Pattern: `SafeArea` → `SingleChildScrollView` with `padding.bottom += MediaQuery.viewInsets.bottom`
- `windowSoftInputMode="adjustResize"` retained on Android
- Regression test simulates bottom inset and ensures field + SCAN remain reachable
- Suitable later adaptation note for Orpheus Deck: prefer inset-aware full-screen scroll over cramped dialogs

## 10. Four-level machine shell
- 01 status/spec: `JfMachineStatusStrip` — `AGORA MK-I // V0.1.0 // FREE // YYYY.MM.DD` (+ `DEV` in debug)
- 02 main display: title, prompt, awaiting/location readout, window + signal type
- 03 animated art: `JfSignalCoil` CustomPainter; idle/focused/ready/warning; reduced-motion static
- 04 controls: location, time, category, SCAN, locked ADD SIGNAL

## 11. Design-system files and components
- New: `jf_machine_status_strip.dart`, `jf_signal_coil.dart`
- Updated: `jf_oled_toast.dart`, `jf_machine_field.dart` (focusNode), gallery, Scan Control
- Tokens/theme unchanged in spirit; still centralized

## 12. Files created, changed, renamed, moved, or deleted
**Created:** `jf_machine_status_strip.dart`, `jf_signal_coil.dart`, `PASS_02A1_COUNCIL_HANDOFF.md`, `FOUNDER_TOOL_ACCESS.md` (tracked)
**Renamed:** AI coding instructions + both blueprints to canonical names
**Changed:** Scan Control, gallery, toast, field, main, AndroidManifest, iOS Info.plist, tests, Pass 02A handoff (physical record), PASS_02_READINESS, DECISIONS, design system, blueprints content from Drive
**Deleted:** Drive-title `.docx` blueprint copies (already untracked deletions)

## 13. Commands and actual results

| Command | Result |
|---|---|
| `flutter pub get` | PASS (via analyze/test/build) |
| `flutter analyze` | PASS — No issues found |
| `flutter test` | PASS — 23 tests |
| `flutter build apk --debug` | PASS |
| `flutter build web` | PASS |
| `npm run keryx:spike` | NOT RUN |

## 14. Automated tests
Cover AGORA MK-I, absent company header, splash brand intact, status strip date/version/FREE, levels 01–04, top warning/info toasts, square toast, signal coil + reduced motion, exclusive selections, keyboard inset, reduced viewport, debug gate, no map/font/firebase packages, no network in scan source, portrait config assertions.

## 15. APK and web-build information
- Build command: `flutter build apk --debug`
- Exact APK path: `build/app/outputs/flutter-apk/app-debug.apk`
- File existence: VERIFIED
- File size: 160,426,033 bytes (~152.99 MB)
- Package: `com.junkfeathers.localagora`
- Version: `0.1.0` / build `1`
- Orientation: portrait-only (Flutter + Android + iOS)
- Live Keryx connection: **NO**
- Internet required: **NO**
- Firebase required: **NO**
- Paid API calls: **NO**
- Web: `build/web` produced

## 16. Physical Android test script

1. Install the new Pass 02A.1 APK. **Expected:** Install succeeds.
2. Launch the app. **Expected:** Scan Control machine opens.
3. Confirm `AGORA MK-I`. **Expected:** Visible in 01 status strip.
4. Confirm old Junkfeathers Tech in-app header is absent. **Expected:** No `JUNKFEATHERS TECH // CIVIC RECEIVER 01`.
5. Confirm `THE LOCAL AGORA` remains present. **Expected:** In 02 display.
6. Inspect the `01` status strip. **Expected:** Compact machine strip, not a website navbar.
7. Confirm version, FREE state, and local date. **Expected:** `V0.1.0`, `FREE`, today’s `YYYY.MM.DD`.
8. Inspect the `02` main display. **Expected:** Prompt + awaiting/location + window/type readouts; no fake events.
9. Inspect the `03` signal-coil animation. **Expected:** Rectangular line-art coil on black.
10. Confirm animation is restrained and not distracting. **Expected:** Slow/low motion; no strobe.
11. Inspect `04` controls. **Expected:** Field, time, category, SCAN, locked ADD SIGNAL.
12. Test exclusive time selection. **Expected:** One active only; display WINDOW updates.
13. Test exclusive category selection. **Expected:** One active only; SIGNAL TYPE updates.
14. Press Scan with empty location. **Expected:** Top warning toast; field focuses.
15. Confirm warning toast appears at the top. **Expected:** Below status bar / safe area; amber border.
16. Confirm location error remains after toast disappears. **Expected:** Inline amber field error persists.
17. Enter `Springfield, Missouri`. **Expected:** Text accepted; awaiting line updates.
18. Press Scan. **Expected:** Top informational toast; no spinner pretending network search.
19. Confirm informational toast at top. **Expected:** `SCAN CONTROL READY` + next-pass Keryx copy.
20. Confirm no live search occurs. **Expected:** No fake events/citations/percentages.
21. Open the keyboard. **Expected:** Screen scrolls; field usable.
22. Confirm field and Scan remain reachable. **Expected:** Not permanently hidden.
23. Attempt to rotate the phone. **Expected:** App stays portrait.
24. Confirm portrait lock. **Expected:** No landscape UI.
25. Enable reduced motion where available; inspect signal visual. **Expected:** Static or non-continuous frame.
26. Open debug component gallery. **Expected:** Debug APK only; gallery opens.
27. Inspect toast styles and static/animated art. **Expected:** Top info/warning; coil demos.
28. Increase text size one step. **Expected:** Usable; scroll if needed.
29. Force-close and reopen. **Expected:** Clean relaunch; sensible defaults.
30. Record PASS/FAIL and any further visual refinement requests.

## 17. Security, privacy, source, and cost impact
- No secrets, GPS, Firebase, or paid Gemini
- Source honesty preserved
- Cost: local Flutter builds only; Cursor overage not used; no secondary agents

## 18. Known limitations and risks
- Signal coil is Stage 1 art, not final illustration
- Physical review of 02A.1 APK still required
- Node 22 / Firebase / remote still pending
- Toast is Overlay-based; must remain below safe area on varied devices

## 19. Founder actions still required
- Node 22: Still pending
- Firebase CLI: Still pending
- FlutterFire CLI: Still pending
- GitHub remote: Still pending
- Physical review: Required for this refined APK (script §16)

## 20. Recommended next pass
After Jonathan’s physical approval of Pass 02A.1:

**Smallest next pass:** Pass 02B — Wire Scan Control to live Keryx (Firebase/FlutterFire callable only), still without flyer/billing/City Index expansion unless separately governed.

Do not begin Pass 02B until 02A.1 physical approval is recorded.
