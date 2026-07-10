# THE LOCAL AGORA — COUNCIL HANDOFF

## 1. Pass identity
- Pass: 01 — Repository Foundation and Keryx Feasibility Spike
- Objective: Establish a clean Flutter + TypeScript Functions repository and prove two-pass Keryx on real Springfield / 65806 queries for July 10–16, 2026
- Status: PARTIAL / BLOCKED (foundation complete; live grounded feasibility blocked without `GEMINI_API_KEY`)
- Branch: `pass-01-keryx-foundation`
- Final commit: `89b5bb909f206bdd9d2583313e2da3b186f396dc`
- App version: `0.1.0`
- Build number: `1`

## 2. Executive summary
- What was completed:
  - Canonical governing Markdown layout and Flutter project `the_local_agora`
  - Android application ID `com.junkfeathers.localagora`, version `0.1.0+1`
  - Minimal near-black / bone-white Pass 01 foundation screen
  - Junkfeathers splash timing seam (990 / 1000 / 880 ms) without full animation
  - Firebase Cloud Functions 2nd gen TypeScript workspace with Zod event schema
  - Keryx two-pass implementation (Interactions API + Google Search, then structured normalization)
  - Unit tests, Flutter analyze/tests, debug APK, Flutter web build
  - `docs/KERYX_EVALUATION.md`
- What remains:
  - Live Tests A/B/C against Gemini (requires local `GEMINI_API_KEY`)
  - Evidence-backed feasibility verdict upgrade from `KERYX NOT YET PROVEN`
  - Full Scan Control / City Index / flyer loop (explicitly out of Pass 01)
- Keryx feasibility verdict: **KERYX NOT YET PROVEN**

## 3. Acceptance criteria

| Criterion | Status | Evidence |
|---|---|---|
| 1. All five governing Markdown files were read before implementation | PASS | Pre-code report; files read (then renamed to canonical paths) |
| 2. Repository identity matches the approved values | PASS | `pubspec.yaml` name/version; Android `applicationId`; README |
| 3. Flutter project launches successfully | PASS | App entry `lib/main.dart` + widget test pumps `TheLocalAgoraApp` |
| 4. Android package ID is `com.junkfeathers.localagora` | PASS | `android/app/build.gradle.kts` applicationId + namespace |
| 5. Flutter analysis passes without unresolved errors | PASS | `flutter analyze` → No issues found |
| 6. Flutter tests pass | PASS | `flutter test` → 2/2 passed |
| 7. A debug APK is successfully created and verified to exist | PASS | `build/app/outputs/flutter-apk/app-debug.apk` exists (146,111,780 bytes) |
| 8. Flutter web builds successfully | PASS | `flutter build web` → `build/web` with `index.html` + `main.dart.js` |
| 9. A strict TypeScript functions workspace exists | PASS | `functions/` with strict `tsconfig.json` |
| 10. TypeScript lint, tests, and build pass | PASS | `npm run lint`, `npm run build`, `npm test` (8/8) |
| 11. No production Firebase project or permanent cloud identifier was invented | PASS | No Firebase project ID recorded; status callable only |
| 12. No secret was committed | PASS | Secret scan NO_MATCHES; no `.env` present |
| 13. Keryx grounded discovery returns current Springfield event findings with citations | BLOCKED | `GEMINI_API_KEY` absent; spike exit code 2 |
| 14. The broad event scan was evaluated | BLOCKED | Test A not executed live |
| 15. The music-specific scan was evaluated | BLOCKED | Test B not executed live |
| 16. The `65806` postal-code scan was evaluated | BLOCKED | Test C not executed live |
| 17. Grounded discovery and normalization are separate model operations | PASS | `GeminiKeryxEngine.discoverPublicEvents` vs `normalizeGroundedFindings` |
| 18. Normalized output passes runtime schema validation | PASS | Zod `NormalizationResultSchema` + unit tests (live path not run) |
| 19. Accepted normalized facts are traceable to evidence | BLOCKED | No live accepted events; audit pipeline unit-tested |
| 20. Unsupported facts in accepted records total zero | BLOCKED | No live accepted set; offline strip test leaves 0 unsupported |
| 21. Past events are excluded from accepted active results | BLOCKED | Pipeline implements exclusion; not exercised live |
| 22. Private or withheld addresses are not inferred | PASS | Prompt + location-mode rules; no private-address inference code |
| 23. `docs/KERYX_EVALUATION.md` is complete | PASS | File present with all required sections; live sections marked blocked |
| 24. Full application UI / flyer / persistence / billing not prematurely built | PASS | Only Pass 01 foundation screen + backend spike |
| 25. A full council handoff report is produced | PASS | This document |
| 26. The smallest recommended next pass is identified | PASS | See §16 |

## 4. User-visible changes
- Launching the app shows a minimal engineering foundation screen:
  - `JUNKFEATHERS TECH`
  - `THE LOCAL AGORA`
  - `PASS 01 // KERYX FEASIBILITY`
  - Flutter / backend / splash / Keryx UI status lines
  - Statement that the full civic receiver interface arrives later
- No live scan UI, no City Index, no event cards

## 5. Internal implementation
- Flutter: Pass 01 shell + splash spec seam
- Functions: Keryx config, request builder, Gemini engine, Zod schema, evidence audit, two-pass pipeline, local spike script
- Callable stubs: `keryxStatus`, `keryxScanNotEnabled` (scan not publicly enabled)

## 6. Files created, changed, moved, or deleted
- Created: Flutter app tree, `functions/**`, `docs/KERYX_EVALUATION.md`, `docs/pass_handoffs/PASS_01_COUNCIL_HANDOFF.md`, splash/Pass 01 Dart files, tests, README
- Renamed/normalized: governing docs → `AI_CODING_INSTRUCTIONS.md`, `docs/MASTER_BLUEPRINT.md`, `docs/DEV_CONTEST_V0.1_BLUEPRINT.md`
- Deleted: empty speculative `lib/core/`
- Not committed: `build/`, `functions/node_modules/`, `functions/lib/`, secrets

## 7. Architecture and dependency decisions
- Client: Flutter/Dart only (ADR-001)
- Backend: Firebase Functions 2nd gen + TypeScript (ADR-004)
- Keryx: two-pass Interactions API design (ADR-003/006)
- Default model: `gemini-3.5-flash` in server config
- Installed packages: `@google/genai@1.52.0`, `firebase-functions@6.6.0`, `firebase-admin@13.10.0`, `zod@4.4.3`, `typescript@5.9.3`, `vitest@3.2.7`
- No production Firebase project binding

## 8. Keryx evaluation results
- Models: configured `gemini-3.5-flash` / `gemini-3.5-flash` (not live-tested)
- API path: Interactions API + `google_search` (Pass A); structured `response_format` (Pass B)
- Grounded searches: 0
- Normalization calls: 0
- Events discovered: 0 (blocked)
- Events accepted: 0 (blocked)
- Events rejected: 0 (blocked)
- Unsupported accepted facts: N/A (blocked)
- Citation quality: N/A (blocked)
- Broad versus music-specific result: NOT TESTED (blocked)
- Postal-code result: NOT TESTED (blocked)
- Duplicate observations: N/A
- Cost observations: no live spend; Search grounding may bill per model-issued query on Gemini 3 family

## 9. Commands and actual results

```text
flutter pub get          → PASS
flutter analyze          → PASS (No issues found)
flutter test             → PASS (2 tests)
flutter build apk --debug→ PASS → build/app/outputs/flutter-apk/app-debug.apk
flutter build web        → PASS → build/web

cd functions
npm install              → PASS (@google/genai 1.52.0 et al.)
npm run lint             → PASS
npm run build            → PASS (functions/lib emitted)
npm test                 → PASS (8 tests)
npm run keryx:spike      → BLOCKED exit 2 (GEMINI_API_KEY missing)
```

Secret scan command (PowerShell, repo-scoped pattern search over source-like files, excluding `node_modules` / `build` / `.git` / compiled `functions/lib`):

```text
Patterns: AIza…, BEGIN PRIVATE KEY, service_account, GEMINI_API_KEY=non-placeholder, private_key, .p12, keystorePassword
Result: SECRET_SCAN_RESULT: NO_MATCHES
```

## 10. Automated tests
- Flutter: splash timing lock + Pass 01 widget identity labels
- Functions: config defaults, schema validation, request prompt context, evidence audit support/strip, URL sanitize

## 11. APK and web-build information
- APK created: YES
- APK path: `build/app/outputs/flutter-apk/app-debug.apk`
- APK mode: debug
- Package name: `com.junkfeathers.localagora`
- Version: `0.1.0`
- Build number: `1`
- APK file existence verified: YES (146,111,780 bytes)
- Flutter web build: YES (`build/web`)
- Current runtime requirements: no network/AI key required for the foundation screen; live Keryx spike requires local `functions/.env` with `GEMINI_API_KEY`
- Live Keryx connection in APK: **No** — foundation screen only

## 12. Physical Android test script
1. Install: `adb install -r build/app/outputs/flutter-apk/app-debug.apk` → app installs as The Local Agora / `com.junkfeathers.localagora`
2. Launch: open the app from the launcher → OLED near-black screen appears
3. Confirm title and Pass 01 status: visible `JUNKFEATHERS TECH`, `THE LOCAL AGORA`, `PASS 01 // KERYX FEASIBILITY`
4. Confirm layout is readable: bone-white monospaced labels, no colorful Flutter demo counter UI
5. Force-close and relaunch: same foundation screen; no crash
6. Capture any crash, overflow, or rendering failure: report screenshot + device model if any issue appears

## 13. Security, privacy, and operating-cost impact
- Secrets: none committed; model calls designed server-side only
- Privacy: private-address non-inference rules encoded in prompts and location modes
- Cost: no live Gemini spend this pass; public scan callable intentionally disabled

## 14. Known limitations and risks
- Live feasibility evidence missing until API key is provided
- Full splash animation not implemented (seam only)
- No Firestore/Hosting/Auth wiring yet (correct for Pass 01)
- Node local runtime is v24 while Functions commonly target 22; engines field allows both

## 15. Questions requiring council judgment
1. Please provide a Gemini API key for local `functions/.env` (or confirm an approved secret store path) so Tests A/B/C can run before Pass 02 UI work.
2. Confirm whether Pass 02 may begin only after a live `KERYX FEASIBLE` / `FEASIBLE WITH CHANGES` verdict (recommended: yes).

## 16. Recommended next pass
**Smallest next step:** Pass 01b — Live Keryx feasibility completion  
- Objective: run Tests A/B/C with a real key, finish evidence audits, revise `KERYX_EVALUATION.md` verdict  
- Why next: council cannot approve the full build without citation-backed proof  
- Dependencies: `GEMINI_API_KEY` in local ignored `.env`  
- Acceptance: criteria 13–16 and 19–21 move from BLOCKED to measured PASS/FAIL  
- New APK required: NO (unless UI changes)

Only after that: Pass 02 — Scan Control + sourced City Index (still no flyer/billing/maps).
