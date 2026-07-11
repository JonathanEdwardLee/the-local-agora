# Local Agora Welcome Dialog

**Status:** Pass 02C implemented; Pass 02C.1 physical-test repairs applied  
**Date:** 2026-07-11  
**Related:** ADR-037, ADR-038, ADR-039, ADR-040

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
Welcome dialog over main app when SHOW WELCOME ON STARTUP is ON
```

There is **no** Local Agora product splash, **no** intermediate tagline screen, and **no** multi-screen onboarding carousel.

## Splash progression (Pass 02C.1)

Timing remains 990 + 1000 + 880 = **2870 ms**, but normal-motion visuals are:

1. Logo becomes visible / readable  
2. Glitch interference fades in and **continuously worsens**  
3. Splash ends at **strongest** interference  

There is **no** deliberate clean motionless hold in the middle of normal animation. Reduced-motion mode may use a simple accessible fade.

## Exact founder-approved Welcome copy

Do not silently rewrite.

### WELCOME

**Find your scene.**

Discover music, comedy, and theater events near you.

### HELP IT GROW

Every event you submit helps someone discover their next favorite venue, artist, or community.

### TOGETHER

The Local Agora belongs to everyone.

Contest V0.1 discovery categories are **music, comedy, and theater** only. Do not imply art or gatherings discovery in current-version UI copy.

## Controls

| Control | Behavior |
|---------|----------|
| `CLOSE` | Dismisses the dialog. Does **not** change the startup preference. |
| `DON'T SHOW AGAIN` | Sets `hasDismissedAgoraWelcomePermanently` = true (SHOW WELCOME ON STARTUP → OFF). |

## About surface (Pass 02C.1)

`ABOUT` sits in a secondary row beneath `SCAN THE AGORA`, beside `ADD EVENT`:

```text
SCAN THE AGORA
ADD EVENT    ABOUT
```

About is a **real product-information surface**, not a Welcome reopen shortcut.

Approved About statement:

> Made by a musician for people seeking a solid place to promote and discover local music, comedy, and theater performances.

About also includes:

- `THE LOCAL AGORA`
- `Find your scene. Grow your scene.`
- `SHOW WELCOME ON STARTUP` (ON/OFF) — same preference as DON'T SHOW AGAIN  
- `CLOSE`

## Persistence

- Mechanism: `shared_preferences`
- Key: `hasDismissedAgoraWelcomePermanently`
- Switch ON ⇒ stored value `false`
- Switch OFF ⇒ stored value `true`
- Local only — not Firebase

## Acceptance criteria (Pass 02C.1)

1. Splash interference envelope increases; no clean mid pause.  
2. Welcome body uses music / comedy / theater only.  
3. No ABOUT under identity panel 01.  
4. ADD EVENT + ABOUT under SCAN.  
5. ABOUT opens real About content with startup switch.  
6. Preference restoreable from About after DON'T SHOW AGAIN.  
7. Keryx untouched.  
8. Fresh debug APK for physical review (not yet physically approved).
