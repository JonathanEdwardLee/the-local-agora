import { describe, expect, it } from "vitest";

import {
  auditEventEvidence,
  stripUnsupportedFacts,
} from "../src/keryx/audit";
import { buildDiscoveryPrompt } from "../src/keryx/request_builder";
import { sanitizeEventUrls } from "../src/keryx/evidence";
import {
  AgoraEventSchema,
  type AgoraEvent,
} from "../src/schema/agora_event";
import type { GroundedDiscoveryResult } from "../src/keryx/keryx_engine";

function sampleEvent(overrides: Partial<AgoraEvent> = {}): AgoraEvent {
  return AgoraEventSchema.parse({
    schemaVersion: "0.1.0",
    eventTitle: "Downtown Jazz Night",
    performers: ["Local Quartet"],
    eventType: "MUSIC",
    startDate: "2026-07-11",
    doorsTime: null,
    startTime: "19:00",
    endTime: null,
    timeZone: "America/Chicago",
    timeStatus: "SCHEDULED",
    locationMode: "VENUE_ONLY",
    venueName: "The Hippodrome",
    publicLocationText: null,
    city: "Springfield",
    region: "MO",
    postalCode: null,
    country: "US",
    locationInstructions: null,
    price: "$15",
    ageRestriction: null,
    ticketUrl: null,
    infoUrl: "https://example.com/jazz",
    additionalNotes: null,
    sourceType: "PUBLIC_WEB",
    sourceName: "example.com",
    sourceUrl: "https://example.com/jazz",
    sourceUrls: ["https://example.com/jazz"],
    sourceEvidence: [
      {
        claim: "Downtown Jazz Night on July 11 at The Hippodrome",
        sourceUrl: "https://example.com/jazz",
        sourceName: "example.com",
        excerpt: "Downtown Jazz Night — July 11, 7:00 PM at The Hippodrome",
      },
    ],
    uncertainties: [],
    lastVerifiedAt: "2026-07-10T12:00:00.000Z",
    ...overrides,
  });
}

const discovery: GroundedDiscoveryResult = {
  model: "gemini-3.5-flash",
  apiPath: "interactions+google_search",
  promptId: "keryx.discovery.pass_a",
  promptVersion: "0.1.0",
  outputText:
    "Downtown Jazz Night on July 11 at The Hippodrome in Springfield, MO. Starts 19:00. Price $15. Source https://example.com/jazz Local Quartet performing.",
  citations: [
    {
      title: "example.com",
      url: "https://example.com/jazz",
      citedText: "Downtown Jazz Night — July 11, 7:00 PM at The Hippodrome",
    },
  ],
  searchQueries: ["Springfield MO events July 10 2026"],
  rawStepTypes: ["google_search_call", "google_search_result", "model_output"],
  attempts: 1,
  usedFallback: false,
};

describe("AgoraEventSchema", () => {
  it("accepts a complete supported record", () => {
    const event = sampleEvent();
    expect(event.schemaVersion).toBe("0.1.0");
    expect(event.locationMode).toBe("VENUE_ONLY");
  });

  it("rejects invented schema versions", () => {
    const result = AgoraEventSchema.safeParse({
      ...sampleEvent(),
      schemaVersion: "9.9.9",
    });
    expect(result.success).toBe(false);
  });
});

describe("request builder", () => {
  it("includes location and exact calendar date context", () => {
    const built = buildDiscoveryPrompt({
      locationText: "Springfield, Missouri",
      windowStartDate: "2026-07-10",
      windowEndDate: "2026-07-12",
      category: "ALL",
      timeZone: "America/Chicago",
      calendarContextDate: "Friday, July 10, 2026",
    });
    expect(built.input).toContain("Springfield, Missouri");
    expect(built.input).toContain("Friday, July 10, 2026");
    expect(built.input).toContain("Do not invent missing details");
  });
});

describe("evidence audit", () => {
  it("marks grounded fields as SUPPORTED", () => {
    const audit = auditEventEvidence(sampleEvent(), discovery);
    expect(audit.unsupportedCount).toBe(0);
    expect(
      audit.fields.find((f) => f.field === "eventTitle")?.status,
    ).toBe("SUPPORTED");
  });

  it("strips unsupported invented facts", () => {
    const invented = sampleEvent({
      price: "$999 VIP imaginary",
      ageRestriction: "87+",
    });
    const audit = auditEventEvidence(invented, discovery);
    expect(audit.unsupportedCount).toBeGreaterThan(0);
    const cleaned = stripUnsupportedFacts(invented, audit);
    const reaudit = auditEventEvidence(cleaned, discovery);
    expect(cleaned.price).toBeNull();
    expect(cleaned.ageRestriction).toBeNull();
    expect(reaudit.unsupportedCount).toBe(0);
  });
});

describe("sanitizeEventUrls", () => {
  it("drops invalid ticket URLs", () => {
    const base = sampleEvent();
    const cleaned = sanitizeEventUrls({
      ...base,
      ticketUrl: "not-a-url",
    });
    expect(cleaned.ticketUrl).toBeNull();
  });
});
