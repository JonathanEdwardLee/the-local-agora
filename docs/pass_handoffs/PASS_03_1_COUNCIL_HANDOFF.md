# THE LOCAL AGORA — PASS 03.1 COUNCIL HANDOFF

## 1. Pass identity
- Objective: CRT-hosted results, green-only UI, real sources policy, one live beta scan
- Status: **READY FOR PHYSICAL + WEB RE-REVIEW** — not merge-approved
- Branch: `pass-03-agora-discovery-vertical-slice`
- Starting commit: `a92e62825cb0c8879ba391bc34cf085cf13abecb`
- Ending commit: `bd4a3019355070fbee231b64a9c4cee23cf0e23d`
- ADR: ADR-042

## 2. CRT results
Ordinary Scan stays on Scan Control. CRT hosts idle / searching / results / empty / error.
`OPEN RECORD` pushes the dedicated detail route; back restores CRT results (no rescan).

## 3. Color
Local Agora UI: black / white / occasional green only. Amber removed from product surfaces.

## 4. Sources
Fixture: no `example.com` URLs; `sourceUrl` omitted; `SOURCE NOT AVAILABLE IN THIS RECORD`.
Live path: preserves callable source URLs; human-readable labels only in UI.

## 5. One-scan beta (Android)
`hasUsedBetaKeryxScan` via `shared_preferences`. Consumed only on completed results/empty.
Second attempt: `ERR // ONLY ONE SCAN ALLOWED FOR BETA`.

## 6. Platform
| Platform | Scan path |
|---|---|
| Android + App Check | One live `keryxScanDebug` via `OneScanBetaKeryxService` |
| Web | Verified demo fixture (`DemoKeryxService`) — no reCAPTCHA site key configured |

## 7. Tests / builds
| Command | Result |
|---|---|
| flutter analyze | PASS — No issues found |
| flutter test | PASS — 107 tests |
| flutter build apk --debug | PASS — `build/app/outputs/flutter-apk/app-debug.apk` (162,982,552 bytes) |
| flutter build web | PASS — `build/web` (~36.8 MB) |

## 8. Drive sync
`build/drive_sync/PASS_03_1_DRIVE_SYNC.zip`

## 9. Limitations
- Web live scan not enabled (App Check web provider absent).
- Fixture events lack verified publisher URLs in-repo.
- Local Boolean is contest UX/cost guard, not secure rate limiting.
- Cache-first / async jobs remain future work.
- No secrets exposed in client.

## 10. Next
Founder physical + web approval; push/merge only when directed.
