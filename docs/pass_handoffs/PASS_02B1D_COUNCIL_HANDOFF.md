# THE LOCAL AGORA — PASS 02B.1D COUNCIL HANDOFF

## 1. Pass identity
- Objective: Fix Search Parameter dialog so the location field remains visible above the keyboard.
- Status: **PHYSICALLY APPROVED — READY FOR MAIN**
- Branch: `pass-02b1d-keyboard-safe-parameter-dialog`
- Commit: abde8bfc343c43221bcf7c3412c28d6d8c7ec0c3
- Tip: `f15ab99a8df1ff625a98a567557c60962c5ea62a` (handoff hash record; approval commit follows)
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
Pass 02B.1D is a narrow keyboard bug-fix only. Flutter’s `Dialog` already pads for `viewInsets` and strips them from child `MediaQuery`. The 02B.1C dialog still sized itself to `0.86 × full screen height`, so when the keyboard opened the dialog overflowed upward and the location field left the visible area. The fix sizes the dialog face to the remaining height above the real keyboard inset, keeps the scrollable body, and ensures the focused location field into view. No approved visual redesign. No Firebase/Functions/Keryx/scan changes. No cloud deploy.

## 3. Pre-code inspection
- Started from clean `pass-02b1c-parameter-dialog-monitor-height` tip `c347dcd`
- Working tree clean
- Governing docs + dialog/field/main-screen inset pattern inspected
- Cloud / Firebase / backend: **NO**
- New APK: **YES**

## 4. Pass 02B.1C physical result
Recorded in `docs/pass_handoffs/PASS_02B1C_COUNCIL_HANDOFF.md` §23.

Result: `FUNCTIONALLY APPROVED — KEYBOARD VISIBILITY FIX REQUIRED`

## 5. Keyboard regression cause
1. Flutter `Dialog` applies `AnimatedPadding(viewInsets + insetPadding)` and then `MediaQuery.removeViewInsets` for children.
2. Child `MediaQuery.viewInsets.bottom` is therefore **0** inside the dialog body.
3. `maxHeight = screenHeight * 0.86` ignored the keyboard, so the dialog was taller than the space above the keyboard.
4. Centering that oversized dialog pushed the top (location field) off-screen.

## 6. Proven prior keyboard-safe pattern
Main Scan Control deck (Passes 02A–02B.1B):
- `MediaQuery.viewInsetsOf(context).bottom`
- `SingleChildScrollView` padding includes `JfSpacing.lg + bottomInset`
- Scaffold `resizeToAvoidBottomInset` (default)

Design system ADR-020 / keyboard behavior rule: inset-aware scrollable input surfaces.

Dialog adaptation (this pass): read raw inset via `MediaQueryData.fromView(View.of(context)).viewInsets.bottom`, constrain dialog height to remaining space, scroll + `Scrollable.ensureVisible` on focus.

## 7. Search Parameter dialog fix
In `jf_search_parameter_dialog.dart`:
- `_maxDialogHeight` = `(size.height - keyboardBottom - vertical inset chrome).clamp(240, size.height * 0.86)`
- Removed ineffective internal `+ bottomInset` padding (was 0 under Dialog’s removed insets)
- `ScrollController` + post-frame `Scrollable.ensureVisible` for the location field on focus
- `TextInputAction.done` / `onEditingComplete` unfocuses (dismisses keyboard) without closing the dialog
- WHEN / WHAT remain in the scroll body; CLOSE stays pinned and above the keyboard with correct sizing

## 8. State and validation preservation
Location controller, WHEN/WHAT, phosphor invalid styling, persistence after Close, monitor updates, portrait lock, local-only Scan — unchanged.

## 9. Locked UI verification
Panel 01, Panel 02 art/CRT styling/height policy, compact Panel 04 copy/buttons, dial styling, phosphor token, info toasts — not redesigned.

## 10. Test-count investigation
| Pass | Approx. `flutter test` count | Notes |
|---|---|---|
| 02B.1B | **44** | Reveal/collapse WHEN/WHAT tests + full geometry regressions |
| 02B.1C | **36** | Widget tests rewritten for compact Panel 04 + dialog; reveal tests removed (superseded); some static/reduced-motion/Gemini/source-gate regressions dropped during rewrite |
| 02B.1D | **47** | Restored meaningful lost regressions; added keyboard-safe dialog tests; did **not** restore superseded reveal/collapse tests |

Restored (not duplicates of dialog coverage):
- reduced-motion waiting prompt / coil / indicator
- scrollbar fits case
- indicator board non-interactive
- debug gallery source gate
- no Gemini key in sources
- no keyboard-only dependency

Intentionally not restored: side-by-side WHEN/WHAT reveal tests (replaced by parameter dialog coverage in 02B.1C).

## 11. Acceptance criteria
| Criterion | Status | Evidence |
|---|---|---|
| 1. Required files were read | PASS | Pre-code |
| 2. Working tree was clean | PASS | Clean 02B.1C tip |
| 3. Pass 02B.1C physical result was recorded | PASS | PASS_02B1C §23 |
| 4. Keyboard regression cause was identified | PASS | §5 |
| 5. Proven earlier keyboard-safe behavior was inspected | PASS | §6 |
| 6. Location field remains visible when keyboard opens | PASS | Widget tests + fix |
| 7. Cursor and typed text remain visible | PASS | enterText under inset test |
| 8. Dialog responds to real view insets | PASS | fromView inset sizing |
| 9. Dialog scrolls when necessary | PASS | ScrollView + ensureVisible |
| 10. WHEN remains reachable | PASS | ensureVisible test |
| 11. WHAT remains reachable | PASS | ensureVisible test |
| 12. Close remains reachable | PASS | ensureVisible test |
| 13. Keyboard dismissal does not close the dialog | PASS | Widget test |
| 14. Dialog Close still preserves parameters | PASS | Existing persist test |
| 15. Invalid-field treatment remains unchanged | PASS | Phosphor tests |
| 16. Valid entry clears validation | PASS | Widget test |
| 17. Panel 01 is unchanged | PASS | Diff scope |
| 18. Panel 02 is unchanged | PASS | Diff scope |
| 19. Panel 04 design is unchanged | PASS | Diff scope |
| 20. Keryx link behavior is unchanged | PASS | Diff + keryx tests |
| 21. Main Scan remains local-only | PASS | Source test |
| 22. Portrait lock remains | PASS | Config test |
| 23. No Firebase files changed | PASS | Diff scope |
| 24. No backend files changed | PASS | Diff scope |
| 25. No cloud deployment occurred | PASS | Not run |
| 26. Test-count change was investigated | PASS | §10 |
| 27. Meaningful lost tests were restored if needed | PASS | §10 |
| 28. Flutter analyze passes | PASS | No issues |
| 29. Flutter tests pass | PASS | 47 tests |
| 30. Debug APK builds | PASS | §15 |
| 31. Web build exists | PASS | §15 |
| 32. Complete handoff exists | PASS | This file |
| 33. Drive-sync status is explicit | PASS | §17 |

## 12. Files created, changed, moved, or deleted
**Created:** `docs/pass_handoffs/PASS_02B1D_COUNCIL_HANDOFF.md`
**Changed:**
- `lib/design/jf_search_parameter_dialog.dart` — keyboard-safe height + ensureVisible
- `lib/design/jf_machine_field.dart` — optional `onEditingComplete`
- `test/widget_test.dart` — keyboard dialog tests + restored regressions
- `docs/pass_handoffs/PASS_02B1C_COUNCIL_HANDOFF.md` — physical result §23
- `docs/PASS_02_READINESS.md`
- `docs/DECISIONS.md` — ADR-036 keyboard-safe dialog note

**Deleted:** none
**Backend / Firebase:** none

## 13. Commands and actual results
| Command | Result |
|---|---|
| `flutter pub get` | PASS |
| `flutter analyze` | PASS — No issues found |
| `flutter test` | PASS — **47** tests |
| `flutter build apk --debug` | PASS |
| `flutter build web` | PASS |
| `firebase deploy` | NOT RUN |

`BACKEND FILES CHANGED: NO`

## 14. Automated tests
Keyboard inset visibility (two viewport sizes); dismiss keyboard keeps dialog; restored reduced-motion / scrollbar / indicator / Gemini / source-gate regressions; prior 02B.1C dialog/validation/local-scan coverage retained.

## 15. APK and web-build information
- Exact APK path: `build/app/outputs/flutter-apk/app-debug.apk`
- File existence: **YES**
- File size: **162,484,951** bytes (~154.9 MB)
- Package name: `com.junkfeathers.localagora`
- Version: `0.1.0`
- Build number: `1`
- Keyboard visibility fixed: **YES**
- Panel 01 changed: **NO**
- Panel 02 changed: **NO**
- Panel 04 design changed: **NO**
- Firebase changed: **NO**
- Keryx transport changed: **NO**
- Backend deployed: **NO**
- Live event search enabled: **NO**
- Web: `build/web/index.html` exists

## 16. GitHub push
- Branch: `pass-02b1d-keyboard-safe-parameter-dialog`
- Upstream: `origin/pass-02b1d-keyboard-safe-parameter-dialog` (after push)
- `main` not updated

## 17. DRIVE SYNC STATUS
```text
DRIVE SYNC STATUS: REQUIRED
```
Files requiring sync (approved repository versions for Drive mirror after main integration):
- `docs/DECISIONS.md` — ADR-036 keyboard-safe dialog note
- `docs/PASS_02_READINESS.md` — Pass 02B.1D readiness + physical approval
- `docs/pass_handoffs/PASS_02B1C_COUNCIL_HANDOFF.md` — physical result intake
- `docs/pass_handoffs/PASS_02B1D_COUNCIL_HANDOFF.md` — this handoff + physical approval

Package: `build/drive_sync/PASS_02B1D_MAIN_DRIVE_SYNC.zip` (created at main integration; not committed).

## 18. Physical Android test script
1. Install and launch the APK.
2. Confirm Panel 01 is unchanged.
3. Confirm Panel 02 is unchanged.
4. Confirm the compact Panel 04 is unchanged.
5. Tap `INPUT SEARCH PARAMETERS`.
6. Confirm the dialog opens.
7. Tap the location field.
8. Confirm the keyboard opens.
9. Confirm the location field remains visible.
10. Type several words.
11. Confirm the cursor and typed text remain visible.
12. Continue typing enough text to test horizontal or line behavior.
13. Confirm the field does not move behind the keyboard.
14. Scroll downward while the keyboard is open.
15. Confirm WHEN is reachable.
16. Confirm WHAT is reachable.
17. Confirm CLOSE is reachable.
18. Change WHEN.
19. Change WHAT.
20. Confirm the location text remains intact.
21. Dismiss the keyboard.
22. Confirm the dialog remains open.
23. Focus the field again.
24. Confirm it becomes visible again.
25. Clear the location.
26. Close the dialog.
27. Press Scan.
28. Confirm the phosphor-green location error still works.
29. Reopen Search Parameters.
30. Confirm the invalid field is visible above the keyboard.
31. Enter `Springfield, Missouri`.
32. Confirm the field error clears.
33. Close the dialog.
34. Confirm the monitor reflects WHEN and WHAT.
35. Confirm `TEST KERYX LINK` still returns ready.
36. Confirm Scan remains local-only.
37. Confirm portrait lock.
38. Record PASS/FAIL.

## 19. Security, privacy, cloud, and cost impact
No secrets changed. No Firebase deploy. No Gemini. No new dependencies. Local UI layout fix only.

## 20. Known limitations and risks
- Very large keyboards on short devices leave a compact dialog viewport; scrolling remains required for WHEN/WHAT

## 21. Founder next action
Physical approval recorded. Integrate into `main`, then proceed to Pass 02B.2A (secure live Keryx debug scan) on a new branch from approved `main`.

---

## 22. Physical approval record (main integration)

**Date:** 2026-07-10
**Result:** `PASS 02B.1D PHYSICALLY APPROVED`
**Integration status:** `PHYSICALLY APPROVED — READY FOR MAIN`

Founder physical results:
- Location field remains visible above the keyboard
- Cursor and entered text remain visible
- Dialog scrolls while the keyboard is open
- WHEN remains reachable
- WHAT remains reachable
- CLOSE remains reachable
- Keyboard Done leaves the dialog open
- Refocusing returns the location field to view
- Validation still works
- Keryx status link still works
- Main Scan remains local-only
- Portrait lock remains active
- All other approved UI remains correct

Authorization: founder authorized integration into `main`.
