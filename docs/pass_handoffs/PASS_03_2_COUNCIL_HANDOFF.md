# THE LOCAL AGORA — PASS 03.2 COUNCIL HANDOFF

## 1. Pass identity
- Objective: Public plain language, search overlay, CRT-first event actions
- Status: **READY FOR PHYSICAL + WEB RE-REVIEW** — not merge-approved
- Branch: `pass-03-agora-discovery-vertical-slice`
- Starting commit: `089e29808dab137dd6c5f6837bcc5cdd850440c1`
- Ending commit: *(recorded after tip commit)*
- ADR: ADR-043

## 2. Public language
Ordinary UI uses event-search wording (UPCOMING EVENTS, SCAN FOR EVENTS, TIME FRAME, EVENT TYPE).
Keryx/signal jargon reserved for code, docs, debug, technical credits.

## 3. CRT-first actions
Open Record removed from ordinary flow.
Each CRT event: CHECK SOURCE (when URL exists) + ADD TO CALENDAR // SOON (disabled).

## 4. Search UX
Opening CRT: WELCOME / SEARCH FOR AN EVENT NEAR YOU / USING THE CONTROL BELOW.
Primary control: SEARCH FOR AN EVENT → modal overlay → CANCEL | SCAN FOR EVENTS.
No location/time/type presets on open.

## 5. Searching animation
Continuous CRT animation (scan line, dots, rotating status) for long live scans.
Reduced-motion: blinking cursor + status text.

## 6. One-scan
Consumed beta: SEARCH shows `ERR // ONLY ONE SCAN ALLOWED FOR BETA`; results preserved.
Backend / App Check / live callable unchanged.

## 7. Tests / builds
| Command | Result |
|---|---|
| dart format | PASS (0 changed) |
| flutter analyze | PASS — no issues |
| flutter test | PASS — 112 tests |
| flutter build apk --debug | PASS — `build/app/outputs/flutter-apk/app-debug.apk` (162,993,954 bytes ≈ 155.4 MB) |
| flutter build web | PASS — `build/web` |

## 8. Drive sync
`build/drive_sync/PASS_03_2_DRIVE_SYNC.zip` (72,327,264 bytes ≈ 69.0 MB)

## 9. Limitations
- ADD TO CALENDAR is future-only (disabled).
- Web remains verified demo fallback.
- Open Record screen retained for optional legacy/debug tests only; not in ordinary flow.
- No additional paid live scan was run during this pass.

## 10. Next
Founder physical + web approval; merge only when directed.
