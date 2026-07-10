export type EventCategoryFilter =
  | "ALL"
  | "MUSIC"
  | "ART"
  | "STAGE"
  | "COMEDY"
  | "GATHERINGS";

export interface ScanRequest {
  locationText: string;
  windowStartDate: string;
  windowEndDate: string;
  category: EventCategoryFilter;
  timeZone: string;
  /** Calendar context for the evaluation (e.g. Friday, July 10, 2026). */
  calendarContextDate: string;
}

export interface BuiltDiscoveryPrompt {
  promptId: string;
  promptVersion: string;
  input: string;
}

const APPROVED_CATEGORIES =
  "music, art, stage/theatre, comedy, poetry, markets, workshops, and other creative or community gatherings";

export function buildDiscoveryPrompt(request: ScanRequest): BuiltDiscoveryPrompt {
  const categoryClause =
    request.category === "ALL"
      ? `Include all approved creative and community event categories (${APPROVED_CATEGORIES}).`
      : `Restrict findings to the category: ${request.category}. Still only report events supported by public sources.`;

  const input = [
    "You are Keryx Pass A — grounded public event discovery for The Local Agora.",
    "Search current public web sources only. Preserve citations and source URLs.",
    "Do not invent missing details. Do not claim completeness.",
    "Exclude clearly past events relative to the requested window.",
    "Do not search for, infer, or reveal private or withheld street addresses.",
    "If a source withholds an address, preserve that wording and leave the address absent.",
    "",
    `Calendar context (local): ${request.calendarContextDate}`,
    `Location request: ${request.locationText}`,
    `Date window (inclusive): ${request.windowStartDate} through ${request.windowEndDate}`,
    `Time zone context: ${request.timeZone}`,
    categoryClause,
    "",
    "Return a clear inventory of candidate events found in public sources.",
    "For each candidate include:",
    "- event title",
    "- date(s) if stated",
    "- start time / doors if stated",
    "- venue or public location wording if stated",
    "- city/region if stated",
    "- performers if stated",
    "- price / age restriction / ticket or info URL if stated",
    "- source name and source URL(s)",
    "- short evidence excerpts supporting each stated fact",
    "- explicit unknowns when a fact is not present",
    "",
    "Prefer official venue/organizer pages, city calendars, ticket platforms, local publications,",
    "and publicly indexed event pages. Label low-confidence sources honestly.",
  ].join("\n");

  return {
    promptId: "keryx.discovery.pass_a",
    promptVersion: "0.1.0",
    input,
  };
}

export function buildNormalizationPrompt(params: {
  request: ScanRequest;
  groundedFindingsText: string;
  citationSummary: string;
  verifiedAtIso: string;
}): string {
  return [
    "You are Keryx Pass B — fact-constrained event normalization.",
    "You have NO search tool. Use ONLY the grounded findings and citations provided.",
    "Convert supported findings into the approved event schema.",
    "Do not invent or infer absent facts. Unsupported values must be null.",
    "Do not invent private street addresses. Use ASK_ORGANIZER / CITY_ONLY / VENUE_ONLY / GENERAL_AREA when appropriate.",
    "Exclude events clearly outside the requested date window or clearly already past.",
    "Preserve source URLs and evidence. Record uncertainties explicitly.",
    "Every accepted event must set schemaVersion to \"0.1.0\".",
    `lastVerifiedAt for accepted events should be: ${params.verifiedAtIso}`,
    "",
    `Location request: ${params.request.locationText}`,
    `Date window: ${params.request.windowStartDate} through ${params.request.windowEndDate}`,
    `Time zone: ${params.request.timeZone}`,
    `Category filter: ${params.request.category}`,
    "",
    "CITATION SUMMARY:",
    params.citationSummary,
    "",
    "GROUNDED FINDINGS:",
    params.groundedFindingsText,
  ].join("\n");
}
