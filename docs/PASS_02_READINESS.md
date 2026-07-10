# THE LOCAL AGORA — PASS 02 READINESS

**Pass:** 02B.1 — Firebase Link Foundation and Final Machine Geometry  
**Date:** July 10, 2026  
**Branch:** `pass-02b1-firebase-link-foundation`

---

## Pass 02B.1 Firebase link foundation (July 10, 2026)

| Item | Status |
|---|---|
| Pass 02A.2 physical test | **FUNCTIONALITY APPROVED — FINAL GEOMETRY REFINEMENTS REQUESTED** |
| Pass 02B.1 geometry refinements | **COMPLETE** (awaiting physical review) |
| Pass 02B.1 Firebase link | **CONFIGURED + `keryxStatus` DEPLOYED** (physical link test pending) |
| Branch | `pass-02b1-firebase-link-foundation` |
| Handoff | `docs/pass_handoffs/PASS_02B1_COUNCIL_HANDOFF.md` |
| Firebase project | `gen-lang-client-0718451481` (The Local Agora Dev) |
| FlutterFire platforms | Android + web |
| Flutter packages | `firebase_core`, `cloud_functions` only |
| Deployed function | `keryxStatus` (us-central1, Node 22) |
| Live Keryx / Gemini | **NO** |
| Gemini secret | **Intentionally not configured** |
| App Check | **Deferred** |
| Node 22 | **Complete** (`v22.23.1`) |
| Firebase CLI | **Complete** (`15.23.0`) |
| FlutterFire CLI | **Complete** (`1.4.0`) |
| Budget alert | **Complete** (founder) |
| GitHub remote | **Still pending** |
| New debug APK | `build/app/outputs/flutter-apk/app-debug.apk` — **required for physical review** |

Physical test: use the **Pass 02B.1** APK and the numbered script in the Pass 02B.1 council handoff.

---

## Pass 02A.2 integrated machine panel (July 10, 2026)

| Item | Status |
|---|---|
| Pass 02A.2 physical test | **FUNCTIONALITY APPROVED — FINAL GEOMETRY REFINEMENTS REQUESTED** |
| Branch | `pass-02a2-integrated-machine-panel` |
| Handoff | `docs/pass_handoffs/PASS_02A2_COUNCIL_HANDOFF.md` |
| Geometry | Superseded by Pass 02B.1 compact identity / taller CRT / coil ticks |
| Firebase / live Keryx | Status callable only in 02B.1; live scan still deferred |

---

## Pass 02A.1 / 02A (summary)

Prior visual and machine-shell passes remain accepted. Portrait lock, top OLED toasts, keyboard inset behavior, and dial WHEN/WHAT are preserved through 02B.1. See `PASS_02A1_COUNCIL_HANDOFF.md` and `PASS_02A_COUNCIL_HANDOFF.md`.

---

## Environment

| Item | Value |
|---|---|
| Operating system | Windows 11 Home 64-bit (build 26200) |
| Active Node version | **v22.23.1** (`C:\nvm4w\nodejs\node.exe`) |
| Required Node version | **22** |
| npm version | 10.9.8 |
| Flutter version | 3.41.9 (stable) |
| Dart version | 3.11.5 |
| Firebase CLI version | **15.23.0** |
| FlutterFire CLI | **1.4.0** |
| Firebase project | `gen-lang-client-0718451481` (The Local Agora Dev) |
| Billing | Blaze + monthly budget alert (founder) |
| Git version | 2.54.0.windows.1 |
| GitHub remote | **Still pending** |

## Repository

| Item | Value |
|---|---|
| Branch | `pass-02b1-firebase-link-foundation` |
| GitHub remote | **None configured** |
| Functions `engines.node` | `"22"` |
| `firebase.json` | Present (functions only) |
| `.firebaserc` | `default` + `dev` → `gen-lang-client-0718451481` |
| Live Keryx verdict | `KERYX FEASIBLE WITH CHANGES` (Pass 01B) — **unchanged** by transport proof |

## Backend (Pass 02B.1)

| Check | Result |
|---|---|
| Functions lint | PASS |
| Functions build | PASS |
| Functions tests | PASS |
| Deploy `functions:keryxStatus` | SUCCESS (create); cleanup-policy warning only |
| `keryxScanNotEnabled` | Not deployed; remains disabled in source |
| Gemini secret | Not set |
| Live scan | Not enabled |

## Readiness verdict

### `READY FOR PHYSICAL ANDROID + FIREBASE LINK TEST`

Founder Node 22 / Firebase CLI / FlutterFire / project / budget alert are complete. Geometry and status-callable transport are implemented. Jonathan must physically approve the APK and the debug `TEST KERYX LINK` call before Pass 02B.2.

## Explicitly deferred

- Live Keryx event scan
- Gemini Secret Manager / `GEMINI_API_KEY`
- Firestore, Storage, Authentication, App Check, Analytics packages, Hosting
- GitHub remote
- iOS FlutterFire registration
- Flyer processing, billing, maps, accounts
- Artifact Registry cleanup policy (optional founder follow-up; deploy warned)
