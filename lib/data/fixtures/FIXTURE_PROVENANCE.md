# Springfield Keryx demo fixture — provenance

**Pass:** 03 / 03.1 — Agora discovery vertical slice  
**Status:** Deterministic demonstration fixture (not a fresh live scan)

## Origin

Signals are reconstructed from **previously evaluated / verified Keryx discovery evidence** documented in:

- `docs/KERYX_EVALUATION.md` (Pass 01 Tests A/B — Springfield, Missouri MUSIC and related titles/venues)
- Pass 02B.2A council handoff (founder physical live proof: Springfield / NEXT 7 DAYS / MUSIC returned 10 signals)

## Honesty rules

- This is **not** a byte-for-byte copy of the original 10-signal live JSON payload (that payload was never committed).
- Results must be labeled as **verified Keryx signals / demonstration fixture data**.
- Do **not** present fixture output as a newly completed live Gemini/Keryx scan.
- Only public-safe, source-supported-style fields are included (title, date, optional time, venue/city, category, short summary, uncertainties, privacy mode).
- Unknown facts remain omitted (no invented ticket prices, lineups, ages, or private addresses).

## Source URL status (Pass 03.1)

Pass 01 eval artifacts under `functions/.eval-cache/` were never committed. The evaluation document records titles/venues but **does not preserve verified publisher URLs** for each accepted event. Grounding redirects were the common stored origin pattern and are not suitable to invent as publisher pages.

| Event id | Verified real source URL in repo? |
|---|---|
| demo-music-01 … demo-music-08 | **No** — `sourceUrl` omitted |
| demo-comedy-01 | **No** — `sourceUrl` omitted |

Therefore:

- Fixture `OPEN ORIGINAL SOURCE` is disabled.
- UI shows `SOURCE NOT AVAILABLE IN THIS RECORD`.
- No `example.com` / placeholder URLs remain in the production fixture path.
- Live Keryx responses continue to preserve real grounding/source URLs from the callable payload.

## Last checked

Demonstration `lastCheckedAt` aligns with the Pass 01 evaluation window (2026-07-10).
