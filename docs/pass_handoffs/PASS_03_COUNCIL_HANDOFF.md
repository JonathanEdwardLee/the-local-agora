# THE LOCAL AGORA — PASS 03 COUNCIL HANDOFF

## 1. Pass identity
- Objective: Real Agora discovery vertical slice (demo fixture + City Index + Open Record)
- Status: **READY FOR PHYSICAL + WEB REVIEW** — not merge-approved
- Branch: `pass-03-agora-discovery-vertical-slice`
- Starting approved commit: `4ae055ff5bf06c4ba3dc74fff324905fa2b265ab`
- Ending commit: *(filled after tip commit)*
- No paid live Gemini scan run in this pass

## 2. Architecture
```text
SCAN THE AGORA → DemoKeryxService.scan
  → searching (~1.1s) → City Index | empty | typed error
  → Open Record route → OPEN ORIGINAL SOURCE (url_launcher)

Live keryxScanDebug → debug gallery only (unchanged)
```

## 3. Fixture provenance
- `lib/data/fixtures/springfield_keryx_demo_signals.dart`
- Provenance: `lib/data/fixtures/FIXTURE_PROVENANCE.md`
- Derived from Pass 01 evaluated titles; **not** the exact 02B.2A 10-signal JSON
- Banner: `VERIFIED KERYX SIGNALS // LAST CHECKED 2026.07.10`
- Demo URLs are `example.com/agora-demo/...` with human-readable labels

## 4. State machine
idle → validating → searching → results | empty | error  
Double-scan blocked while in flight.

## 5. Tests / builds
| Command | Result |
|---|---|
| flutter analyze | PASS — No issues found |
| flutter test | PASS — 83 tests |
| flutter build apk --debug | PASS — `build/app/outputs/flutter-apk/app-debug.apk` (162,970,557 bytes) |
| flutter build web | PASS — `build/web` |

## 6. Physical checklist
Springfield / NEXT 7 DAYS / MUSIC → searching → chronological City Index → open ≥3 records → OPEN ORIGINAL SOURCE → COMEDY → THEATER empty → ADD EVENT / ABOUT intact. Do **not** run paid live scan unless separately authorized. Confirm splash / Welcome / Pass 02C.1 identity preserved.

## 7. Drive sync
`build/drive_sync/PASS_03_DRIVE_SYNC.zip` (handoff + ADR excerpt + provenance + debug APK)

## 8. Next
Founder physical + web approval; then council; merge only when directed. Future: cache-first / async jobs / citation URL hygiene.
