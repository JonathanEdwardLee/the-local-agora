# THE LOCAL AGORA


## AI CODING INSTRUCTIONS


Junkfeathers Tech  
Applies to: Cursor, Antigravity, and any coding AI working in this repository  
Project AI system: Keryx Engine  
Current priority: DEV Passion Challenge Version 0.1  
Permanent product rule: No embedded map in any version  
Last revised: July 10, 2026 — shared-platform, cache-first, web-launch, iOS-demand, and repository–Drive sync rules integrated


# 1\. PURPOSE


These instructions govern how an AI coding agent should plan, write, review, test, and document code for The Local Agora. All user-facing application code must be built in Flutter and Dart unless the founder explicitly changes this permanent standard.


The Local Agora must feel like a strange myth-magic-fueled civic machine displayed through a retro OLED interface. Beneath that surface, it must use current, secure, maintainable, high-performing, and adaptable Flutter and Dart engineering that supports Android first, iOS as a first-class future release, and web from the same codebase.


The AI agent is not only a code generator. It is also responsible for protecting the approved product mission, resisting unnecessary scope, preserving user trust, and leaving the codebase easier to extend in future versions.


# 2\. REQUIRED READING AND SOURCE-OF-TRUTH ORDER


Before planning or changing code, read these project documents in full:


1\. `docs/DEV_CONTEST_V0.1_BLUEPRINT.md` — current contest scope and delivery priorities  
2\. `docs/MASTER_BLUEPRINT.md` — permanent product rules and future roadmap  
3\. `docs/DECISIONS.md` — approved architecture and product decisions  
4\. `docs/JUNKFEATHERS_DESIGN_SYSTEM.md` — company typography, geometry, controls, spacing, motion, and visual approval rules  
5\. `docs/FOUNDER_TOOL_ACCESS.md` — Jonathan's current paid AI tools, cross-tool workflow, cost boundaries, and founder-only actions  
6\. `AI_CODING_INSTRUCTIONS.md` — engineering, testing, and handoff rules  
7\. `DO_NOT_UPLOAD_SECRETS.md` — repository security and secret-handling rules


Use this authority order when instructions appear to conflict:


1\. The founder’s newest direct instruction for the current task  
2\. The current DEV Passion Challenge V0.1 Build Blueprint  
3\. The Master Blueprint  
4\. Approved entries in `docs/DECISIONS.md`  
5\. `docs/JUNKFEATHERS_DESIGN_SYSTEM.md` for company visual identity  
6\. This AI Coding Instructions document  
7\. `DO_NOT_UPLOAD_SECRETS.md` for security and public-repository handling  
8\. `docs/FOUNDER_TOOL_ACCESS.md` for operational capability and tool routing only  
9\. Existing implementation details


Existing code does not overrule an approved blueprint. However, do not destroy working code merely to match a preference. Identify the conflict, choose the smallest safe correction, and preserve user data and working behavior.


At the beginning of every substantial work session:


• Read or re-read the relevant blueprint sections.  
• Inspect the existing repository before proposing architecture.  
• State the exact current pass and its acceptance criteria.  
• Separate what must be built now from what belongs to a future version.  
• Do not begin unrelated features.


After every major feature, architecture, or visible-interface change, check the implementation against all six governing Markdown files and the founder tool-access profile again.


# 2A. FOUNDER PAID-TOOL ROUTING


Jonathan currently pays for Google AI Pro, ChatGPT Plus, and Cursor Pro as Junkfeathers Tech business infrastructure.


For The Local Agora:


- ChatGPT council defines passes, contest strategy, business decisions, risk reviews, Drive documentation, and acceptance.
- Cursor Pro is the primary active repository executor for Flutter, TypeScript, tests, builds, Git, APKs, and handoffs.
- Google AI Studio supports Keryx feasibility and model/API experiments.
- Gemini, Deep Research, and NotebookLM may provide independent research or source-grounded review.
- Jules or Antigravity may be assigned only a bounded secondary task on an isolated branch or file set.
- Do not let Cursor and a secondary coding agent modify the same files simultaneously.
- Do not rerun paid Keryx calls merely to use another subscribed tool.
- Google AI Pro does not eliminate the need to track Gemini API and cloud-project billing separately.
- ChatGPT Plus does not include OpenAI API usage.
- Cursor usage-based overage, Bugbot billing, and Cloud Agent spending require explicit founder approval.
- Read `docs/FOUNDER_TOOL_ACCESS.md` for the complete current capability and cost-control profile.


The subscriptions should reduce Jonathan's workload and increase quality; they must not create duplicate work, branch conflicts, or uncontrolled spending.


# 2B. POST-PASS-02A VISUAL AND INTERACTION LOCKS


Jonathan approved the Pass 02A visual foundation on a physical Android phone with these permanent refinements:


- The shared splash may display **Junkfeathers Tech**, but the in-app machine should use a product/model identity such as `AGORA MK-I` rather than `JUNKFEATHERS TECH // ...`.
- Local Agora is **portrait-only** unless Jonathan explicitly changes the rule.
- The keyboard-open behavior from Pass 02A is the preferred Local Agora standard. Preserve the inset-aware, scrollable pattern that keeps the field and primary action reachable.
- Default OLED toast and transient status messages appear near the **top** of the machine.
- The visual direction is a **cyberpunk civic control center**, not a generic form page.
- Future interface passes should evolve the machine around:
  1. `01` — status/spec strip
  2. `02` — main display
  3. `03` — animated art visual
  4. `04` — controls
- The animated art visual is a permanent design intention. It should eventually provide the same kind of characteristic machine life that the reel animation provides in Orpheus Deck.


The foundational theme passed. Future passes may refine spacing, proportions, density, and art while preserving the approved Junkfeathers family identity.


# 3\. PRODUCT MISSION


The Local Agora performs one primary job:


Tell me what is happening here and when.


The current product is a text-first local event finder. A visitor chooses a city or ZIP/postal code, a time window, and optionally an event category. The Keryx Engine searches current public signals, preserves their origins, normalizes supported findings into event records, stores useful results for later visitors, and merges community events added through flyer uploads.


The public web starts the local index.  
The community strengthens it.  
The stored index helps the next visitor.


Do not turn the application into a generic social network, map application, AI assistant personality, promotional-copy generator, ticketing platform, or engagement feed.


# 4\. CURRENT VERSION 0.1 SCOPE


Build and protect this loop first:


1\. Accept city, city plus region, or ZIP/postal-code input.  
2\. Accept a time window such as Tonight, Tomorrow, This Weekend, or Next Seven Days.  
3\. Accept a small optional event-category filter.  
4\. Run a current public-signal search through Google AI grounding.  
5\. Preserve source links and supported evidence.  
6\. Normalize findings into a versioned typed event schema.  
7\. Remove or flag likely duplicates.  
8\. Store useful current records for reuse by later visitors.  
9\. Display sourced events as a chronological text index.  
10\. Let a visitor load a flyer for a missing event.  
11\. Extract flyer details with Gemini image understanding.  
12\. Require human review before saving the contributed record.  
13\. Support public and private-location modes.  
14\. Add the confirmed event to the same local index.  
15\. Hide past events from active results.


Do not build these during the contest unless the founder explicitly changes the scope:


• Visible accounts or profiles  
• Subscriptions or billing  
• Paid placement  
• Likes, comments, followers, or messaging  
• Push notifications  
• Artist or venue dashboards  
• Full moderation administration  
• Play Store production submission and final store packaging  
• Direct Facebook or Instagram integration  
• Automated social posting  
• Personalized recommendations  
• Permanent event history  
• Nationwide background crawling  
• Any embedded map or map view


Future-ready architecture is required. Future user-facing features are not. Do not replace Flutter with React, Next.js, Vue, a separate web-only frontend, native-only Android UI, or a separate iOS interface.


## LOCKED REPOSITORY IDENTITY


Use these values unless the founder explicitly changes them:


• Product name: The Local Agora  
• Flutter project name: `the_local_agora`  
• GitHub repository name: `the-local-agora`  
• Android application ID: `com.junkfeathers.localagora`  
• Initial app version: `0.1.0+1`


Firebase project IDs, Hosting site names, public URLs, and cloud resource names must be checked for availability. Do not invent permanent production identifiers without reporting the accepted values in the council handoff and `docs/DECISIONS.md`.


# 5\. PERMANENT PRODUCT RULES


## NO EMBEDDED MAP


The Local Agora will never contain a visual map, map markers, map-first browsing, or a decorative map background.


Future versions may geocode a public address, calculate distance, accept current-location permission, and display text such as “2.4 MI” or “SPRINGFIELD AREA.” Public addresses may link outward to an external directions service. The machine itself remains text-first and map-free.


## SOURCE HONESTY


Never present the feed as a complete list of every event. Use language such as “signals found” or “public signals found for this location.”


Every public-web record must preserve:


• Original source URL or citation  
• Source name when available  
• Last checked time  
• Known uncertainty  
• Any missing important facts


Unknown data remains unknown. Never invent a price, age restriction, time, venue, performer, address, cancellation, or ticket link.


## PRIVATE LOCATION PROTECTION


A private or intentionally withheld address must never be inferred, searched for, reverse-engineered, stored secretly, logged, or exposed.


Supported location modes are:


• EXACT PUBLIC  
• VENUE ONLY  
• GENERAL AREA  
• CITY ONLY  
• ASK ORGANIZER


Preserve useful source language such as “Ask a punk,” “DM for address,” “Private house venue,” or “Location announced day of show.” City is the minimum useful public location for a contributed private event.


## FREE DISCOVERY REMAINS USEFUL


Future monetization must never intentionally damage the ordinary free event-finding experience. Paid promotion must be clearly labeled and separated from organic chronological results. Do not silently implement pay-to-rank behavior.


## ACCOUNTS FOLLOW UTILITY


Do not force visible account creation into Version 0.1. The data model may contain nullable future ownership fields, but no unfinished account system should leak into the current user experience. Invisible Firebase Anonymous Authentication may be used for contribution identity and abuse controls without creating a profile experience.


## FUTURE SUBSCRIPTION STANDARD


Version 0.1 contains no billing. When paid Local Agora features are introduced, use the standing Junkfeathers Tech model: one simple auto-renewing monthly Pro subscription targeted at **$3.33/month in the United States**. Do not create a paid-upfront app, lifetime unlock, one-time Pro purchase, permanent feature purchase, annual plan, or consumable purchase unless the founder explicitly changes the company rule. Free event discovery must remain genuinely useful, and any paid Spotlight placement must be clearly labeled and separated from chronological organic results.


## SHARED JUNKFEATHERS SPLASH — PERMANENT BRAND COMPONENT


Every Junkfeathers Tech application uses the same approved Junkfeathers Tech splash identity:


• Exact approved Junkfeathers Tech logo and procedural geometry  
• Reveal/glitch-in phase: exactly 990 ms  
• Clean full-logo hold: exactly 1000 ms  
• Hide/glitch-out phase: exactly 880 ms  
• Total branded sequence: exactly 2870 ms


The splash implementation may be scheduled after the core Version 0.1 Keryx loop works, but it is not optional and must exist before public release and should appear in the final contest presentation when schedule permits. Do not change the timing constants without the founder explicitly changing the company standard. Do not redraw, reinterpret, replace, recolor, simplify, or “modernize” the logo. Do not substitute a generic Flutter splash. App-specific rotating tips may change for The Local Agora and should describe real features only. Keep startup lightweight and do not initialize expensive AI, Firebase, billing, or risky plugins solely to display the splash. Because the contest repository must be new, recreate the approved splash from this specification and approved brand artwork during the challenge rather than copying pre-challenge application source code.


# 6\. JUNKFEATHERS TECH DESIGN SYSTEM


`docs/JUNKFEATHERS_DESIGN_SYSTEM.md` is the company visual source of truth. The Local Agora may express a civic-receiver metaphor, but it must look like a machine built by the same workshop as Orpheus Deck. The current Pass 01 foundation screen is a temporary engineering shell and is **not** an approved visual reference for Pass 02 or later screens.


## CORE FEEL


Junkfeathers Tech builds myth-magic-fueled machines that appear recovered from another age while using modern technology underneath. Flutter and Dart are the permanent application foundation across Junkfeathers Tech software.


The Local Agora should feel like a civic signal receiver, not a conventional event website, generic Flutter sample, or collection of rounded Material cards.


## TYPOGRAPHY — LOCKED COMPANY BASELINE


• Use the centralized family token `fontFamily: 'monospace'` for visible product UI.  
• Do not introduce a different custom font, `google_fonts`, or ordinary proportional Material typography without Jonathan’s explicit approval.  
• Device titles, controls, machine states, numeric displays, supporting copy, dialogs, and temporary visible screens must use the shared type system.  
• ALL CAPS is appropriate for short operational labels; longer explanations should use readable sentence case.  
• Use deliberate letter spacing and tabular figures for times, counts, prices, and aligned readings where supported.


## GEOMETRY AND BORDER HIERARCHY


• Ordinary buttons, panels, fields, dialogs, records, and toasts use square geometry: `BorderRadius.zero` or no radius.  
• Rounded shapes are reserved for a genuine physical metaphor such as a reel, dial, knob, LED, or meter.  
• 3 px borders identify the major device shell or hero module.  
• 2 px borders identify primary controls, dialogs, and main content frames.  
• 1 px borders identify fields, compact controls, separators, and secondary structure.  
• No shadows, fake elevation, glassmorphism, glossy cards, floating pills, or decorative web-card chrome.


## COLOR AND CONTROL STATES


• Black is the default scaffold, panel, and control fill.  
• White or bone-white is the default operational text, outline, and active signal.  
• `white70`, `white54`, `white38`, `white24`, and `white12` provide secondary, inactive, locked, disabled, and structural hierarchy.  
• Restrained amber may communicate warnings, uncertainty, missing information, or review states; it must never become a general decorative accent.  
• Idle control: black fill, white outline, white label.  
• Active or pressed control: white fill, black label or icon, with immediate inversion and an approximately 50 ms response where animation is appropriate.  
• Locked or disabled controls remain understandable and explain why they are unavailable.  
• Essential state may not rely on color alone.


## SPACING, DENSITY, AND TOUCH


Use the shared compact rhythm: `4 / 8 / 12 / 16 / 24 / 48` px. Dense device screens generally begin near 8 px outer padding; landing screens near 24 px; major panels near 12 px internal padding. Visible hardware faces may be compact, but their semantic tap areas should be approximately 44×44 px wherever layout permits. Do not turn compact controls into generic pills merely to enlarge the hit target.


## REQUIRED REUSABLE DESIGN LAYER


Before broad Pass 02 interface work, establish and reuse a design layer such as:


```text
lib/design/
├── junkfeathers_theme.dart
├── junkfeathers_tokens.dart
├── jf_device_button.dart
├── jf_panel.dart
├── jf_oled_dialog.dart
├── jf_oled_toast.dart
├── jf_section_label.dart
└── jf_numeric_display.dart
```


Use centralized groups such as `JfColors`, `JfTypography`, `JfSpacing`, `JfBorders`, `JfMotion`, and `JfControlSizes`. Do not scatter raw visual constants through feature widgets.


## LOCAL AGORA SURFACE LANGUAGE


• Near-black OLED field  
• Bone-white text and line work  
• Restrained amber warnings and uncertainty  
• Minimal classical title treatment inside the shared monospace system  
• Thin hardware-panel dividers  
• Deliberate scan and indexing states  
• Text-first event records  
• Flyers hidden until deliberately opened  
• Responsive mobile-first layout  
• No conventional social-media cards  
• No map, pins, or visual geography


## VISUAL FOUNDATION APPROVAL GATE


Before the full Scan Control and City Index are wired, Cursor must demonstrate the shared style through a small component gallery or representative screen containing:


• Device title and numeric/status display  
• Full-width primary action  
• Compact and transport-scale controls  
• Input field  
• Square dialog and OLED-style toast  
• Idle, active, pressed, locked, disabled, loading, empty, error, and offline states  
• 3/2/1 px border hierarchy  
• Scalable text and semantic tap targets


Build a fresh APK and provide a numbered physical-phone visual test. Jonathan must approve typography, square geometry, density, state inversion, readability, and device metaphor before broad UI expansion.


## AVOID


• Purple or rainbow AI gradients  
• Glassmorphism  
• Generic sparkle icons  
• Rounded social-media cards or floating chips  
• Infinite-feed engagement design  
• Popularity counters  
• Excessive Greek ornament  
• Fake parchment  
• Cartoon mythology  
• Constant glitching or flashing effects  
• Dense analytics dashboards  
• Fake terminal clutter that harms comprehension  
• Emojis as primary interface icons


The interface may use mythic vocabulary, but every unusual term must include clear plain-language support.


Approved vocabulary includes:


Search → SCAN  
Event → SIGNAL  
Results → CITY INDEX  
Add event → ADD SIGNAL  
Upload flyer → LOAD FLYER  
Event details → OPEN RECORD  
Source → ORIGIN  
Refresh → RESCAN  
AI processing → KERYX INDEXING  
Unknown address → LOCATION WITHHELD  
Stored recent results → CACHED SIGNALS


Do not make the user decode the theme to complete a task.


# 7\. MODERN ENGINEERING PRINCIPLE


The machine may look retro. Its code must not be retro.


Use the current stable Flutter and Dart SDKs and current officially supported packages at implementation time. Before adding or upgrading a dependency:


1\. Check the package’s official documentation and release status.  
2\. Confirm compatibility with the current runtime and existing dependencies.  
3\. Prefer maintained packages with clear security and type support.  
4\. Avoid adding a dependency when a small, reliable native implementation is clearer.  
5\. Record meaningful architecture or dependency decisions.  
6\. Do not chase novelty when a stable current solution is better.  
7\. Do not retain obsolete packages merely because they appeared in an older plan.


“Innovative” means applying current capabilities to make the machine simpler, safer, faster, and more useful. It does not mean using experimental technology without a product reason.


# 8\. ARCHITECTURE RULES


Build clear service boundaries from the beginning.


Recommended logical modules:


• Location interpretation and normalization  
• Public event discovery  
• Grounded-result parsing  
• Event normalization  
• Flyer image extraction  
• Human-confirmed submission  
• Duplicate detection and merging  
• Source freshness  
• Event persistence  
• Cache policy  
• Reporting and moderation  
• Cost and rate controls  
• UI presentation models


Keryx-specific code must sit behind a Keryx service interface. Flutter widgets must never call privileged model providers, grounded-search tools, or production write operations directly. Use protected callable or HTTPS endpoints for secret-bearing and expensive operations.


Contest backend lock:  
The user-facing application is Flutter and Dart. Version 0.1 protected operations use **Firebase Cloud Functions 2nd generation with TypeScript**, exposed to Flutter primarily through HTTPS callable functions. Use Cloud Firestore for the shared event index, Cloud Storage for approved flyer objects, Firebase Hosting for the Flutter web demonstration, invisible Firebase Anonymous Authentication for contribution identity, and App Check before publicly exposing write or expensive AI endpoints. Cloud Run is a future escape hatch, not an unresolved Version 0.1 choice. Keep API contracts explicit so a future backend runtime change does not require rewriting Flutter screens.


Authentication and App Check staging:


• The first local Keryx feasibility spike does not require production Auth or App Check enforcement.  
• Public event reading does not require a visible login.  
• Saving a community contribution requires an invisible anonymous Firebase identity.  
• Before public deployment, protect write and paid-AI callable functions with App Check and server validation.  
• During local development, use supported debug providers or the Firebase Emulator Suite.  
• Enable enforcement only after valid Android and Flutter web clients have been tested.


Keep these concerns separate:


• Provider-specific server API code  
• Prompt construction  
• Grounded source evidence  
• Structured schema validation  
• Database persistence  
• Flutter presentation and widget formatting


Do not couple the Flutter widget tree directly to Firestore document shapes. Create typed Dart domain models, repositories, and explicit mapping functions.


Version the event schema from the first release.


Keep future fields optional and dormant. Do not build abstract systems for imaginary future needs. Add only the seams that are already justified by the Master Blueprint.


# 9\. TYPES, VALIDATION, AND CODE QUALITY


Use Dart sound null safety with strict analyzer and lint settings.


Requirements:


• Avoid \`dynamic\` except at unavoidable external boundaries; validate and convert untrusted values into typed Dart models immediately.  
• Define explicit return types for public service and repository methods.  
• Validate all model output, request input, URL input, file metadata, and database writes at runtime.  
• Keep one authoritative event schema and derive related types where practical.  
• Use Dart 3 sealed classes, enhanced enums, or equivalent exhaustive typed structures for location modes, source types, record statuses, and scan states.  
• Make nullable and optional values intentional.  
• Use consistent date and time handling with an explicit event time zone.  
• Store machine timestamps separately from local event date and time.  
• Never silently coerce an invalid date into a valid-looking record.  
• Prefer small pure functions for normalization, date checks, deduplication, and display formatting.  
• Remove dead code and abandoned experiments before final submission.  
• Use descriptive names rather than clever abbreviations.  
• Comment why a non-obvious decision exists, not what an obvious line does.


Do not duplicate business rules across components, server routes, and database logic. Centralize them in tested services or validation modules.


# 10\. KERYX ENGINE RULES


Keryx is an indexing engine, not an all-knowing oracle and not a chat personality.


## PUBLIC SIGNAL PIPELINE


Use a two-pass design whenever practical:


## PASS A — GROUNDED DISCOVERY


Use the Gemini Interactions API with Google Search grounding. The configured Version 0.1 default model is `gemini-3.5-flash`, but the model name must live in server configuration rather than Flutter widgets or repeated literals. Preserve source citations, source evidence, requested location, requested date window, and the raw supported findings needed for audit and normalization.


## PASS B — FACT-CONSTRAINED NORMALIZATION


Use a separate Gemini structured-output request with no Google Search tool enabled. Validate the returned JSON Schema with Zod on the TypeScript backend, then validate again before Firestore persistence. The normalizer may organize, classify, and merge only facts present in the grounded findings. It may not introduce a fact absent from the grounded result.


Do not depend on a preview one-call search-plus-structured-output combination for the contest. Never ask the normalization pass to “fill in” missing event information.


## FLYER PIPELINE


1\. Validate file type and size.  
2\. Preview the image locally when possible.  
3\. Ask Gemini whether the image appears to be an event notice.  
4\. Extract structured event fields.  
5\. Preserve unusual names and spellings.  
6\. Mark missing and unclear information.  
7\. Show all fields for human review.  
8\. Require the contributor to choose the public location mode.  
9\. Send only the confirmed record to persistence.


## PROMPT AND MODEL MANAGEMENT


• Keep model names in configuration.  
• Keep prompts in versioned files or modules.  
• Give prompts stable identifiers.  
• Record which prompt and model produced a stored AI-derived draft when useful for debugging.  
• Set conservative generation settings for factual normalization.  
• Do not expose private keys or raw provider responses to the browser.  
• Do not log full private flyer content unless necessary and approved.  
• Build model calls so a future supported model can replace the current one without rewriting the UI or database.


## AI FAILURE BEHAVIOR


When AI extraction or discovery fails:


• Return an understandable error state.  
• Preserve any safe partial result.  
• Do not publish an unverified partial record automatically.  
• Let the user retry without losing manually entered information.  
• Log a sanitized operational error for debugging.  
• Never fabricate a successful result.


# 11\. SEARCH, CACHE, AND COST CONTROL


Do not run a new paid or slow public scan every time the application opens.


Expected flow:


1\. Normalize location into a stable location key.  
2\. Check for sufficiently recent stored records.  
3\. Return fresh cached records immediately.  
4\. Trigger Keryx only when the requested index is absent or stale.  
5\. Store newly supported records.  
6\. Merge community records.  
7\. Hide past events from active results.  
8\. Retain expired records only as long as needed for correction, duplicate detection, or policy requirements.  
9\. Clean old records through controlled jobs or database TTL.


Keep cache windows in configuration. Rate-limit rescans and flyer submissions. Track enough usage to estimate cost per useful local index.


Do not expose an unlimited AI endpoint directly to the client.


# 12\. SECURITY AND PRIVACY


`DO_NOT_UPLOAD_SECRETS.md` is mandatory repository policy. When security language conflicts with convenience, protect the secret and report the blocker.


All secrets stay server-side.


Required protections:


• Commit a backend \`.env.example\` when applicable, never real credentials. Never embed privileged API secrets in the Flutter application.  
• Validate and authorize every write on the server.  
• Do not allow arbitrary client writes to production event collections.  
• Restrict upload file types and sizes.  
• Generate safe storage names rather than trusting user filenames.  
• Sanitize and validate external URLs.  
• Rate-limit expensive and write operations.  
• Use App Check or an equivalent protection when the infrastructure supports it.  
• Apply least-privilege database and storage rules.  
• Do not log secret values, authorization headers, hidden addresses, or unnecessary personal information.  
• Treat model output as untrusted input.  
• Design deletion and expiration behavior intentionally.  
• Never collect precise user location without explicit permission.


If a security shortcut is necessary for a local prototype, isolate it, document it, prevent it from reaching production, and create a clear removal task.


# 13\. ACCESSIBILITY


The OLED aesthetic must remain accessible.


Requirements:


• Flutter Semantics widgets and meaningful accessibility labels across mobile and web  
• Real visible form labels and semantic field descriptions  
• Keyboard-accessible controls  
• Visible focus indicators  
• High contrast  
• Scalable text  
• Screen-reader announcements for scan and error states  
• No essential information communicated only through color  
• Reduced-motion support  
• No continuous animation behind reading or editing areas  
• Accessible dialog behavior for the flyer viewer  
• Meaningful button names instead of icon-only mystery controls  
• Plain-text alternatives for flyer information


Retro is a visual language, not permission to reproduce old hardware limitations.


# 14\. ERROR, EMPTY, AND LOADING STATES


Every asynchronous feature must define:


• Initial state  
• Loading state  
• Successful state  
• Empty state  
• Partial state  
• Recoverable error state  
• Fatal configuration error state


Do not use fake percentages. Use honest machine states such as:


• INTERPRETING LOCATION  
• SEARCHING PUBLIC SIGNALS  
• CHECKING DATES  
• PRESERVING ORIGINS  
• REMOVING DUPLICATES  
• MERGING COMMUNITY RECORDS  
• INDEX READY


Empty results should remain useful:


NO CURRENT SIGNALS FOUND.  
TRY ANOTHER TIME WINDOW OR ADD A MISSING FLYER.


# 15\. TESTING AND EVALUATION


Do not treat a successful manual demonstration as sufficient proof.


At minimum, maintain tests or repeatable fixtures for:


• Valid city search  
• Valid ZIP/postal search  
• Empty result  
• Stale cache and fresh cache behavior  
• Duplicate event merge  
• Same event with unusual performer spelling  
• Missing start time  
• Doors time distinct from show time  
• Past event rejection  
• Event crossing midnight  
• Incorrect or ambiguous year  
• Cancelled event  
• Exact public address  
• Venue-only location  
• General-area location  
• City-only location  
• Ask-organizer location  
• Flyer that is not an event notice  
• Flyer with stylized hard-to-read text  
• AI output missing required structure  
• Malformed source URL  
• Upload too large or unsupported  
• Rate-limit response  
• Mobile keyboard and focus flow  
• Shared monospace typography is applied consistently  
• Square-corner geometry and 3/2/1 px border hierarchy  
• Idle, pressed, active, locked, disabled, loading, empty, error, and offline visual states  
• Approximately 44×44 semantic tap targets where practical  
• Component-gallery or representative-screen visual approval on a physical Android phone


For AI behavior, keep a small evaluation set of real or controlled event examples. Verify factual preservation, missing-field behavior, citation retention, and duplicate handling after prompt or model changes.


Before declaring a pass complete, run the applicable:


• \`dart format \--output=none \--set-exit-if-changed .\`  
• \`flutter analyze\`  
• Dart analyzer checks with no unresolved errors  
• \`flutter test\` unit and widget tests  
• Flutter \`integration\_test\` flows where applicable  
• \`flutter build web\` for the contest demo and relevant Android build checks  
• Security or dependency audit available to the project


Do not report a check as passed unless it actually ran and passed.


# 16\. DEVELOPMENT WORKFLOW


## BEFORE CHANGING CODE


1\. Read the relevant governing Markdown sections, including `docs/JUNKFEATHERS_DESIGN_SYSTEM.md`, current decisions, and security rules.  
2\. Inspect existing files, scripts, dependencies, design tokens, and repository status.  
3\. Identify the smallest complete vertical slice.  
4\. State what will not be changed.  
5\. Check current official documentation before using unfamiliar or fast-changing APIs.


## WHILE CHANGING CODE


• Make small, scoped changes.  
• Do not rewrite unrelated working code.  
• Preserve established naming and design tokens; visible temporary screens are not exempt from the company font, square geometry, palette, or control-state rules.  
• Keep commits or checkpoints logically separated.  
• Prefer a working vertical slice over many unfinished abstractions.  
• Surface a discovered blocker or serious risk immediately.  
• Do not hide warnings or failing tests.  
• Do not remove safeguards merely to make a demo pass.


## AFTER CHANGING CODE


Report:


• What changed  
• Why it changed  
• Files affected  
• Tests and commands actually run  
• Current limitations  
• New configuration required  
• Security or cost implications  
• The next smallest recommended pass


Update project documentation when behavior, schemas, setup, architecture, or deployment changes.


# COUNCIL HANDOFF REPORT — REQUIRED OUTPUT


At the end of every coding pass, produce one complete Markdown report that the founder can paste directly into the Junkfeathers Tech Business Council chat without rewriting it. Do not end with only “done,” a short summary, or a file list.


Use this structure:


```markdown
# COUNCIL HANDOFF — PASS [NUMBER]: [NAME]


## 1. Pass identity
- Objective:
- Status: COMPLETE / PARTIAL / BLOCKED
- Git branch:
- Latest commit hash:
- App version and build number:
- DRIVE SYNC STATUS: REQUIRED / NOT REQUIRED
- FILES REQUIRING DRIVE SYNC: (when required)
  - exact/path/file.md — created/updated — one-sentence reason


## 2. Acceptance criteria results
- [Criterion]: PASS / FAIL / NOT TESTED / BLOCKED — evidence


## 3. Implementation summary
- What the user can now do
- What changed internally
- Why this implementation was chosen
- How it follows the governing Markdown files
- What was deliberately left for later


## 4. Files changed
- Created:
- Modified:
- Moved:
- Deleted:


## 5. Architecture, data, dependency, and configuration changes
- Dart models and repositories
- Keryx interfaces, prompts, model configuration, and API contracts
- Firestore collections and document shapes
- Storage paths and retention behavior
- Security rules, Auth, and App Check
- Environment variables and Firebase configuration
- Android permissions, Gradle, and package changes
- Dependencies
- Cache, quota, and rate-limit behavior
- If none: NONE


## 6. Verification actually performed
- `flutter pub get`: PASS / FAIL / NOT RUN
- `dart format --output=none --set-exit-if-changed .`: PASS / FAIL / NOT RUN
- `flutter analyze`: PASS / FAIL / NOT RUN
- `flutter test`: PASS / FAIL / NOT RUN
- `flutter test integration_test`: PASS / FAIL / NOT RUN
- `flutter build apk --debug`: PASS / FAIL / NOT RUN
- `flutter build web`: PASS / FAIL / NOT RUN
- Backend tests, emulator checks, or deployment validation:
- Meaningful warnings or failures:


## 7. Android APK handoff
- APK BUILT: YES / NO / NOT REQUIRED
- Exact APK path:
- Build mode:
- Application ID:
- Version and build number:
- Minimum Android SDK when relevant:
- Signing state:
- File existence confirmed: YES / NO
- Firebase, network, API, or environment requirements:
- Installation instructions:


## 8. Real Android phone test script
1. Required setup
2. Exact action
3. Expected visible result
4. Error, empty, offline, invalid-input, or denied-permission test when relevant
5. Evidence to return when a step fails


Final founder checklist:
- [ ] PASS
- [ ] FAIL


## 9. Known limitations and risks
- Contest-safe limitations
- Blockers
- Technical debt
- Platform differences
- Security, privacy, cost, and abuse assumptions


## 10. Security, privacy, and cost review
- Secret handling:
- Public/private event data:
- Hidden venue-location protection:
- Upload exposure:
- Authentication and authorization:
- Paid Google AI calls:
- Firestore, Storage, Functions, and Hosting cost:
- Rate limits and abuse risk:
- If unchanged: NO MATERIAL CHANGE


## 11. Questions for the council
- Decisions requiring founder or council judgment


## 12. Documentation updates
- Markdown files changed or recommended for change
- New decision records added


## 13. Next recommended pass
- Objective:
- Why it should be next:
- Dependencies:
- Acceptance criteria:
- New APK and physical Android test required: YES / NO


## 14. Founder test response handling
After test feedback, classify it as:
- Confirmed pass
- Reproducible defect
- Unclear observation requiring instrumentation
- Severity and likely cause
- Smallest repair pass
```


Do not claim an APK exists until the build succeeds and the artifact is confirmed on disk. Automated checks never replace physical Android testing when the pass changes Android behavior. Do not begin unrelated features while a current-pass defect remains unresolved unless the founder explicitly reprioritizes.


# 17\. CONTEST-SPECIFIC GUARDRAILS


For the DEV Passion Challenge Version 0.1:


• Use a new Flutter repository created during the challenge window.  
• Do not copy application code from older projects.  
• Keep visible, understandable commit history.  
• Disclose Cursor, Antigravity, and other AI-assisted development honestly and only to the extent each tool actually contributed.  
• Google AI must perform meaningful work inside the functioning app.  
• Do not add ElevenLabs.  
• Do not let future accounts, monetization, or native packaging delay the working event loop.  
• Prioritize a functional public scan, source display, stored index, flyer extraction, human verification, and visible community contribution.  
• Build the Springfield, Missouri demonstration path first, then test at least one additional location when time permits.  
• Preserve original source links in the demo.  
• Do not use fabricated production events as if they were live public data.  
• Submit a stable, understandable Flutter build and public Flutter web demonstration rather than an unfinished feature collection.


# 18\. FUTURE-READY WITHOUT OVERBUILDING


Current code should anticipate the approved future direction through clean seams, not unfinished interfaces.


Reasonable future-ready choices include:


• Versioned event schema  
• Nullable ownership fields  
• Public-location coordinates as optional fields, never requiring a map widget  
• Service interfaces around Keryx and persistence  
• Role-ready authorization boundaries  
• Clear source and moderation fields  
• Configurable cache rules  
• Replaceable model configuration  
• Flutter-widget-independent Dart domain models


Do not build these until their version begins:


• Full account screens  
• Subscription checkout  
• Pro dashboards  
• Team permissions  
• Notification systems  
• Artist or venue profile experiences  
• Spotlight purchasing  
• Complex reputation algorithms  
• Calendar-import infrastructure


A good future seam is small and tested. A speculative platform is not.


# 18A. SHARED PLATFORM AND CACHE-FIRST RULES


The Local Agora is one shared product served through Android, public Flutter web, and future iOS clients.


Permanent engineering rules:


- Android, web, and future iOS use the same typed domain models, protected backend contracts, and shared event index.
- Do not fork product logic into a separate web-only application or separate event database.
- The WordPress marketing site is not the event engine. It links to or embeds the public Flutter web machine and provides search-friendly product, support, privacy, and demand-capture pages.
- Stored current event records are checked before any paid Keryx discovery call.
- The backend, not the client, decides whether a cache entry is fresh enough or a rescan is justified.
- Do not let a browser or mobile client directly trigger unrestricted paid AI work.
- Store reusable event facts and sources; do not create permanent cache silos for every exact filter combination.
- Android and web must receive the same source links, uncertainty, freshness, and privacy treatment.
- Ordinary results remain useful when Gemini or a source is temporarily unavailable.


## Event lifecycle


Use explicit lifecycle fields or equivalent server logic:


- `UPCOMING`
- `ACTIVE`
- `RECENTLY_EXPIRED`
- `PURGED`


Active result queries exclude past events. Recently expired records may remain temporarily for corrections, duplicate detection, source-quality review, and abuse investigation. Initial full-record retention is approximately 14–30 days and must remain configurable.


When a full record is purged, retain only the smallest justified non-public fingerprint. Never retain hidden private addresses, unnecessary personal data, or obsolete flyer files merely for history.


TTL or scheduled cleanup must be tested, monitored, and documented. Cleanup does not replace rate limits, App Check, server-side validation, cache freshness rules, or cost alerts.


## Public web release


The public Flutter web machine should launch alongside or shortly after Android and use the same backend and stored index. It is the immediate access path for iPhone, desktop, and tablet users.


Preferred public structure, subject to final DNS and hosting decisions:


- `junkfeathers.com/local-agora/` for the WordPress landing page
- `agora.junkfeathers.com` for the full-screen Flutter machine


Do not rebuild the event machine as a WordPress plugin or ordinary WordPress event directory unless Jonathan explicitly reverses the shared Flutter-client decision.


## Launch-before-Pro


Do not let visible accounts, subscriptions, or professional dashboards delay:


1. trustworthy free scanning
2. shared event caching
3. expiration and deduplication
4. Android public release
5. public web access
6. support, privacy, abuse, and cost controls


Build Pro only after usage or interviews prove a specific paid workflow.


## iPhone demand measurement


The website may record a deduplicated anonymous iOS request and an optional one-purpose email waitlist. Email collection must state its purpose, use separate consent from the general Junkfeathers newsletter, support removal, and avoid unrelated marketing.


Native iOS development begins when at least two approved thresholds are met:


- 100 verified iPhone waitlist emails
- 25% or more of Local Agora web usage from iPhones for two consecutive months
- at least $300 in available Junkfeathers Tech business cash
- reliable access to a Mac and physical iPhone


Do not create fake urgency, inflate demand counts, or expose user email addresses to public clients.


## Website promotion boundary


The Local Agora landing page, About, Settings, footer, or deliberate “More from Junkfeathers” surface may promote Android, Orpheus Deck, Junkfeathers music, and other products.


Never insert advertising or company promotion between chronological event records or in a way that corrupts the ordinary result order.


# 18B. REPOSITORY AND GOOGLE DRIVE SYNCHRONIZATION


## Authority


- During an active coding pass, the local Git repository is the technical source of truth.
- Google Drive is the council-readable mirror and planning archive.
- Drive copies must never blindly overwrite newer repository files.
- Council-approved Drive changes must be merged against the current repository version.
- After each substantial pass, Cursor must identify every governing Markdown file changed.


## Required handoff field


Every future council handoff must contain:


```text
DRIVE SYNC STATUS: REQUIRED / NOT REQUIRED
```


When required, include:


```text
FILES REQUIRING DRIVE SYNC:
- exact/path/file.md
```


Also include branch, commit, whether each file was created or updated, and a one-sentence reason for the change.


## Sync responsibility


- Cursor prepares the current files (typically a `build/drive_sync/` package that is not committed).
- Jonathan uploads the generated sync ZIP to the business-council chat.
- The council updates the Google Drive mirror.
- The council confirms completion.
- If the council cannot update Drive, Jonathan must receive an explicit manual-update notice.
- No pass should silently assume Drive is current.


# 19\. DEFINITION OF DONE


A feature is not complete merely because code was generated.


A pass is complete when:


• The requested behavior works end to end.  
• The implementation matches the current blueprint scope.  
• The permanent no-map and privacy rules remain intact.  
• Inputs and model outputs are validated.  
• Errors and empty states are usable.  
• The experience works at mobile width.  
• Accessibility requirements are respected.  
• Secrets remain server-side.  
• Applicable checks pass.  
• Documentation and environment setup are current.  
• No unrelated regressions are known.  
• Remaining limitations are stated honestly.  
• Visible UI uses the approved shared typography, square geometry, border hierarchy, spacing rhythm, and control-state language.  
• A fresh physical-phone visual test has passed whenever a pass creates or materially changes the interface.


# 20\. FINAL DIRECTIVE TO EVERY CODING AI


Protect the one useful machine before expanding the platform.


Build the search.  
Preserve the origins.  
Store the shared signal.  
Let the community add what is missing.  
Never expose a private venue.  
Never invent an event fact.  
Never add a map.


The Flutter interface carries the myth across Android, iOS, and web.  
The modern Dart architecture and protected cloud services carry the load.  
The community completes the signal.