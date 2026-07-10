/**
 * Local Pass 01 Keryx feasibility spike.
 * Requires GEMINI_API_KEY in the environment or functions/.env (never commit).
 */
import { readFileSync, existsSync, writeFileSync, mkdirSync } from "node:fs";
import { resolve } from "node:path";

import { loadKeryxConfig } from "../src/config/keryx_config";
import { GeminiKeryxEngine } from "../src/keryx/gemini_keryx_engine";
import { runFeasibilityScan } from "../src/keryx/pipeline";
import type { ScanRequest } from "../src/keryx/request_builder";

function loadDotEnv(): void {
  const envPath = resolve(__dirname, "..", ".env");
  if (!existsSync(envPath)) return;
  const text = readFileSync(envPath, "utf8");
  for (const line of text.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eq = trimmed.indexOf("=");
    if (eq <= 0) continue;
    const key = trimmed.slice(0, eq).trim();
    let value = trimmed.slice(eq + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (!process.env[key]) process.env[key] = value;
  }
}

const TESTS: Array<{ id: string; request: ScanRequest }> = [
  {
    id: "A_broad_local_scan",
    request: {
      locationText: "Springfield, Missouri",
      windowStartDate: "2026-07-10",
      windowEndDate: "2026-07-12",
      category: "ALL",
      timeZone: "America/Chicago",
      calendarContextDate: "Friday, July 10, 2026",
    },
  },
  {
    id: "B_music_category_scan",
    request: {
      locationText: "Springfield, Missouri",
      windowStartDate: "2026-07-10",
      windowEndDate: "2026-07-12",
      category: "MUSIC",
      timeZone: "America/Chicago",
      calendarContextDate: "Friday, July 10, 2026",
    },
  },
  {
    id: "C_postal_65806_scan",
    request: {
      locationText: "65806",
      windowStartDate: "2026-07-10",
      windowEndDate: "2026-07-16",
      category: "ALL",
      timeZone: "America/Chicago",
      calendarContextDate: "Friday, July 10, 2026",
    },
  },
];

function sanitizeForDisk(value: unknown): unknown {
  // Keep evaluation artifacts free of env secrets; truncate huge raw blobs.
  return JSON.parse(
    JSON.stringify(value, (_key, v) => {
      if (typeof v === "string" && v.length > 12000) {
        return `${v.slice(0, 12000)}…[truncated]`;
      }
      return v;
    }),
  );
}

async function main(): Promise<void> {
  loadDotEnv();
  const config = loadKeryxConfig();
  if (!config.apiKey) {
    console.error(
      "BLOCKED: GEMINI_API_KEY is not set. Copy functions/.env.example to functions/.env.",
    );
    process.exit(2);
  }

  const engine = new GeminiKeryxEngine(config);
  const outDir = resolve(__dirname, "..", ".eval-cache");
  mkdirSync(outDir, { recursive: true });

  const summary = {
    ranAt: new Date().toISOString(),
    discoveryModel: config.discoveryModel,
    normalizationModel: config.normalizationModel,
    modelOverrideReason: config.modelOverrideReason ?? null,
    tests: [] as unknown[],
  };

  for (const test of TESTS) {
    console.log(`\n=== Running ${test.id} ===`);
    try {
      const result = await runFeasibilityScan(engine, test.request);
      const compact = {
        id: test.id,
        request: test.request,
        discoveryModel: result.discovery.model,
        normalizationModel: result.normalization.model,
        searchQueries: result.discovery.searchQueries,
        citationCount: result.discovery.citations.length,
        citations: result.discovery.citations.map((c) => ({
          title: c.title,
          url: c.url,
        })),
        groundedPreview: result.discovery.outputText.slice(0, 4000),
        acceptedCount: result.acceptedAfterAudit.length,
        rejectedFromNormalization: result.normalization.rejected,
        rejectedTitles: result.rejectedTitles,
        invalidStructuredOutputCount:
          result.normalization.invalidStructuredOutputCount,
        unsupportedAcceptedFacts: result.unsupportedAcceptedFacts,
        pastExcluded: result.pastExcluded,
        outsideWindowExcluded: result.outsideWindowExcluded,
        duplicateTitleDatePairs: result.duplicateTitleDatePairs,
        accepted: result.acceptedAfterAudit.map((e) => ({
          eventTitle: e.eventTitle,
          startDate: e.startDate,
          startTime: e.startTime,
          venueName: e.venueName,
          city: e.city,
          region: e.region,
          eventType: e.eventType,
          locationMode: e.locationMode,
          performers: e.performers,
          price: e.price,
          ageRestriction: e.ageRestriction,
          ticketUrl: e.ticketUrl,
          infoUrl: e.infoUrl,
          sourceUrl: e.sourceUrl,
          sourceUrls: e.sourceUrls,
          uncertainties: e.uncertainties,
        })),
        audits: result.audits,
      };
      summary.tests.push(compact);
      writeFileSync(
        resolve(outDir, `${test.id}.json`),
        JSON.stringify(sanitizeForDisk(compact), null, 2),
        "utf8",
      );
      console.log(
        `Accepted=${compact.acceptedCount} citations=${compact.citationCount} invalid=${compact.invalidStructuredOutputCount}`,
      );
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.error(`ERROR in ${test.id}: ${message}`);
      summary.tests.push({ id: test.id, error: message });
    }
  }

  const summaryPath = resolve(outDir, "summary.json");
  writeFileSync(summaryPath, JSON.stringify(sanitizeForDisk(summary), null, 2));
  console.log(`\nWrote sanitized summary to ${summaryPath}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
