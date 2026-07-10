/**
 * Minimal grounded-search smoke test (Pass 01B correction).
 * Preferred: Interactions API + gemini-3.5-flash + google_search.
 * Fallback: generateContent + googleSearch (capacity only).
 * Final diagnostic: gemini-3-flash-preview via generateContent only if needed.
 * Never prints API keys or full sensitive payloads.
 */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

import { GoogleGenAI } from "@google/genai";

import { loadKeryxConfig } from "../src/config/keryx_config";
import {
  extractHttpStatus,
  isRetryableError,
  withBoundedRetries,
} from "../src/keryx/retry";

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

const SMOKE_PROMPT =
  "Using Google Search, name exactly one current publicly listed creative or community event in Springfield, Missouri around July 10–12, 2026 if available. Include the source URL. Do not invent facts. If none found, say so.";

type SmokeReport = {
  success: boolean;
  httpOrApiStatus: number | string | null;
  errorCategory: string | null;
  model: string;
  apiPath: string;
  attempts: number;
  citationsReturned: boolean;
  citationCount: number;
  searchCallCount: number;
  usedFallback: boolean;
  previewModelDiagnosticUsed: boolean;
  errorMessageSanitized: string | null;
};

function categorize(status: number | null, message: string): string {
  if (status === 429 || /high demand|RESOURCE_EXHAUSTED/i.test(message)) {
    return "provider_capacity";
  }
  if (status != null && [500, 502, 503, 504, 408].includes(status)) {
    return "transient_server";
  }
  if (status != null && [400, 401, 403, 404].includes(status)) {
    return "client_or_unavailable";
  }
  return "unknown";
}

function sanitizeMessage(message: string): string {
  return message
    .replace(/AIza[0-9A-Za-z\-_]{10,}/g, "[REDACTED_KEY]")
    .replace(/key=[^&\s]+/gi, "key=[REDACTED]")
    .slice(0, 500);
}

async function main(): Promise<void> {
  loadDotEnv();
  const config = loadKeryxConfig();
  if (!config.apiKey) {
    console.error("BLOCKED: GEMINI_API_KEY not set");
    process.exit(2);
  }

  const client = new GoogleGenAI({ apiKey: config.apiKey });
  const model = "gemini-3.5-flash";
  const outDir = resolve(__dirname, "..", ".eval-cache");
  mkdirSync(outDir, { recursive: true });

  const report: SmokeReport = {
    success: false,
    httpOrApiStatus: null,
    errorCategory: null,
    model,
    apiPath: "interactions+google_search",
    attempts: 0,
    citationsReturned: false,
    citationCount: 0,
    searchCallCount: 0,
    usedFallback: false,
    previewModelDiagnosticUsed: false,
    errorMessageSanitized: null,
  };

  const runInteractions = async () => {
    const interaction = await client.interactions.create({
      model,
      input: SMOKE_PROMPT,
      tools: [{ type: "google_search" }],
      store: false,
    });
    return interaction as {
      output_text?: string;
      steps?: Array<Record<string, unknown>>;
    };
  };

  const runGenerateContent = async (useModel: string) => {
    const response = await client.models.generateContent({
      model: useModel,
      contents: SMOKE_PROMPT,
      config: {
        tools: [{ googleSearch: {} }],
      },
    });
    return response as unknown as Record<string, unknown>;
  };

  try {
    const retried = await withBoundedRetries("smoke:interactions", runInteractions, {
      onRetry: (info) => console.warn(info),
    });
    report.attempts = retried.attempts;
    report.success = true;
    report.httpOrApiStatus = 200;
    const steps = retried.value.steps ?? [];
    const searchCalls = steps.filter((s) => s.type === "google_search_call");
    report.searchCallCount = searchCalls.length;
    let citations = 0;
    for (const step of steps) {
      if (step.type !== "model_output") continue;
      const content = (step.content as Array<Record<string, unknown>>) ?? [];
      for (const block of content) {
        const annotations =
          (block.annotations as Array<Record<string, unknown>>) ?? [];
        citations += annotations.filter((a) => a.type === "url_citation").length;
      }
    }
    report.citationCount = citations;
    report.citationsReturned = citations > 0;
  } catch (interactionsError) {
    const message =
      interactionsError instanceof Error
        ? interactionsError.message
        : String(interactionsError);
    const status = extractHttpStatus(interactionsError);
    report.attempts = 4;
    report.httpOrApiStatus = status;
    report.errorCategory = categorize(status, message);
    report.errorMessageSanitized = sanitizeMessage(message);

    const capacityBlocked =
      /BLOCKED after/i.test(message) || isRetryableError(interactionsError);

    if (!capacityBlocked) {
      writeFileSync(
        resolve(outDir, "smoke_test.json"),
        JSON.stringify(report, null, 2),
      );
      console.log(JSON.stringify(report, null, 2));
      process.exit(1);
    }

    console.warn("Interactions smoke blocked by capacity; trying generateContent fallback.");
    report.usedFallback = true;
    report.apiPath = "generateContent+googleSearch";

    try {
      const retried = await withBoundedRetries(
        "smoke:generateContent",
        () => runGenerateContent(model),
        { onRetry: (info) => console.warn(info) },
      );
      report.attempts = retried.attempts;
      report.success = true;
      report.httpOrApiStatus = 200;
      report.errorCategory = null;
      report.errorMessageSanitized = null;
      const candidates =
        (retried.value.candidates as Array<Record<string, unknown>>) ?? [];
      let citationCount = 0;
      let searchCount = 0;
      for (const c of candidates) {
        const g = c.groundingMetadata as Record<string, unknown> | undefined;
        const chunks =
          (g?.groundingChunks as Array<Record<string, unknown>>) ?? [];
        citationCount += chunks.length;
        const queries = (g?.webSearchQueries as string[]) ?? [];
        searchCount += queries.length;
      }
      report.citationCount = citationCount;
      report.citationsReturned = citationCount > 0;
      report.searchCallCount = searchCount;
    } catch (fallbackError) {
      const fbMessage =
        fallbackError instanceof Error
          ? fallbackError.message
          : String(fallbackError);
      const fbStatus = extractHttpStatus(fallbackError);
      report.httpOrApiStatus = fbStatus;
      report.errorCategory = categorize(fbStatus, fbMessage);
      report.errorMessageSanitized = sanitizeMessage(fbMessage);

      console.warn(
        "generateContent gemini-3.5-flash blocked; one diagnostic attempt with gemini-3-flash-preview.",
      );
      report.previewModelDiagnosticUsed = true;
      report.model = "gemini-3-flash-preview";
      try {
        const diagnostic = await withBoundedRetries(
          "smoke:preview-diagnostic",
          () => runGenerateContent("gemini-3-flash-preview"),
          { maxAttempts: 4, onRetry: (info) => console.warn(info) },
        );
        report.attempts = diagnostic.attempts;
        report.success = true;
        report.httpOrApiStatus = 200;
        report.errorCategory = null;
        report.errorMessageSanitized = null;
        report.apiPath = "generateContent+googleSearch";
        const candidates =
          (diagnostic.value.candidates as Array<Record<string, unknown>>) ?? [];
        let citationCount = 0;
        let searchCount = 0;
        for (const c of candidates) {
          const g = c.groundingMetadata as Record<string, unknown> | undefined;
          const chunks =
            (g?.groundingChunks as Array<Record<string, unknown>>) ?? [];
          citationCount += chunks.length;
          const queries = (g?.webSearchQueries as string[]) ?? [];
          searchCount += queries.length;
        }
        report.citationCount = citationCount;
        report.citationsReturned = citationCount > 0;
        report.searchCallCount = searchCount;
      } catch (previewError) {
        const pMessage =
          previewError instanceof Error
            ? previewError.message
            : String(previewError);
        report.success = false;
        report.httpOrApiStatus = extractHttpStatus(previewError);
        report.errorCategory = categorize(
          extractHttpStatus(previewError),
          pMessage,
        );
        report.errorMessageSanitized = sanitizeMessage(pMessage);
      }
    }
  }

  writeFileSync(resolve(outDir, "smoke_test.json"), JSON.stringify(report, null, 2));
  console.log(JSON.stringify(report, null, 2));
  process.exit(report.success ? 0 : 1);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
