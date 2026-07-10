# THE LOCAL AGORA — PASS 02A.2 COUNCIL HANDOFF

## 1. Pass identity
- Objective: Integrate Scan Control into one machine face — remove external numbered headers; redesign panels 01–04; CRT monitor with real scrollbar; compact triple rings; WHEN/WHAT dial selectors.
- Status: COMPLETE — awaiting physical Android review of the refined APK
- Branch: `pass-02a2-integrated-machine-panel`
- Commit: `822870229dffe1aabbcc63ea8a44b8f2fb0b8613`
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
Pass 02A.2 records Physical Test 02A.1 as **FUNCTIONALITY PASS — VISUAL REFINEMENT REQUESTED** and delivers the requested layout: no external section headers; identity/spec panel with retro date; CRT-only monitor; shorter triple-ring art; one control chassis with dial WHEN/WHAT. Keyboard, top toasts, portrait lock, and honest non-network scan behavior are preserved. No Firebase, Keryx, Gemini, maps, or secondary agents.

## 3. Physical Test 02A.1 record
Recorded in `PASS_02A1_COUNCIL_HANDOFF.md`:
- Functionality, portrait, toasts, keyboard, selection, signal animation, force-close: passed
- Visual layout refinement requested → executed in this pass

## 4. Acceptance criteria

| Criterion | Status | Evidence |
|---|---|---|
| 1. Governing documents read | PASS | Pre-code reading |
| 2. Pass 02A.1 functionality pass recorded | PASS | Handoff appendix |
| 3. No external numbered headers | PASS | Tests + UI |
| 4. Panel 01 contains Local Agora title | PASS | `JfMachineIdentityPanel` |
| 5. Panel 01 truthful specs | PASS | MODEL/VERSION/ACCESS/MODE/ENGINE |
| 6. Separate retro date display | PASS | `JfRetroDateDisplay` |
| 7. Panel 02 is only CRT monitor | PASS | `JfCrtMonitor` |
| 8. Monitor does not repeat title/prompt | PASS | Test |
| 9. Rounded geometry limited to inner CRT | PASS | `JfCrtMonitor.innerRadius` |
| 10. Truthful real scroll mechanism | PASS | `ScrollController` + `JfMachineScrollbar` |
| 11. Panel 03 shorter | PASS | Height 72 |
| 12. Three concentric rings | PASS | `_TripleRingPainter` |
| 13. Rings inside art box | PASS | Padded max radius + ClipRect |
| 14. Reduced-motion mode | PASS | `forceStatic` / disableAnimations |
| 15. Panel 04 one chassis | PASS | Single bordered control column |
| 16. Location input preserved | PASS | Field + keyboard tests |
| 17. WHEN dial selector | PASS | `JfDialSelector` |
| 18. WHAT dial selector | PASS | `JfDialSelector` |
| 19. Selector snap | PASS | Step tests |
| 20. Selector accessibility | PASS | Semantics + edge labels |
| 21. Scan inside panel 04 | PASS | Chassis layout |
| 22–24. Empty validation + top toasts | PASS | Tests |
| 25. Keyboard behavior | PASS | Inset regression test |
| 26. Portrait lock | PASS | Config assertion |
| 27. No fake data/network | PASS | Honest monitor lines |
| 28–29. No Firebase / Gemini | PASS | Exclusions |
| 30–33. Analyze / tests / APK / web | PASS | Verified |
| 34–35. Handoff + physical script | PASS | This document |

## 5. Removed external headers
Removed `01 // STATUS`, `02 // DISPLAY`, `03 // SIGNAL COIL`, `04 // CONTROLS` from Scan Control.

## 6. Panel 01 identity/specification module
`JfMachineIdentityPanel` + `JfRetroDateDisplay`: title, MODEL/VERSION/ACCESS/MODE/ENGINE (+ DEV in debug), local `YYYY.MM.DD` date window. Narrow screens stack date below.

## 7. Panel 02 CRT monitor and scrolling
Square outer frame; rounded inner CRT (`innerRadius` 14); honest lines only; `JfMachineScrollbar` tied to real `ScrollController`; idle track when content fits; draggable thumb when overflowing.

## 8. Panel 03 compact triple-ring visual
`JfSignalCoil` height 72; three concentric phased rings; contained padding; reduced-motion static.

## 9. Panel 04 integrated control chassis
One bordered chassis: location, WHEN dial, WHAT dial, SCAN, locked ADD SIGNAL, debug button (debug only).

## 10. WHEN and WHAT dial selectors
`JfDialSelector`: one visible value; `<`/`>` edges; horizontal drag snap; pointer scroll; keyboard arrows when focused; monitor updates immediately.

## 11. Keyboard and toast regression status
Preserved inset-aware scroll; top Overlay toasts; empty validation + readiness toast tests pass.

## 12. Files created, changed, moved, or deleted
**Created:** `jf_machine_identity_panel.dart`, `jf_crt_monitor.dart`, `jf_dial_selector.dart`, `PASS_02A2_COUNCIL_HANDOFF.md`  
**Changed:** `jf_signal_coil.dart`, `scan_control_screen.dart`, gallery, tests, `PASS_02A1` handoff (physical record), `PASS_02_READINESS.md`, `DECISIONS.md` (ADR-022–024), `jf_machine_status_strip.dart` (legacy stub/export)  
**Deleted:** none of substance

## 13. Commands and actual results

| Command | Result |
|---|---|
| `flutter analyze` | PASS — No issues found |
| `flutter test` | PASS — 23 tests |
| `flutter build apk --debug` | PASS |
| `flutter build web` | PASS |
| `npm run keryx:spike` | NOT RUN |

## 14. Automated tests
No external headers; title once; CRT rounding; date; dial advance; monitor scroll; coil height; reduced motion; toasts; keyboard inset; portrait; no firebase/map/font/carousel deps; debug gate.

## 15. APK and web-build information
- Build command: `flutter build apk --debug`
- Path: `build/app/outputs/flutter-apk/app-debug.apk`
- Existence: VERIFIED
- Size: 160,438,362 bytes (~153.01 MB)
- Package: `com.junkfeathers.localagora` `0.1.0+1`
- Portrait: YES
- Live Keryx / Firebase / Internet / Paid API: **NO**

## 16. Physical Android test script
1. Install new APK. **Expected:** succeeds  
2. Launch. **Expected:** machine face opens  
3. No external `01`/`02`/`03`/`04` headers. **Expected:** absent  
4–7. Inspect panel 01: title, specs, separate retro date. **Expected:** present  
8–11. Panel 02 CRT only; no title/prompt; scroll control when needed. **Expected:** pass  
12–16. Panel 03 shorter; three rings inside; not distracting. **Expected:** pass  
17–18. Panel 04 one box with all controls. **Expected:** pass  
19–20. Keyboard: field + Scan reachable. **Expected:** pass  
21–26. WHEN/WHAT dials: one value, snap, monitor updates. **Expected:** pass  
27–32. Empty/valid scan toasts; no network. **Expected:** pass  
33–34. Rotate → portrait. **Expected:** pass  
35–36. Larger text; force-close/reopen. **Expected:** pass  
37. Record PASS/FAIL and notes.

## 17. Security, privacy, source, and cost impact
No secrets/GPS/Firebase/Gemini. Cursor-only. Paid cost: NONE.

## 18. Known limitations and risks
CRT/dial Stage 1 visual; physical review still required; Node 22 / Firebase / remote pending.

## 19. Founder actions still required
- Node 22: Still pending  
- Firebase CLI: Still pending  
- FlutterFire CLI: Still pending  
- GitHub remote: Still pending  
- Physical review: Required for this APK  

## 20. Recommended next pass
After Jonathan’s physical approval of Pass 02A.2:

**Smallest next pass:** Pass 02B — Wire Scan Control to live Keryx (Firebase/FlutterFire callable only).

Do not begin Pass 02B until 02A.2 physical approval is recorded.
