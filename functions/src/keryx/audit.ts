import type { AgoraEvent } from "../schema/agora_event";
import type { GroundedDiscoveryResult } from "./keryx_engine";

export type FieldAuditStatus =
  | "SUPPORTED"
  | "UNKNOWN"
  | "CONFLICTING"
  | "UNSUPPORTED";

export interface FieldAudit {
  field: string;
  status: FieldAuditStatus;
  note: string;
}

export interface EventEvidenceAudit {
  eventTitle: string;
  fields: FieldAudit[];
  unsupportedCount: number;
  sourceQuality: string;
}

function evidenceCorpus(
  event: AgoraEvent,
  discovery: GroundedDiscoveryResult,
): string {
  const parts = [
    discovery.outputText,
    ...discovery.citations.map(
      (c) => `${c.title ?? ""} ${c.url} ${c.citedText ?? ""}`,
    ),
    ...event.sourceEvidence.map(
      (e) => `${e.claim} ${e.sourceName ?? ""} ${e.sourceUrl ?? ""} ${e.excerpt ?? ""}`,
    ),
    ...event.sourceUrls,
    event.sourceUrl ?? "",
  ];
  return parts.join("\n").toLowerCase();
}

function includesLoose(haystack: string, needle: string | null): boolean {
  if (!needle) return false;
  const n = needle.trim().toLowerCase();
  if (n.length < 2) return false;
  return haystack.includes(n);
}

const MONTHS = [
  "january",
  "february",
  "march",
  "april",
  "may",
  "june",
  "july",
  "august",
  "september",
  "october",
  "november",
  "december",
] as const;

/** Match ISO dates against common public-web phrasings like "July 11" or "2026-07-11". */
function dateAppearsInCorpus(haystack: string, isoDate: string | null): boolean {
  if (!isoDate) return false;
  if (includesLoose(haystack, isoDate)) return true;
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(isoDate.trim());
  if (!match) return false;
  const year = match[1];
  const monthIndex = Number(match[2]) - 1;
  const day = String(Number(match[3]));
  if (monthIndex < 0 || monthIndex > 11) return false;
  const monthName = MONTHS[monthIndex];
  const patterns = [
    `${monthName} ${day}`,
    `${monthName} ${day}, ${year}`,
    `${monthName} ${day} ${year}`,
    `${Number(match[2])}/${day}/${year}`,
    `${Number(match[2])}-${day}-${year}`,
  ];
  return patterns.some((p) => haystack.includes(p));
}

function auditScalar(
  field: string,
  value: string | null,
  corpus: string,
): FieldAudit {
  if (value == null || value.trim() === "") {
    return { field, status: "UNKNOWN", note: "Absent or null in normalized record." };
  }
  if (includesLoose(corpus, value)) {
    return {
      field,
      status: "SUPPORTED",
      note: "Value appears in grounded findings or citations.",
    };
  }
  // Soft tokens (city names often appear) — still mark unsupported if absent.
  return {
    field,
    status: "UNSUPPORTED",
    note: "Value does not appear in grounded findings/citations; must not remain accepted.",
  };
}

function classifySourceQuality(event: AgoraEvent): string {
  const urls = [
    event.sourceUrl,
    ...event.sourceUrls,
    ...event.sourceEvidence.map((e) => e.sourceUrl),
  ]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();

  if (/ticketmaster|eventbrite|dice\.fm|seetickets/.test(urls)) {
    return "Ticket platform";
  }
  if (/springfieldmo\.gov|\.gov\b|library|university|edu\b/.test(urls)) {
    return "Public institution or city calendar";
  }
  if (/facebook\.com|instagram\.com/.test(urls)) {
    return "Publicly indexed social page";
  }
  if (/news-leader|sgfcitizen|kspr|ky3|ozarks/.test(urls)) {
    return "Local publication";
  }
  if (event.venueName && includesLoose(urls, event.venueName.split(" ")[0] ?? "")) {
    return "Likely official venue or organizer source";
  }
  if (/eventbrite|bandsintown|songkick|allevents/.test(urls)) {
    return "Event aggregator";
  }
  if (!urls.trim()) {
    return "Low-confidence or unclear source";
  }
  return "Public web source (unclassified)";
}

/**
 * Field-by-field evidence audit for evaluation.
 * Any UNSUPPORTED field must be stripped before accepting a record.
 */
export function auditEventEvidence(
  event: AgoraEvent,
  discovery: GroundedDiscoveryResult,
): EventEvidenceAudit {
  const corpus = evidenceCorpus(event, discovery);
  const cityRegion =
    [event.city, event.region].filter(Boolean).join(", ") || null;

  const fields: FieldAudit[] = [
    auditScalar("eventTitle", event.eventTitle, corpus),
    {
      field: "startDate",
      status:
        event.startDate == null || event.startDate.trim() === ""
          ? "UNKNOWN"
          : dateAppearsInCorpus(corpus, event.startDate)
            ? "SUPPORTED"
            : "UNSUPPORTED",
      note:
        event.startDate == null || event.startDate.trim() === ""
          ? "Absent or null in normalized record."
          : dateAppearsInCorpus(corpus, event.startDate)
            ? "Date appears in grounded findings (ISO or natural-language form)."
            : "Date does not appear in grounded findings/citations; must not remain accepted.",
    },
    auditScalar("startTime", event.startTime, corpus),
    auditScalar("venueName", event.venueName, corpus),
    auditScalar("cityRegion", cityRegion, corpus),
    {
      field: "performers",
      status:
        event.performers.length === 0
          ? "UNKNOWN"
          : event.performers.every((p) => includesLoose(corpus, p))
            ? "SUPPORTED"
            : event.performers.some((p) => includesLoose(corpus, p))
              ? "CONFLICTING"
              : "UNSUPPORTED",
      note:
        event.performers.length === 0
          ? "No performers listed."
          : "Checked each performer token against grounded corpus.",
    },
    auditScalar("price", event.price, corpus),
    auditScalar("ageRestriction", event.ageRestriction, corpus),
    auditScalar(
      "ticketOrInfoUrl",
      event.ticketUrl ?? event.infoUrl,
      corpus,
    ),
    {
      field: "locationMode",
      status: "SUPPORTED",
      note: `Declared mode ${event.locationMode}; private addresses must remain absent.`,
    },
  ];

  // Title is required; if unsupported, count it.
  const unsupportedCount = fields.filter((f) => f.status === "UNSUPPORTED").length;

  return {
    eventTitle: event.eventTitle,
    fields,
    unsupportedCount,
    sourceQuality: classifySourceQuality(event),
  };
}

/** Strip unsupported scalar fields to null / empty rather than inventing replacements. */
export function stripUnsupportedFacts(
  event: AgoraEvent,
  audit: EventEvidenceAudit,
): AgoraEvent {
  const unsupported = new Set(
    audit.fields.filter((f) => f.status === "UNSUPPORTED").map((f) => f.field),
  );

  const next: AgoraEvent = { ...event };
  if (unsupported.has("startDate")) next.startDate = null;
  if (unsupported.has("startTime")) next.startTime = null;
  if (unsupported.has("venueName")) next.venueName = null;
  if (unsupported.has("cityRegion")) {
    next.city = null;
    next.region = null;
  }
  if (unsupported.has("performers")) next.performers = [];
  if (unsupported.has("price")) next.price = null;
  if (unsupported.has("ageRestriction")) next.ageRestriction = null;
  if (unsupported.has("ticketOrInfoUrl")) {
    next.ticketUrl = null;
    next.infoUrl = null;
  }

  if (unsupported.has("eventTitle")) {
    next.uncertainties = [
      ...next.uncertainties,
      "eventTitle unsupported by grounded evidence — record must be rejected",
    ];
  } else if (unsupported.size > 0) {
    next.uncertainties = [
      ...next.uncertainties,
      ...[...unsupported].map((f) => `Stripped unsupported field: ${f}`),
    ];
  }

  return next;
}

export function isPastRelativeToWindow(
  event: AgoraEvent,
  windowStartDate: string,
): boolean {
  if (!event.startDate) return false;
  return event.startDate < windowStartDate;
}

export function isOutsideWindow(
  event: AgoraEvent,
  windowStartDate: string,
  windowEndDate: string,
): boolean {
  if (!event.startDate) return false;
  return event.startDate < windowStartDate || event.startDate > windowEndDate;
}
