# THE LOCAL AGORA


## DEV Weekend Challenge: Passion Edition — Version 0.1 Build Blueprint


Junkfeathers Tech  
Project status: Approved contest direction  
Build method: Cursor-assisted Flutter and Dart development; Antigravity may contribute when actually used and will be credited honestly  
Primary prize category: Best Use of Google AI  
Contest deadline: Monday, July 13, 2026 at 1:59 AM Central Daylight Time  
Internal finish line: Sunday, July 12, 2026 at 9:00 PM Central Daylight Time  
Last revised: July 10, 2026 — post-contest shared-platform continuity approved; Pass 02B.1A merged against repository history


# ZEUS DECISION


Build the first functional version of The Local Agora for the contest.


The Local Agora is a text-first machine for discovering creative events near a chosen city or ZIP code. The Keryx Engine scans current public web signals, converts them into consistent event records, stores useful results for the next local visitor, and merges them with events contributed through flyer uploads.


The contest entry must remain focused on one job:


Tell me what is happening here and when.


The application is not a social network, a map, a promotional copywriter, or a ticketing platform. It is a local event-finding instrument.


# THE PASSION STORY


The Local Agora comes from years of playing in bands, promoting shows, and helping operate The Fungeon in Springfield, Missouri.


Local scenes contain extraordinary music, art, comedy, theatre, poetry, markets, workshops, and other gatherings. The information is usually scattered across venue websites, ticket pages, community calendars, public social posts, and handmade flyers. A person who wants to go out often has to search several platforms and still misses the smaller events.


The Local Agora treats all of those public notices as signals.


Keryx gathers the signals it can verify. The community adds the ones the public web missed. Each search makes the local index more useful for the next person.


# CORE PRODUCT PROMISE


Find your scene. Grow your scene.


Operational scan workflow (machine instruction, not the public tagline):  
Choose a place. Choose a time. Scan the Agora.


The machine returns a sourced, chronological list of creative events without maps, social noise, popularity algorithms, or intrusive advertising.


Primary mission:  
Make it effortless to answer, “What is happening near me tonight?”


Community mission:  
The more a local community searches, verifies, and contributes, the more useful its shared event index becomes.


# VERSION 0.1 — ONE THING DONE WELL


Version 0.1 performs one complete loop:


1\. A visitor enters a city or ZIP code.  
2\. The visitor chooses a time window and optional event category.  
3\. Keryx searches current public web sources through Google Search grounding.  
4\. Keryx converts supported findings into normalized event records.  
5\. The records are deduplicated, stored, and displayed chronologically.  
6\. Existing recent records are reused for later visitors.  
7\. A visitor may add a missing event by uploading its flyer.  
8\. Keryx reads the flyer and prepares a record for human confirmation.  
9\. The confirmed event joins the same local index.


The public web starts the index.  
The local community strengthens it.


# PUBLIC POSITIONING


Product:  
The Local Agora


AI system:  
Keryx Engine


Descriptor:  
A text-first local event finder powered by public signals and community flyers.


Primary tagline (public brand):  
Find your scene. Grow your scene.


Operational scan workflow phrase (machine / demo instruction — not the public tagline):  
Choose a place. Choose a time. Scan the Agora.


Approved onboarding beats:  
• WELCOME — Find your scene. Discover music, comedy, and theater events near you.  
• HELP IT GROW — Every event you submit helps someone discover their next favorite venue, artist, or community.  
• TOGETHER — The Local Agora belongs to everyone.


One-sentence pitch:  
The Local Agora uses Google AI to find current creative events for a city or ZIP code, store sourced event records for the local community, and turn contributed flyers into searchable listings.


Do not describe the project as:  
• A complete list of every event  
• A map application  
• A Facebook scraper  
• A social network  
• An AI event recommendation personality  
• A promotional-content generator  
• A national database that is already complete


# THE MACHINE EXPERIENCE


## POST-PASS-02A VISUAL APPROVALS


Jonathan's physical Android review approved the foundational theme and locked these refinements:


- The splash carries the Junkfeathers Tech name; the in-app machine uses a Local Agora model identity such as `AGORA MK-I`.
- Local Agora is **portrait-only**.
- Default OLED toast/status messages appear near the **top** of the machine.
- Preserve the current keyboard-open behavior.
- Continue evolving the interface toward a **cyberpunk civic control center** with four conceptual levels:
  - `01` status/spec strip
  - `02` main display
  - `03` animated art visual
  - `04` controls


Future contest passes should move toward this machine structure without delaying the proven Keryx loop or creating decorative scope sprawl.


The Local Agora should feel like a myth-magic-fueled civic receiver displayed through a retro OLED machine.


On the surface, follow `docs/JUNKFEATHERS_DESIGN_SYSTEM.md`:


• Near-black OLED field with black device panels  
• White or bone-white text and line work  
• Canonical `fontFamily: 'monospace'` throughout visible UI  
• Square ordinary controls, fields, dialogs, records, and toasts  
• 3 px major shell, 2 px primary control/dialog, and 1 px field/separator borders  
• Black/white inversion for active and pressed controls  
• Compact 4 / 8 / 12 / 16 / 24 / 48 px spacing rhythm  
• Accessible semantic tap targets around 44×44 px where practical  
• Restrained amber only for warnings, uncertainty, missing information, and review states  
• Minimal classical title treatment inside the shared monospace family  
• Deliberate scan and indexing states  
• No rounded Material cards, shadows, elevation, glassmorphism, or floating pills  
• No conventional social-media cards  
• No map, pins, or visual geography  
• No flyer image in the primary event list


The Pass 01 foundation screen was an engineering proof only. Do not use its typography or generic temporary widgets as the reference for the contest interface.


Under the surface:  
• Current Google AI capabilities  
• Official Google GenAI server SDK behind protected endpoints, plus current FlutterFire packages in the Flutter app  
• Typed schemas  
• Secure server-side tools  
• Cloud data caching  
• Modular services  
• Automated validation  
• Accessible responsive code  
• Replaceable model and provider layers  
• Architecture designed for later accounts, subscriptions, and new event sources


Junkfeathers Tech principle:  
The machine may look recovered from another age, but its internals should use current, maintainable, adaptable technology. Flutter and Dart are the permanent user-facing application foundation so Android, iOS, and web builds share one product codebase. Do not substitute React, Next.js, Vue, or a separate web-only frontend.


Shared splash requirement:  
Use the approved reusable Junkfeathers Tech splash from the canonical universal package (Pass 02C / 02C.1): exact approved logo and procedural geometry; timing 990 + 1000 + 880 = 2870 ms. Normal-motion interference intensity increases continuously with **no clean middle pause** and ends at strongest interference (ADR-040). Runtime sources: `lib/brand/junkfeathers_splash/`. Reference: `docs/Junkfeathers Universal Splash/`. Local Agora rotating tips may differ. Do not alter the timing totals, redesign the logo, substitute a generic Flutter splash, or invent a Local Agora product splash. Startup sequence: Junkfeathers splash → existing main app → Welcome dialog over main when appropriate. About control: secondary row under Scan beside Add Event (`docs/LOCAL_AGORA_WELCOME_DIALOG.md`).


# APP LANGUAGE


Ordinary action → Local Agora language


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
Saved recent search → CACHED SIGNALS


Every mythic term must have clear supporting language. The user should feel the machine without having to decode it.


# PRIMARY SCREEN FLOW


## SCREEN 1 — SCAN CONTROL


Header:  
AGORA MK-I


Title:  
THE LOCAL AGORA


Prompt:  
WHAT IS HAPPENING HERE?


Location field:  
CITY OR ZIP CODE


Default demonstration location:  
Springfield, Missouri


Time controls:  
• TONIGHT  
• TOMORROW  
• THIS WEEKEND  
• NEXT 7 DAYS


Event controls:  
• ALL SIGNALS  
• MUSIC  
• ART  
• STAGE  
• COMEDY  
• GATHERINGS


Primary action:  
SCAN THE AGORA


Secondary action:  
ADD SIGNAL


Version 0.1 location rule:  
The contest build accepts a city, city and region, or ZIP/postal code. It does not promise mathematically exact distance filtering. A future release may add 5-, 10-, 25-, and 50-mile radius options through geocoding and distance calculation without ever displaying a map.


## SCREEN 2 — KERYX INDEXING


Visible machine states:  
• INTERPRETING LOCATION  
• SEARCHING PUBLIC SIGNALS  
• CHECKING DATES  
• PRESERVING ORIGINS  
• REMOVING DUPLICATES  
• MERGING COMMUNITY RECORDS  
• INDEX READY


Do not display a fake percentage. Display honest process states.


## SCREEN 3 — CITY INDEX


Header example:  
SPRINGFIELD, MISSOURI  
TONIGHT  
12 SIGNALS FOUND  
LAST SCAN: 2H 14M AGO


Sort order:  
1\. Soonest event start  
2\. Events with unknown time after timed events  
3\. Stable title ordering as final tie-breaker


Each text record shows:  
• Date  
• Start time or TIME NOT LISTED  
• Event name  
• Performers when relevant  
• Venue or public location label  
• City and region  
• Price when known  
• Age restriction when known  
• Event category  
• Origin type  
• Record status


Primary action:  
OPEN RECORD


Optional action:  
VIEW FLYER, only when a flyer exists


No thumbnail appears in the feed.


## SCREEN 4 — OPEN RECORD


Show:  
• Event title  
• Full performer or participant list  
• Date  
• Doors time  
• Start time  
• End time when known  
• Venue name when public  
• Public location text  
• City, region, country  
• Price  
• Age restriction  
• Ticket or information link  
• Original sources  
• Last checked time  
• Missing or uncertain details  
• Community flyer viewer when available


Trust line:  
VERIFY DETAILS WITH THE ORIGINAL SOURCE.


## SCREEN 5 — ADD SIGNAL


Prompt:  
KNOW OF A MISSING EVENT?


Action:  
LOAD FLYER


Keryx responsibilities:  
1\. Confirm that the image appears to contain an event announcement.  
2\. Read event details with Gemini image understanding.  
3\. Return a strict structured event record.  
4\. Mark missing or unclear details.  
5\. Require human review.  
6\. Preserve unusual artist, event, and venue spellings.  
7\. Save only the public location information the contributor approves.  
8\. Add the confirmed record to the local index.


The contribution flow does not create a visible account in Version 0.1.


# KERYX ENGINE — PUBLIC SIGNAL SCAN


Keryx uses Google Search grounding to access current public web information and preserve source citations.


The search request should be constructed from:  
• Normalized location  
• Time window  
• Event category  
• Current date in the location’s calendar context  
• Clear definition of creative and community events  
• Instruction to return only findings supported by a public source  
• Instruction not to invent missing details  
• Instruction to exclude past events  
• Instruction to preserve source URLs


Potential source types:  
• Official venue calendars  
• Organizer websites  
• Ticket listings  
• Local newspapers  
• Arts organizations  
• Universities and libraries  
• City and tourism calendars  
• Publicly indexable event pages  
• Publicly indexable social pages


The app does not directly scrape Facebook or Instagram. If a public page is discoverable through normal web search, it may appear as an attributed source.


# KERYX ENGINE — TWO-PASS SAFETY DESIGN


Preferred design:


## PASS A — GROUNDED DISCOVERY


Gemini searches public web sources and produces cited findings.


## PASS B — NORMALIZATION


A separate structured-output step converts only those findings into the event schema. It may organize, merge, and classify facts but may not add a fact that was absent from the grounded result.


This separation prevents a formatting request from becoming an invitation to invent missing details.


# COMMUNITY FLYER CHANNEL


A contributed flyer creates a second event source.


The flyer itself is not the product. Its extracted information becomes a searchable record that can help everyone in the same community.


Flyer contribution flow:  
1\. Load JPG, PNG, or WebP.  
2\. Preview privately.  
3\. Keryx extracts the record.  
4\. Contributor reviews every field.  
5\. Contributor selects the allowed location disclosure level.  
6\. Contributor confirms the record.  
7\. Server validates and checks for duplicates.  
8\. Event joins the city index.  
9\. Original flyer remains available only through VIEW FLYER.


# LOCATION PRIVACY


Exact addresses are optional.


Every event uses one location mode:


EXACT PUBLIC  
Public venue and public street address.


VENUE ONLY  
Venue name and city, with no street address.


GENERAL AREA  
Neighborhood, district, campus, or broad area.


CITY ONLY  
City and region only.


ASK ORGANIZER  
Private or changing location. Preserve language such as:  
• Ask a punk  
• DM for address  
• Location announced day of show  
• Private house venue


Rules:  
• Keryx must never search for or infer the hidden address of a private venue.  
• A private address should not be collected and hidden in the database; it should remain absent.  
• City is the minimum useful public location for a community-submitted record.  
• Public source wording must be preserved when it communicates how to obtain details.


# EVENT RECORD


Core identity:  
eventId  
eventTitle  
performers\[\]  
eventType


Time:  
startDate  
doorsTime  
startTime  
endTime  
timeZone  
timeStatus


Location:  
locationMode  
venueName  
publicLocationText  
city  
region  
postalCode  
country  
locationInstructions


Details:  
price  
ageRestriction  
ticketUrl  
infoUrl  
additionalNotes


Origin and trust:  
sourceType  
sourceName  
sourceUrl  
sourceUrls\[\]  
sourceCount  
sourceEvidence  
recordStatus  
uncertainties\[\]  
lastVerifiedAt


Community:  
flyerUrl  
anonymousContributorId  
contributorConfirmedAt  
reportCount


System:  
locationKey  
dedupeKey  
createdAt  
updatedAt  
expiresAt  
schemaVersion


# SOURCE TYPES


PUBLIC WEB  
Found through a current grounded public search.


COMMUNITY FLYER  
Submitted and confirmed by a local contributor.


MULTIPLE ORIGINS  
Supported by more than one public or community source.


# RECORD STATUSES


SOURCE FOUND  
At least one source supports the event record.


COMMUNITY CONFIRMED  
A contributor reviewed the flyer-derived record.


DETAILS INCOMPLETE  
The event is useful but one or more important facts are unknown.


POSSIBLE DUPLICATE  
The event requires merge review.


REPORTED  
A visitor reported a possible error.


CANCELLED  
A credible current source states that the event was cancelled.


PAST  
The event no longer appears in the active index.


# DEDUPLICATION


Likely duplicate key:  
normalized title \+ local calendar date \+ normalized venue or city


Merge behavior:  
• Preserve every source URL.  
• Prefer official organizer or venue information for cancellation and schedule changes.  
• Preserve human-confirmed unusual spellings from the flyer.  
• Do not merge records when the match remains materially uncertain.  
• Display one event record with multiple origins rather than duplicate feed entries.


# STORAGE AND SHARED COMMUNITY VALUE


A scan should not run every time the app opens.


Flow:  
1\. Normalize the location request into a locationKey.  
2\. Check for a sufficiently recent cached scan.  
3\. Return cached records immediately when fresh.  
4\. Trigger a new Keryx scan when absent or stale.  
5\. Store newly supported records.  
6\. Merge community records.  
7\. Hide past events from every visible query.  
8\. Retain expired records briefly for duplicate checks and corrections.  
9\. Remove old records through scheduled cleanup or Firestore TTL.


Suggested cache windows:  
• Tonight: 2–3 hours  
• Tomorrow: 6 hours  
• Weekend: 8–12 hours  
• Seven days: 12 hours


The exact values are configuration, not hard-coded product rules.


Growth loop:  
FIRST PERSON SCANS A LOCATION  
→ KERYX BUILDS A LOCAL INDEX  
→ RECORDS ARE STORED  
→ NEXT PERSON RECEIVES RESULTS FASTER  
→ COMMUNITY ADDS MISSED FLYERS  
→ THE INDEX BECOMES MORE COMPLETE


# TRUST AND HONESTY


Never claim:  
ALL EVENTS NEAR YOU


Use:  
PUBLIC SIGNALS FOUND FOR THIS LOCATION


Permanent footer:  
THE AGORA MAY NOT CONTAIN EVERY EVENT.  
VERIFY DETAILS WITH THE ORIGINAL SOURCE.  
KNOW OF A MISSING SIGNAL? ADD THE FLYER.


Google Search citations or original source links must remain visible on every public-web record.


Unknown facts remain unknown.


No popularity ranking is used in Version 0.1.


# NO MAP — PERMANENT PRODUCT RULE


The Local Agora will never contain an embedded map.


Reasons:  
• The product is a text-first machine.  
• Many DIY events intentionally withhold exact locations.  
• Maps add visual noise and cost without improving the core answer.  
• City, ZIP, time, and optional distance are enough for discovery.  
• A public address may later link outward to directions, but a map will not appear inside the machine.


This is a permanent brand and product constraint, not merely a contest shortcut.


# TECHNICAL ARCHITECTURE


Build with current, adaptable technology rather than imitating retro limitations internally.


Locked contest shape:  
• Cursor-assisted Flutter and Dart development; credit Antigravity or other AI tools only when they actually contribute  
• Flutter and Dart as the permanent application stack  
• Flutter project name `the_local_agora`  
• Repository name `the-local-agora`  
• Android application ID `com.junkfeathers.localagora`  
• Initial version `0.1.0+1`  
• Current FlutterFire packages in the Flutter app  
• Firebase Cloud Functions 2nd generation with TypeScript for protected operations  
• HTTPS callable functions for Flutter-to-Keryx requests  
• Official Google GenAI server SDK inside the protected backend  
• Gemini Interactions API with Google Search grounding for Pass A  
• Configured Version 0.1 default model `gemini-3.5-flash`  
• Separate Gemini structured-output request for Pass B  
• Zod validation on the TypeScript backend before persistence  
• Gemini image understanding for flyer extraction  
• Cloud Firestore for cached event records  
• Cloud Storage for approved community flyer objects  
• Firebase Anonymous Authentication for invisible contributor identity  
• Firebase App Check before public write and expensive AI endpoint enforcement  
• Firebase Hosting for the public Flutter web demonstration  
• Responsive accessible Flutter application: Android first, iOS first-class from the same codebase, and Flutter web for judges  
• New public GitHub repository created during the challenge window, containing the Flutter application and isolated backend services


Authentication and App Check staging:  
• The first local Keryx feasibility spike does not require production Auth or App Check enforcement.  
• Reading public event records does not require a visible login.  
• Saving a community contribution requires invisible Anonymous Authentication.  
• Before public deployment, protect write and paid-AI callable functions with App Check and server validation.  
• Use supported debug providers or the Firebase Emulator Suite during local work.  
• Enable enforcement only after Android and Flutter web clients have been tested.


Adaptability rules:  
• Keep model names and cache windows in configuration.  
• Put all AI calls behind a Keryx service interface.  
• Version the event schema and prompts.  
• Separate public discovery, normalization, flyer extraction, deduplication, and persistence.  
• Keep the Flutter UI independent from Firestore document shape.  
• Use current stable packages at implementation time.  
• Keep secrets server-side and follow `DO_NOT_UPLOAD_SECRETS.md`.  
• Do not depend on a preview one-call search-plus-structured-output combination.  
• Log enough metadata to debug failed scans without storing unnecessary personal information.  
• Record accepted Firebase resource names and architecture decisions in `docs/DECISIONS.md`.


# VERSION 0.1 MVP


Required:  
• City or ZIP input  
• Time-window selector  
• Basic category selector  
• Keryx grounded public scan  
• Sourced chronological text results  
• Firestore caching  
• One stored index reusable by later visitors  
• Event detail record  
• Original source links  
• Flyer upload  
• Gemini flyer extraction  
• Human verification  
• Private-location modes  
• Duplicate check  
• Past-event filtering  
• Optional retro flyer viewer  
• Android phone usability plus responsive Flutter web demonstration  
• Public Flutter web deployment for judges, while preserving Android and iOS build compatibility  
• Public challenge-window repository


Strong stretch goals:  
• Report incorrect information  
• Manual rescan with rate limit  
• Multiple-origin merge  
• ZIP normalization  
• Reduced-motion mode  
• A second test location outside Springfield


# DO NOT BUILD FOR THE CONTEST


• Accounts or profile screens  
• Subscription checkout or paid features during Version 0.1  
• Any one-time purchase, lifetime unlock, paid download, annual plan, or consumable purchase  
• Likes, comments, or followers  
• Artist or venue pages  
• Notifications  
• Full moderation dashboard  
• Ticket purchasing  
• Automated social posting  
• Direct Facebook integration  
• Map or map view  
• Exact radius calculations  
• Play Store production packaging or store submission  
• Nationwide background crawling  
• Permanent event history  
• Personalized recommendation algorithm


# CONTEST DEMO


Demonstration location:  
Springfield, Missouri


Suggested sequence:  
1\. Open the empty retro machine.  
2\. Enter Springfield, Missouri.  
3\. Select THIS WEEKEND and ALL SIGNALS.  
4\. Run SCAN THE AGORA.  
5\. Show Keryx indexing states.  
6\. Reveal a sourced chronological event list.  
7\. Open one public-web event and show its origin.  
8\. Return to the list.  
9\. Select ADD SIGNAL.  
10\. Upload a local flyer missed by the public scan.  
11\. Correct one unclear detail.  
12\. Select ASK ORGANIZER or CITY ONLY for a private location.  
13\. Confirm the record.  
14\. Show the new event inside the same city index.  
15\. End on:  
   FIND YOUR SCENE.  
   GROW YOUR SCENE.


# JUDGING STRATEGY


## RELEVANCE TO PASSION


The project comes directly from the founder’s experience in bands and DIY music spaces.


## CREATIVITY


A global event finder is presented as a mythic civic signal machine, and every local search contributes to a shared community index.


## TECHNICAL EXECUTION


The demo shows current web grounding, citations, normalization, caching, deduplication, image understanding, human confirmation, and database persistence.


## GOOGLE AI USE


Gemini performs essential in-app work:  
• Current public event discovery  
• Source-grounded synthesis  
• Structured normalization  
• Flyer image understanding  
• Missing-detail detection  
• Duplicate assistance


## WRITING QUALITY


The article should tell the story of trying to find one good local show, discovering how scattered the information is, and building a machine that becomes more useful every time a community uses it.


# ARGUS RISK REVIEW


Risk: Grounded search returns incomplete events.  
Response: The product openly presents “signals found,” keeps sources visible, and invites flyer contributions.


Risk: Search results contain stale or wrong dates.  
Response: Use explicit date windows, preserve citations, exclude past records, show last checked time, and require source verification.


Risk: The model invents structured fields.  
Response: Use a two-pass design and prohibit the normalization pass from adding facts.


Risk: The event feed is slow or expensive.  
Response: Cache scans by location and time window, reuse records, and rate-limit manual rescans.


Risk: A private location is exposed.  
Response: Never collect hidden addresses. Support venue-only, area-only, city-only, and ask-organizer modes.


Risk: The contest scope grows into the full future platform.  
Response: Finish public scan, stored index, flyer contribution, and source trust before adding anything else.


Risk: The retro styling delays the working product.  
Response: Establish the minimal shared Junkfeathers typography, square geometry, border hierarchy, and reusable controls before broad feature UI. Defer texture, decorative interference, and nonessential animation until the loop works; do not defer the company visual DNA itself.


# BUILD ORDER


## PHASE 1 — REPOSITORY FOUNDATION AND KERYX FEASIBILITY SPIKE


• Create the Flutter repository with the locked project name, package ID, and initial version.  
• Create the isolated Firebase Functions 2nd generation TypeScript backend.  
• Add safe configuration templates without committing secrets.  
• Test one grounded Springfield query through the Gemini Interactions API.  
• Inspect source quality, dates, duplicates, citations, geographic relevance, and missing fields.  
• Compare one broad search with category-specific searches when useful.  
• Run a separate structured-output normalization pass validated with Zod.  
• Prove the normalizer does not add unsupported facts.  
• Produce `KERYX_EVALUATION.md` from actual results before beginning the full interface.


## PHASE 2 — VISUAL FOUNDATION


• Add `docs/JUNKFEATHERS_DESIGN_SYSTEM.md` to the repository and treat it as governing.  
• Establish centralized theme/tokens and reusable Junkfeathers controls.  
• Replace the Pass 01 temporary typography and generic widgets.  
• Demonstrate device title, inputs, primary action, compact controls, panel hierarchy, dialogs, toasts, and all major states.  
• Build a fresh APK and obtain Jonathan’s physical-phone approval for font, square geometry, spacing, line weights, state inversion, readability, and touch targets.


## PHASE 3 — BUILD THE INDEX


• Create the location and time controls from the approved components.  
• Implement cached public scan.  
• Store normalized records.  
• Render the chronological text feed.  
• Build event detail and origin display.


## PHASE 4 — ADD THE COMMUNITY CHANNEL


• Build flyer upload.  
• Add Gemini image extraction.  
• Build human verification.  
• Add location privacy choices.  
• Store and merge the confirmed event.


## PHASE 5 — MACHINE FINISH


• Add indexing states and reduced motion.  
• Add the optional flyer viewer.  
• Add only restrained texture or machine animation that does not harm the task.  
• Test mobile layout and error handling.


## PHASE 6 — PROVE AND SUBMIT


• Test Springfield and one additional location.  
• Record the demonstration.  
• Finish README and architecture notes.  
• Publish the DEV article.  
• Submit before the internal deadline.


# FINAL ACCEPTANCE TEST


Before the final visitor test, Jonathan must approve the shared Junkfeathers visual foundation on a physical Android phone.


A new visitor must be able to:  
1\. Understand the machine within ten seconds.  
2\. Enter a city or ZIP code.  
3\. Choose when and what type of event to find.  
4\. Receive current sourced event records.  
5\. Understand when the results were last checked.  
6\. Open the original source.  
7\. Add a missing event through a flyer.  
8\. Protect a private event’s exact location.  
9\. See the contributed event join the local index.  
10\. Use the complete experience on a phone without seeing a map.


# POST-CONTEST CONTINUITY RULE


The contest repository is the first milestone of the real Local Agora product, not a disposable demonstration.


After submission, preserve and extend the same Flutter client, typed event schema, Keryx service boundaries, Firebase project, and shared event index toward:


- Android public release
- a public Flutter web machine using the same protected backend and stored event records
- future native iOS release from the same Flutter codebase
- one cache-first event system rather than separate platform databases


The public web machine should launch alongside or shortly after Android so iPhone and desktop visitors can use the service before native iOS distribution.


Post-contest architecture priorities:


1. Stored current records are queried before paid discovery.
2. The server decides when a rescan is justified.
3. Event facts are stored once and filtered by location, date, and category.
4. Past events disappear from active results.
5. Recently expired full records remain briefly for corrections and duplicate prevention, then are purged under a configurable retention policy.
6. Minimal non-public fingerprints may remain only when justified for deduplication, source history, moderation, or abuse controls.
7. Android and web receive the same sourced event records and trust metadata.
8. Pro accounts do not delay the useful free public release.


Website continuity:


- Junkfeathers.com receives a Local Agora landing page.
- The preferred full-screen web machine location is `agora.junkfeathers.com`, subject to final hosting and DNS verification.
- The landing page may promote Android, offer immediate web access, measure native iPhone demand, and introduce Orpheus Deck and Junkfeathers music.
- Product promotion must not interrupt chronological event results.


Native iOS work begins only after evidence supports the Apple fee and testing burden. The permanent trigger is recorded in the master blueprint and decisions file.


These items are roadmap commitments, not permission to expand the contest submission beyond its approved current scope.




# FINAL COUNCIL DIRECTIVE


The Local Agora should not pretend to contain the whole world.


It should prove that a city’s scattered public signals can be gathered into one useful machine, stored for the next visitor, and improved by the people who actually live there.


Build the search.  
Preserve the origins.  
Let the community complete the signal.


# SOURCE NOTES


Flutter supported platforms:  
https://docs.flutter.dev/reference/supported-platforms


Firebase for Flutter setup:  
https://firebase.google.com/docs/flutter/setup


Google Search grounding:  
https://ai.google.dev/gemini-api/docs/google-search


Gemini structured outputs:  
https://ai.google.dev/gemini-api/docs/structured-output


Gemini image understanding:  
https://ai.google.dev/gemini-api/docs/image-understanding


Firebase Anonymous Authentication:  
https://firebase.google.com/docs/auth/web/anonymous-auth


Firebase App Check:  
https://firebase.google.com/docs/app-check


Firestore TTL:  
https://firebase.google.com/docs/firestore/ttl