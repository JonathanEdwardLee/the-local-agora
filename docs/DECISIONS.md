# THE LOCAL AGORA — APPROVED DECISIONS

**Status:** Active architecture decision record  
**Owner:** Jonathan / Junkfeathers Tech Business Council  
**Last revised:** July 10, 2026 — Pass 02B.1A reconciliation: restored ADRs 022–026 after Drive overwrite; integrated shared-platform roadmap ADRs; added repository–Drive sync protocol  
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

## ADR-013 — Local Agora adopts the Junkfeathers Tech device design system

**Status:** Accepted  
**Decision:** The repository contains the current company standard at `docs/JUNKFEATHERS_DESIGN_SYSTEM.md`. Visible Local Agora UI uses the shared `fontFamily: 'monospace'`, black/white monochrome baseline, square ordinary controls, 3/2/1 px border hierarchy, compact 4/8/12/16/24/48 spacing rhythm, black/white active-state inversion, and accessible semantic tap targets. Amber is restrained to warning, uncertainty, missing-information, or review roles.  
**Consequence:** Cursor may not independently select another font, rounded card system, Material-demo appearance, shadow/elevation language, glassmorphism, or decorative color system. Product-specific exceptions require Jonathan’s explicit approval and documentation.

## ADR-014 — Visual foundation approval precedes broad feature UI

**Status:** Accepted  
**Decision:** The Pass 01 foundation screen is a temporary engineering shell, not the reference design. Before the full Scan Control and City Index are built, Cursor establishes centralized Junkfeathers tokens and reusable components, demonstrates the main control and state language, builds a fresh APK, and provides a numbered physical-phone visual test. Jonathan approves typography, square geometry, density, line weights, state inversion, readability, and touch targets before broad interface expansion.  
**Consequence:** Technical feasibility may be proven before visual work, but feature screens may not expand on generic temporary styling.

## ADR-015 — Keryx provider calls use bounded, observable failure handling

**Status:** Accepted  
**Decision:** Paid or rate-limited Keryx operations begin with a minimal smoke test, run sequentially when parallelism is unnecessary, and retry only transient 408, 429, and 5xx failures with bounded exponential backoff and jitter. Automated model cycling is prohibited. Approved compatibility fallbacks remain behind the Keryx provider interface and are reported.  
**Current verified implementation:** `@google/genai` 2.11.0 successfully completed the Interactions smoke test and Tests A/B/C on `gemini-3.5-flash`; the Functions deployment target is Node.js 22. Reverify versions against official support before future upgrades or deployment.

## ADR-016 — Pass 01 established Keryx feasibility

**Status:** Accepted  
**Decision:** Live Tests A, B, and C completed through the preferred Interactions path. The council verdict is `KERYX FEASIBLE WITH CHANGES`. The next product work addresses citation URL quality, missing start times, caching, cost controls, and the approved visual foundation before broad public scan UI.  
**Consequence:** The project proceeds from engine feasibility into the real app rather than restarting as a disposable contest prototype.



## ADR-017 — In-app machine branding uses product/model identity

**Status:** Accepted  
**Decision:** The shared Junkfeathers Tech name appears on the common startup splash. Inside the Local Agora machine, routine headers and chrome use the product name and approved model identity, such as `AGORA MK-I`.  
**Consequence:** Replace in-app company-brand headers with the approved product/model pattern unless Jonathan later approves a specific exception.

## ADR-018 — Local Agora is portrait-only

**Status:** Accepted  
**Decision:** Local Agora supports portrait orientation only unless Jonathan explicitly approves a future exception.  
**Consequence:** Android and future iOS configuration should lock portrait orientation, and UI passes should not optimize landscape behavior.

## ADR-019 — OLED toast placement is top-edge by default

**Status:** Accepted  
**Decision:** Transient OLED toast and short-lived status messages appear near the top of the machine by default.  
**Consequence:** Bottom toasts require a specific interaction justification.

## ADR-020 — Pass 02A keyboard behavior is the Local Agora input standard

**Status:** Accepted  
**Decision:** Preserve the Pass 02A keyboard-open behavior. Input surfaces remain inset-aware and scrollable so the active field and primary action remain reachable.  
**Consequence:** Do not regress to cramped dialogs or keyboard-obscured actions.

## ADR-021 — Local Agora machine shell follows a four-layer direction

**Status:** Accepted  
**Decision:** The Local Agora machine evolves around `01` status/spec strip, `02` main display, `03` animated art visual, and `04` controls.  
**Consequence:** Future visual passes should build a cyberpunk civic control-center identity and eventually add a characteristic animated signal-machine panel.

## ADR-022 — Integrated machine panels without external section headers

**Status:** Accepted  
**Decision:** Scan Control presents one assembled machine face. Numbered layers remain conceptual; external webpage-style headers such as `01 // STATUS` are not shown. Panel 01 holds product identity/specs and a retro local-date module; panel 02 is a CRT monitor only (square outer frame, rounded inner screen); panel 03 is a compact triple-ring signal window; panel 04 is one control chassis.  
**Consequence:** Do not reintroduce titled section stacks that break the single-device composition.

## ADR-023 — WHEN/WHAT use dial-like single-value selectors

**Status:** Accepted  
**Decision:** Time window and event category are chosen through dial-like selectors that show one snapped value at a time (swipe/drag, edge controls, keyboard arrows). Do not present all options as simultaneous button rows or generic dropdowns.  
**Consequence:** Monitor readouts update immediately from the typed selection state.

## ADR-024 — CRT inner screen may use rounded geometry

**Status:** Accepted  
**Decision:** The monitor’s inner CRT surface may use rounded corners as an approved machine metaphor. Outer frames, controls, fields, toasts, and dials remain square.  
**Consequence:** Do not generalize rounded Material cards elsewhere.

## ADR-025 — Pass 02B.1 Firebase link foundation uses status-only callable

**Status:** Accepted  
**Date:** 2026-07-10  
**Decision:** Bind Flutter (Android + web) to Firebase project `gen-lang-client-0718451481` with `firebase_core` and `cloud_functions` only. Prove transport via deployed Gen2 callable `keryxStatus` in `us-central1` (Node 22, `minInstances: 0`, `maxInstances: 1`). Live scan, Gemini secret, Auth, Firestore, Storage, App Check, and Analytics packages remain deferred. Debug-only `TEST KERYX LINK` may call status; main `SCAN THE AGORA` stays local readiness.  
**Consequence:** A successful status call proves callable transport only — not Keryx discovery feasibility, Gemini quality, or cost per scan.

## ADR-026 — Final machine geometry after Physical Test 02A.2

**Status:** Accepted  
**Date:** 2026-07-10  
**Decision:** Panel 01 is a compact identity plate (title upper-left, retro date upper-right, one bottom spec row). Panel 02 is the primary CRT surface (taller; honest `WAITING FOR SCAN...` prompt with slow blink / static under reduced motion). Panel 03 is shorter with three rings, side ticks, and a contained vertical-moving scan line. Panel 04 controls remain as approved in 02A.2.  
**Consequence:** Geometry refinements do not authorize live scanning.

## ADR-027 — Local Agora is one shared platform across Android, web, and future iOS

**Status:** Accepted  
**Date:** 2026-07-10  
**Decision:** Android, the public Flutter web machine, and a future native iPhone release use the same Flutter product codebase, protected backend contracts, and shared event index. The WordPress website provides marketing, support, privacy, and discovery pages rather than becoming a second event engine.  
**Consequence:** Do not fork event data or core product logic into a separate web-only database, WordPress directory, or independent iOS implementation.  
**Note:** Council Drive copy numbered this ADR-030; renumbered to ADR-027 to follow Git-history ADR-026 without renumbering older ADRs.

## ADR-028 — Keryx uses cache-first shared event records

**Status:** Accepted  
**Date:** 2026-07-10  
**Decision:** The backend checks stored current event records and freshness before invoking paid discovery or normalization. Event facts are stored once and filtered by location, time, and category rather than permanently caching every exact filter combination.  
**Consequence:** The server controls refresh eligibility, rate limits, and rescans. Mobile and web clients may not directly trigger unrestricted paid AI work.  
**Note:** Council Drive copy numbered this ADR-031; renumbered to ADR-028.

## ADR-029 — Event data follows an expiration lifecycle

**Status:** Accepted  
**Date:** 2026-07-10  
**Decision:** Event records progress through `UPCOMING`, `ACTIVE`, `RECENTLY_EXPIRED`, and `PURGED` or equivalent server states. Past events are hidden from ordinary active results. Recently expired full records are retained approximately 14–30 days under a configurable policy, then purged.  
**Consequence:** A minimal non-public fingerprint may remain only when justified for deduplication, source history, moderation, or abuse controls. Hidden private addresses, unnecessary personal data, and bulky obsolete files are not retained merely for history.  
**Note:** Council Drive copy numbered this ADR-032; renumbered to ADR-029.

## ADR-030 — Public web access launches before visible Pro accounts

**Status:** Accepted  
**Date:** 2026-07-10  
**Decision:** The useful free loop, shared cache, Android release, public Flutter web machine, support/privacy surfaces, and cost controls launch before visible Pro accounts and professional dashboards.  
**Consequence:** Pro work must not delay public usefulness. The web machine should launch alongside or shortly after Android and use the same backend and event index.  
**Note:** Council Drive copy numbered this ADR-033; renumbered to ADR-030.

## ADR-031 — Junkfeathers.com hosts the Local Agora landing and discovery path

**Status:** Accepted  
**Date:** 2026-07-10  
**Decision:** Junkfeathers.com receives a search-friendly Local Agora landing page. The preferred full-screen Flutter machine location is `agora.junkfeathers.com`, subject to final hosting and DNS verification; a maintainable subpath is acceptable if needed.  
**Consequence:** The landing page may promote Android, immediate web access, future iPhone availability, Orpheus Deck, and Junkfeathers music. Promotion does not interrupt chronological event results.  
**Note:** Council Drive copy numbered this ADR-034; renumbered to ADR-031.

## ADR-032 — Native iPhone demand is measured before Apple distribution spending

**Status:** Accepted  
**Date:** 2026-07-10  
**Decision:** The website may record a deduplicated anonymous iOS request count and an optional verified one-purpose email waitlist. A general Junkfeathers newsletter requires separate optional consent.  
**Release trigger:** Begin the native iPhone release when at least two conditions are true: 100 verified iPhone waitlist emails; at least 25% of web usage from iPhones for two consecutive months; at least $300 in available business cash; reliable Mac and physical-iPhone access.  
**Consequence:** The public web machine serves iPhone users while demand is measured. Do not use fake urgency or manipulated vote counters.  
**Note:** Council Drive copy numbered this ADR-035; renumbered to ADR-032.

## ADR-033 — Cross-promotion remains outside the event index

**Status:** Accepted  
**Date:** 2026-07-10  
**Decision:** Orpheus Deck, Junkfeathers music, Android download, iPhone request, and other workshop promotion belong on the landing page, About, Settings, footer, or a deliberately opened discovery surface.  
**Consequence:** Do not place company promotion between event records or alter organic chronological order.  
**Note:** Council Drive copy numbered this ADR-036; renumbered to ADR-033.

## ADR-034 — Repository is technical source of truth; Drive is council mirror

**Status:** Accepted  
**Date:** 2026-07-10  
**Decision:** During an active coding pass, the local Git repository is the technical source of truth. Google Drive is the council-readable mirror and planning archive. Drive copies must never blindly overwrite newer repository files. Council-approved Drive changes must be merged against the current repository version. After each substantial pass, Cursor identifies every governing Markdown file changed and records `DRIVE SYNC STATUS` in the council handoff. Cursor prepares sync files; Jonathan uploads the sync ZIP to the business-council chat; the council updates Drive and confirms completion.  
**Consequence:** No pass may silently assume Drive is current. Blind Drive→repo overwrites are prohibited.
