/**
 * App Check–protected debug live Keryx scan callable.
 * Bound only to GEMINI_API_KEY. Not connected to main SCAN THE AGORA.
 */
import { randomUUID } from "node:crypto";
import { HttpsError, type CallableRequest } from "firebase-functions/v2/https";

import { loadKeryxConfig } from "../config/keryx_config";
import { GeminiKeryxEngine } from "../keryx/gemini_keryx_engine";
import { runFeasibilityScan } from "../keryx/pipeline";
import {
  mapClientCategory,
  resolveScanWindow,
  type ClientCategory,
  type ClientTimeWindow,
} from "../keryx/scan_window";

const MAX_LOCATION_LEN = 120;
const MAX_EVENTS = 12;
const RESPONSE_SCHEMA_VERSION = "0.1.0-debug";

const TIME_WINDOWS = new Set<ClientTimeWindow>([
  "TONIGHT",
  "TOMORROW",
  "THIS_WEEKEND",
  "NEXT_7_DAYS",
]);

const CATEGORIES = new Set<ClientCategory>([
  "MUSIC",
  "COMEDY",
  "STAGE",
]);

export interface KeryxScanDebugRequest {
  location?: unknown;
  timeWindow?: unknown;
  category?: unknown;
  clientRequestId?: unknown;
}

function sanitizeErrorMessage(err: unknown): string {
  const raw = err instanceof Error ? err.message : String(err);
  return raw
    .replace(/AIza[0-9A-Za-z_-]{10,}/g, "[REDACTED]")
    .replace(/GEMINI_API_KEY[^\s]*/gi, "[REDACTED]")
    .slice(0, 280);
}

export function parseKeryxScanDebugRequest(data: unknown): {
  location: string;
  timeWindow: ClientTimeWindow;
  category: ClientCategory;
  clientRequestId: string;
} {
  if (data == null || typeof data !== "object" || Array.isArray(data)) {
    throw new HttpsError("invalid-argument", "Request body must be an object.");
  }
  const body = data as KeryxScanDebugRequest;

  if (typeof body.location !== "string") {
    throw new HttpsError("invalid-argument", "location must be a string.");
  }
  const location = body.location.trim();
  if (!location) {
    throw new HttpsError("invalid-argument", "location is required.");
  }
  if (location.length > MAX_LOCATION_LEN) {
    throw new HttpsError(
      "invalid-argument",
      `location must be at most ${MAX_LOCATION_LEN} characters.`,
    );
  }

  if (typeof body.timeWindow !== "string" || !TIME_WINDOWS.has(body.timeWindow as ClientTimeWindow)) {
    throw new HttpsError("invalid-argument", "timeWindow is invalid.");
  }
  if (typeof body.category !== "string" || !CATEGORIES.has(body.category as ClientCategory)) {
    throw new HttpsError("invalid-argument", "category is invalid.");
  }

  // Reject client-controlled model/prompt injection fields if present.
  const forbidden = [
    "prompt",
    "systemInstruction",
    "model",
    "apiKey",
    "tools",
    "retryCount",
    "tokenBudget",
    "maxResults",
  ];
  for (const key of forbidden) {
    if (Object.prototype.hasOwnProperty.call(body, key)) {
      throw new HttpsError(
        "invalid-argument",
        "Client may not supply model, prompt, or tool controls.",
      );
    }
  }

  const clientRequestId =
    typeof body.clientRequestId === "string" && body.clientRequestId.trim()
      ? body.clientRequestId.trim().slice(0, 80)
      : randomUUID();

  return {
    location,
    timeWindow: body.timeWindow as ClientTimeWindow,
    category: body.category as ClientCategory,
    clientRequestId,
  };
}

export async function handleKeryxScanDebug(
  request: CallableRequest,
  apiKey: string,
): Promise<Record<string, unknown>> {
  if (!request.app) {
    throw new HttpsError(
      "failed-precondition",
      "App Check token is required for live Keryx debug scans.",
    );
  }

  const parsed = parseKeryxScanDebugRequest(request.data);
  const window = resolveScanWindow(parsed.timeWindow);
  const scanStartedAt = new Date().toISOString();
  const requestId = parsed.clientRequestId;

  const config = {
    ...loadKeryxConfig(),
    apiKey,
    // Cloud Functions: stream grounded discovery to keep idle sockets alive;
    // skip Interactions for this debug proof (local smoke still uses Interactions).
    forceGenerateContentPath: true,
    forceStreamDiscovery: true,
  };

  console.info(
    `keryxScanDebug start requestId=${requestId} locationLen=${parsed.location.length} window=${parsed.timeWindow} category=${parsed.category} path=generateContentStream apiKeyLen=${apiKey.length}`,
  );

  const SCAN_DEADLINE_MS = 330_000;

  try {
    const engine = new GeminiKeryxEngine(config);
    const result = await Promise.race([
      runFeasibilityScan(engine, {
        locationText: parsed.location,
        windowStartDate: window.windowStartDate,
        windowEndDate: window.windowEndDate,
        category: mapClientCategory(parsed.category),
        timeZone: "America/Chicago",
        calendarContextDate: window.calendarContextDate,
      }),
      new Promise<never>((_, reject) => {
        setTimeout(() => {
          reject(
            new Error(
              `Scan exceeded ${SCAN_DEADLINE_MS}ms server deadline before completion.`,
            ),
          );
        }, SCAN_DEADLINE_MS);
      }),
    ]);

    console.info(
      `keryxScanDebug pipeline ok requestId=${requestId} accepted=${result.acceptedAfterAudit.length} discoveryPath=${result.discovery.apiPath} normPath=${result.normalization.apiPath}`,
    );

    const events = result.acceptedAfterAudit.slice(0, MAX_EVENTS).map((event) => ({
      title: event.eventTitle,
      date: event.startDate,
      startTime: event.startTime,
      doorsTime: event.doorsTime,
      venue: event.venueName,
      city: event.city,
      region: event.region,
      category: event.eventType,
      uncertainties: event.uncertainties,
      sourceUrl: event.sourceUrl,
      sourceUrls: event.sourceUrls,
      sourceName: event.sourceName,
    }));

    const sources = result.discovery.citations
      .map((c) => ({ title: c.title, url: c.url }))
      .filter((s) => !!s.url)
      .slice(0, 24);

    const warnings: string[] = [];
    if (result.discovery.citations.length === 0) {
      warnings.push("No structured citation annotations were returned by discovery.");
    }
    if (result.pastExcluded > 0) {
      warnings.push(`${result.pastExcluded} past signal(s) excluded.`);
    }
    if (result.outsideWindowExcluded > 0) {
      warnings.push(`${result.outsideWindowExcluded} out-of-window signal(s) excluded.`);
    }
    if (result.duplicateTitleDatePairs.length > 0) {
      warnings.push(`${result.duplicateTitleDatePairs.length} duplicate title/date pair(s) detected.`);
    }
    if (result.normalization.invalidStructuredOutputCount > 0) {
      warnings.push("Normalization produced invalid structured output on at least one attempt.");
    }
    for (const title of result.rejectedTitles.slice(0, 8)) {
      warnings.push(`Rejected: ${title}`);
    }

    const scanCompletedAt = new Date().toISOString();

    return {
      schemaVersion: RESPONSE_SCHEMA_VERSION,
      requestId: parsed.clientRequestId,
      location: parsed.location,
      timeWindow: parsed.timeWindow,
      category: parsed.category,
      events,
      sources,
      warnings,
      signalCount: events.length,
      scanStartedAt,
      scanCompletedAt,
      cacheStatus: "not_implemented",
      discoveryApiPath: result.discovery.apiPath,
      normalizationApiPath: result.normalization.apiPath,
      discoveryAttempts: result.discovery.attempts,
      normalizationAttempts: result.normalization.attempts,
    };
  } catch (err) {
    console.error("keryxScanDebug failed:", sanitizeErrorMessage(err));
    throw new HttpsError(
      "internal",
      `Live Keryx debug scan failed: ${sanitizeErrorMessage(err)}`,
    );
  }
}
