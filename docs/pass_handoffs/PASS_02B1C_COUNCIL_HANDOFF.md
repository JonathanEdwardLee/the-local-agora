# THE LOCAL AGORA — PASS 02B.1C COUNCIL HANDOFF

## 1. Pass identity
- Objective: Move search controls into a dedicated Search Parameter dialog; recover vertical space for a taller CRT; replace amber empty-location validation with faded phosphor green.
- Status: **COMPLETE — awaiting physical Android review**
- Branch: `pass-02b1c-parameter-dialog-monitor-height`
- Commit: *(recorded after commit)*
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
Pass 02B.1C is the final narrow UI refinement before live Keryx activation. Panel 04 is now a compact search-launch deck. Location, WHEN, and WHAT live in `JfSearchParameterDialog` and update shared state immediately; Close only dismisses. CRT height increases via responsive sizing while the approved lower art/control band stays locked at 72. Empty-location validation uses `JfColors.validationPhosphor` on the error dialog and invalid field only. Firebase, Functions, Keryx transport, and local-only Scan are unchanged. No cloud deploy.

## 3. Pre-code inspection
- Started from `pass-02b1b-monitor-control-refinement` tip `c877d82649072859f66415f94f231c66252dc939`
- Working tree clean before coding
- Governing docs read; Panel 01/02/04, dials, toasts, gallery, and tests inspected
- Cloud changes: **NO**
- Firebase changes: **NO**
- Backend changes: **NO**
- New APK required: **YES**

## 4. Pass 02B.1B physical-result record
Recorded in `docs/pass_handoffs/PASS_02B1B_COUNCIL_HANDOFF.md` §19.

Result: `VISUAL FOUNDATION APPROVED — FINAL PANEL 04 REFINEMENT REQUESTED`

- Panel 01 approved
- Combined Panel 02 approved
- Merged signal art approved
- Decorative indicator board approved
- No separate Panel 03 approved
- Keryx link still approved
- Panel 04 needs one final control-layout revision
- CRT should receive recovered vertical space

## 5. Locked Panel 01 verification
Panel 01 (`JfMachineIdentityPanel`) was not modified. Regression tests still assert title, date, specification line, and compact height.

## 6. Locked Panel 02 art verification
Combined `JfMonitorModule` outer composition preserved:
- CRT frame/screen styling, scrollbar, `WAITING FOR SCAN...`
- Lower band height **72** (locked)
- Square three-ring signal art (not vertically stretched)
- Decorative indicator board + flicker behavior
- No separate Panel 03

## 7. CRT monitor-height increase
- Previous default CRT height in 02B.1B: **220**
- New default: **300**
- Responsive: `JfMonitorModule.resolveMonitorHeight` → `(viewportHeight * 0.40).clamp(260, 360)`
- CRT remains taller than the lower art/control band
- Band internal proportions unchanged

## 8. Compact Panel 04 main deck
In order:
1. Instruction: `Search for an event` (supporting text, not warning-colored)
2. Primary button: `INPUT SEARCH PARAMETERS`
3. Scan button: `SCAN THE AGORA` (local-only behavior preserved)
4. Optional compact summary line when location is present (e.g. `SPRINGFIELD, MISSOURI // TONIGHT // MUSIC`)
5. Locked `ADD SIGNAL`; debug `DEBUG // COMPONENTS` unchanged

Location field, WHEN dial, and WHAT dial are **not** permanently visible on the main deck.

## 9. Search Parameter dialog
`JfSearchParameterDialog` / `showJfSearchParameterDialog`:
- Square machine dialog (no Material rounded card / elevation)
- Title: `SEARCH PARAMETERS`
- Instruction: `Choose a city or ZIP code, then set WHEN and WHAT.`
- Location field (shared controller/state/validation)
- Standalone WHEN dial (pre-02B.1B interaction style)
- Standalone WHAT dial (stacked beneath WHEN)
- `CLOSE` pinned below scroll body; keyboard-safe scroll for field + dials
- State updates immediately; Close only dismisses

## 10. WHEN and WHAT dial restoration
Standalone `JfDialSelector` controls restored inside the dialog (not side-by-side reveal buttons). Approved enum values unchanged. Monitor lines update while the dialog remains open.

## 11. Validation and faded-green error treatment
- Token: `JfColors.validationPhosphor` (`0xFF6B9B6E`) + `JfTypography.validationError`
- Empty Scan → square `LOCATION REQUIRED` dialog with phosphor border/body
- Secondary action: `INPUT SEARCH PARAMETERS`
- Invalid location field uses phosphor border/label/error text
- Persistent invalid state until a valid value is entered
- Ordinary info toasts (`SCAN CONTROL READY`, etc.) remain monochrome
- Amber/yellow removed from this empty-location validation path

## 12. Preserved Firebase and Keryx behavior
- No Firebase config / FlutterFire / Functions source changes
- `TEST KERYX LINK` remains in debug gallery
- Keryx link service / callable transport unchanged
- Main Scan remains local-only (no live event search, no Gemini)
- Portrait lock unchanged
- Backend files changed: **NO**

## 13. Acceptance criteria
| Criterion | Status | Evidence |
|---|---|---|
| 1. Governing documents were read | PASS | Pre-code |
| 2. Working tree was clean before coding | PASS | Started from clean 02B.1B tip |
| 3. Pass 02B.1B physical result was recorded | PASS | PASS_02B1B §19 |
| 4. Panel 01 was not changed | PASS | Diff + tests |
| 5. Panel 02 art/control band was not changed | PASS | Band height 72; art widgets unchanged in appearance |
| 6. CRT monitor height increased | PASS | 220 → responsive 260–360 (default 300) |
| 7. CRT scrollbar remains | PASS | Widget test |
| 8. Waiting prompt remains | PASS | Widget test |
| 9. No separate Panel 03 exists | PASS | Layout + test |
| 10. Main Panel 04 shows the approved instruction | PASS | `Search for an event` |
| 11. Main Panel 04 shows the parameter button | PASS | `INPUT SEARCH PARAMETERS` |
| 12. Main Panel 04 shows the Scan button | PASS | `SCAN THE AGORA` |
| 13. Main location field was removed | PASS | No permanent TextField |
| 14. Main WHEN control was removed | PASS | Dial only in dialog |
| 15. Main WHAT control was removed | PASS | Dial only in dialog |
| 16. Parameter button opens the dialog | PASS | Widget test |
| 17. Dialog contains location input | PASS | Widget test |
| 18. Dialog contains standalone WHEN dial | PASS | Widget test |
| 19. Dialog contains standalone WHAT dial | PASS | Widget test |
| 20. Dialog contains Close | PASS | Widget test |
| 21. Parameter state persists | PASS | Widget test |
| 22. Monitor reflects parameter changes | PASS | Widget test |
| 23. Empty Scan shows an error dialog | PASS | LOCATION REQUIRED |
| 24. Invalid location field is marked | PASS | Phosphor field error |
| 25. Faded green limited to error dialog + invalid field | PASS | Token usage + tests |
| 26. Yellow/amber absent from this validation path | PASS | Widget test |
| 27. Info messages remain ordinary monochrome | PASS | SCAN CONTROL READY test |
| 28. Keyboard-safe behavior passes | PASS | Inset/scroll dialog body |
| 29. Portrait lock passes | PASS | Config test |
| 30. Keryx link remains available | PASS | Debug gallery + keryx tests |
| 31. Main Scan remains local-only | PASS | Source + tests |
| 32. No Firebase files changed | PASS | Diff scope |
| 33. No backend files changed | PASS | Diff scope |
| 34. No cloud deploy occurred | PASS | Not run |
| 35. Flutter analyze passes | PASS | No issues |
| 36. Flutter tests pass | PASS | 36 tests |
| 37. Debug APK builds | PASS | §17 |
| 38. Web build exists | PASS | §17 |
| 39. Complete handoff exists | PASS | This file |
| 40. Drive-sync status is explicit | PASS | §18 |

## 14. Files created, changed, moved, or deleted
**Created:**
- `lib/design/jf_search_parameter_dialog.dart`
- `docs/pass_handoffs/PASS_02B1C_COUNCIL_HANDOFF.md`

**Changed:**
- `lib/design/junkfeathers_tokens.dart` — `validationPhosphor` + validation typography
- `lib/design/junkfeathers_theme.dart` — error/input theme uses phosphor
- `lib/design/jf_machine_field.dart` — invalid field uses phosphor
- `lib/design/jf_oled_dialog.dart` — `validationError` + optional secondary action
- `lib/design/jf_monitor_module.dart` — taller responsive CRT; band locked
- `lib/features/scan_control/scan_control_screen.dart` — compact Panel 04 + dialog flow
- `lib/features/debug/debug_component_gallery.dart` — 02B.1C demos
- `test/widget_test.dart`, `test/keryx_link_test.dart`
- `docs/pass_handoffs/PASS_02B1B_COUNCIL_HANDOFF.md` — physical result §19
- `docs/PASS_02_READINESS.md`
- `docs/DECISIONS.md` — ADR-036; ADR-035 note

**Deleted:** none  
**Backend / Firebase / Functions:** none

## 15. Commands and actual results
| Command | Result |
|---|---|
| `flutter pub get` | PASS |
| `flutter analyze` | PASS — No issues found |
| `flutter test` | PASS — 36 tests |
| `flutter build apk --debug` | PASS |
| `flutter build web` | PASS |
| `firebase deploy` | NOT RUN |
| Functions tests | NOT RUN — backend intentionally untouched |

Backend files changed: **NO**

## 16. Automated tests
Locked Panel 01/02; taller CRT; compact Panel 04; parameter dialog open/persist/close; phosphor validation; no amber on empty-location path; monochrome info toast; local-only Scan; Firebase/Keryx unchanged; portrait lock; dependency guards.

## 17. APK and web-build information
- Exact APK path: `build/app/outputs/flutter-apk/app-debug.apk`
- File existence: **YES**
- File size: **162,481,143** bytes (~154.9 MB)
- Package name: `com.junkfeathers.localagora`
- Version: `0.1.0`
- Build number: `1`
- Panel 01 changed: **NO**
- Panel 02 art changed: **NO**
- CRT height increased: **YES**
- Panel 04 restructured: **YES**
- Firebase config changed: **NO**
- Keryx transport changed: **NO**
- Backend deployed: **NO**
- Live event search enabled: **NO**
- Web: `build/web/index.html` exists

## 18. DRIVE SYNC STATUS
```text
DRIVE SYNC STATUS: REQUIRED
```
Files requiring sync:
- `docs/DECISIONS.md` — updated — ADR-036 search parameter dialog + phosphor validation; ADR-035 note
- `docs/PASS_02_READINESS.md` — updated — Pass 02B.1C readiness
- `docs/pass_handoffs/PASS_02B1B_COUNCIL_HANDOFF.md` — updated — physical result §19
- `docs/pass_handoffs/PASS_02B1C_COUNCIL_HANDOFF.md` — created — this handoff

Do not create the final Drive ZIP until physical approval unless protocol requires a provisional package. Jonathan/council handle Drive upload after review.

## 19. Physical Android test script
1. Launch the app.
2. Confirm Panel 01 is unchanged.
3. Confirm the combined Panel 02 art/control band is unchanged.
4. Confirm the CRT monitor is visibly taller.
5. Confirm the monitor scrollbar still works.
6. Confirm the waiting prompt remains.
7. Confirm there is no separate Panel 03.
8. Confirm Panel 04 says `Search for an event`.
9. Confirm `INPUT SEARCH PARAMETERS` appears.
10. Confirm `SCAN THE AGORA` appears underneath.
11. Confirm no location field is permanently visible on the main deck.
12. Confirm no WHEN or WHAT dial is permanently visible.
13. Tap `INPUT SEARCH PARAMETERS`.
14. Confirm the Search Parameter dialog opens.
15. Confirm the instruction reads: `Choose a city or ZIP code, then set WHEN and WHAT.`
16. Confirm the location input appears.
17. Confirm the standalone WHEN dial appears.
18. Confirm the standalone WHAT dial appears.
19. Change WHEN.
20. Change WHAT.
21. Close the dialog.
22. Confirm selections persist.
23. Confirm the monitor reflects them.
24. Reopen the dialog.
25. Confirm location and selections remain.
26. Clear the location.
27. Close the dialog.
28. Press `SCAN THE AGORA`.
29. Confirm a square error dialog appears.
30. Confirm the error treatment is faded phosphor green.
31. Confirm no yellow appears.
32. Open Search Parameters.
33. Confirm only the invalid location field uses faded green.
34. Enter a valid city or ZIP code.
35. Confirm the field error clears.
36. Close the dialog.
37. Press Scan.
38. Confirm the ordinary info message is not green or yellow.
39. Open the keyboard in the parameter dialog.
40. Confirm all controls remain reachable by scrolling.
41. Open `DEBUG // COMPONENTS`.
42. Confirm `TEST KERYX LINK` still returns ready.
43. Confirm main Scan still does not perform a live event search.
44. Rotate the phone.
45. Confirm portrait lock.
46. Force-close and reopen.
47. Confirm the selected parameters behave as currently intended.
48. Record PASS/FAIL and any final refinements.

## 20. Security, privacy, cloud, and cost impact
No secrets changed. No Firebase deploy. No Gemini. No new network calls from Scan. Phosphor validation is local UI only.

## 21. Known limitations and risks
- Physical review still required before live Keryx
- Optional parameter summary is compact; may wrap on very narrow widths
- Dialog route exit animation requires a short settle in automated tests (infinite indicator animations prevent `pumpAndSettle`)

## 22. Founder next action
Install the Pass 02B.1C debug APK and run §19.

**Recommend no live-Keryx work until this final UI pass is physically approved.**

After physical approval, the next logical pass remains:

**Pass 02B.2 — Secure Live Keryx Scan Activation**
