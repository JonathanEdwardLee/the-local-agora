# THE LOCAL AGORA — PASS 02B.1 COUNCIL HANDOFF

## 1. Pass identity
- Objective: Apply Jonathan’s final approved machine-face geometry refinements; configure Firebase (Android + web) and prove callable transport via non-AI `keryxStatus` only.
- Status: **COMPLETE — awaiting physical Android + Firebase link test**
- Branch: `pass-02b1-firebase-link-foundation`
- Commit: `ed1e9bcbc4332a3832944b0d8e2b1c53b884146a`
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
Pass 02B.1 delivers compact Panel 01 identity, taller CRT Panel 02 with honest `WAITING FOR SCAN...` prompt, shorter Panel 03 with ticks + scan line, Firebase project binding to `gen-lang-client-0718451481`, FlutterFire Android/web options, safe Firebase init fallback, debug-only `TEST KERYX LINK`, and deployment of Gen2 `keryxStatus` only. Live scanning, Gemini, and secrets remain disabled. Feasibility verdict unchanged.

## 3. Pre-code inspection
- Started from `pass-02a2-integrated-machine-panel` @ `86f8f320396d9d266f379712a7f1294700e30ecc`
- Working tree was clean before branch creation
- Governing docs read (AI_CODING_INSTRUCTIONS, DO_NOT_UPLOAD_SECRETS, MASTER_BLUEPRINT, DEV_CONTEST, DECISIONS, design system, FOUNDER_TOOL_ACCESS, KERYX_EVALUATION, PASS_02_READINESS, pass handoffs 01–02A.2)
- No prior `.firebaserc` / `firebase.json`; Functions workspace already present with Gen2 exports
- Existing `keryxStatus` rewritten to safe fields only (no Gemini/config exposure)
- Node engines already `"22"`; region `us-central1`
- Flutter had no Firebase packages before this pass
- No blockers; no second project; no production overwrite risk

## 4. Physical Test 02A.2 record
Recorded in `docs/pass_handoffs/PASS_02A2_COUNCIL_HANDOFF.md` §21.  
Result: `FUNCTIONALITY APPROVED — FINAL GEOMETRY REFINEMENTS REQUESTED`

## 5. Founder environment verification
| Tool | Result |
|---|---|
| Node | `v22.23.1` |
| npm | `10.9.8` |
| Firebase CLI | `15.23.0` |
| FlutterFire CLI | `1.4.0` |
| Firebase login | Successful (founder) |
| Project list | Only `gen-lang-client-0718451481` (The Local Agora Dev) |
| Budget alert | Complete (founder) |
| GitHub remote | Still pending |
| Gemini secret | Intentionally not configured |
| App Check | Deferred |

## 6. Final machine geometry refinements
- Panel 01: Compact plate — title upper-left, retro date upper-right, one bottom spec line `AGORA MK-I // V0.1.0 // FREE // KERYX` (+ DEV in debug)
- Panel 02: Height 180; CRT + scrollbar preserved; `> WAITING FOR SCAN... █` slow blink; static under reduced motion
- Panel 03: Height 60; three rings; side ticks; vertical-moving horizontal scan line; ClipRect; reduced-motion static
- Panel 04: Unchanged (location, WHEN/WHAT dials, SCAN, locked ADD SIGNAL)

## 7. Firebase project binding
- `.firebaserc`: aliases `default` and `dev` → `gen-lang-client-0718451481`
- `firebase.json`: functions-only workspace (predeploy build); FlutterFire platform metadata appended by CLI
- No second project created

## 8. FlutterFire configuration
- Platforms: Android + web only
- Android package: `com.junkfeathers.localagora`
- Generated: `lib/firebase_options.dart`, `android/app/google-services.json`
- Android app ID: `1:913778015345:android:a4af7a75000a992b1aafd0`
- Web app ID: `1:913778015345:web:e3bce0e15e03480e1aafd0`
- Packages added: `firebase_core`, `cloud_functions` only
- iOS deferred

## 9. Firebase initialization
- `initializeFirebaseSafely()` in `lib/main.dart` uses `DefaultFirebaseOptions.currentPlatform`
- Failure returns `false` and app still launches (no blank crash)
- Link service injected only when init succeeds
- No automatic callable on startup

## 10. Keryx status callable review
- Gen2 `onCall`, region `us-central1`
- No Gemini, no secret, no Firestore, no Auth
- Response: `{ service, status, scanEnabled: false, version, serverTime }`
- `keryxScanNotEnabled` remains in source as disabled seam (not deployed)

## 11. Function runtime and cost controls
- Node 22
- `minInstances: 0`, `maxInstances: 1`
- `timeoutSeconds: 15`, `memory: 256MiB`
- Region decision: `us-central1` (existing / documented)

## 12. Deployment
- Exact command: `firebase deploy --only functions:keryxStatus --project gen-lang-client-0718451481 --non-interactive`
- Project: `gen-lang-client-0718451481`
- Function: `keryxStatus`
- Result: **Successful create** (Node.js 22, 2nd Gen, us-central1). CLI exit code 1 solely due to Artifact Registry cleanup-policy warning (not a failed function create). Verified via `firebase functions:list` — only `keryxStatus` present.
- APIs auto-enabled by CLI for Gen2: cloudfunctions, cloudbuild, artifactregistry, run, eventarc, firebaseextensions (plus already-enabled pubsub/storage APIs). No Gemini secret requested.
- Optional founder follow-up: `firebase functions:artifacts:setpolicy` (not forced in this pass)

## 13. Debug Firebase link test
- Location: `DEBUG // COMPONENTS` → `TEST KERYX LINK`
- States: untested → connecting → ready / unavailable / malformed
- No auto call; button disables while busy; main SCAN unchanged
- Support text on success: live event scanning remains disabled

## 14. Acceptance criteria
| Criterion | Status | Evidence |
|---|---|---|
| 1. Governing files read | PASS | Pre-code inspection |
| 2. Working tree inspected | PASS | Clean tip of 02A.2 |
| 3. Physical Test 02A.2 recorded | PASS | PASS_02A2 handoff §21 |
| 4. Correct Firebase project verified | PASS | projects:list |
| 5. No second project created | PASS | Single project listed |
| 6. Panel 01 height reduced | PASS | Compact plate + tests |
| 7. Title upper-left Panel 01 | PASS | Identity panel |
| 8. Date upper-right Panel 01 | PASS | JfRetroDateDisplay |
| 9. Specs compact bottom row | PASS | compactSpecLine |
| 10. Panel 02 height increased | PASS | height 180 |
| 11. Blinking waiting prompt | PASS | JfWaitingScanPrompt |
| 12. Reduced-motion static prompt | PASS | forceStatic / MediaQuery |
| 13. Panel 03 height reduced | PASS | height 60 |
| 14. Three rings preserved | PASS | ringCount 3 |
| 15. Marker lines restored | PASS | side ticks |
| 16. Scan line restored | PASS | triangle-wave Y |
| 17. Panel 03 art inside bounds | PASS | ClipRect + pad |
| 18. Panel 04 unchanged | PASS | Controls preserved |
| 19. Keyboard behavior approved | PASS | Inset test |
| 20. Portrait lock active | PASS | main + manifest |
| 21. Firebase Core configured | PASS | firebase_core + init |
| 22. Android package correct | PASS | google-services.json |
| 23. Web Firebase configured | PASS | firebase_options web |
| 24. firebase_options.dart generated | PASS | lib/firebase_options.dart |
| 25. Only approved Flutter Firebase pkgs | PASS | pubspec + tests |
| 26. Safe Firebase init fallback | PASS | initializeFirebaseSafely |
| 27. Functions workspace preserved | PASS | No destructive init |
| 28. Node 22 verified | PASS | engines + deploy runtime |
| 29. keryxStatus no Gemini | PASS | index.ts + tests |
| 30. keryxStatus no secret | PASS | No secret binding |
| 31. Status scaling limited | PASS | maxInstances 1 |
| 32. Only keryxStatus deployed | PASS | functions:list |
| 33. Correct project targeted | PASS | --project flag |
| 34. keryxScanNotEnabled disabled | PASS | Throws failed-precondition; not deployed |
| 35. Debug link test exists | PASS | Gallery control |
| 36. No automatic link test | PASS | Tests |
| 37. Main Scan no Firebase | PASS | Tests |
| 38. Flutter analyze | PASS | No issues |
| 39. Flutter tests | PASS | 38 tests |
| 40. Functions lint | PASS | tsc --noEmit |
| 41. Functions build | PASS | tsc |
| 42. Functions tests | PASS | 17 tests |
| 43. Debug APK builds | PASS | See §18 |
| 44. Flutter web builds | PASS | build/web |
| 45. Secret scan | PASS | No private secrets; see §20 |
| 46. Council handoff exists | PASS | This file |
| 47. Physical Android script | PASS | §19 |
| 48. Smallest next pass identified | PASS | §24 |

## 15. Files created, changed, moved, or deleted
**Created:** `.firebaserc`, `firebase.json`, `lib/firebase_options.dart`, `lib/design/jf_waiting_scan_prompt.dart`, `lib/services/keryx/*`, `android/app/google-services.json`, `functions/test/status_callable.test.ts`, `test/keryx_link_test.dart`, `docs/pass_handoffs/PASS_02B1_COUNCIL_HANDOFF.md`  
**Changed:** Panel 01/02/03 design files, scan control, debug gallery, main, pubspec, Functions `index.ts`, Android Gradle (google-services), PASS_02A2 handoff (physical record), PASS_02_READINESS, DECISIONS (ADR-025/026), KERYX_EVALUATION §21, widget tests  
**Deleted:** none of substance

## 16. Commands and actual results
| Command | Result |
|---|---|
| `node --version` | `v22.23.1` |
| `npm --version` | `10.9.8` |
| `firebase --version` | `15.23.0` |
| `flutterfire --version` | `1.4.0` |
| `firebase projects:list` | 1 project: `gen-lang-client-0718451481` |
| `flutter pub get` | PASS |
| `flutter analyze` | PASS — No issues found |
| `flutter test` | PASS — 38 tests |
| `flutter build apk --debug` | PASS |
| `flutter build web` | PASS — `build/web` |
| `cd functions && npm ci && npm run lint && npm run build && npm test` | PASS — 17 tests |
| `firebase deploy --only functions:keryxStatus --project gen-lang-client-0718451481` | Function created; cleanup-policy warning (exit 1) |
| `firebase functions:list --project gen-lang-client-0718451481` | Only `keryxStatus` |
| `npm run keryx:spike` | NOT RUN |

## 17. Automated tests
Geometry, waiting prompt, coil ticks/scan line, keyboard, portrait, Firebase init representation, no auto callable, Scan does not probe, debug link once + disable while busy, parse ready/malformed/unavailable, dependency guards, Functions status contract, Node 22, maxInstances.

## 18. APK and web-build information
- APK build command: `flutter build apk --debug`
- Exact APK path: `build/app/outputs/flutter-apk/app-debug.apk`
- File existence: YES
- File size: 148,064,359 bytes (~141.2 MB)
- Package name: `com.junkfeathers.localagora`
- Version: `0.1.0`
- Build number: `1`
- Firebase initialized: YES (with safe fallback)
- Status callable configured: YES
- Status callable deployed: YES
- Live Keryx scanning: NO
- Gemini calls: NO
- Firestore: NO
- Authentication: NO
- App Check: NO
- Internet required for ordinary visual use: NO
- Internet required for explicit debug link test: YES
- Web build: `build/web/index.html` exists

## 19. Physical Android test script
1. Install the new APK. **Expected:** installs
2. Launch the app. **Expected:** machine face opens
3. Confirm Panel 01 is shorter. **Expected:** compact plate
4. Confirm `THE LOCAL AGORA` is upper-left. **Expected:** yes
5. Confirm the date is upper-right. **Expected:** `YYYY.MM.DD`
6. Confirm machine specifications form a compact bottom row. **Expected:** `AGORA MK-I // V0.1.0 // FREE // KERYX`
7. Confirm Panel 02 is taller and visually dominant. **Expected:** yes
8. Confirm CRT styling and scrollbar remain correct. **Expected:** yes
9. Confirm `WAITING FOR SCAN...` is visible. **Expected:** yes
10. Confirm the command cursor blinks slowly. **Expected:** slow blink
11. Confirm the waiting prompt does not imply a real active search. **Expected:** idle wording only
12. Confirm Panel 03 is slightly shorter. **Expected:** yes
13. Confirm all three rings remain visible. **Expected:** yes
14. Confirm marker lines are visible. **Expected:** side ticks
15. Confirm the horizontal scan line moves vertically. **Expected:** slow motion
16. Confirm the scan line and rings remain inside the panel. **Expected:** no overflow
17. Confirm Panel 04 still works. **Expected:** yes
18. Confirm WHEN dial still works. **Expected:** yes
19. Confirm WHAT dial still works. **Expected:** yes
20. Open the keyboard. **Expected:** opens
21. Confirm the field and Scan button remain reachable. **Expected:** yes
22. Press Scan with an empty location. **Expected:** top warning + field error
23. Confirm top warning and persistent field error. **Expected:** yes
24. Enter `Springfield, Missouri`. **Expected:** accepted
25. Press Scan. **Expected:** local readiness toast
26. Confirm the existing local readiness message appears. **Expected:** `SCAN CONTROL READY`
27. Confirm no event search occurs. **Expected:** no results list
28. Open `DEBUG // COMPONENTS`. **Expected:** gallery opens
29. Find `TEST KERYX LINK`. **Expected:** present
30. Confirm the control says the link is untested before pressing. **Expected:** `KERYX LINK UNTESTED`
31. Press it once. **Expected:** request starts
32. Confirm it displays `CONNECTING TO KERYX...`. **Expected:** yes
33. Confirm it becomes `KERYX LINK READY`, or record the exact error. **Expected:** ready (or honest unavailable)
34. Confirm the support text says live event scanning remains disabled. **Expected:** yes
35. Confirm no event records appear. **Expected:** none
36. Confirm repeated manual link testing works. **Expected:** yes
37. Rotate the phone. **Expected:** stays portrait
38. Confirm portrait lock. **Expected:** yes
39. Force-close and reopen. **Expected:** relaunches
40. Confirm no automatic Firebase status call occurs on startup. **Expected:** stays untested until pressed
41. Record PASS/FAIL and screenshots for any problem.

## 20. Security and secret scan
Repository-scoped scan (excluded `.git`, `build`, `node_modules`, `functions/lib`, `.dart_tool`):

| Pattern | Result |
|---|---|
| `AIza` | Matches only FlutterFire **client** API keys in `lib/firebase_options.dart` (+ redaction regexes in spike scripts). Allowed public Firebase web/Android config — not Gemini secrets. |
| `BEGIN PRIVATE KEY` | Only in test assertion string |
| `private_key` | No matches |
| `service_account` | No matches |
| `GEMINI_API_KEY=` | Placeholder in `functions/.env.example` + test assertion only |
| OAuth bearer tokens | No matches |
| keystore passwords | No matches |

**Verdict:** No committed private credentials, service-account keys, or Gemini secrets.

## 21. Privacy, cloud-resource, and cost impact
- Ordinary UI remains offline-capable
- Debug link test incurs a small Gen2 callable invocation (cold start possible; minInstances 0)
- Gen2 prerequisite APIs were enabled by Firebase CLI
- Artifact Registry images may accumulate a small monthly cost until a cleanup policy is set
- No Gemini spend in this pass
- No Firestore/Auth/App Check usage

## 22. Known limitations and risks
- Physical Firebase link test not yet performed on device
- Web `measurementId` appears in generated options; Analytics package was **not** added
- Windows/desktop platforms intentionally unsupported in `firebase_options` (safe init catches)
- Cleanup policy not configured (CLI warning)
- Callable is publicly invokable without App Check (acceptable for status-only; harden before live scan)

## 23. Founder actions still required
- GitHub remote: still pending
- Physical Firebase link test: required (script §19)
- Gemini secret: intentionally not configured (Pass 02B.2)
- App Check: deferred and documented
- Optional: Artifact Registry cleanup policy

## 24. Recommended next pass
After Jonathan’s physical approval of geometry + `TEST KERYX LINK`:

**Pass 02B.2 — Secure Live Keryx Scan Activation**

That later pass may:
- store `GEMINI_API_KEY` through Firebase Secret Manager,
- run controlled live Keryx feasibility tests,
- enable one protected callable scan route,
- connect `SCAN THE AGORA`,
- and present sourced results.

Do **not** perform those actions now.

---

## Drive sync status (Pass 02B.1A)

```text
DRIVE SYNC STATUS: REQUIRED
```

```text
FILES REQUIRING DRIVE SYNC:
- AI_CODING_INSTRUCTIONS.md — updated — shared-platform rules + repository–Drive sync protocol
- docs/MASTER_BLUEPRINT.md — updated — post-contest shared platform roadmap
- docs/DEV_CONTEST_V0.1_BLUEPRINT.md — updated — post-contest continuity rule
- docs/DECISIONS.md — updated — restored ADRs 022–026; roadmap ADRs 027–033; Drive sync ADR-034
- docs/KERYX_EVALUATION.md — updated — Pass 02B.1 transport note
- docs/PASS_02_READINESS.md — updated — Pass 02B.1 readiness
- docs/pass_handoffs/PASS_02A2_COUNCIL_HANDOFF.md — updated — Physical Test 02A.2 record
- docs/pass_handoffs/PASS_02B1_COUNCIL_HANDOFF.md — created — Pass 02B.1 council handoff
```

Branch: `pass-02b1-firebase-link-foundation`  
Package: `build/drive_sync/PASS_02B1_DRIVE_SYNC.zip` (not committed; Jonathan uploads to council chat)
