import { z } from "zod";

/** Approved location disclosure modes — never infer private street addresses. */
export const LocationModeSchema = z.enum([
  "EXACT_PUBLIC",
  "VENUE_ONLY",
  "GENERAL_AREA",
  "CITY_ONLY",
  "ASK_ORGANIZER",
]);

export const TimeStatusSchema = z.enum([
  "SCHEDULED",
  "TENTATIVE",
  "CANCELLED",
  "UNKNOWN",
]);

export const SourceTypeSchema = z.enum([
  "PUBLIC_WEB",
  "COMMUNITY_FLYER",
  "MULTIPLE_ORIGINS",
  "UNKNOWN",
]);

export const EventTypeSchema = z.enum([
  "MUSIC",
  "ART",
  "STAGE",
  "COMEDY",
  "GATHERINGS",
  "OTHER",
  "UNKNOWN",
]);

export const SourceEvidenceSchema = z.object({
  claim: z.string().min(1),
  sourceUrl: z.string().url().nullable(),
  sourceName: z.string().nullable(),
  excerpt: z.string().nullable(),
});

/**
 * Versioned event schema for the Pass 01 feasibility spike.
 * Unknown facts must remain null — never substitute guesses.
 */
export const AgoraEventSchema = z.object({
  schemaVersion: z.literal("0.1.0"),
  eventTitle: z.string().min(1),
  performers: z.array(z.string()).default([]),
  eventType: EventTypeSchema,

  startDate: z.string().nullable(),
  doorsTime: z.string().nullable(),
  startTime: z.string().nullable(),
  endTime: z.string().nullable(),
  timeZone: z.string().nullable(),
  timeStatus: TimeStatusSchema,

  locationMode: LocationModeSchema,
  venueName: z.string().nullable(),
  publicLocationText: z.string().nullable(),
  city: z.string().nullable(),
  region: z.string().nullable(),
  postalCode: z.string().nullable(),
  country: z.string().nullable(),
  locationInstructions: z.string().nullable(),

  price: z.string().nullable(),
  ageRestriction: z.string().nullable(),
  ticketUrl: z.string().url().nullable().or(z.literal(null)),
  infoUrl: z.string().url().nullable().or(z.literal(null)),
  additionalNotes: z.string().nullable(),

  sourceType: SourceTypeSchema,
  sourceName: z.string().nullable(),
  sourceUrl: z.string().url().nullable(),
  sourceUrls: z.array(z.string().url()).default([]),
  sourceEvidence: z.array(SourceEvidenceSchema).default([]),
  uncertainties: z.array(z.string()).default([]),
  lastVerifiedAt: z.string().nullable(),
});

export const NormalizationResultSchema = z.object({
  events: z.array(AgoraEventSchema),
  rejected: z
    .array(
      z.object({
        reason: z.string(),
        partialTitle: z.string().nullable(),
      }),
    )
    .default([]),
});

export type LocationMode = z.infer<typeof LocationModeSchema>;
export type AgoraEvent = z.infer<typeof AgoraEventSchema>;
export type NormalizationResult = z.infer<typeof NormalizationResultSchema>;
export type SourceEvidence = z.infer<typeof SourceEvidenceSchema>;

/** JSON Schema subset for Gemini structured-output response_format. */
export const agoraEventJsonSchema = {
  type: "object",
  additionalProperties: false,
  properties: {
    events: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          schemaVersion: { type: "string", enum: ["0.1.0"] },
          eventTitle: { type: "string" },
          performers: { type: "array", items: { type: "string" } },
          eventType: {
            type: "string",
            enum: [
              "MUSIC",
              "ART",
              "STAGE",
              "COMEDY",
              "GATHERINGS",
              "OTHER",
              "UNKNOWN",
            ],
          },
          startDate: { type: ["string", "null"] },
          doorsTime: { type: ["string", "null"] },
          startTime: { type: ["string", "null"] },
          endTime: { type: ["string", "null"] },
          timeZone: { type: ["string", "null"] },
          timeStatus: {
            type: "string",
            enum: ["SCHEDULED", "TENTATIVE", "CANCELLED", "UNKNOWN"],
          },
          locationMode: {
            type: "string",
            enum: [
              "EXACT_PUBLIC",
              "VENUE_ONLY",
              "GENERAL_AREA",
              "CITY_ONLY",
              "ASK_ORGANIZER",
            ],
          },
          venueName: { type: ["string", "null"] },
          publicLocationText: { type: ["string", "null"] },
          city: { type: ["string", "null"] },
          region: { type: ["string", "null"] },
          postalCode: { type: ["string", "null"] },
          country: { type: ["string", "null"] },
          locationInstructions: { type: ["string", "null"] },
          price: { type: ["string", "null"] },
          ageRestriction: { type: ["string", "null"] },
          ticketUrl: { type: ["string", "null"] },
          infoUrl: { type: ["string", "null"] },
          additionalNotes: { type: ["string", "null"] },
          sourceType: {
            type: "string",
            enum: [
              "PUBLIC_WEB",
              "COMMUNITY_FLYER",
              "MULTIPLE_ORIGINS",
              "UNKNOWN",
            ],
          },
          sourceName: { type: ["string", "null"] },
          sourceUrl: { type: ["string", "null"] },
          sourceUrls: { type: "array", items: { type: "string" } },
          sourceEvidence: {
            type: "array",
            items: {
              type: "object",
              additionalProperties: false,
              properties: {
                claim: { type: "string" },
                sourceUrl: { type: ["string", "null"] },
                sourceName: { type: ["string", "null"] },
                excerpt: { type: ["string", "null"] },
              },
              required: ["claim", "sourceUrl", "sourceName", "excerpt"],
            },
          },
          uncertainties: { type: "array", items: { type: "string" } },
          lastVerifiedAt: { type: ["string", "null"] },
        },
        required: [
          "schemaVersion",
          "eventTitle",
          "performers",
          "eventType",
          "startDate",
          "doorsTime",
          "startTime",
          "endTime",
          "timeZone",
          "timeStatus",
          "locationMode",
          "venueName",
          "publicLocationText",
          "city",
          "region",
          "postalCode",
          "country",
          "locationInstructions",
          "price",
          "ageRestriction",
          "ticketUrl",
          "infoUrl",
          "additionalNotes",
          "sourceType",
          "sourceName",
          "sourceUrl",
          "sourceUrls",
          "sourceEvidence",
          "uncertainties",
          "lastVerifiedAt",
        ],
      },
    },
    rejected: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          reason: { type: "string" },
          partialTitle: { type: ["string", "null"] },
        },
        required: ["reason", "partialTitle"],
      },
    },
  },
  required: ["events", "rejected"],
} as const;
