# Local Agora Welcome Dialog

**Status:** Founder-approved Pass 02C implementation  
**Date:** 2026-07-11  
**Related:** ADR-037, ADR-039, `docs/Junkfeathers Universal Splash/` (canonical splash reference)

## Purpose

First-run Welcome information appears **over the real Local Agora main app** after the Junkfeathers Tech universal splash completes. It is not a route, not a splash, not a carousel, and not a separate onboarding screen.

## Startup sequence (approved)

```text
APP LAUNCH
    ↓
JUNKFEATHERS TECH UNIVERSAL SPLASH (2870 ms)
    ↓
EXISTING LOCAL AGORA MAIN APP (Scan Control)
    ↓
Welcome dialog over main app when automatic display is appropriate
```

There is **no** Local Agora product splash, **no** intermediate tagline screen, and **no** multi-screen onboarding carousel.

## Exact founder-approved copy

Do not silently rewrite.

### WELCOME

**Find your scene.**

Discover music, comedy, art, and creative events near you.

### HELP IT GROW

Every event you submit helps someone discover their next favorite venue, artist, or community.

### TOGETHER

The Local Agora belongs to everyone.

## Controls

| Control | Behavior |
|---------|----------|
| `CLOSE` | Dismisses the dialog. Does **not** set permanent suppression. Automatic display may occur again on a future cold launch. |
| `DON'T SHOW AGAIN` | Stores local Boolean `hasDismissedAgoraWelcomePermanently`, dismisses, and prevents future **automatic** display. |

## Persistence

- Mechanism: `shared_preferences` (local device only)
- Key: `hasDismissedAgoraWelcomePermanently`
- **Not** stored in Firestore, Auth, Cloud Storage, or Remote Config
- No account, network, App Check, Gemini, or location required

## Manual reopen

Production-facing compact `ABOUT` control on Scan Control (identity/status area), subordinate to `SCAN THE AGORA`. Manual reopen **ignores** the suppression Boolean and shows the dialog on demand.

## Visual requirements

- Monospace typography
- Black primary surface; white / bone-white text
- Square geometry; no rounded Material card appearance
- No shadows; no glassmorphism
- 2 px primary dialog border
- Compact spacing; scrollable under text scaling
- Design-system control inversion (`JfDeviceButton`)

## Lifecycle / accessibility acceptance

- Automatic Welcome schedules after the main shell’s first completed frame
- Does not reopen repeatedly from ordinary rebuilds
- Does not appear twice while already open
- Splash completion happens once; parent rebuilds do not restart splash
- Text scaling must leave CLOSE / DON'T SHOW AGAIN reachable
- Dialog remains dismissible (barrier + CLOSE)

## Implementation map

| Piece | Location |
|-------|----------|
| Universal splash (runtime) | `lib/brand/junkfeathers_splash/` |
| Canonical reference package | `docs/Junkfeathers Universal Splash/` |
| Local Agora tips | `lib/brand/local_agora_splash_tips.dart` |
| Startup gate | `lib/features/startup/startup_gate.dart` |
| Welcome dialog / copy / store | `lib/features/welcome/` |
| Reopen control | `ScanControlScreen` `ABOUT` |

## Acceptance criteria (Pass 02C)

1. Canonical Junkfeathers Tech splash runs first (990 + 1000 + 880 = 2870 ms).
2. One Local Agora tip per launch; tips do not extend splash timing.
3. Direct transition to existing main interface.
4. Welcome appears over main when suppression is false.
5. CLOSE and DON'T SHOW AGAIN behave as specified.
6. Manual `ABOUT` reopen works after permanent suppression.
7. Automated tests cover splash + Welcome behaviors.
8. Fresh debug APK available for physical Android review.
9. Proven Keryx / Gemini pipeline undisturbed.
