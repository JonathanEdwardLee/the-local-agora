# THE LOCAL AGORA — APPROVED DECISIONS

**Status:** Active architecture decision record  
**Owner:** Jonathan / Junkfeathers Tech Business Council  
**Last revised:** July 10, 2026  
**Rule:** Cursor may document approved decisions here. It may not silently create or reverse a major decision.

## How to use this file

Each decision receives a stable ADR number. Record the decision, reason, consequences, and status. Newer approved decisions may supersede older entries, but old entries remain for history. The current build blueprint and founder’s newest direct instruction remain higher authority.

---

## ADR-001 — Flutter and Dart are the permanent client stack

**Status:** Accepted  
**Decision:** All user-facing Local Agora code is built in Flutter and Dart. Android is the first physical and commercial target, iOS remains first-class from the same codebase, and Flutter web provides the contest demonstration.  
**Consequence:** Do not introduce React, Next.js, Vue, a web-only frontend, native-only Android UI, or a separate iOS implementation.

## ADR-002 — The application never contains an embedded map

**Status:** Accepted  
**Decision:** Local Agora remains a text-first event machine. Future releases may calculate distance and link outward for directions, but no map, marker view, decorative map, or map-first browsing appears in the app.

## ADR-003 — Keryx uses a two-pass factual pipeline

**Status:** Accepted  
**Decision:** Pass A performs grounded discovery with citations. Pass B performs separate fact-constrained structured normalization and may not add unsupported facts.  
**Consequence:** Do not use a single prompt that both searches and freely fills an event record.

## ADR-004 — Version 0.1 backend uses Firebase Cloud Functions 2nd generation with TypeScript

**Status:** Accepted  
**Decision:** Protected AI calls, validation, and privileged writes use Firebase Cloud Functions 2nd generation with TypeScript. HTTPS callable functions are the primary Flutter-to-Keryx interface.  
**Consequence:** Cloud Run is reserved as a future escape hatch rather than an unresolved contest choice.

## ADR-005 — Firebase is the Version 0.1 shared infrastructure

**Status:** Accepted  
**Decision:** Cloud Firestore stores the shared event index and cache. Cloud Storage stores approved flyer objects. Firebase Hosting serves the Flutter web demonstration. Anonymous Authentication provides invisible contribution identity. App Check protects public write and expensive AI endpoints after valid clients are tested.

## ADR-006 — Keryx API strategy is locked for the feasibility spike

**Status:** Accepted  
**Decision:** Pass A uses the Gemini Interactions API with Google Search grounding. The configured Version 0.1 default model is `gemini-3.5-flash`. Pass B uses a separate Gemini structured-output request validated with Zod on the TypeScript backend.  
**Consequence:** Model names remain configurable. The contest does not depend on a preview one-call search-plus-structured-output combination.

## ADR-007 — Source honesty and private-location protection are mandatory

**Status:** Accepted  
**Decision:** Public-web records preserve origins, last-checked time, uncertainty, and missing facts. Hidden private addresses are never inferred, searched for, secretly stored, logged, or exposed.

## ADR-008 — Repository and application identity

**Status:** Accepted  
**Decision:**  
- Product: The Local Agora  
- Flutter project: `the_local_agora`  
- Repository: `the-local-agora`  
- Android application ID: `com.junkfeathers.localagora`  
- Initial version: `0.1.0+1`

Firebase project IDs, Hosting site names, and URLs are recorded here after the services accept available names.

## ADR-009 — Junkfeathers splash is a shared permanent brand component

**Status:** Accepted  
**Decision:** Every Junkfeathers Tech app uses the exact approved Junkfeathers Tech logo and procedural geometry with fixed timing: 990 ms glitch-in/reveal, 1000 ms clean hold, and 880 ms glitch-out/hide, totaling 2870 ms. Local Agora may use its own rotating tips, but the logo, geometry, and timing are not redesigned or altered without an explicit founder policy change.  
**Scheduling:** Implement after the core Keryx loop when necessary, but before public release and in the final contest presentation when schedule permits. For this contest, recreate the approved behavior from the specification and approved brand artwork rather than copying pre-challenge application source code.

## ADR-010 — Future monetization is subscription-only

**Status:** Accepted; not part of Version 0.1  
**Decision:** Future paid Local Agora access uses one auto-renewing monthly Pro subscription targeted at **$3.33/month in the United States**. No paid-upfront app, lifetime unlock, one-time Pro purchase, permanent feature purchase, annual plan, or consumable purchase unless Jonathan explicitly changes the company rule.  
**Trust boundary:** Free event discovery remains useful. Paid Spotlight placement is labeled and separated from chronological organic results.

## ADR-011 — Cursor is the initial coding agent

**Status:** Accepted  
**Decision:** Initial implementation is Cursor-assisted. Antigravity and other AI tools may be used when they provide real project contributions and must be credited honestly.

## ADR-012 — First coding pass is a feasibility spike

**Status:** Accepted  
**Decision:** Pass 01 creates the repository foundation and proves Keryx on a real Springfield, Missouri query before the full interface is built. It must inspect citation quality, dates, duplicates, missing fields, geographic relevance, and unsupported-fact behavior.
