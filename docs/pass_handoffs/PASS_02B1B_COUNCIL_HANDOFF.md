# THE LOCAL AGORA — PASS 02B.1B COUNCIL HANDOFF

## 1. Pass identity
- Objective: Combine panels 02/03 into one monitor module; refine Panel 04 WHEN/WHAT reveal/collapse; preserve Firebase link and local-only scan behavior.
- Status: **COMPLETE — awaiting physical Android review**
- Branch: `pass-02b1b-monitor-control-refinement`
- Commit: `2aeb6857ce581d065f604825a878ef3ccbdb569d`
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
Pass 02B.1B is a UI-only refinement after Jonathan’s physical approval of Pass 02B.1 (including Keryx link). The main screen no longer shows a separate Panel 03. Panel 02 is one assembled module: taller CRT plus a lower band with square triple-ring art and a decorative non-interactive indicator board. Panel 04 keeps the location field and uses side-by-side WHEN/WHAT buttons that reveal one dial at a time and collapse after selection. Firebase, Functions, and Keryx transport are unchanged. No cloud deploy.

## 3. Pre-code inspection
- Started from `pass-02b1-firebase-link-foundation` @ `3d7dcf80bf93b763cbd466d56bcabebdd0908eef`
- Working tree clean
- Governing docs read; current CRT, coil, dials, gallery, and tests inspected
- No unrelated modifications; no secret-risk blockers

## 4. Physical approval record for Pass 02B.1
Recorded in `docs/pass_handoffs/PASS_02B1_COUNCIL_HANDOFF.md` §25.  
Result: `FUNCTIONALITY APPROVED — UI REFINEMENT REQUESTED`  
Keryx link passed; ordinary scan remained local-only; Panel 01 and monitor approved; UI refinements requested for combined monitor/control layout and Panel 04 selector reveal.

## 5. Combined panel 02 monitor module
- New `JfMonitorModule`: single outer frame
- Upper: `JfCrtMonitor` (framed: false when embedded), height **220** (was 180)
- Scrollbar and `WAITING FOR SCAN...` preserved
- Selection readouts unchanged

## 6. Lower signal-art and decorative indicator band
- Left: square `JfSignalCoil` (height 72, `square: true`), three rings, ticks, scan line, ClipRect, reduced-motion static
- Right: `JfIndicatorBoard` — 3×8 decorative indicators, restrained flicker, IgnorePointer, reduced-motion static
- No separate primary Panel 03 on the main screen

## 7. Panel 04 selector reveal/collapse refinement
- Location field unchanged
- Side-by-side `WHEN // …` and `WHAT // …` selectable machine buttons
- Exclusive reveal: only one dial open
- Selection collapses the dial; re-tapping open button also collapses
- Dial values/snap/semantics preserved; monitor updates immediately

## 8. Regressions checked and preserved
- `TEST KERYX LINK` (debug gallery)
- Local-only `SCAN THE AGORA`
- Top warning/info toasts
- Keyboard inset scroll
- Portrait lock
- Firebase init / packages / project binding
- No Functions source changes; no deploy

## 9. Acceptance criteria
| Criterion | Status | Evidence |
|---|---|---|
| 1. Governing files read | PASS | Pre-code |
| 2. Pass 02B.1 physical result recorded | PASS | PASS_02B1 §25 |
| 3. No separate main panel 03 | PASS | Scan Control layout |
| 4. Combined panel 02 | PASS | JfMonitorModule |
| 5. Monitor intact/scrollable | PASS | CRT + scrollbar tests |
| 6. Monitor taller than before | PASS | height 220 > 180 |
| 7. Lower band inside panel 02 | PASS | Module composition |
| 8. Square-ish bounded art | PASS | square coil size test |
| 9. Three rings visible | PASS | ringCount 3 |
| 10. Decorative indicators exist | PASS | JfIndicatorBoard |
| 11. Safe flicker | PASS | Throttled animation |
| 12. Reduced-motion safe | PASS | forceStatic tests |
| 13. Location field kept | PASS | Panel 04 |
| 14. WHEN/WHAT side by side | PASS | Row + test |
| 15. WHEN reveal works | PASS | Widget test |
| 16. WHAT reveal works | PASS | Widget test |
| 17. Only one reveal open | PASS | Widget test |
| 18. Auto-collapse after choice | PASS | Widget test |
| 19. Monitor updates selection | PASS | Widget test |
| 20. Keyboard approved | PASS | Inset test |
| 21. Top warning toast | PASS | Empty location test |
| 22. Top info toast | PASS | Ready toast test |
| 23. TEST KERYX LINK debug | PASS | Gallery + kDebugMode |
| 24. Scan local-only | PASS | Source + tests |
| 25. No Firebase config change | PASS | Diff scope |
| 26. No backend deploy | PASS | Not run |
| 27. Flutter analyze | PASS | No issues |
| 28. Flutter tests | PASS | 44 tests |
| 29. Debug APK exists | PASS | §13 |
| 30. Web build exists | PASS | §13 |
| 31. Complete handoff | PASS | This file |

## 10. Files created, changed, moved, or deleted
**Created:** `lib/design/jf_monitor_module.dart`, `lib/design/jf_indicator_board.dart`, `docs/pass_handoffs/PASS_02B1B_COUNCIL_HANDOFF.md`  
**Changed:** `jf_crt_monitor.dart` (`framed`), `jf_signal_coil.dart` (`square`), `scan_control_screen.dart`, `debug_component_gallery.dart`, tests, `PASS_02B1` handoff (physical record), `PASS_02_READINESS.md`, `DECISIONS.md` (ADR-035)  
**Deleted:** none

## 11. Commands and actual results
| Command | Result |
|---|---|
| `flutter pub get` | PASS (via analyze/test) |
| `flutter analyze` | PASS — No issues found |
| `flutter test` | PASS — 44 tests |
| `flutter build apk --debug` | PASS |
| `flutter build web` | PASS (see §13) |
| `firebase deploy` | NOT RUN |
| Functions tests | NOT RUN — backend intentionally untouched |

## 12. Automated tests
Combined module; taller monitor; square coil; indicator board non-interactive; WHEN/WHAT reveal/collapse/exclusivity; monitor updates; keyboard; toasts; local scan; Firebase config unchanged; dependency guards; Keryx link tests updated for reveal flow.

## 13. APK and web-build information
- Exact APK path: `build/app/outputs/flutter-apk/app-debug.apk`
- File existence: YES
- File size: 162,475,098 bytes (~154.9 MB)
- Package name: `com.junkfeathers.localagora`
- Version: `0.1.0`
- Build number: `1`
- Keryx link logic changed: **NO**
- Firebase config changed: **NO**
- Backend deployed: **NO**
- Web: `build/web/index.html` exists

## 14. DRIVE SYNC STATUS
```text
DRIVE SYNC STATUS: REQUIRED
```
Files requiring sync:
- `docs/DECISIONS.md` — updated — ADR-035 combined monitor + selector reveal
- `docs/PASS_02_READINESS.md` — updated — Pass 02B.1B readiness
- `docs/pass_handoffs/PASS_02B1_COUNCIL_HANDOFF.md` — updated — Physical Test 02B.1 record
- `docs/pass_handoffs/PASS_02B1B_COUNCIL_HANDOFF.md` — created — this handoff

Do not perform Drive sync in this pass; Jonathan/council handle after review.

## 15. Physical Android test script
1. Launch app. **Expected:** machine face opens  
2. Confirm no separate main 03 panel. **Expected:** absent  
3. Confirm panel 02 contains the taller monitor. **Expected:** yes  
4. Confirm monitor still scrolls. **Expected:** scrollbar works when needed  
5. Confirm lower left square signal art exists. **Expected:** yes  
6. Confirm three rings remain visible. **Expected:** yes  
7. Confirm right-side decorative indicator field exists. **Expected:** yes  
8. Confirm decorative indicators flicker safely. **Expected:** slow/restrained  
9. Confirm panel 04 shows location field. **Expected:** yes  
10. Confirm `WHEN` and `WHAT` buttons are side by side. **Expected:** yes  
11. Open WHEN. **Expected:** WHEN dial appears  
12. Select a WHEN option. **Expected:** value changes  
13. Confirm the dial collapses. **Expected:** dial hidden  
14. Open WHAT. **Expected:** WHAT dial appears  
15. Select a WHAT option. **Expected:** value changes  
16. Confirm the dial collapses. **Expected:** dial hidden  
17. Confirm monitor reflects the selected values. **Expected:** WINDOW/SIGNAL TYPE lines update  
18. Open keyboard. **Expected:** opens  
19. Confirm field and controls remain reachable. **Expected:** yes  
20. Test top warning toast (empty Scan). **Expected:** LOCATION REQUIRED  
21. Test top info toast (valid Scan). **Expected:** SCAN CONTROL READY  
22. Open DEBUG // COMPONENTS. **Expected:** gallery opens  
23. Confirm `TEST KERYX LINK` still works. **Expected:** ready/unavailable honest result  
24. Confirm main scan is still local-only. **Expected:** no event results  
25. Rotate device and confirm portrait lock. **Expected:** stays portrait  
26. Record PASS/FAIL and refinements.

## 16. Security, privacy, and cloud impact
No secrets changed. No Firebase deploy. No Gemini. No new network calls from Scan. Decorative indicators are local-only animation.

## 17. Known limitations and risks
- Physical review of combined layout still required
- Long WHEN/WHAT labels may wrap on narrow widths inside toggle buttons
- Live Keryx still deferred

## 18. Founder next action
Install the Pass 02B.1B debug APK and run §15. After physical approval, the smallest next logical pass remains:

**Pass 02B.2 — Secure Live Keryx Scan Activation**

(Do not begin until UI approval is recorded.)

---

## 19. Physical result record (Pass 02B.1C intake)

**Date:** 2026-07-10  
**Result:** `VISUAL FOUNDATION APPROVED — FINAL PANEL 04 REFINEMENT REQUESTED`

Recorded findings (do not erase earlier evidence above):
- Panel 01 approved
- Combined Panel 02 approved
- Merged signal art approved
- Decorative indicator board approved
- No separate Panel 03 approved
- Keryx link still approved
- Panel 04 needs one final control-layout revision (search parameter dialog)
- CRT should receive the recovered vertical space from the simplified Panel 04

Follow-on pass: `pass-02b1c-parameter-dialog-monitor-height` — see `docs/pass_handoffs/PASS_02B1C_COUNCIL_HANDOFF.md`.
