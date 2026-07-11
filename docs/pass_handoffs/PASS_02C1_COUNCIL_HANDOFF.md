# THE LOCAL AGORA — PASS 02C.1 COUNCIL HANDOFF

## 1. Pass identity
- Objective: Physical-test repairs for Pass 02C (splash progression, Welcome copy, About)
- Status: **READY FOR PHYSICAL ANDROID RE-REVIEW** — **not physically approved; do not merge**
- Branch: `pass-02c-universal-splash-welcome`
- Starting HEAD: `a7421ccac97bd0f892e0e7e8f71d7767d99aa11c`
- Ending HEAD: *f1ef31d3b7d71fc56f5a5a3566336436b7860905*
- Prior Pass 02C tip remained unapproved

## 2. Repairs shipped

### Splash progression
Timing totals unchanged: 990 + 1000 + 880 = **2870 ms**.  
Normal-motion envelope remapped via `splashInterferenceIntensity`:
- logo becomes readable;
- interference fades in / continuously worsens;
- splash ends at strongest interference;
- **no** deliberate clean motionless mid hold;
- **no** cleaning glitch-out fade.
Reduced-motion remains a simple accessible fade.

### Welcome copy
Exact body: `Discover music, comedy, and theater events near you.`  
Contest UI no longer claims art / gatherings discovery.

### About placement + surface
- Removed identity/section-01 ABOUT control.
- Secondary row under `SCAN THE AGORA`: `ADD EVENT` | `ABOUT`.
- ABOUT opens real About dialog (not Welcome reopen).
- About includes product title, tagline, approved statement, `SHOW WELCOME ON STARTUP` ON/OFF, CLOSE.
- Preference key unchanged: `hasDismissedAgoraWelcomePermanently` (ON=false, OFF=true).

## 3. Keryx
Untouched — no live scans, no redeploy, no main Scan wiring to live callable.

## 4. Tests / analyze
| Command | Result |
|---|---|
| `dart format` (touched sources) | PASS |
| `flutter analyze` | PASS — No issues found |
| `flutter test` | PASS — **73** tests |

## 5. APK
- Path: `build/app/outputs/flutter-apk/app-debug.apk`
- Absolute: `C:\Users\joned\Desktop\JunkfeathersTech\The Local Agora\The-Local-Agora\build\app\outputs\flutter-apk\app-debug.apk`
- Size: **162,882,048 bytes** (~155.34 MB)

## 6. Physical re-test steps
1. Fresh install / clear data.
2. Launch — verify splash: logo readable → increasing glitch → ends at peak (no clean mid pause).
3. One Local Agora tip; ~2870 ms total feel.
4. Main Scan Control appears; Welcome over main with corrected category copy.
5. CLOSE — preference unchanged; cold launch may show Welcome again.
6. DON'T SHOW AGAIN — cold launch skips Welcome.
7. Confirm no ABOUT under identity plate.
8. Confirm `ADD EVENT` | `ABOUT` under SCAN.
9. ABOUT opens About statement + SHOW WELCOME ON STARTUP.
10. Switch ON — cold launch shows Welcome again.
11. Switch OFF — cold launch skips Welcome.
12. Debug gallery still works.
13. Do **not** run live Gemini scan.

## 7. Drive sync
`build/drive_sync/PASS_02C1_DRIVE_SYNC.zip` (not committed)

## 8. Docs
ADR-040; updated Welcome dialog doc, DECISIONS, MASTER, DEV_CONTEST, AI_CODING, README.

## Founder next
Physical re-review. Do not merge until approval phrase.
