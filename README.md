# The Local Agora

Junkfeathers Tech · Flutter · Keryx Engine

**Find your scene. Grow your scene.**

This repository is the DEV Passion Challenge Version 0.1 codebase for The Local Agora — a text-first local event finder. Android is the first commercial target; iOS remains first-class from the same Flutter codebase; Flutter web supports demonstration.

Operational scan workflow (machine instruction, not the public tagline): **Choose a place. Choose a time. Scan the Agora.**

## Pass 03 / 03.1 status

Contest discovery on branch `pass-03-agora-discovery-vertical-slice`: Scan results appear inside the CRT monitor; Open Record is a dedicated route. Android (App Check ready) allows one live beta Keryx scan; Flutter web uses verified demo fixture fallback. See ADR-041 / ADR-042 and `lib/data/fixtures/FIXTURE_PROVENANCE.md`.

## Locked identity

| Item | Value |
|---|---|
| Product | The Local Agora |
| Public tagline | Find your scene. Grow your scene. |
| Flutter project | `the_local_agora` |
| Repository | `the-local-agora` |
| Android application ID | `com.junkfeathers.localagora` |
| Version | `0.1.0+1` |

Approved onboarding copy (ADR-037; Pass 02C Welcome dialog over main — see `docs/LOCAL_AGORA_WELCOME_DIALOG.md`):

- **WELCOME** — Find your scene. Discover music, comedy, and theater events near you.
- **HELP IT GROW** — Every event you submit helps someone discover their next favorite venue, artist, or community.
- **TOGETHER** — The Local Agora belongs to everyone.

Startup sequence (ADR-039): Junkfeathers Tech universal splash → existing main app → Welcome dialog over main when appropriate. No Local Agora product splash.

## Governing documents

1. `AI_CODING_INSTRUCTIONS.md`
2. `DO_NOT_UPLOAD_SECRETS.md`
3. `docs/MASTER_BLUEPRINT.md`
4. `docs/DEV_CONTEST_V0.1_BLUEPRINT.md`
6. `docs/LOCAL_AGORA_WELCOME_DIALOG.md`

## Local setup

### Flutter client

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

### Functions / Keryx spike

```bash
cd functions
cp .env.example .env
# Put a real GEMINI_API_KEY in functions/.env (never commit it)
npm install
npm run lint
npm run build
npm test
npm run keryx:spike
```

The spike writes sanitized evaluation artifacts under `functions/.eval-cache/` (gitignored).

## Security

Follow `DO_NOT_UPLOAD_SECRETS.md`. Never commit Gemini keys, service-account JSON, keystores, or private venue addresses.

## Permanent product rules

- No embedded map in any version
- Unknown event facts remain unknown
- Private / withheld addresses are never inferred or stored
- Keryx uses a two-pass pipeline (discovery, then normalization)
- Founder-approved brand copy must not be silently rewritten
