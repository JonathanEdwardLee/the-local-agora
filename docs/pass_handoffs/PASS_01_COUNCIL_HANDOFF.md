# THE LOCAL AGORA — COUNCIL HANDOFF

## 1. Pass identity
- Pass: 01 / 01B — Repository Foundation + Live Keryx Feasibility Completion (controlled correction)
- Objective: Complete live two-pass Keryx feasibility on Springfield / 65806 for July 10–16, 2026
- Status: COMPLETE (Outcome A — smoke + Tests A/B/C succeeded)
- Branch: `pass-01-keryx-foundation`
- Final commit: `3db7fa5b8e17de4124550f4d5cc9edb386ccd121`
- App version: `0.1.0`
- Build number: `1`
- New APK: NO (Flutter unchanged in 01B)

## 2. Executive summary
- What was completed:
  - Live Interactions smoke test succeeded (`gemini-3.5-flash`, attempt 1)
  - Tests A, B, and C completed sequentially on Interactions (no generateContent fallback needed in final run)
  - Bounded retry policy corrected (max 4; 408/429/5xx only; ~2s/5s/10s backoff)
  - `@google/genai` locked at **2.11.0**; Functions runtime engines locked to **Node 22**
  - `docs/KERYX_EVALUATION.md` and this handoff updated with measured results
- What remains:
  - Pass 02 Scan Control / City Index UI
  - Origin-URL hardening, start-time audit tuning, cost controls
- Keryx feasibility verdict: **KERYX FEASIBLE WITH CHANGES**

## 3. Acceptance criteria

| Criterion | Status | Evidence |
|---|---|---|
| 1. Governing Markdown read | PASS | Pass 01B re-read |
| 2. Repository identity | PASS | Unchanged from Pass 01 |
| 3. Flutter launches | PASS | Unchanged |
| 4. Android package ID | PASS | `com.junkfeathers.localagora` |
| 5. Flutter analyze | PASS | Pass 01 |
| 6. Flutter tests | PASS | Pass 01 |
| 7. Debug APK exists | PASS | Pass 01 artifact |
| 8. Flutter web build | PASS | Pass 01 |
| 9. TypeScript functions workspace | PASS | Present |
| 10. TS lint/tests/build | PASS | Re-run after 01B correction |
| 11. No invented Firebase project | PASS | None |
| 12. No secret committed | PASS | Post-scan NO_MATCHES for secret values; `.env` ignored |
| 13. Grounded Springfield findings with citations | PASS | A: 13 accepted, 157 citations |
| 14. Broad scan evaluated | PASS | Test A completed |
| 15. Music scan evaluated | PASS | Test B completed; 9/9 MUSIC |
| 16. `65806` scan evaluated | PASS | Test C completed; Springfield interpretation |
| 17. Separate discovery + normalization | PASS | Two Interactions operations per test |
| 18. Zod validation | PASS | invalidStructuredOutputCount=0 |
| 19. Accepted facts traceable to evidence | PASS | Audit + strip pipeline; residual unsupported=0 |
| 20. Unsupported accepted facts = 0 | PASS | A/B/C all 0 |
| 21. Past events excluded | PASS | A and C each excluded 1 past event |
| 22. Private addresses not inferred | PASS | No private-address inference observed |
| 23. `KERYX_EVALUATION.md` complete | PASS | Updated with live results |
| 24. Full UI/flyer/billing not built | PASS | Out of scope |
| 25. Council handoff produced | PASS | This document |
| 26. Smallest next pass identified | PASS | Pass 02 Scan Control + City Index |

## 4. User-visible changes
- None in the Flutter app (foundation screen unchanged).
- Backend/docs only for 01B.

## 5. Internal implementation
- Bounded retry helper (`retry.ts`)
- Interactions preferred + generateContent capacity fallback behind `GeminiKeryxEngine`
- Smoke script `npm run keryx:smoke`
- Sequential spike saves each test before the next
- Node engines locked to `22`

## 6. Files created, changed, moved, or deleted
- Created: `functions/src/keryx/retry.ts`, `functions/scripts/smoke_grounded_search.ts`, `functions/test/retry.test.ts`
- Modified: `gemini_keryx_engine.ts`, `keryx_engine.ts`, `run_keryx_spike.ts`, `package.json`, `package-lock.json`, tests, `docs/KERYX_EVALUATION.md`, this handoff
- Not committed: `functions/.env`, `functions/.eval-cache/**`, secrets

## 7. Architecture and dependency decisions
- Preferred API: Interactions + `google_search`
- Fallback API: `generateContent` + `googleSearch` (capacity only; unused in final A/B/C)
- Default model: `gemini-3.5-flash` (unchanged in permanent docs)
- SDK: `@google/genai@2.11.0`
- Functions deploy runtime target: Node **22** (local machine remains Node 24 with EBADENGINE warning)

## 8. Keryx evaluation results
- Live feasibility verdict: **KERYX FEASIBLE WITH CHANGES**
- Models: `gemini-3.5-flash` / `gemini-3.5-flash`
- API path: Interactions (discovery + structured normalization)
- Smoke: success; attempts=1; citations=16; searchCalls=3
- Grounded searches (A+B+C discovery): 3 successful
- Normalization calls: 3 successful
- Events accepted: A=13, B=9, C=16 (total 38 accepted across tests; not deduped across tests)
- Events rejected: past exclusions A=1, C=1; other rejectedTitles as recorded
- Unsupported accepted facts: **0**
- Citation quality: high volume; stored origins often grounding redirects (change required)
- Broad vs music: music filter strongly improves music relevance (9/9 MUSIC)
- Postal-code: `65806` → Springfield MO coherent
- Duplicates within tests: 0
- Cost: material search-query counts (B reported 22 queries in one discovery); caching required before public exposure
- Fallback used in final run: **no**

## 9. Commands and actual results

```text
npm list @google/genai     → @google/genai@2.11.0
npm run lint               → PASS
npm run build              → PASS
npm test                   → PASS (12 tests)
npm run keryx:smoke        → PASS (Interactions, attempt 1)
npm run keryx:spike        → PASS (A, B, C sequential)

PRE_SECRET_SCAN            → doc var-name mentions only (no committed keys)
POST_SECRET_SCAN           → NO committed secret values
```

## 10. Automated tests
- Config, schema/audit, retry policy unit tests — all passing

## 11. APK and web-build information
- APK rebuilt in 01B: NO
- Prior Pass 01 debug APK remains valid for foundation UI only
- Live Keryx not connected in APK

## 12. Physical Android test script
Unchanged from Pass 01 foundation screen checks (no Flutter delta).

## 13. Security, privacy, and operating-cost impact
- Secrets: not committed; key used from environment only
- Privacy: no private address inference observed
- Cost: Search query volume is non-trivial; do not expose unlimited public scan yet

## 14. Known limitations and risks
- Start times over-stripped / missing after audit
- Origin URLs often grounding redirects
- Provider capacity 500s can recur; fallback exists but preferred path is Interactions
- Local Node 24 vs Functions Node 22 — install Node 22 before emulator/deploy

## 15. Questions requiring council judgment
1. Approve Pass 02 Scan Control + City Index given `KERYX FEASIBLE WITH CHANGES`?
2. Should origin-URL resolution and start-time audit hardening be required gates inside Pass 02, or a quick 01C polish?

## 16. Recommended next pass
**Pass 02 — Scan Control + sourced City Index**  
- Objective: city/ZIP + time window + category → cached chronological text index with origins  
- Why next: feasibility proven enough to build the receiver loop  
- Dependencies: protected callable design, cache policy, App Check staging plan  
- New APK: YES  
- Do not begin flyer upload, billing, maps, or accounts in Pass 02
