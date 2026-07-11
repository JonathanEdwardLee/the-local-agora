# THE LOCAL AGORA — PASS 02C COUNCIL HANDOFF

## 1. Pass identity
- Objective: Integrate canonical Junkfeathers Universal Splash + Local Agora Welcome dialog over main
- Status: **READY FOR PHYSICAL ANDROID REVIEW** (stop for founder approval; do not merge)
- Branch: `pass-02c-universal-splash-welcome`
- Starting approved commit (02B.2A tip): `19bbaf284c3eea12fc617408d97ffba8ff6a3f3e`
- Ending commit: `eacac43f55ab9b24b5a9bde04ee3ba9d954153f7`
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
Pass 02C wires the founder-supplied universal Junkfeathers Tech splash into an app-owned `StartupGate` (`onComplete`, not `Navigator.pushReplacement`), then shows the existing Scan Control shell. A first-run Welcome dialog appears over the real main app with CLOSE / DON'T SHOW AGAIN. Permanent suppression uses local `shared_preferences` only. Manual reopen is a subordinate production `ABOUT` control. Proven Keryx / Gemini pipeline was not expanded; no live Gemini calls; no function redeploy.

## 3. Startup sequence (shipped)
```text
APP LAUNCH
    ↓
JUNKFEATHERS TECH UNIVERSAL SPLASH (990 + 1000 + 880 = 2870 ms)
    ↓
EXISTING LOCAL AGORA MAIN APP (Scan Control)
    ↓
Welcome dialog over main when automatic display is appropriate
```
No Local Agora product splash. No tagline interstitial. No onboarding carousel.

## 4. Universal splash
- Canonical reference: `docs/Junkfeathers Universal Splash/`
- Runtime: `lib/brand/junkfeathers_splash/` (copied; no `docs/` imports)
- Compatibility changes to universal sources: **none** (formatting only if applied by `dart format`)
- Local Agora tips: `lib/brand/local_agora_splash_tips.dart` (tip01–tip08 approved copy)
- One tip per launch; empty tips safe; reduced motion respected

## 5. Welcome dialog
- Copy: exact ADR-037 / Pass 02C founder text (`docs/LOCAL_AGORA_WELCOME_DIALOG.md`)
- CLOSE: dismiss without permanent suppression
- DON'T SHOW AGAIN: `hasDismissedAgoraWelcomePermanently` via `shared_preferences`
- Manual reopen: Scan Control `ABOUT` (ignores suppression)
- Visual: monospace, black, 2 px square border, no elevation/shadows

## 6. Persistence
- Dependency added: `shared_preferences` (approved in pre-code report)
- Not Firebase / Auth / Storage / Remote Config

## 7. Known limitations
- Firebase + App Check still initialize before `runApp` (may delay first paint; splash remains network-independent)
- No formal shared Flutter package (contest-safe `lib/brand/` integration)

## 8. Keryx protection
Confirmed undisturbed:
- Main `SCAN THE AGORA` remains local-only
- Debug-only live scan boundary preserved
- No Gemini model/prompt/retry/memory/timeout changes
- No `keryxScanDebug` redeploy
- No paid live scans in this pass

## 9. Tests / analyze
| Command | Result |
|---|---|
| `dart format` | PASS (ran) |
| `flutter analyze` | PASS — No issues found |
| `flutter test` | PASS — 70 tests |

## 10. APK
- Command: `flutter build apk --debug` — PASS
- Path: `build/app/outputs/flutter-apk/app-debug.apk`
- Absolute: `C:\Users\joned\Desktop\JunkfeathersTech\The Local Agora\The-Local-Agora\build\app\outputs\flutter-apk\app-debug.apk`
- Size: **162,879,480 bytes** (~155.33 MB)

## 11. Physical-phone test script
1. Fresh-install the new debug APK.
2. Launch app.
3. Verify Junkfeathers Tech splash (canonical geometry).
4. Verify one Local Agora tip.
5. Verify ~2870 ms timing / transition feel.
6. Verify direct arrival at existing main Scan Control.
7. Verify Welcome dialog over main with exact approved copy.
8. Tap CLOSE.
9. Cold-launch — Welcome may appear again.
10. Tap DON'T SHOW AGAIN.
11. Cold-launch — Welcome does not appear automatically.
12. Tap `ABOUT` — Welcome reopens.
13. Verify Debug Component Gallery still works.
14. Do **not** run a live Gemini scan.

## 12. Documentation updates
- `docs/LOCAL_AGORA_WELCOME_DIALOG.md` (new)
- `docs/DECISIONS.md` (ADR-009 scheduling; ADR-037 consequence; ADR-039)
- `docs/MASTER_BLUEPRINT.md`
- `docs/DEV_CONTEST_V0.1_BLUEPRINT.md`
- `AI_CODING_INSTRUCTIONS.md`
- `README.md`
- `docs/Junkfeathers Universal Splash/README.md`

## 13. Drive sync
DRIVE SYNC STATUS: REQUIRED  
Package: `build/drive_sync/PASS_02C_DRIVE_SYNC.zip` (not committed)

## 14. Next-pass recommendation
After physical approval + council review: merge Pass 02C; then resume Keryx productization only under a new bounded pass (cache-first / async jobs / citation hygiene — not this splash/Welcome pass).

## Founder next actions
1. Physical Android review using §11
2. On approval: commit hash confirmation / merge direction from council
3. Upload Drive sync ZIP to council chat
