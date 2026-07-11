# THE LOCAL AGORA — PASS 02B.2A COUNCIL HANDOFF

## 1. Pass identity
- Objective: Integrate approved 02B.1D into `main`, then prove one App Check–protected, Secret Manager–backed, debug-only live Keryx scan.
- Status: **PASS 02B.2A PHYSICALLY APPROVED**
- Branch: `pass-02b2a-secure-live-keryx-debug-scan`
- Implementation base commit: `530d4a9c55bcbfbb2ade884a0cfa0f236e274a92`
- Approval recorded: founder phrase `PASS 02B.2A PHYSICALLY APPROVED — COMMIT AND PUSH`
- Working tip: `1e6130638424efb31eb2da3f405cbe3b6aaeed6a`
- Approved main commit: `49c81ff7cd4acb4b1ee41d2ddb6d29f203547ae4`
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
Part A integrated Pass 02B.1D into `main`. Part B shipped `keryxScanDebug` (App Check enforced, `GEMINI_API_KEY` secret-bound) and debug-only `TEST LIVE KERYX SCAN`. Ordinary `SCAN THE AGORA` remains local-only.

Cloud live discovery required repair: undici headersTimeout, streaming grounded discovery, 1GiB memory, extended timeouts, 503 capacity retries + `gemini-3-flash-preview` diagnostic fallback. V0.1 categories narrowed to MUSIC / COMEDY / THEATER (ADR-038).

**Founder live result:** Springfield / NEXT 7 DAYS / MUSIC returned **10 signals**. Test successful. Source URLs are very long (Google grounding redirector / citation URL quality — known Pass 01 follow-up; not a blocker for this proof).

**Physical approval:** `PASS 02B.2A PHYSICALLY APPROVED` — commit and push requested.

ADR-037 brand tagline/onboarding copy recorded in docs only (no onboarding UI this pass).

## 3. Pass 02B.1D physical approval
Recorded: `PASS 02B.1D PHYSICALLY APPROVED` / `PHYSICALLY APPROVED — READY FOR MAIN`  
Approval commit: `49c81ff7cd4acb4b1ee41d2ddb6d29f203547ae4`

## 4. Main integration
- Local/remote main: `49c81ff7cd4acb4b1ee41d2ddb6d29f203547ae4` (match YES)
- GitHub default branch may still need manual switch to `main`

## 5. Drive sync
- Prior: `build/drive_sync/PASS_02B1D_MAIN_DRIVE_SYNC.zip`
- This pass: `build/drive_sync/PASS_02B2A_DRIVE_SYNC.zip` (see § Drive sync status)

## 6–11. Implementation (summary)
- App Check after Firebase; Android debug provider; web live scan not wired
- `defineSecret('GEMINI_API_KEY')` only on `keryxScanDebug`
- Callable: Gen2, Node 22, `us-central1`, App Check on, maxInstances 1, concurrency 1
- Deployed runtime (final): `timeoutSeconds: 360`, `memory: 1GiB`
- Discovery path (cloud debug): `generateContentStream` + googleSearch; capacity retry ×2; diagnostic `gemini-3-flash-preview`
- Prompt: `0.2.0-v01-narrow` (≤12 candidates; music/comedy/theater)
- Max 12 events; `cacheStatus: not_implemented`
- Main Scan unchanged / local-only

## 12–14. Cost / latency notes
- Cold cloud grounded scan can take several minutes (first stream chunk observed ~164s in earlier failure before success path)
- 503 high demand occurred; retries/diagnostic path required
- Cache-first (ADR-028) and async job architecture deferred — primary public cost controls for later passes

## 15. Debug-only client test
- Gallery: `TEST LIVE KERYX SCAN` with confirmation
- Client timeout aligned to 360s

## 16. Deployment
- Multiple iterative `firebase deploy --only functions:keryxScanDebug` (cleanup-policy CLI warning only; function updates succeeded)
- No unrestricted `firebase deploy`

## 17–18. Live test evidence / quality
- **PASS** — founder report: **10 signals** returned for Springfield / NEXT 7 DAYS / MUSIC
- Quality note: **source links are very long** (grounding citation/redirect URLs). Acceptable for this debug proof; URL hygiene remains a known Keryx follow-up from Pass 01
- Main `SCAN THE AGORA` still local-only (correct for this pass)

## 19. Acceptance criteria
| Criterion | Status | Evidence |
|---|---|---|
| 1–6 Main integration | PASS | §3–4 |
| 7–11 App Check code | PASS | Source + tests |
| 12 Founder debug token | PASS | Founder confirmation |
| 13–14 Secret set | PASS | Founder confirmation |
| 15–28 Callable/Keryx code | PASS | Source + functions tests |
| 29 Automated tests no Gemini | PASS | Fake/unit only |
| 30–31 Live ops / deploy | PASS | Function live us-central1 |
| 32–35 Debug UI / main scan | PASS | Gallery + tests |
| 36–42 Local builds/tests | PASS | flutter/functions green; debug APK |
| 43–44 Live Android test | PASS | Founder: 10 signals |
| 45–48 Docs/Drive | PASS / REQUIRED | This handoff + Drive ZIP |

## 20. Files (high level)
Created: `keryx_scan_debug.ts`, `scan_window.ts`, `http_agent.ts`, `keryx_live_scan_service.dart`, tests, handoff  
Changed: engine (stream/timeouts/503), index (1GiB/360s), categories, brand docs (ADR-037/038), gallery/client timeouts  
Backend: `keryxScanDebug` live

## 21. Commands (final)
| Command | Result |
|---|---|
| flutter test | PASS (55) |
| functions test | PASS (31) |
| flutter build apk --debug | PASS |
| firebase deploy --only functions:keryxScanDebug | PASS (function update; cleanup-policy warning only) |

## Brand (ADR-037) + categories (ADR-038)
- Tagline: `Find your scene. Grow your scene.`
- Onboarding copy documented; UI deferred
- V0.1 dial: MUSIC / COMEDY / THEATER (`STAGE` wire); art/gatherings/all deferred

## Deferred
- Async Firestore scan jobs
- Cache-first shared records
- AbortController cancel path
- Citation URL shortening / hygiene
- Onboarding UI surfaces

## DRIVE SYNC STATUS
DRIVE SYNC STATUS: REQUIRED  
Package: `build/drive_sync/PASS_02B2A_DRIVE_SYNC.zip` (not committed)  
Jonathan uploads to council chat; council updates Drive.

FILES REQUIRING DRIVE SYNC:
- `docs/pass_handoffs/PASS_02B2A_COUNCIL_HANDOFF.md`
- `docs/DECISIONS.md`
- `docs/MASTER_BLUEPRINT.md`
- `docs/DEV_CONTEST_V0.1_BLUEPRINT.md`
- `AI_CODING_INSTRUCTIONS.md`
- `README.md`

## Founder next actions
1. Upload `PASS_02B2A_DRIVE_SYNC.zip` to council Drive sync (refresh after this approval commit if needed)
2. Optional: merge/integrate to `main` when council directs
3. Do not paste secrets or tokens into chat
