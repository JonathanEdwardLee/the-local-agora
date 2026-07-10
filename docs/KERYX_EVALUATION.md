# THE LOCAL AGORA — KERYX EVALUATION

**Pass:** 01 — Repository Foundation and Keryx Feasibility Spike  
**Product:** The Local Agora  
**Engine:** Keryx  
**Document status:** Complete for Pass 01 infrastructure; live grounded scans BLOCKED pending API key  
**Last revised:** July 10, 2026

---

## 1. Pass objective

Prove that the Keryx Engine can:

1. Search current public event information for a specific place and time.
2. Preserve usable source citations.
3. Convert grounded findings into a strict typed event structure.
4. Avoid inventing unsupported event facts.
5. Produce evidence strong enough for the council to approve the full application build.

Pass 01 also establishes the Flutter repository foundation and the TypeScript Cloud Functions workspace.

---

## 2. Date and environment

| Item | Value |
|---|---|
| Evaluation calendar context | Friday, July 10, 2026 |
| Local time zone context | America/Chicago |
| Host OS | Windows 10 (build 26200) |
| Flutter | 3.41.9 (stable) |
| Dart | 3.11.5 |
| Node (local) | v24.18.0 |
| npm | 10.7.0 |
| Functions engine target | Node 22 \|\| 24 |
| Gemini API key present | **No** (`GEMINI_API_KEY` unset; `functions/.env` absent) |

---

## 3. Models and API paths tested

### Intended / configured (ADR-006)

| Pass | API path | Model | Tooling |
|---|---|---|---|
| A — Grounded discovery | Gemini **Interactions API** via `@google/genai` `interactions.create` | `gemini-3.5-flash` (config default) | `tools: [{ type: "google_search" }]` |
| B — Normalization | Separate `interactions.create` | `gemini-3.5-flash` (config default) | Structured `response_format` JSON Schema; **no** search tool |

### Official docs consulted at implementation time

- https://ai.google.dev/gemini-api/docs/google-search (Interactions API + `google_search`)
- https://ai.google.dev/gemini-api/docs/structured-output
- https://ai.google.dev/gemini-api/docs/interactions/quickstart

### Compatibility override

None applied. No live model call succeeded, so no override was required.

### Packages recorded (installed)

| Package | Installed version |
|---|---|
| `@google/genai` | 1.52.0 |
| `firebase-functions` | 6.6.0 |
| `firebase-admin` | 13.10.0 |
| `zod` | 4.4.3 |
| `typescript` | 5.9.3 |
| `vitest` | 3.2.7 |

---

## 4. Exact test queries

### Test A — broad local scan

- Location: `Springfield, Missouri`
- Window: `2026-07-10` through `2026-07-12`
- Category: `ALL` (all approved creative and community categories)
- Calendar context: `Friday, July 10, 2026`

### Test B — category-specific scan

- Location: `Springfield, Missouri`
- Window: `2026-07-10` through `2026-07-12`
- Category: `MUSIC`
- Calendar context: `Friday, July 10, 2026`

### Test C — postal-code interpretation

- Location: `65806`
- Window: `2026-07-10` through `2026-07-16`
- Category: `ALL`
- Calendar context: `Friday, July 10, 2026`

Runner: `functions` → `npm run keryx:spike` (`scripts/run_keryx_spike.ts`)

---

## 5. Number of grounded searches and model calls

| Metric | Result |
|---|---|
| Grounded discovery calls (Pass A) | **0** (blocked) |
| Normalization calls (Pass B) | **0** (blocked) |
| Billable Google Search queries | **0** (blocked) |

`npm run keryx:spike` exited with code 2:

```text
BLOCKED: GEMINI_API_KEY is not set. Copy functions/.env.example to functions/.env.
```

---

## 6. Sanitized event-result summaries

**No live normalized events.** Live discovery did not run.

Offline unit fixtures exercised schema validation and evidence stripping only (see §10 automated tests in the council handoff). Those fixtures are synthetic and are **not** claimed as Springfield public findings.

---

## 7. Source URLs

None from live grounded search.

---

## 8. Source-quality assessment

Not available — no live citations.

Planned classification labels (implemented in `functions/src/keryx/audit.ts` for future runs):

- Official venue or organizer source
- Public institution or city calendar
- Ticket platform
- Local publication
- Event aggregator
- Publicly indexed social page
- Low-confidence or unclear source

---

## 9. Field-by-field evidence audit

Not available for live events.

Audit machinery is implemented and unit-tested:

- Fields classified as `SUPPORTED` / `UNKNOWN` / `CONFLICTING` / `UNSUPPORTED`
- Unsupported scalars are stripped before acceptance
- Records with unsupported titles are rejected
- ISO dates can match natural-language date phrases in the grounded corpus

---

## 10. Duplicate observations

Not available — no live accepted set.

Deduplication key implemented: normalized title + start date + venue/city.

---

## 11. Broad-query versus category-query comparison

**NOT TESTED (BLOCKED).** Tests A and B did not execute against Gemini.

---

## 12. Postal-code interpretation result

**NOT TESTED (BLOCKED).** Test C (`65806`) did not execute against Gemini.

---

## 13. Unsupported-fact count

| Scope | Count |
|---|---|
| Live accepted records | N/A (no live run) |
| Offline unit test after strip | **0** residual unsupported facts on cleaned fixture |

---

## 14. Invalid structured-output count

| Scope | Count |
|---|---|
| Live Pass B | N/A |
| Offline Zod rejection of bad `schemaVersion` | Covered by unit test (invalid rejected) |

---

## 15. Missing-field patterns

Not available from live data. Expected common gaps (hypothesis only, not measured): start time, price, age restriction, exact venue address mode, performer lists.

---

## 16. Errors and retries

| Event | Detail |
|---|---|
| Spike start | Hard-stop when `GEMINI_API_KEY` missing (intentional; no silent fake success) |
| Model retries | None |
| API rejections | None (no call made) |

---

## 17. Approximate operating-cost considerations

No live spend occurred.

Planning notes from official Search grounding docs (Gemini 3 family):

- Grounding with Google Search may bill per search query the model executes inside a single prompt.
- Pass A is the cost-dominant step; Pass B is a separate structured-output call without Search.
- Caching and rate limits remain future Pass 02+ concerns; Pass 01 does not deploy public callables for scans.

Exact dollar amounts are **not invented** here.

---

## 18. Security and privacy observations

- No Gemini key committed; `.env.example` uses placeholders only.
- Flutter client contains no provider credentials or prompt construction.
- Provider implementation sits behind `KeryxEngine` / `GeminiKeryxEngine`.
- Private-address instructions are present in Pass A and Pass B prompts.
- Repo secret scan (Pass 01): **NO_MATCHES** (see council handoff for command).
- No production Firebase project ID invented or bound.

---

## 19. Conclusion

### `KERYX NOT YET PROVEN`

**Reason:** The two-pass pipeline, schema, audit, and Functions workspace are implemented and unit-tested, but the required live Springfield / `65806` grounded evaluations could not run because `GEMINI_API_KEY` was unavailable in the environment.

Infrastructure readiness does **not** substitute for citation-backed feasibility evidence.

---

## 20. Smallest recommended next technical step

1. Founder places a Gemini API key in local `functions/.env` (never commit).
2. Re-run `cd functions && npm run keryx:spike`.
3. Complete this evaluation document with real sanitized results, audits, and a revised feasibility verdict.
4. Only after a non-blocked verdict, begin Pass 02 — Scan Control + cached public index UI (still no flyer/billing/maps).

---

## Appendix — Implementation map

| Concern | Location |
|---|---|
| Configuration | `functions/src/config/keryx_config.ts` |
| Request construction | `functions/src/keryx/request_builder.ts` |
| Engine interface | `functions/src/keryx/keryx_engine.ts` |
| Gemini provider | `functions/src/keryx/gemini_keryx_engine.ts` |
| Evidence URL sanitize | `functions/src/keryx/evidence.ts` |
| Schema + Zod | `functions/src/schema/agora_event.ts` |
| Audit | `functions/src/keryx/audit.ts` |
| Two-pass pipeline | `functions/src/keryx/pipeline.ts` |
| Local spike runner | `functions/scripts/run_keryx_spike.ts` |
