# THE LOCAL AGORA — PASS 03 COUNCIL HANDOFF

## 1. Pass identity
- Objective: Real Agora discovery vertical slice (demo fixture + City Index + Open Record)
- Status: **SUPERSEDED FOR UI/WIRING BY PASS 03.1** — concept approved; repair on same branch
- Branch: `pass-03-agora-discovery-vertical-slice`
- Starting approved commit: `4ae055ff5bf06c4ba3dc74fff324905fa2b265ab`
- Ending implementation commit: `2e8bb51f987d115e1b198c15f950a7589e04479f`
- Tip after Pass 03 handoff hash: `a92e62825cb0c8879ba391bc34cf085cf13abecb`
- See `PASS_03_1_COUNCIL_HANDOFF.md` for CRT / color / one-scan repair

## 2. Architecture (Pass 03 as shipped; updated in 03.1)
```text
Pass 03: SCAN → DemoKeryxService → City Index route → Open Record
Pass 03.1: SCAN → CRT-hosted results on Scan Control → Open Record route
```

## 3. Fixture provenance
- `lib/data/fixtures/springfield_keryx_demo_signals.dart`
- Provenance: `lib/data/fixtures/FIXTURE_PROVENANCE.md`
- Derived from Pass 01 evaluated titles; **not** the exact 02B.2A 10-signal JSON
- Pass 03.1: placeholder `example.com` URLs removed; sources omitted when unverified

## 4. State machine
idle → validating → searching → results | empty | error

## 5. Tests / builds (Pass 03 tip)
| Command | Result |
|---|---|
| flutter analyze | PASS — No issues found |
| flutter test | PASS — 83 tests (Pass 03 tip) |
| flutter build apk --debug | PASS — `build/app/outputs/flutter-apk/app-debug.apk` (162,970,557 bytes) |
| flutter build web | PASS — `build/web` |

## 6. Source-link status
Pass 03 used demo provenance labels with placeholder URLs (later removed in 03.1).

## 7. Limitations (Pass 03)
- City Index was a separate route (rejected; fixed in 03.1)
- Amber still present in some chrome (removed in 03.1)
- Ordinary Scan was demo-only (Android one live beta added in 03.1)
- Cache-first / async jobs remain future work

## 8. Drive sync
`build/drive_sync/PASS_03_DRIVE_SYNC.zip`

## 9. Next
Use Pass 03.1 handoff for re-review and merge authorization.
