# THE LOCAL AGORA — PASS 02 READINESS

**Pass:** 01C — Node 22 and Pass 02 Readiness Audit  
**Date:** July 10, 2026  
**Branch:** `pass-01-keryx-foundation`

---

## Pass 02A.2 integrated machine panel (July 10, 2026)

| Item | Status |
|---|---|
| Pass 02A.1 physical test | **FUNCTIONALITY PASS — VISUAL REFINEMENT REQUESTED** |
| Pass 02A.2 refinements | **COMPLETE** (awaiting physical review of refined APK) |
| Branch | `pass-02a2-integrated-machine-panel` |
| Handoff | `docs/pass_handoffs/PASS_02A2_COUNCIL_HANDOFF.md` |
| External numbered headers | Removed |
| Panel 01 identity + retro date | Implemented |
| Panel 02 CRT monitor + real scrollbar | Implemented |
| Panel 03 compact triple rings | Implemented |
| Panel 04 chassis + WHEN/WHAT dials | Implemented |
| Keyboard / top toasts / portrait | Preserved |
| New debug APK | `build/app/outputs/flutter-apk/app-debug.apk` — **required for physical review** |
| Node 22 | **Still pending** |
| Firebase CLI / FlutterFire CLI | **Still deferred** |
| GitHub remote | **Still pending** |
| Firebase / live Keryx | **Still deferred** |

---

## Pass 02A.1 machine-shell refinement (July 10, 2026)

| Item | Status |
|---|---|
| Pass 02A physical Android Test 02A | **PASS WITH APPROVED REFINEMENTS** |
| Pass 02A.1 refinements | **COMPLETE** — physical: **FUNCTIONALITY PASS — VISUAL REFINEMENT REQUESTED** |
| Branch | `pass-02a1-machine-shell-refinement` |
| Handoff | `docs/pass_handoffs/PASS_02A1_COUNCIL_HANDOFF.md` |
| Portrait lock | Implemented (`portraitUp` + Android/iOS config) |
| Top OLED toast | Implemented (replaces bottom SnackBar pattern) |
| Keyboard regression | Preserved (inset-aware scroll); automated test added |
| Machine-shell Stage 1 | Implemented (01–04 + `JfSignalCoil`) |
| New debug APK | Superseded for review by Pass 02A.2 APK |
| Node 22 | **Still pending** |
| Firebase CLI / FlutterFire CLI | **Still deferred** |
| GitHub remote | **Still pending** |
| Firebase / live Keryx | **Still deferred** |

---

## Pass 02A visual readiness (July 10, 2026)

| Item | Status |
|---|---|
| Pass 02A visual foundation + Scan Control | **COMPLETE** — physical review **PASS WITH APPROVED REFINEMENTS** |
| Branch | `pass-02a-visual-foundation` |
| Handoff | `docs/pass_handoffs/PASS_02A_COUNCIL_HANDOFF.md` |
| New debug APK | `build/app/outputs/flutter-apk/app-debug.apk` (~152.98 MB) — superseded for review by Pass 02A.1 APK |
| Package | `com.junkfeathers.localagora` `0.1.0+1` |
| Live Keryx in APK | No |
| Internet / Firebase required for 02A UI | No |
| Node 22 | **Still pending** (founder action; local Node remains 24) |
| Firebase CLI / FlutterFire CLI | **Still deferred** |
| GitHub remote | **Still pending** (none configured) |

Physical test: use the **Pass 02A.1** APK and the numbered script in the Pass 02A.1 council handoff.

---

## Environment

| Item | Value |
|---|---|
| Operating system | Windows 11 Home 64-bit (build 26200) |
| Active Node version | **v24.18.0** (system install at `C:\Program Files\nodejs\`) |
| Required Node version | **22** |
| npm version | 10.7.0 |
| Flutter version | 3.41.9 (stable) |
| Dart version | 3.11.5 |
| Firebase CLI version | **Not installed** (`firebase` not found) |
| FlutterFire CLI version | **Not installed** (`flutterfire` not found) |
| Git version | 2.54.0.windows.1 |
| Version managers (nvm / fnm / volta) | **None found** |

## Repository

| Item | Value |
|---|---|
| Branch | `pass-01-keryx-foundation` |
| Commit (at audit start) | `be4ee605a557bdefd479d6b28772ab0db4accdcb` |
| GitHub remote | **None configured** (`git remote -v` empty) |
| Working-tree status | Clean before 01C edits |
| Functions `engines.node` | `"22"` in `functions/package.json` |
| `firebase.json` | Absent (repository unbound to a Firebase project — correct for this stage) |
| `.nvmrc` / `.node-version` | Added with `22` |
| Secret-scan result | NO_MATCHES for committed secret values |
| `functions/.env` | Ignored by Git |
| Live Keryx verdict | `KERYX FEASIBLE WITH CHANGES` (Pass 01B) |

## Device

| Item | Value |
|---|---|
| Physical Android device detected now | **No** (`adb devices` empty; `flutter devices` shows Windows + Edge only) |
| ADB status | Daemon OK; no authorized device currently attached |
| Physical Test 01 result | **PASS** (founder-verified earlier on Jonathan’s phone) |

Physical Test 01 details (founder-verified):

- APK installed successfully
- App launched successfully
- `JUNKFEATHERS TECH` visible
- `THE LOCAL AGORA` visible
- `PASS 01 // KERYX FEASIBILITY` visible
- Force-close then reopen succeeded
- No crash reported

## Backend

| Check | Result |
|---|---|
| Functions lint | PASS (run under active Node 24; engines declare 22) |
| Functions build | PASS |
| Functions tests | PASS — 12 tests |
| `npm ci` under Node 22 | **NOT RUN** — Node 22 not active |
| Gemini key availability | Available to local tooling (value not exposed) |
| Live Keryx spike re-run | Not performed (correct — already passed) |

## Readiness verdict

### `READY WITH MANUAL NODE ACTION`

Repository declarations, Flutter checks, Functions checks on current Node, secret hygiene, and Physical Test 01 recording are in good shape. Local Node is still **24**, not **22**. No GitHub remote is configured yet. Firebase / FlutterFire CLIs are not installed (deferred to Pass 02 connection work, but noted).

## Required founder action

1. **Install and activate Node.js 22** without removing Node 24. Recommended Windows method:
   - Install **NVM for Windows**: https://github.com/coreybutler/nvm-windows/releases  
   - Then in a new terminal:
     ```powershell
     nvm install 22
     nvm use 22
     node --version
     ```
   - Expect `v22.x.x`. Restart Cursor (or at least open a new Cursor terminal) so PATH picks up Node 22.
   - From `functions/`:
     ```powershell
     npm ci
     npm run lint
     npm run build
     npm test
     ```
2. **Optional before Pass 02:** reconnect the Android phone via USB with USB debugging authorized (`adb devices` should list it).
3. **Optional before Pass 02:** add the GitHub remote for `the-local-agora` when ready to push (none exists yet).
4. **Pass 02 will cover:** Firebase CLI / FlutterFire install and project binding — do not invent project IDs now.

## Explicitly deferred

- Firebase project connection
- FlutterFire configuration
- Firebase deployment
- Firestore creation
- App Check
- Authentication
- Hosting
- Live phone scanning UI
- Flyer processing
- Billing
- Paid Keryx re-evaluation
- Pass 02 feature development
