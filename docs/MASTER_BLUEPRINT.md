# THE LOCAL AGORA

## Master Product Blueprint, Architecture, and Version Roadmap

Junkfeathers Tech  
Document status: Active master blueprint  
Current build target: DEV Passion Challenge Version 0.1  
AI system: Keryx Engine  
Product principle: Retro OLED myth-machine outside; current adaptable technology inside  
Permanent interface rule: No embedded map in any version  
Last revised: July 10, 2026 — Pass 02A phone-test machine refinements

# 1\. ZEUS DECISION

The Local Agora will be built as a simple, text-first local event finder that improves as each community uses it.

The first product promise is deliberately narrow:

Tell me what is happening here and when.

The machine will search current public sources for creative events, convert supported findings into consistent records, store useful results for later local visitors, and accept community-contributed flyers for events the public web missed.

The product must remain useful without accounts, subscriptions, social activity, or a map. Future versions may add accounts, stewardship tools, and paid professional features only after the free event-finding loop proves valuable.

# 2\. VISION AND MISSION

VISION

Create a global network of local event indexes that feel like small mythological civic receivers: strange, focused machines that help people find music, art, comedy, theatre, poetry, markets, workshops, and other creative gatherings near them.

MISSION

Make it effortless to answer one question:

What is happening near me tonight?

COMMUNITY FLYWHEEL

The public web starts each local index.  
The local community improves it.  
The stored index helps the next visitor.

Every successful scan, correction, source confirmation, and flyer contribution should make the machine more useful for the people who live there.

# 3\. PRODUCT THESIS

Local event information is fragmented rather than absent.

Useful events are scattered across:  
• Venue calendars  
• Organizer websites  
• Ticket platforms  
• Local newspapers  
• Public social pages  
• University and library calendars  
• Tourism and city calendars  
• Arts organizations  
• Handmade flyers  
• Word of mouth

The Local Agora does not need to own every source. It needs to gather public signals into one honest, chronological, reusable local index while preserving where each record came from.

The community contribution channel solves the events that search engines miss: house shows, underground art, temporary spaces, last-minute performances, and events whose only durable public artifact is a flyer.

# 4\. PERMANENT PRODUCT RULES

ONE CORE JOB

The Local Agora finds local creative events by place and time.

NO EMBEDDED MAP — IN ANY VERSION

The application will never contain a visual map, marker map, or map-first browsing screen.

Reasons:  
• The product identity is a text-first machine.  
• Maps introduce visual noise without answering the core question better.  
• Many DIY events intentionally hide exact locations.  
• City, ZIP/postal code, time, and optional radius are enough for discovery.  
• Public exact addresses may link outward to directions, but no map appears inside the machine.

SOURCE HONESTY

The machine says “signals found,” not “all events.”

Every public-web event keeps its source link and last-checked time. Unknown information remains unknown. Community records identify their community origin.

NO ORGANIC PAY-TO-RANK

Future paid placement must never silently alter the normal chronological event order. Any paid Spotlight or promoted event must be clearly labeled and visually separated from organic results.

FREE DISCOVERY REMAINS USEFUL

The core ability to search local events, open records, view sources, and contribute basic event information should remain useful without a subscription.

ACCOUNTS FOLLOW UTILITY

Version 0.1 proves discovery and contribution before asking anyone to create an account. Accounts arrive only when they unlock clear stewardship, trust, personalization, or professional value.

# 5\. BRAND AND MACHINE IDENTITY

Junkfeathers Tech builds myth-magic-fueled machines that appear through retro OLED interfaces while using current, highly capable technology underneath. Flutter and Dart are the permanent user-facing application foundation for Junkfeathers Tech software so Android, iOS, and web can evolve from one consistent codebase and design system.

VISUAL SOURCE OF TRUTH

The repository must contain the current company standard at `docs/JUNKFEATHERS_DESIGN_SYSTEM.md`. The Local Agora adopts that system unless Jonathan approves a documented exception. The Pass 01 foundation screen is a temporary engineering shell and must not become the visual reference for the real Scan Control or City Index.

THE SURFACE

• Near-black OLED field with black device panels  
• White or bone-white operational text and line work  
• Canonical Flutter family token: `fontFamily: 'monospace'`  
• No app-specific font substitution or `google_fonts` dependency without founder approval  
• Square ordinary controls, fields, dialogs, records, and toasts using `BorderRadius.zero` or no radius  
• 3 px major shell, 2 px primary control/dialog, and 1 px field/separator border hierarchy  
• Black/white state inversion for active or pressed controls  
• Restrained amber only for warnings, uncertainty, missing information, and review states  
• Compact spacing rhythm: 4 / 8 / 12 / 16 / 24 / 48 px  
• Approximately 44×44 semantic tap targets where practical, even when visible hardware faces are smaller  
• Minimal classical title treatment inside the shared monospace system  
• Thin hardware-panel dividers  
• Deliberate scan and indexing states  
• No rounded social cards, shadows, elevation, glassmorphism, glossy surfaces, or floating pills  
• No map, pins, or geographical graphics  
• Flyers hidden until deliberately opened

THE INTERNAL MACHINE

• Current stable Flutter SDK, Dart SDK, FlutterFire packages, and carefully selected maintained Dart packages  
• Current FlutterFire packages in the app and official Google AI server SDKs behind protected endpoints  
• Typed schemas and validation  
• Server-side secrets and protected tools  
• Modular service boundaries  
• Versioned data models  
• Cloud caching and controlled persistence  
• Accessible responsive interfaces  
• Replaceable model configurations  
• Architecture capable of later accounts, billing, moderation, new data sources, and Apple-platform release without rebuilding the interface in another framework

DESIGN PRINCIPLE

The machine may look recovered from another age. Its internal engineering should never be artificially primitive. Do not replace the Flutter client with React, Next.js, Vue, native-only Android UI, or a separate iOS interface.

SHARED JUNKFEATHERS SPLASH — PERMANENT BRAND COMPONENT

The Local Agora uses the same approved Junkfeathers Tech splash identity as every Junkfeathers Tech application:

• Exact approved Junkfeathers Tech logo and procedural geometry  
• Reveal/glitch-in phase: exactly 990 ms  
• Clean full-logo hold: exactly 1000 ms  
• Hide/glitch-out phase: exactly 880 ms  
• Total branded sequence: exactly 2870 ms

This is a reusable company identity, not an app-specific redesign opportunity. Do not change the timing constants without an explicit founder policy change. Do not redraw, recolor, simplify, replace, or modernize the logo. The rotating tips are app-specific and may teach Local Agora features, but the logo, procedural geometry, and 2870 ms core sequence remain identical. The implementation may follow the working Keryx loop during contest development, but it is required before public release and should appear in the final contest presentation when schedule permits. Startup must remain lightweight. For this challenge, recreate the approved behavior from the documented specification and approved brand artwork rather than copying pre-challenge application source code.

LOCKED PROJECT IDENTITY

• Product name: The Local Agora  
• Flutter project name: `the_local_agora`  
• Repository name: `the-local-agora`  
• Android application ID: `com.junkfeathers.localagora`  
• Initial version: `0.1.0+1`

Firebase project IDs, Hosting site names, and public URLs depend on availability and must be recorded in `docs/DECISIONS.md` after creation.

APP VOCABULARY

Search → SCAN  
Event → SIGNAL  
Search results → CITY INDEX  
Add event → ADD SIGNAL  
Upload flyer → LOAD FLYER  
Event details → OPEN RECORD  
Source → ORIGIN  
Refresh → RESCAN  
Unknown address → LOCATION WITHHELD  
AI processing → KERYX INDEXING  
Stored recent search → CACHED SIGNALS

Every unusual term must have plain supporting copy. Brand language should create atmosphere without creating confusion.

DESIGN FOUNDATION GATE

Before broad feature UI is approved, the Flutter client must establish centralized Junkfeathers tokens and reusable components for typography, palette, spacing, border widths, motion, control sizes, device buttons, panels, dialogs, toasts, labels, and numeric/status displays. Cursor must demonstrate idle, active, pressed, locked, disabled, loading, empty, error, and offline states in a component gallery or representative screen, build a fresh APK, and provide a numbered phone test. Jonathan approves the font, square geometry, density, state inversion, readability, and device metaphor before the real Scan Control and City Index expand.

The correct sequence is: prove uncertain engine capability, establish the shared machine surface, then wire broad feature UI. Design polish such as texture and decorative motion may wait; company typography, geometry, line weights, and control behavior may not.

## CURRENT MACHINE-FACE DIRECTION

The Local Agora should evolve toward a **cyberpunk civic control center**.

Approved physical-phone review rules:

- The shared opening splash carries the Junkfeathers Tech company identity.
- Inside the machine, use the product and model identity, such as `AGORA MK-I`, rather than repeating `JUNKFEATHERS TECH` in routine headers.
- The mobile app is **portrait-only**.
- Default OLED toast and transient machine notices appear near the **top**.
- Preserve the Pass 02A keyboard behavior: inset-aware, scrollable interaction that keeps the active field and primary action reachable.
- Organize the machine conceptually into:
  - `01` — status/spec strip: model, version, FREE/PRO state, current date, and compact technical indicators
  - `02` — main display: Keryx state, results, records, uncertainty, and useful information
  - `03` — animated art visual: a rectangular signal-machine animation or pixel-art receiver visual
  - `04` — controls: tactile buttons, selectors, sliders or step controls, and visible selection state

The art panel does not need to control the engine in its earliest implementation, but it should eventually become a characteristic Local Agora machine visual.

# 6\. VERSION ROADMAP

## VERSION 0.1 — DEV CONTEST FIELD TEST

Purpose:  
Prove that Keryx can create a useful local event index from current public signals and community flyers.

Core capabilities:  
• City or ZIP/postal-code search  
• Time-window selection  
• Basic event-category filtering  
• Grounded current public search  
• Sourced chronological text records  
• Cached shared local index  
• Event details and origin links  
• Flyer upload and image extraction  
• Human confirmation  
• Private-location modes  
• Duplicate and past-event handling  
• Optional retro flyer viewer

No visible accounts, subscriptions, maps, social features, or notifications.

## VERSION 0.2 — RELIABILITY RELEASE

Purpose:  
Turn the contest prototype into a trustworthy small public beta.

Possible work:  
• Stronger source validation  
• Better duplicate merging  
• Cancellation and schedule-change handling  
• Submission limits and abuse controls  
• Anonymous authentication  
• FlutterFire App Check  
• Report incorrect information  
• Lightweight administrator review tools  
• Better ZIP/postal normalization  
• Configurable cache and rescan policies  
• Performance and cost monitoring  
• Accessibility audit  
• Privacy policy, terms, and community rules

## VERSION 1.0 — PUBLIC CORE RELEASE

Purpose:  
Release the useful free event-finding machine without requiring a social network.

Possible capabilities:  
• Reliable city and ZIP/postal search  
• Optional device or browser “use my location” with explicit permission  
• Remembered recent locations on device  
• 5-, 10-, 25-, and 50-mile search ranges  
• Text-only distance labels where reliable  
• Better category and date controls  
• Saved local indexes  
• Community flyer contribution  
• Reporting and correction flow  
• Public source freshness indicators  
• External direction links for public addresses  
• No map

## VERSION 1.X — NEAR-ME WITHOUT MAPS

Purpose:  
Improve local relevance without changing the text-first identity.

Possible technical additions:  
• Geocode user-entered ZIP/postal codes and public event addresses  
• Store latitude and longitude only for public locations  
• Calculate straight-line or service-area distance on the server  
• Include city-only and private-location events through sensible inclusion rules  
• Offer radius filters without displaying coordinates or maps  
• Clearly distinguish exact, approximate, city-only, and private location matches

## VERSION 2.0 — ACCOUNTS AND STEWARDSHIP

Purpose:  
Give trusted participants control over their own work and communities.

Possible accounts:  
• Fan  
• Artist or performer  
• Venue or organizer  
• Community steward or moderator

Possible free account value:  
• Manage submitted events  
• Correct or cancel an event  
• Save locations and filters  
• Follow cities, categories, artists, or venues  
• Submission history  
• Claim a public artist or venue identity  
• Reputation based on accurate contributions  
• Notification preferences

## VERSION 2.X — PRO AND SUPPORTER FEATURES

Purpose:  
Fund the service without damaging trust or blocking basic discovery.

Potential paid value for artists, venues, and organizers:  
• Verified profile controls  
• Recurring-event tools  
• Bulk event submission  
• Calendar or feed import  
• Scheduled flyer processing  
• Team access  
• Event performance summaries  
• Correction priority  
• Enhanced event-detail modules  
• Clearly labeled Spotlight placement  
• Longer event management windows  
• Professional export and workflow tools

Potential supporter value for fans:  
• Cosmetic machine skins  
• More saved cities and filters  
• Early experimental features  
• Supporter badge, only when desired  
• Voluntary contribution to local infrastructure

Paid features must save time, improve stewardship, or add customization. They must not make ordinary free event discovery intentionally worse.

## FUTURE VERSIONS

Possible later systems:  
• Push notifications  
• Artist, venue, and city following  
• Festival mode  
• Event-history archive  
• Setlists, photos, and post-event records  
• Ticket links and approved commerce integrations  
• Community moderation councils  
• Trusted public calendar ingestion  
• Continued Android and iOS releases from the shared Flutter codebase  
• Web and platform expansion  
• New Keryx source adapters

Future work remains conditional on proven use, manageable moderation, and sustainable operating cost.

# 7\. VERSION 0.1 — APPROVED PRODUCT DEFINITION

The contest version performs one complete loop:

1\. A visitor enters a city or ZIP/postal code.  
2\. The visitor chooses a time window and optional event category.  
3\. Keryx searches current public web sources.  
4\. Keryx preserves citations and supported facts.  
5\. A separate normalization step creates consistent event records.  
6\. The system removes obvious duplicates.  
7\. Current records are stored and displayed chronologically.  
8\. Later visitors receive recent stored results faster.  
9\. A visitor can load a flyer for a missing event.  
10\. Keryx reads the flyer and prepares a draft record.  
11\. The contributor reviews every field and selects the public location level.  
12\. The confirmed event joins the same local index.

Core statement:

Choose a place. Choose a time. Scan the Agora.

Community invitation:

Find the signals. Add what the scene is missing.

# 8\. KERYX ENGINE

Keryx is the event-indexing system inside The Local Agora.

Keryx is not an all-knowing oracle and should never be presented as one.

## PUBLIC DISCOVERY RESPONSIBILITIES

• Interpret the requested location and time window  
• Search current public web sources through Google Search grounding  
• Return only findings supported by a public origin  
• Preserve source links and evidence  
• Exclude clearly past events  
• Avoid inventing missing details  
• Identify uncertainty  
• Pass grounded findings into normalization

## TWO-PASS DESIGN

PASS A — GROUNDED DISCOVERY  
Gemini searches current public sources and returns cited findings.

PASS B — NORMALIZATION  
A structured-output step converts only those findings into the versioned event schema. It may organize, classify, and merge facts but may not introduce unsupported facts.

## FLYER RESPONSIBILITIES

• Confirm that an image resembles an event notice  
• Read dates, times, performers, venue, price, age limit, and public instructions  
• Preserve unusual names and spellings  
• Mark unclear or missing details  
• Require human review  
• Respect the selected location privacy mode  
• Submit only the confirmed record

## KERYX SERVICE BOUNDARIES

Keep separate modules for:  
• Location interpretation  
• Public discovery  
• Grounded-result parsing  
• Event normalization  
• Flyer image extraction  
• Duplicate detection  
• Persistence  
• Source freshness  
• Moderation and reporting  
• Cost and rate controls

All AI access should run behind a Keryx service interface so models, prompts, tools, and providers can evolve without rewriting the application.

# 9\. LOCATION AND PRIVACY MODEL

The location model must support both mainstream public venues and underground events that intentionally withhold an address.

LOCATION MODES

EXACT PUBLIC  
Public venue and public street address.

VENUE ONLY  
Venue name and city, without a street address.

GENERAL AREA  
Neighborhood, district, campus, or broad local area.

CITY ONLY  
City and region only.

ASK ORGANIZER  
Private or changing location. Preserve wording such as:  
• Ask a punk  
• DM for address  
• Private house venue  
• Location announced day of show

PRIVACY RULES

• Keryx never searches for or infers a private venue’s hidden address.  
• A private address should remain absent rather than being collected secretly.  
• City is the minimum useful public location for a contributed event.  
• Public source wording explaining how to get the location should be preserved.  
• Future accounts may let venue owners control public location precision.  
• Precise user location is optional and permission-based.  
• No location choice creates an embedded map.

# 10\. EVENT AND DATA MODEL

The event schema should be versioned from the beginning.

CORE IDENTITY

eventId  
eventTitle  
performers\[\]  
eventType

TIME

startDate  
doorsTime  
startTime  
endTime  
timeZone  
timeStatus

LOCATION

locationMode  
venueName  
publicLocationText  
city  
region  
postalCode  
country  
locationInstructions  
latitude — public locations only, future-ready  
longitude — public locations only, future-ready  
locationPrecision

DETAILS

price  
ageRestriction  
ticketUrl  
infoUrl  
additionalNotes

ORIGIN AND TRUST

sourceType  
sourceName  
sourceUrl  
sourceUrls\[\]  
sourceCount  
sourceEvidence  
recordStatus  
uncertainties\[\]  
lastVerifiedAt

COMMUNITY

flyerUrl  
anonymousContributorId  
ownerAccountId — nullable until accounts  
claimedVenueId — nullable until venue accounts  
claimedArtistIds\[\] — nullable until artist accounts  
contributorConfirmedAt  
reportCount

SYSTEM

locationKey  
dedupeKey  
createdAt  
updatedAt  
expiresAt  
schemaVersion  
visibility  
moderationStatus

FUTURE BUSINESS FIELDS

spotlightStatus  
spotlightStartsAt  
spotlightEndsAt  
subscriptionOwnerId  
professionalMetadata

Future fields may exist as optional values without exposing unfinished features in Version 0.1.

# 11\. SEARCH, CACHING, AND SHARED VALUE

A paid or slow public scan should not run every time the application opens.

STANDARD FLOW

1\. Normalize the requested city or ZIP/postal code into a locationKey.  
2\. Check for sufficiently recent stored records.  
3\. Return cached signals immediately when fresh.  
4\. Trigger a Keryx rescan when absent or stale.  
5\. Store newly supported records.  
6\. Merge community records.  
7\. Hide past events from active views.  
8\. Retain expired records briefly for duplicate and correction work.  
9\. Remove old records through scheduled cleanup or database TTL.

Suggested configurable freshness windows:  
• Tonight: 2–3 hours  
• Tomorrow: 6 hours  
• Weekend: 8–12 hours  
• Seven days: 12 hours

The exact windows belong in configuration rather than scattered throughout the code.

COMMUNITY VALUE LOOP

FIRST PERSON SCANS A LOCATION  
→ KERYX BUILDS A LOCAL INDEX  
→ RECORDS ARE STORED  
→ NEXT PERSON RECEIVES RESULTS FASTER  
→ COMMUNITY ADDS MISSED FLYERS  
→ TRUSTED USERS CORRECT AND MAINTAIN RECORDS  
→ THE LOCAL INDEX BECOMES MORE COMPLETE

# 12\. DEDUPLICATION AND TRUST

LIKELY DUPLICATE KEY

normalized event title \+ local date \+ normalized venue or city

MERGE RULES

• Preserve every origin URL.  
• Prefer current official organizer or venue information for cancellations and changes.  
• Preserve human-confirmed unusual spellings from a flyer.  
• Do not merge materially uncertain matches automatically.  
• Display one record with multiple origins when the evidence supports a merge.

SOURCE TYPES

PUBLIC WEB  
Found through a current grounded search.

COMMUNITY FLYER  
Submitted and confirmed by a contributor.

MULTIPLE ORIGINS  
Supported by more than one source.

FUTURE VERIFIED OWNER  
Confirmed by an authorized artist, venue, or organizer account.

RECORD STATUSES

SOURCE FOUND  
At least one origin supports the record.

COMMUNITY CONFIRMED  
A person reviewed the flyer-derived record.

DETAILS INCOMPLETE  
Useful, but one or more important facts are unknown.

POSSIBLE DUPLICATE  
Requires merge review.

REPORTED  
A visitor reported a possible error.

CANCELLED  
A credible current origin indicates cancellation.

PAST  
Hidden from the active event index.

# 13\. TECHNICAL ARCHITECTURE

## FRONTEND DIRECTION

Permanent application foundation:  
• Flutter  
• Dart with sound null safety  
• Responsive accessible Flutter interface shared across Android, iOS, and web

Platform strategy:  
• Android is the first production mobile target  
• iOS is a planned first-class target from the same Flutter codebase  
• Flutter web is used for public demonstrations and optional browser access  
• Shared schemas and backend contracts remain independent from individual screens and widgets

## BACKEND DIRECTION

Version 0.1 lock:  
• FlutterFire Cloud Firestore integration for the shared event index, cache, and future account seams  
• FlutterFire Cloud Storage integration for approved community flyer objects  
• FlutterFire Anonymous Authentication for invisible contribution identity  
• FlutterFire App Check before public write and paid-AI endpoint enforcement  
• Firebase Cloud Functions 2nd generation with TypeScript for protected operations  
• HTTPS callable functions as the primary Flutter-to-Keryx interface  
• Firebase Hosting for the public Flutter web demonstration  
• Server-side validation, rate limits, quotas, and cost controls  
• Scheduled cleanup and moderation jobs only when required

Cloud Run remains a future escape hatch for workloads that later require specialized containers, extended control, or execution characteristics that no longer fit Cloud Functions. It is not an unresolved contest choice.

Authentication and App Check staging:  
• The first local Keryx feasibility spike may run without production Auth or App Check enforcement.  
• Public event reading requires no visible login.  
• Saving a community contribution requires an invisible anonymous Firebase identity.  
• Publicly exposed write and expensive AI endpoints require App Check after valid Android and Flutter web clients have been tested.  
• Local work should use supported debug providers or the Firebase Emulator Suite.

## AI DIRECTION

• Official Google GenAI server SDK inside protected Keryx functions  
• Gemini Interactions API with Google Search grounding for current public discovery  
• Configured Version 0.1 default model: `gemini-3.5-flash`  
• Model name stored in server configuration and replaceable without UI changes  
• Separate Gemini structured-output request for normalized event records  
• Zod validation on the TypeScript backend before persistence  
• No Search tool during fact-constrained normalization  
• Gemini image understanding for flyer extraction  
• Prompts versioned with stable identifiers and evaluation cases  
• Two-pass discovery and normalization  
• No unsupported fact completion  
• Do not make the contest depend on a preview one-call search-plus-structured-output combination

## LOCATION DIRECTION

• City and ZIP/postal text input first  
• Optional geocoding later  
• Coordinates stored only for public locations  
• Server-side distance calculation for future radius search  
• No visual map components or map-first dependencies

## ARCHITECTURE RULES

• Keep secrets server-side.  
• Validate every write on the server.  
• Do not allow arbitrary client writes to production collections.  
• Keep UI models separate from stored document models.  
• Version schemas and prompts.  
• Isolate provider-specific code.  
• Use current stable packages at implementation time.  
• Add dependency and security updates as routine maintenance.  
• Log operational failures without retaining unnecessary personal data.  
• Build cost controls, quotas, and caching into the design rather than adding them after growth.

# 14\. ACCOUNTS — VERSION 2 DESIGN INTENT

Accounts should solve real problems rather than merely increasing sign-up numbers.

FAN ACCOUNT VALUE

• Save cities, ZIP codes, time windows, and categories  
• Follow artists, venues, and local indexes  
• Receive chosen notifications  
• Keep a personal event list  
• Contribute corrections and reports

ARTIST ACCOUNT VALUE

• Claim identity  
• Confirm appearances  
• Manage submitted events  
• Correct billing and links  
• Connect to verified venue records  
• Access professional workflow tools later

VENUE OR ORGANIZER ACCOUNT VALUE

• Claim a venue  
• Control public location precision  
• Create, update, cancel, or duplicate events  
• Import a calendar or structured feed in a future version  
• Delegate access to staff  
• Review community-submitted events attributed to the venue

COMMUNITY STEWARD VALUE

• Review reports and duplicates  
• Confirm obvious corrections  
• Protect private location practices  
• Help maintain the local index  
• Earn trust through accurate actions rather than popularity

# 15\. PRO AND FUNDING PRINCIPLES

The Local Agora will require sustainable funding if search, storage, moderation, and notifications grow.

JUNKFEATHERS SUBSCRIPTION STANDARD

When Local Agora monetization begins, use one simple auto-renewing monthly Pro subscription targeted at **$3.33/month in the United States**. Do not create a paid-upfront app, lifetime unlock, one-time Pro purchase, permanent feature purchase, annual plan, or consumable purchase unless the founder explicitly changes the company rule. A user may subscribe for one month and cancel without pressure. Display the localized store price returned by the platform billing system rather than hardcoding the public price.

APPROVED REVENUE DIRECTIONS

PROFESSIONAL SUBSCRIPTION  
For artists, venues, and organizers who need recurring workflow, management tools, current infrastructure, or continuing service.

SUPPORTER SUBSCRIPTION  
For fans who voluntarily support local infrastructure and receive optional personalization or cosmetic benefits. The same monthly Pro system should avoid confusing price ladders unless the founder later approves a different structure.

SPOTLIGHT EVENTS  
Clearly labeled paid placement, separated from chronological organic results. Spotlight access must be implemented through the approved subscription strategy or another later founder-approved arrangement; it must never silently purchase organic rank.

PARTNERSHIPS  
Carefully selected city, festival, arts, or venue partnerships that do not compromise source honesty.

MONETIZATION GUARDRAILS

• Never hide basic event discovery behind a subscription.  
• Never silently sell organic ranking.  
• Never make free contribution intentionally frustrating to force payment.  
• Charge for continuing technology, time savings, advanced management, automation, team access, customization, current data, shared infrastructure, or clearly marked promotion.  
• Keep costs measurable before offering unlimited AI or scanning features.  
• Introduce billing only after the product demonstrates repeated use.  
• No paid-upfront app, lifetime unlock, one-time feature purchase, annual plan, or consumable purchase without an explicit founder policy change.

# 16\. LOCATION EXPANSION WITHOUT MAPS

Future “near me” behavior can be delivered through text and calculation.

POSSIBLE INPUTS

• City  
• City and region  
• ZIP/postal code  
• Optional current device or browser location  
• Saved location from an account

POSSIBLE RANGE CONTROLS

• City only  
• 5 miles  
• 10 miles  
• 25 miles  
• 50 miles  
• Metro or surrounding area

INCLUSION RULES

• Exact public locations can be distance-filtered.  
• Venue-only records may use the public venue’s known coordinates.  
• General-area records can use approximate public area centroids with an approximation label.  
• City-only and ask-organizer records should remain eligible when the city matches, even if exact distance cannot be proven.  
• The interface must label exact, approximate, and city-only matches honestly.

DISPLAY EXAMPLES

2.4 MI  
APPROX. 8 MI  
SPRINGFIELD AREA  
CITY MATCH — LOCATION WITHHELD

No map is necessary to communicate useful proximity.

# 17\. MODERATION AND COMMUNITY SAFETY

Version 0.1 uses limited contribution and server validation. Later versions require a measured trust system.

FUTURE MODERATION LAYERS

• Anonymous rate limits  
• App Check  
• Duplicate prevention  
• Report incorrect information  
• Automated rejection of past dates and impossible records  
• Content and image safety checks  
• Trusted-account correction privileges  
• Venue and organizer ownership claims  
• Community steward review  
• Administrative audit log  
• Appeal or correction path

PRIVATE VENUE PROTECTION

Private-location events require special care. The platform must never reveal, infer, or monetize a hidden private address.

# 18\. ACCESSIBILITY

The retro OLED appearance must remain readable and inclusive.

Requirements:  
• High contrast  
• Keyboard-accessible controls  
• Visible focus indicators  
• Semantic headings and form labels  
• Screen-reader status announcements  
• Reduced-motion support  
• No essential information conveyed only by color  
• Plain-text event records  
• Accessible flyer descriptions when possible  
• Scalable text without broken layout

Retro is a visual language, not permission to reproduce the accessibility failures of old hardware.

# 19\. SUCCESS METRICS

VERSION 0.1 SIGNALS

• Grounded searches returning valid current events  
• Percentage of records with usable sources  
• Duplicate rate  
• Search-to-record-open rate  
• Flyer extraction completion rate  
• Number of community events added  
• Number of locations scanned  
• Repeat scans from the same local area  
• Search cost per useful local index  
• Time saved through cache reuse

VERSION 1 SIGNALS

• Weekly active local indexes  
• Repeat visitors  
• Correction and report quality  
• Event-source freshness  
• Community contribution rate  
• Retention by location  
• Reliable search cost

VERSION 2 BUSINESS SIGNALS

• Claimed artists and venues  
• Account conversion driven by useful features  
• Professional-tool adoption  
• Supporter conversion  
• Revenue compared with infrastructure and moderation costs  
• No material decline in free discovery quality

# 20\. PRODUCT RISKS

EMPTY OR INCOMPLETE INDEX

Response:  
Use on-demand grounded search to start a city and invite the community to add missing flyers.

STALE OR INCORRECT INFORMATION

Response:  
Preserve sources, show last-checked time, rescan stale windows, support correction, and never claim completeness.

AI HALLUCINATION

Response:  
Use grounded discovery followed by fact-constrained normalization. Unknown values remain unknown.

HIGH SEARCH COST

Response:  
Cache local scans, reuse records, set quotas, monitor cost, and rate-limit rescans.

PRIVATE LOCATION EXPOSURE

Response:  
Never collect an intentionally hidden address. Support venue-only, area-only, city-only, and ask-organizer modes.

MODERATION BURDEN

Response:  
Start with narrow contributions and server controls. Add accounts and reputation only when use justifies them.

NETWORK-EFFECT FAILURE

Response:  
Make the first public scan useful before requiring community participation.

OVERBUILDING

Response:  
Version 0.1 remains scan, store, display, contribute, and verify. Everything else waits.

VISUAL DRIFT

Response:  
Use the company design-system file, centralized Flutter tokens, square controls, shared monospace typography, and a founder-approved physical-phone component test before broad feature UI. Temporary engineering screens are not accepted as style references.

MONETIZATION DAMAGE

Response:  
Keep discovery useful, label paid promotion, and charge for professional value rather than artificial scarcity.

# 21\. BUILD AND RELEASE GATES

VERSION 0.1 GATE

Before this gate is approved, the app has passed the Junkfeathers visual foundation test on Jonathan’s physical Android phone: shared monospace typography, square geometry, 3/2/1 px border hierarchy, readable density, visible state inversion, and accessible tap targets.

A visitor can:  
• Enter a city or ZIP code  
• Choose when and what to find  
• Receive current sourced text records  
• Open the original origin  
• Add a missing flyer  
• Protect a private event location  
• See the confirmed event join the index  
• Use the app on a phone without a map

VERSION 0.2 GATE

The service has:  
• Stable source handling  
• Cost controls  
• Abuse controls  
• Reporting  
• Privacy and legal documents  
• Basic moderation  
• Accessibility verification

VERSION 1.0 GATE

The product demonstrates:  
• Repeated use in more than one local area  
• Useful cache reuse  
• Trustworthy correction behavior  
• Manageable infrastructure cost  
• A reason to package or release more broadly

VERSION 2.0 GATE

Accounts are introduced only when:  
• Users need to manage continuing activity  
• Claims and ownership materially improve trust  
• Saved preferences or notifications improve retention  
• Professional workflows have validated demand

PRO SUBSCRIPTION GATE

Paid features begin only after interviews or usage data show that artists, venues, or organizers will pay for specific time-saving tools.

# 22\. FINAL COUNCIL DIRECTIVE

The Local Agora should not pretend to contain the whole world.

It should prove that scattered local signals can be gathered into one useful machine, stored for the next visitor, and improved by the people who live there.

The retro interface carries the myth.  
The modern architecture carries the load.  
The community completes the signal.

Build the search.  
Preserve the origins.  
Never add a map.

# 23\. OFFICIAL TECHNICAL REFERENCES

Flutter supported deployment platforms  
https://docs.flutter.dev/reference/supported-platforms

Firebase for Flutter setup  
https://firebase.google.com/docs/flutter/setup

Google Search grounding  
https://ai.google.dev/gemini-api/docs/google-search

Gemini structured outputs  
https://ai.google.dev/gemini-api/docs/structured-output

Gemini image understanding  
https://ai.google.dev/gemini-api/docs/image-understanding

Google Maps Geocoding API — future location normalization only, not map display  
https://developers.google.com/maps/documentation/geocoding

Firebase Firestore  
https://firebase.google.com/docs/firestore

Firebase Anonymous Authentication  
https://firebase.google.com/docs/auth/web/anonymous-auth

Firebase App Check  
https://firebase.google.com/docs/app-check

Firestore TTL  
https://firebase.google.com/docs/firestore/ttl  
