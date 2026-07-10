# THE LOCAL AGORA — DO NOT UPLOAD SECRETS

**Status:** Mandatory public-repository security policy  
**Applies to:** Jonathan, Cursor, Antigravity, scripts, CI, screenshots, council handoffs, and every repository commit  
**Last revised:** July 10, 2026

## Permanent rule

The Local Agora contest repository is intended to be public. Never commit, upload, paste into documentation, or expose in screenshots any credential or private data that could grant access, create charges, identify a private contributor, or reveal a withheld venue location.

## Never commit or upload

- Gemini or Google AI API keys
- `.env`, `.env.local`, production environment files, or unredacted configuration exports
- Firebase Admin service-account JSON files or private keys
- Google Cloud credentials, access tokens, refresh tokens, OAuth client secrets, or session cookies
- Android keystores, key properties, signing passwords, certificate private keys, or Play Console credentials
- Apple signing certificates, provisioning profiles, or App Store Connect secrets
- GitHub personal access tokens or CI secrets
- Database exports containing contributor identifiers or private event information
- Raw production logs containing uploaded flyer contents, hidden addresses, tokens, request headers, or user identifiers
- Private house-show addresses or intentionally withheld venue locations
- Unredacted screenshots of consoles, billing pages, environment settings, or terminal output containing secrets

## Repository-safe configuration

Commit only sanitized templates such as:

- `.env.example` with placeholder values
- `firebase_options.dart` only when generated client configuration is appropriate and reviewed; it must never contain server secrets
- Public Firebase identifiers intended for client use
- Documented environment-variable names without values
- Emulator configuration
- Sanitized fixtures and fake test records
- Redacted example logs

Server secrets belong in Google Cloud Secret Manager, supported Firebase Functions secret configuration, protected CI secret storage, or another founder-approved secret store. Flutter clients must never contain server AI credentials or Firebase Admin credentials.

## Required ignore and scanning controls

Before the first public commit, ensure `.gitignore` covers at minimum:

```gitignore
.env
.env.*
!.env.example
*.jks
*.keystore
key.properties
android/key.properties
service-account*.json
*serviceAccount*.json
secrets/
.firebase/
functions/.secret.local
functions/.env*
```

Cursor must inspect staged changes before every public push. Before contest submission, run an available secret scanner or perform an equivalent repository-wide check and report the actual result in the council handoff.

## Private-location protection

A hidden event address is not a secret to store safely; it is data the system should not collect. For `VENUE ONLY`, `GENERAL AREA`, `CITY ONLY`, and `ASK ORGANIZER` records, do not search for, infer, cache, log, or persist an undisclosed street address. Sanitizing the UI while retaining the address in a backend field is prohibited.

## Flyer and test-data rules

- Use founder-approved public flyers or purpose-made fixtures for public repository tests.
- Do not commit a flyer containing a private address unless the address is intentionally public and approved for publication.
- Prefer small sanitized images for automated tests.
- Do not store raw AI responses containing unnecessary personal or private information.
- Production flyer retention must follow the approved product blueprint and Storage rules.

## When a secret may have leaked

1. Stop pushing or deploying.
2. Tell the founder immediately.
3. Identify the exposed credential and every location where it appeared.
4. Revoke or rotate it; deleting the file alone is not enough.
5. Remove it from current files and, when necessary, repository history.
6. Check logs and billing for misuse.
7. Record the incident and fix in the council handoff without repeating the secret.

## Coding-agent directive

Never weaken this policy to make setup faster. When required credentials are unavailable, create safe placeholders, emulator paths, or explicit setup instructions and report the work as BLOCKED where appropriate.
