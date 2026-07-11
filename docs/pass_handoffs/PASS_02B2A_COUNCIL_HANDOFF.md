# THE LOCAL AGORA — PASS 02B.2A COUNCIL HANDOFF

## 1. Pass identity
- Objective: Integrate approved 02B.1D into `main`, then prove one App Check–protected, Secret Manager–backed, debug-only live Keryx scan.
- Status: **IN PROGRESS — FOUNDER GATES REQUIRED BEFORE DEPLOY / LIVE TEST**
- Branch: `pass-02b2a-secure-live-keryx-debug-scan`
- Commit: *(pending commit)*
- Approved main commit: `49c81ff7cd4acb4b1ee41d2ddb6d29f203547ae4`
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
Part A integrated Pass 02B.1D into `main` and produced the Drive-sync package. Part B implements `keryxScanDebug` (App Check enforced, `GEMINI_API_KEY` secret-bound, two-pass grounded discovery + Zod normalization) and a debug-only `TEST LIVE KERYX SCAN` control. Ordinary `SCAN THE AGORA` remains local-only. **Deployment and live Gemini calls are paused** until Jonathan registers the App Check debug token and sets the Gemini secret via CLI.

## 3. Pass 02B.1D physical approval
Recorded: `PASS 02B.1D PHYSICALLY APPROVED` / `PHYSICALLY APPROVED — READY FOR MAIN`  
Approval commit on feature branch: `49c81ff7cd4acb4b1ee41d2ddb6d29f203547ae4`

## 4. Main integration
- Local main: `49c81ff7cd4acb4b1ee41d2ddb6d29f203547ae4`
- Remote main: `49c81ff7cd4acb4b1ee41d2ddb6d29f203547ae4`
- Match: **YES**
- Default branch on GitHub: still `pass-02b1-firebase-link-foundation` — **manual founder action:** GitHub → Settings → General → Default branch → `main`
- Result: `main` created from approved tip and pushed (no prior `main` existed)

## 5. Drive sync package for approved foundation
- Path: `build/drive_sync/PASS_02B1D_MAIN_DRIVE_SYNC.zip`
- Size: 108,013 bytes
- Files: 15 (including manifest)
- Not committed

## 6. Pre-code inspection
See session pre-code report. Engine already had Pass A/B locally; callables were status-only; no App Check; no Secret Manager.

## 7. App Check implementation
- Package: `firebase_app_check`
- Init after Firebase in `initializeAppCheckSafely`
- Android debug: `AndroidDebugProvider`
- Android release prepared: `AndroidPlayIntegrityProvider`
- Web: live scan service not wired (`!kIsWeb`); no reCAPTCHA key invented
- Failure: app still opens; live scan unavailable

## 8. App Check founder gate
**REQUIRED BEFORE DEPLOY**

1. Install the Pass 02B.2A debug APK.
2. Launch once on device/emulator.
3. Read logcat for the App Check debug token (FlutterFire debug provider output).
4. Do **not** paste the token into Cursor chat or commit it.
5. Register it in Firebase Console → App Check → Apps → Android Local Agora → Manage debug tokens.
6. Reply in chat only: `App Check debug token registered`.

## 9. Secret Manager implementation
- `defineSecret('GEMINI_API_KEY')` bound **only** to `keryxScanDebug`
- `keryxStatus` / `keryxScanNotEnabled` remain secret-free

## 10. Secret founder gate
**REQUIRED BEFORE DEPLOY**

Run locally (type the value into the secure prompt — do not paste into chat):

```powershell
firebase functions:secrets:set GEMINI_API_KEY --project gen-lang-client-0718451481
```

Reply in chat only: `GEMINI_API_KEY secret set`.

## 11. Protected callable
- Name: `keryxScanDebug`
- Gen2, Node 22, `us-central1`
- `enforceAppCheck: true`
- `minInstances: 0`, `maxInstances: 1`, `timeoutSeconds: 120`, `memory: 512MiB`, `concurrency: 1`
- Strict input validation; rejects prompt/model injection fields
- Max 12 events; `cacheStatus: not_implemented`

## 12–14. Keryx / cost
- Pass A: Interactions + Google Search (existing `GeminiKeryxEngine`)
- Pass B: separate structured normalization + Zod
- Retries: existing bounded policy (max 4)
- Authorized live ops after gates: ≤1 smoke + 1 full Springfield scan (+1 transient retry)

## 15. Debug-only client test
- Gallery: `TEST LIVE KERYX SCAN`
- Confirmation dialog required
- Stages: CONTACTING / SEARCHING / CHECKING SOURCES / NORMALIZING
- Main Scan unchanged / local-only

## 16. Deployment
- **NOT RUN YET** — waiting on founder gates
- Planned: `firebase deploy --only functions:keryxScanDebug --project gen-lang-client-0718451481`

## 17–18. Live test evidence / quality
- **BLOCKED** pending gates + deploy

## 19. Acceptance criteria (partial)
| Criterion | Status | Evidence |
|---|---|---|
| 1–6 Main integration | PASS | §3–4 |
| 7–11 App Check code | PASS | Source + tests |
| 12 Founder debug token | BLOCKED | Awaiting Jonathan |
| 13–14 Secret set | BLOCKED | Awaiting Jonathan |
| 15–28 Callable/Keryx code | PASS | Source + functions tests |
| 29 Automated tests no Gemini | PASS | Fake/unit only |
| 30–31 Live ops / deploy | BLOCKED | Gates |
| 32–35 Debug UI / main scan | PASS | Gallery + tests |
| 36–42 Local builds/tests | PASS / IN PROGRESS | analyze/test green; APK building |
| 43–44 Live Android test | BLOCKED | Gates |
| 45–48 Docs/Drive | IN PROGRESS | This handoff |

## 20. Files (high level)
Created: `functions/src/callables/keryx_scan_debug.ts`, `functions/src/keryx/scan_window.ts`, `lib/services/keryx/keryx_live_scan_service.dart`, tests, this handoff  
Changed: `functions/src/index.ts`, Flutter main/gallery/scan screen, `pubspec.yaml`, dialog return values  
Backend deploy: pending

## 21. Commands
| Command | Result |
|---|---|
| flutter analyze | PASS |
| flutter test | PASS (55) |
| functions lint/build/test | PASS (26) |
| flutter build apk --debug | IN PROGRESS / report after |
| firebase deploy | NOT RUN |

## 22–30. Remaining
Complete after founder gates, deploy, and one Springfield live test.

## Founder next actions (now)
1. Set GitHub default branch to `main` (optional but recommended).
2. Upload `PASS_02B1D_MAIN_DRIVE_SYNC.zip` to council Drive sync.
3. Install debug APK → register App Check debug token → confirm in chat.
4. Run `firebase functions:secrets:set GEMINI_API_KEY --project gen-lang-client-0718451481` → confirm in chat.
5. Do **not** paste secrets or tokens into chat.
