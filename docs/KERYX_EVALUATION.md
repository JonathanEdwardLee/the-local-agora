# THE LOCAL AGORA — KERYX EVALUATION

**Pass:** 01 / 01B — Repository Foundation + Live Keryx Feasibility Completion  
**Product:** The Local Agora  
**Engine:** Keryx  
**Document status:** Live grounded scans completed (Pass 01B correction)  
**Last revised:** July 10, 2026  
**Verdict:** `KERYX FEASIBLE WITH CHANGES`

---

## 1. Pass objective

Prove that the Keryx Engine can:

1. Search current public event information for a specific place and time.
2. Preserve usable source citations.
3. Convert grounded findings into a strict typed event structure.
4. Avoid inventing unsupported event facts.
5. Produce evidence strong enough for the council to approve the full application build.

---

## 2. Date and environment

| Item | Value |
|---|---|
| Evaluation calendar context | Friday, July 10, 2026 |
| Local time zone context | America/Chicago |
| Host OS | Windows 10 (build 26200) |
| Flutter | 3.41.9 (stable) |
| Dart | 3.11.5 |
| Local Node | v24.18.0 |
| Configured Firebase Functions runtime | **Node.js 22** (`engines.node` in `functions/package.json`) |
| Local compatibility warning | `npm` `EBADENGINE` when installing on Node 24 vs engines 22 — expected; not a spike blocker |
| Node 22 required before emulator/deploy? | **Yes** for future Firebase emulator/deploy passes; not required for this local spike |
| Gemini API key | Present in environment (not printed; `functions/.env` optional/ignored) |
| Live run completed at | 2026-07-10T15:07:03Z |

---

## 3. Models and API paths tested

### Preferred path (used successfully for smoke + A/B/C)

| Pass | API path | Model | Tooling |
|---|---|---|---|
| A — Grounded discovery | Interactions API `interactions.create` | `gemini-3.5-flash` | `tools: [{ type: "google_search" }]`, `store: false` |
| B — Normalization | Separate `interactions.create` | `gemini-3.5-flash` | Structured `response_format` JSON Schema; **no** search tool |

### Temporary compatibility path (implemented, not needed for final A/B/C)

| Path | When used |
|---|---|
| `generateContent` + `googleSearch` | Only if Interactions fails after bounded capacity retries |
| `gemini-3-flash-preview` diagnostic | Only if both Interactions and generateContent on `gemini-3.5-flash` fail |

**Final A/B/C run:** preferred Interactions path only. `usedFallback=false` for all three tests.

### SDK correction (Pass 01B)

| Package | Version |
|---|---|
| `@google/genai` | **2.11.0** (≥ 2.3.0 required for current Interactions schema) |
| `firebase-functions` | 6.6.0 |
| `firebase-admin` | 13.10.0 |
| `zod` | 4.4.3 |
| `typescript` | 5.9.3 |
| `vitest` | 3.2.7 |

**Override note:** Earlier in Pass 01B, `@google/genai@1.52.0` returned **400** legacy Interactions schema. Upgraded to **2.11.0**. Permanent blueprints not changed; default model remains `gemini-3.5-flash`.

### Failed paths (recorded, not reused)

| Attempt | Result |
|---|---|
| `gemini-3.5-flash` Interactions before capacity recovered | **500** high demand (bounded retries exhausted) |
| `gemini-2.5-flash` | **404** unavailable to new users — do not retry |

---

## 4. Exact test queries

### Smoke test (required gate)

- Model: `gemini-3.5-flash`
- API: Interactions + `google_search`
- Result: **success** on attempt 1; status 200; citations=16; search calls=3; fallback=false

### Test A — broad local scan

- Location: `Springfield, Missouri`
- Window: `2026-07-10` through `2026-07-12`
- Category: `ALL`

### Test B — music scan

- Location: `Springfield, Missouri`
- Window: `2026-07-10` through `2026-07-12`
- Category: `MUSIC`

### Test C — postal-code scan

- Location: `65806`
- Window: `2026-07-10` through `2026-07-16`
- Category: `ALL`

---

## 5. Number of grounded searches and model calls

| Metric | Smoke | A | B | C | Total (A+B+C) |
|---|---|---|---|---|---|
| Pass A discovery calls (successful) | 1 | 1 | 1 | 1 | 3 |
| Pass B normalization calls | 0 | 1 | 1 | 1 | 3 |
| Discovery attempts (incl. retries) | 1 | 1 | 1 | 1 | 3 |
| Reported Google Search queries (from response) | 3 | 12 | 22 | 8+ | ~42+ |
| Fallback generateContent calls (final run) | 0 | 0 | 0 | 0 | 0 |

Earlier failed capacity retries (pre-correction / pre-recovery) are excluded from the successful-run totals above but are documented in §16.

---

## 6. Sanitized event-result summaries

### Test A — broad (13 accepted)

Examples (titles/dates/venues only):

- 2026 National Teddy Bear Picnic — 2026-07-10 — Silver Springs Park
- Rountree Summerween Block Party — 2026-07-10 — Pickwick Ave. between Grand & Delmar
- Sharkcuterie — 2026-07-10 — Wonders of Wildlife
- Family Fishing Fun Night — 2026-07-10 — Rutledge-Wilson Farm Park
- Eric Eaton Live — 2026-07-10 — Springfield Comedy Club
- On the Lawn — 2026-07-11 — Springfield Art Museum Hatch Lawn
- Fassnight Creek Monthly Cleanup — 2026-07-11 — Springfield Art Museum
- Boom Ball Tour — 2026-07-11 — Route 66 Stadium
- Live From Downtown Concert Series: Sister Lucille — 2026-07-11 — Park Central Square
- Movies in the Park: GOAT — 2026-07-11 — Silver Springs Park
- WonkyWilla — 2026-07-11 — The Regency Live
- Cherry Street Market — 2026-07-12
- Sports Cards and Collectible Show — 2026-07-10 — Battlefield Mall

Rejected: `DOTS Fringe 2026 (past)` — past-event exclusion worked.

### Test B — music (9 accepted)

All accepted `eventType=MUSIC`, including:

- PET SOUNDS LIVE
- Live Music @ Tie & Timber Beer Co. (Fri/Sat sessions)
- Live From Downtown: Sister Lucille …
- WonkyWilla at The Regency Live
- Candlelight tributes (Coldplay/Imagine Dragons; Fleetwood Mac)
- Live Music at Gailey's Cafe
- La Reunión Norteña

### Test C — 65806 (16 accepted)

Interpreted as Springfield, Missouri metro/local area. Mix of music, comedy, gatherings, and film screenings across July 10–16. One past camp event excluded.

---

## 7. Source URLs

Citations were returned in volume (A: 157, B: 109, C: 205 annotation/citation records).

**Important usability finding:** normalized `sourceUrl` values were predominantly Google Grounding redirect URLs (`vertexaisearch.cloud.google.com/grounding-api-redirect/...`) rather than direct publisher URLs. Redirects are attributable and openable, but Pass 02 should prefer resolving/displaying original publisher URLs when available in grounding metadata.

Raw eval artifacts remain local/gitignored under `functions/.eval-cache/` (not committed).

---

## 8. Source-quality assessment

| Observation | Assessment |
|---|---|
| Official venue / organizer calendars | Present in search queries and findings (Gillioz, comedy club, art museum, parks) |
| Ticket / event platforms | Present in discovery corpus |
| Local publications / city calendars | Queried and cited in grounded text |
| Aggregators | Some bleed risk |
| Grounding redirects as stored origin | Weak for user-facing “open original source” until resolved |
| Overall | Usable for feasibility; needs origin-URL hardening for product UX |

---

## 9. Field-by-field evidence audit

Pipeline audited each normalized candidate; unsupported scalars were stripped before acceptance.

| Field pattern (accepted set) | Observation |
|---|---|
| Event title | Generally SUPPORTED |
| Date | Generally SUPPORTED (ISO matched natural-language dates) |
| Start time | **Commonly stripped / null after audit** (0/13, 0/9, 0/16 retained) — time-format matching too strict or discovery phrasing mismatch |
| Venue / city | Generally retained for Springfield |
| Performers | Often missing |
| Price / age | Frequently missing or stripped |
| Ticket/info URL | Often missing after audit |
| Location mode | All accepted used `EXACT_PUBLIC` in this spike (no ASK_ORGANIZER private-house cases observed) |
| Unsupported accepted facts | **0** across A/B/C |

---

## 10. Duplicate observations

| Test | Duplicate title+date+venue pairs in accepted set |
|---|---|
| A | 0 |
| B | 0 |
| C | 0 |

Near-duplicates across tests (same show appearing in A and B) are expected and not counted as within-test duplicates.

---

## 11. Broad-query versus category-query comparison

| | Broad (A) | Music (B) |
|---|---|---|
| Accepted | 13 | 9 |
| Music-typed share | 2/13 | **9/9** |
| Non-music gatherings/comedy/other | Dominant | None accepted |
| Search queries reported | 12 | 22 |

**Conclusion:** Category-specific MUSIC scanning materially improves relevance for music seekers and reduces non-music clutter. Broad scan remains useful for “all signals.”

---

## 12. Postal-code interpretation result

`65806` was interpreted as Springfield, Missouri local events for July 10–16, 2026. Results were geographically coherent with the Springfield scene (downtown venues, parks, local clubs). No evidence of wrong-metro collapse in accepted titles. Longer window correctly admitted mid-week film/comedy entries.

---

## 13. Unsupported-fact count

| Scope | Count |
|---|---|
| Accepted records with residual UNSUPPORTED fields | **0** (A+B+C) |
| Offline unit strip test | 0 |

---

## 14. Invalid structured-output count

| Test | Invalid Zod/JSON outputs |
|---|---|
| A | 0 |
| B | 0 |
| C | 0 |

---

## 15. Missing-field patterns

Most common gaps in accepted records:

1. **Start time** (nearly always absent after audit)
2. Performers
3. Age restriction
4. Price (variable)
5. Direct publisher ticket/info URL (redirect-heavy origins)

---

## 16. Errors and retries

### Pass 01B correction policy (implemented)

- Max **4** attempts per operation
- Retry only 408/429/500/502/503/504 (and capacity language)
- Do **not** retry 400/401/403/404
- Backoff ~0 / 2s / 5s / 10s + jitter
- Sequential tests only; save each result before next

### Historical errors (before successful run)

| Error | Status | Model | Path | Notes |
|---|---|---|---|---|
| Legacy Interactions schema | 400 | gemini-3.5-flash | Interactions | Fixed by upgrading `@google/genai` to 2.11.0 |
| High demand | 500 | gemini-3.5-flash | Interactions | Exhausted older aggressive retries; later recovered |
| Model unavailable to new users | 404 | gemini-2.5-flash | Interactions | Abandoned permanently for this project |

### Successful final run

No retries required (1 attempt each discovery + normalization per test).

---

## 17. Approximate operating-cost considerations

Without inventing prices:

- Gemini 3 Search grounding may bill per model-issued search query.
- Observed query counts were material (especially music scan: 22 queries in one discovery call).
- Pass A dominates cost; Pass B is a second model call without Search.
- Caching/rate limits remain essential before public callables (Pass 02+).

---

## 18. Security and privacy observations

- No API key committed; `functions/.env` gitignored.
- Flutter unchanged; no client secrets.
- Private-address inference not observed; no ASK_ORGANIZER cases in this sample.
- Pre/post secret scans: no committed secret values (doc mentions of the env var name only).
- Eval cache gitignored; not committed.

---

## 19. Conclusion

### `KERYX FEASIBLE WITH CHANGES`

**Why feasible**

- Live grounded Springfield discovery works on Interactions + `gemini-3.5-flash` + `google_search`.
- Separate normalization validates with Zod and yields typed events.
- Citations returned in volume; past events excluded; unsupported accepted facts = 0.
- Music category filtering improves relevance; postal `65806` maps sensibly to Springfield.

**Required changes before/during Pass 02**

1. Improve start-time evidence matching (retain supported clock times; reduce over-stripping).
2. Prefer original publisher URLs over grounding redirect URLs in stored/displayed origins.
3. Add cost controls (cache, query budgets) before exposing public scan callables.
4. Keep generateContent fallback behind the provider interface for capacity incidents only; preferred path remains Interactions.

---

## 20. Smallest recommended next technical step

**Pass 02B.2 — Secure Live Keryx Scan Activation** (after physical approval of 02B.1 link)  
Still no flyer upload, billing, maps, or accounts. Store `GEMINI_API_KEY` via Secret Manager, enable one protected scan callable, then connect `SCAN THE AGORA`.

---

## 21. Pass 02B.1 transport note (July 10, 2026)

Firebase callable transport is configured for project `gen-lang-client-0718451481`:

- Flutter: `firebase_core` + `cloud_functions` (Android + web)
- Deployed Gen2 callable: `keryxStatus` (`us-central1`, Node 22)
- Response is status-only (`scanEnabled: false`); no Gemini invocation
- Debug-only client probe: `TEST KERYX LINK`
- **Physical remote status invocation on device:** pending Jonathan’s Android test
- **Feasibility verdict unchanged:** `KERYX FEASIBLE WITH CHANGES`

A successful status call proves transport only. It does **not** prove grounded discovery, Gemini quality, citations, normalization, event accuracy, or cost per scan.

---

## Appendix — Implementation map

| Concern | Location |
|---|---|
| Bounded retry | `functions/src/keryx/retry.ts` |
| Interactions + generateContent fallback | `functions/src/keryx/gemini_keryx_engine.ts` |
| Status callable (no Gemini) | `functions/src/index.ts` → `keryxStatus` |
| Flutter link service | `lib/services/keryx/` |
| Smoke test | `functions/scripts/smoke_grounded_search.ts` (`npm run keryx:smoke`) |
| Sequential spike | `functions/scripts/run_keryx_spike.ts` |
| Local eval artifacts (gitignored) | `functions/.eval-cache/` |
