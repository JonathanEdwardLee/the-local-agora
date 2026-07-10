# THE LOCAL AGORA — PASS 02A COUNCIL HANDOFF

## 1. Pass identity
- Objective: Establish the permanent Junkfeathers visual foundation and replace the Pass 01 engineering shell with the first real Scan Control screen, plus a debug-only component gallery.
- Status: COMPLETE — awaiting Jonathan’s physical Android visual review
- Branch: `pass-02a-visual-foundation`
- Commit: see section tip after documentation commit (recorded below after final docs commit)
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
Pass 02A delivers the first permanent Local Agora UI: centralized Junkfeathers tokens/theme/components, Scan Control (location + time window + category + honest non-network scan notice), and a debug-only component gallery. The Pass 01 foundation screen is removed. No Firebase, live Keryx, maps, flyer upload, billing, or paid Gemini work was performed. Debug APK and web builds succeeded. Automated Flutter analyze and tests passed. Node 22, Firebase CLI, FlutterFire CLI, and GitHub remote remain founder actions.

## 3. Acceptance criteria

| Criterion | Status | Evidence |
|---|---|---|
| 1. All six governing files were read | PASS | Read before coding; design system applied |
| 2. Temporary Pass 01 appearance was replaced | PASS | `pass01_foundation_screen.dart` deleted; `ScanControlScreen` is home |
| 3. Centralized Junkfeathers design tokens exist | PASS | `lib/design/junkfeathers_tokens.dart` (`JfColors`, `JfTypography`, `JfSpacing`, `JfBorders`, `JfMotion`, `JfControlSizes`) |
| 4. Centralized Flutter theme exists | PASS | `lib/design/junkfeathers_theme.dart` → `buildJunkfeathersTheme()` |
| 5. Typography uses approved `monospace` baseline | PASS | `JfTypography.fontFamily == 'monospace'`; theme + widget tests |
| 6. No new font package or app-specific font added | PASS | `pubspec.yaml` has no `google_fonts`; no custom font assets |
| 7. Ordinary controls use square corners | PASS | `JfBorders.square == BorderRadius.zero`; button test |
| 8. 3/2/1 px border hierarchy represented | PASS | Tokens + panels/buttons/gallery |
| 9. Idle, active, pressed, disabled, locked states exist | PASS | `JfDeviceButton` + gallery demos |
| 10. Restrained amber limited to warning states | PASS | Toast/field error/warning tone only |
| 11. Scan Control contains all required content | PASS | Header, title, prompt, field, windows, categories, SCAN, ADD SIGNAL |
| 12. Time-window selection works | PASS | Exclusive `TimeWindow` state + widget test |
| 13. Category selection works | PASS | Exclusive `EventCategory` state + widget test; default ALL SIGNALS |
| 14. Empty location validation works | PASS | Toast + field error; blocks readiness dialog |
| 15. Valid location shows honest readiness notice | PASS | Dialog: SCAN CONTROL READY + next-pass Keryx copy |
| 16. No fake events or fake search behavior | PASS | No network; dialog states no search performed |
| 17. Debug gallery exists only for development review | PASS | `kDebugMode` gate on Scan Control; gallery route |
| 18. No Firebase resources created or configured | PASS | No `firebase.json`; no FlutterFire; no init |
| 19. No paid Gemini calls executed | PASS | No `keryx:spike`; Flutter-only pass |
| 20. No map dependency or map UI introduced | PASS | pubspec guard test; no map widgets |
| 21. Flutter analysis passes | PASS | `flutter analyze` — No issues found |
| 22. Flutter tests pass | PASS | `flutter test` — 15 tests passed |
| 23. Debug APK builds and physically exists | PASS | See §11 |
| 24. Flutter web builds | PASS | `build/web` produced |
| 25. Layout ready for physical Android visual review | PASS | Compact responsive Scan Control; new APK for phone install |
| 26. Node 22 remains documented as founder action | PASS | `PASS_02_READINESS.md` updated; still pending |
| 27. Complete council handoff produced | PASS | This document |
| 28. Smallest next pass identified | PASS | See §16 |

## 4. User-visible changes
- Home screen is now **Scan Control** (civic receiver machine), not the Pass 01 engineering shell.
- Machine header: `JUNKFEATHERS TECH // CIVIC RECEIVER 01`
- Product title: `THE LOCAL AGORA`
- Location field, exclusive time windows, exclusive event categories
- Primary `SCAN THE AGORA` validates location and shows an honest readiness dialog (no live search)
- Secondary `ADD SIGNAL` locked with flyer-later message
- Debug builds only: `DEBUG // COMPONENTS` opens the component gallery

## 5. Junkfeathers design-system implementation
- Theme: `buildJunkfeathersTheme()` wired in `main.dart`
- Tokens: `lib/design/junkfeathers_tokens.dart`
- Typography: company `monospace` baseline; hierarchy via size/weight/letter-spacing
- Geometry: square corners for ordinary controls (`BorderRadius.zero`)
- Border hierarchy: 3 px major / 2 px primary / 1 px secondary
- State behavior: idle (black/white), selected/active (white fill / black text), pressed (~50 ms), disabled/locked (white38)
- Accessibility: min tap height via `JfControlSizes.minTap`; semantic labels on primary controls; scroll + keyboard inset padding

## 6. Scan Control implementation
- Files: `lib/features/scan_control/scan_control_screen.dart`, `scan_control_state.dart`
- Typed state: location text, time window, category, location error
- No business logic buried only in nested callbacks; handlers on the State class
- Max content width ~560 for web machine centering
- Scrollable layout with bottom inset for keyboard

## 7. Debug component gallery
- File: `lib/features/debug/debug_component_gallery.dart`
- Access: `DEBUG // COMPONENTS` on Scan Control when `kDebugMode`
- Demonstrates typography, borders, buttons (states), field, dialog, toast, status, loading/empty/error/offline/warning

## 8. Files created, changed, moved, or deleted
**Created**
- `lib/design/junkfeathers_tokens.dart`
- `lib/design/junkfeathers_theme.dart`
- `lib/design/jf_device_button.dart`
- `lib/design/jf_panel.dart`
- `lib/design/jf_oled_dialog.dart`
- `lib/design/jf_oled_toast.dart`
- `lib/design/jf_section_label.dart`
- `lib/design/jf_numeric_display.dart`
- `lib/design/jf_machine_field.dart`
- `lib/design/jf_status_line.dart`
- `lib/features/scan_control/scan_control_screen.dart`
- `lib/features/scan_control/scan_control_state.dart`
- `lib/features/debug/debug_component_gallery.dart`
- `docs/JUNKFEATHERS_DESIGN_SYSTEM.md` (earlier in branch)
- `docs/pass_handoffs/PASS_02A_COUNCIL_HANDOFF.md`

**Changed**
- `lib/main.dart`
- `test/widget_test.dart`
- Governing docs alignment (design system references) as committed on branch
- `docs/PASS_02_READINESS.md` (Pass 02A visual readiness note)

**Deleted**
- `lib/features/pass01/pass01_foundation_screen.dart`

**Unchanged (intentionally)**
- `functions/**` Keryx engine, schema, prompts, package versions
- Splash timing constants
- App package ID `com.junkfeathers.localagora`

## 9. Commands and actual results

| Command | Result |
|---|---|
| `flutter pub get` | PASS |
| `flutter analyze` | PASS — No issues found |
| `flutter test` | PASS — 15 tests |
| `flutter build apk --debug` | PASS — APK written |
| `flutter build web` | PASS — `build/web` |
| `npm run keryx:spike` | NOT RUN (excluded) |

## 10. Automated tests
Coverage includes:
- Monospace theme baseline
- Square geometry / border hierarchy tokens
- Exclusive time/category selection (state + UI)
- Required Scan Control labels
- Primary action semantic label `Scan the Agora`
- Empty location blocks readiness dialog
- Valid location shows honest readiness dialog
- Narrow layout smoke (320×640)
- Debug gallery gated by `kDebugMode` in source + debug UI presence
- No map / google_fonts dependencies in `pubspec.yaml`
- Splash timing lock retained

## 11. APK and web-build information
- Build command: `flutter build apk --debug`
- Success: YES
- Exact APK path: `build/app/outputs/flutter-apk/app-debug.apk`
- Absolute path: `C:\Users\joned\Desktop\JunkfeathersTech\The Local Agora\The-Local-Agora\build\app\outputs\flutter-apk\app-debug.apk`
- File existence: VERIFIED
- File size: 160,406,445 bytes (~152.98 MB)
- Package name: `com.junkfeathers.localagora`
- Version: `0.1.0`
- Build number: `1`
- Live Keryx connection in APK: **NO**
- Internet required for this pass’s UI: **NO** (honest offline readiness notice only)
- Firebase configuration required: **NO**
- Web build: `flutter build web` → `build/web` (index present)

## 12. Physical Android test script

Install the **new** Pass 02A debug APK (not the Pass 01 APK).

1. Install the new APK from `build/app/outputs/flutter-apk/app-debug.apk`.  
   **Expected:** Install succeeds for `com.junkfeathers.localagora`.
2. Launch the app.  
   **Expected:** Black OLED Scan Control machine appears; no Pass 01 “KERYX FEASIBILITY” engineering shell.
3. Confirm Junkfeathers header and Local Agora title.  
   **Expected:** `JUNKFEATHERS TECH // CIVIC RECEIVER 01` and `THE LOCAL AGORA` visible.
4. Confirm the font visually matches the Orpheus-family monospace appearance.  
   **Expected:** Monospaced type throughout; no Inter/Roboto marketing look.
5. Confirm ordinary controls have square corners.  
   **Expected:** Buttons, field, panels are square (`BorderRadius.zero`).
6. Confirm selected time and category controls invert to white fill with black text.  
   **Expected:** Selected chip is inverted; others remain black fill / white text.
7. Confirm only one time window can be selected.  
   **Expected:** Selecting a new window deselects the previous.
8. Confirm only one category can be selected.  
   **Expected:** Selecting a new category deselects the previous; default was ALL SIGNALS.
9. Press SCAN with an empty location.  
   **Expected:** Warning toast/error: location required; no readiness dialog.
10. Confirm the approved error treatment appears.  
    **Expected:** Amber-restrained warning notice and/or field error; not a fake search.
11. Enter `Springfield, Missouri`.  
    **Expected:** Text accepted in CITY OR ZIP CODE field.
12. Press SCAN.  
    **Expected:** Square dialog appears (no spinner pretending to search the network).
13. Confirm the app honestly states that the live Keryx connection arrives in the next pass.  
    **Expected:** Title `SCAN CONTROL READY`; body mentions next governed pass; states no network search was performed.
14. Open the debug component gallery.  
    **Expected:** `DEBUG // COMPONENTS` visible in this debug APK; gallery opens.
15. Inspect borders, dialogs, toast, loading, empty, error, offline, disabled, and locked states.  
    **Expected:** 3/2/1 borders; square dialogs; amber only on warning; locked/disabled remain visible but subdued.
16. Rotate the phone if supported and inspect layout.  
    **Expected:** No permanent horizontal overflow; content remains usable.
17. Increase Android text size one step and inspect clipping.  
    **Expected:** Labels remain readable; scroll if needed; no catastrophic clip of primary action.
18. Force-close and reopen the app.  
    **Expected:** Clean relaunch to Scan Control; defaults sensible (ALL SIGNALS; no silent location submit).
19. Confirm selected defaults and startup behavior are sensible.  
    **Expected:** Empty location; category ALL SIGNALS; time window has a single default; ADD SIGNAL locked.
20. Record PASS/FAIL and screenshots for any visual issue.  
    **Expected:** Founder notes returned to council before Pass 02B.

## 13. Security, privacy, source, and cost impact
- No secrets added; no Firebase project binding
- No location permission / GPS requests
- No paid Gemini / Keryx network calls in this pass
- Source-honesty preserved: UI does not invent events or citations
- Cost impact: none beyond local Flutter builds

## 14. Known limitations and risks
- Scan Control does not yet call Keryx (intentional)
- ADD SIGNAL / flyer channel deferred
- Physical visual approval not yet recorded by founder on this APK
- Local Node remains v24 vs Functions engines 22 (does not block this Flutter pass)
- No GitHub remote configured
- Debug gallery must never ship as a release navigation surface (`kDebugMode` only)

## 15. Founder actions still required
- Node 22: Still pending (install/activate via NVM for Windows; see `docs/PASS_02_READINESS.md`)
- Firebase CLI: Not installed — deferred until connection pass
- FlutterFire CLI: Not installed — deferred until connection pass
- GitHub remote: None configured — founder action when ready to push
- Physical Android visual review of this Pass 02A APK (script in §12)

## 16. Recommended next pass
After Jonathan’s visual approval of Scan Control on the physical Android phone, the smallest logical next pass is:

**Pass 02B — Wire Scan Control to live Keryx (Firebase/FlutterFire callable connection only)**

Do not begin Pass 02B until visual approval is recorded. Do not expand into flyer upload, billing, City Index persistence, or contest packaging in that pass unless separately governed.
