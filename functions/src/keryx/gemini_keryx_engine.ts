import { GoogleGenAI } from "@google/genai";

import {
  assertApiKey,
  loadKeryxConfig,
  type KeryxConfig,
} from "../config/keryx_config";
import type {
  CitationAnnotation,
  GroundedDiscoveryResult,
  KeryxEngine,
  NormalizationOutcome,
} from "./keryx_engine";
import {
  buildDiscoveryPrompt,
  buildNormalizationPrompt,
  type ScanRequest,
} from "./request_builder";
import {
  agoraEventJsonSchema,
  NormalizationResultSchema,
  type AgoraEvent,
} from "../schema/agora_event";
import { sanitizeEventUrls } from "./evidence";
import {
  extractHttpStatus,
  isRetryableError,
  withBoundedRetries,
  withTimeout,
} from "./retry";

/** Per-call ceiling so a hung Interactions request cannot burn the full CF timeout. */
const INTERACTIONS_CALL_TIMEOUT_MS = 90_000;
/**
 * Cloud grounded streams can stay quiet ~160s+ before the first chunk
 * (observed on keryxScanDebug). Keep this under the function timeout.
 */
const GENERATE_CONTENT_CALL_TIMEOUT_MS = 210_000;
/** Keep Interactions attempts low so fallback still fits in the CF budget. */
const INTERACTIONS_MAX_ATTEMPTS = 2;
const GENERATE_CONTENT_MAX_ATTEMPTS = 2;
/** Cloud path: allow one capacity retry; diagnostic model is a separate step. */
const CLOUD_GENERATE_CONTENT_MAX_ATTEMPTS = 2;
const CLOUD_CAPACITY_BACKOFF_MS = [0, 8_000, 15_000];
/** Pass 01 approved diagnostic when gemini-3.5-flash is capacity-blocked. */
const CAPACITY_DIAGNOSTIC_MODEL = "gemini-3-flash-preview";

function isCapacityError(error: unknown): boolean {
  const status = extractHttpStatus(error);
  if (status === 503 || status === 429) return true;
  const message = error instanceof Error ? error.message : String(error);
  return /high demand|UNAVAILABLE|RESOURCE_EXHAUSTED|try again later/i.test(
    message,
  );
}

type InteractionLike = {
  output_text?: string;
  outputText?: string;
  steps?: Array<Record<string, unknown>>;
};

function readOutputText(interaction: InteractionLike): string {
  return interaction.output_text ?? interaction.outputText ?? "";
}

function extractCitations(interaction: InteractionLike): CitationAnnotation[] {
  const citations: CitationAnnotation[] = [];
  const steps = interaction.steps ?? [];
  for (const step of steps) {
    if (step.type !== "model_output") continue;
    const content = (step.content as Array<Record<string, unknown>>) ?? [];
    for (const block of content) {
      if (block.type !== "text") continue;
      const text = String(block.text ?? "");
      const annotations =
        (block.annotations as Array<Record<string, unknown>>) ?? [];
      for (const annotation of annotations) {
        if (annotation.type !== "url_citation") continue;
        const url = String(annotation.url ?? "");
        if (!url) continue;
        const start =
          Number(annotation.start_index ?? annotation.startIndex ?? 0) || 0;
        const end =
          Number(annotation.end_index ?? annotation.endIndex ?? start) || start;
        citations.push({
          title: annotation.title ? String(annotation.title) : null,
          url,
          citedText: text.slice(start, end) || null,
        });
      }
    }
  }
  return citations;
}

function extractSearchQueries(interaction: InteractionLike): string[] {
  const queries: string[] = [];
  for (const step of interaction.steps ?? []) {
    if (step.type !== "google_search_call") continue;
    const args = (step.arguments as Record<string, unknown>) ?? {};
    const list = (args.queries as string[]) ?? [];
    for (const q of list) {
      if (q && !queries.includes(q)) queries.push(q);
    }
  }
  return queries;
}

function extractStepTypes(interaction: InteractionLike): string[] {
  return (interaction.steps ?? []).map((step) => String(step.type ?? "unknown"));
}

function citationSummary(citations: CitationAnnotation[]): string {
  if (citations.length === 0) {
    return "(No structured url_citation annotations were returned.)";
  }
  return citations
    .map((c, i) => {
      const title = c.title ?? "untitled";
      const excerpt = c.citedText ? ` — "${c.citedText}"` : "";
      return `${i + 1}. ${title}: ${c.url}${excerpt}`;
    })
    .join("\n");
}

function parseNormalization(rawOutputText: string): {
  accepted: AgoraEvent[];
  rejected: Array<{ reason: string; partialTitle: string | null }>;
  invalidStructuredOutputCount: number;
} {
  let invalidStructuredOutputCount = 0;
  let accepted: AgoraEvent[] = [];
  let rejected: Array<{ reason: string; partialTitle: string | null }> = [];

  try {
    const parsedJson: unknown = JSON.parse(rawOutputText);
    const validated = NormalizationResultSchema.safeParse(parsedJson);
    if (!validated.success) {
      invalidStructuredOutputCount = 1;
      rejected = [
        {
          reason: `Zod validation failed: ${validated.error.message}`,
          partialTitle: null,
        },
      ];
    } else {
      accepted = validated.data.events.map(sanitizeEventUrls);
      rejected = validated.data.rejected;
    }
  } catch (error) {
    invalidStructuredOutputCount = 1;
    rejected = [
      {
        reason: `JSON parse failed: ${error instanceof Error ? error.message : String(error)}`,
        partialTitle: null,
      },
    ];
  }

  return { accepted, rejected, invalidStructuredOutputCount };
}

function extractGenerateContentCitations(
  response: Record<string, unknown>,
): CitationAnnotation[] {
  const citations: CitationAnnotation[] = [];
  const candidates = (response.candidates as Array<Record<string, unknown>>) ?? [];
  for (const candidate of candidates) {
    const grounding = candidate.groundingMetadata as
      | Record<string, unknown>
      | undefined;
    const chunks =
      (grounding?.groundingChunks as Array<Record<string, unknown>>) ?? [];
    for (const chunk of chunks) {
      const web = chunk.web as Record<string, unknown> | undefined;
      const uri = web?.uri ? String(web.uri) : "";
      if (!uri) continue;
      citations.push({
        title: web?.title ? String(web.title) : null,
        url: uri,
        citedText: null,
      });
    }
  }
  return citations;
}

function extractGenerateContentSearchQueries(
  response: Record<string, unknown>,
): string[] {
  const queries: string[] = [];
  const candidates = (response.candidates as Array<Record<string, unknown>>) ?? [];
  for (const candidate of candidates) {
    const grounding = candidate.groundingMetadata as
      | Record<string, unknown>
      | undefined;
    const list = (grounding?.webSearchQueries as string[]) ?? [];
    for (const q of list) {
      if (q && !queries.includes(q)) queries.push(q);
    }
  }
  return queries;
}

function readGenerateContentText(response: Record<string, unknown>): string {
  if (typeof response.text === "string" && response.text.length > 0) {
    return response.text;
  }
  const candidates = (response.candidates as Array<Record<string, unknown>>) ?? [];
  const parts: string[] = [];
  for (const candidate of candidates) {
    const content = candidate.content as Record<string, unknown> | undefined;
    const contentParts = (content?.parts as Array<Record<string, unknown>>) ?? [];
    for (const part of contentParts) {
      if (typeof part.text === "string") parts.push(part.text);
    }
  }
  return parts.join("\n");
}

/**
 * Gemini Keryx engine.
 * Preferred path: Interactions API + google_search.
 * Temporary fallback: generateContent + googleSearch (capacity failures only).
 */
export class GeminiKeryxEngine implements KeryxEngine {
  private readonly config: KeryxConfig;
  private readonly client: GoogleGenAI;
  /** Set when discovery had to use generateContent fallback; normalization may follow. */
  private discoveryUsedFallback = false;

  constructor(config: KeryxConfig = loadKeryxConfig()) {
    this.config = config;
    const apiKey = assertApiKey(config);
    this.client = new GoogleGenAI({
      apiKey,
      // Must exceed worst-case first-chunk wait for grounded streams from CF.
      httpOptions: { timeout: 300_000 },
    });
  }

  private async discoverViaInteractions(
    input: string,
    model: string,
  ): Promise<Omit<GroundedDiscoveryResult, "promptId" | "promptVersion" | "attempts" | "usedFallback">> {
    const interaction = (await withTimeout(
      this.client.interactions.create({
        model,
        input,
        tools: [{ type: "google_search" }],
        store: false,
      }) as Promise<InteractionLike>,
      INTERACTIONS_CALL_TIMEOUT_MS,
      "discovery:interactions",
    ));

    return {
      model,
      apiPath: "interactions+google_search",
      outputText: readOutputText(interaction),
      citations: extractCitations(interaction),
      searchQueries: extractSearchQueries(interaction),
      rawStepTypes: extractStepTypes(interaction),
    };
  }

  private async discoverViaGenerateContentStream(
    input: string,
    model: string,
  ): Promise<Omit<GroundedDiscoveryResult, "promptId" | "promptVersion" | "attempts" | "usedFallback">> {
    const started = Date.now();
    const run = async () => {
      const stream = await this.client.models.generateContentStream({
        model,
        contents: input,
        config: {
          tools: [{ googleSearch: {} }],
        },
      });

      let outputText = "";
      let chunkCount = 0;
      let lastChunk: Record<string, unknown> = {};

      for await (const chunk of stream) {
        chunkCount += 1;
        const rec = chunk as unknown as Record<string, unknown>;
        lastChunk = rec;
        if (typeof rec.text === "string" && rec.text.length > 0) {
          outputText += rec.text;
        }
        if (chunkCount === 1) {
          console.info(
            `keryx discovery stream: first chunk after ${Date.now() - started}ms`,
          );
        } else if (chunkCount % 8 === 0) {
          console.info(
            `keryx discovery stream: chunk=${chunkCount} textLen=${outputText.length} elapsedMs=${Date.now() - started}`,
          );
        }
      }

      if (!outputText) {
        outputText = readGenerateContentText(lastChunk);
      }

      console.info(
        `keryx discovery stream: done chunks=${chunkCount} textLen=${outputText.length} elapsedMs=${Date.now() - started}`,
      );

      return {
        model,
        apiPath: "generateContentStream+googleSearch" as const,
        outputText,
        citations: extractGenerateContentCitations(lastChunk),
        searchQueries: extractGenerateContentSearchQueries(lastChunk),
        rawStepTypes: ["generateContentStream", `chunks:${chunkCount}`],
      };
    };

    return withTimeout(
      run(),
      GENERATE_CONTENT_CALL_TIMEOUT_MS,
      "discovery:generateContentStream",
    );
  }

  async discoverPublicEvents(
    request: ScanRequest,
  ): Promise<GroundedDiscoveryResult> {
    const built = buildDiscoveryPrompt(request);
    const model = this.config.discoveryModel;
    const useGenerateContentPath =
      this.config.forceGenerateContentPath === true ||
      this.config.forceStreamDiscovery === true;

    if (useGenerateContentPath) {
      console.info(
        `keryx discovery: generateContentStream cloud path prompt=${built.promptVersion} model=${model}`,
      );
      try {
        const retried = await withBoundedRetries(
          "discovery:generateContentStream",
          () => this.discoverViaGenerateContentStream(built.input, model),
          {
            maxAttempts: CLOUD_GENERATE_CONTENT_MAX_ATTEMPTS,
            backoffScheduleMs: CLOUD_CAPACITY_BACKOFF_MS,
            onRetry: (info) => console.warn(info),
          },
        );
        this.discoveryUsedFallback = true;
        console.info(
          `keryx discovery: stream ok attempts=${retried.attempts} model=${model}`,
        );
        return {
          ...retried.value,
          promptId: built.promptId,
          promptVersion: built.promptVersion,
          attempts: retried.attempts,
          usedFallback: true,
        };
      } catch (primaryError) {
        if (!isCapacityError(primaryError)) {
          throw primaryError;
        }
        console.warn(
          `keryx discovery: ${model} capacity-blocked; trying diagnostic ${CAPACITY_DIAGNOSTIC_MODEL}`,
        );
        const diagnostic = await withBoundedRetries(
          "discovery:generateContentStream:diagnostic",
          () =>
            this.discoverViaGenerateContentStream(
              built.input,
              CAPACITY_DIAGNOSTIC_MODEL,
            ),
          {
            maxAttempts: 1,
            onRetry: (info) => console.warn(info),
          },
        );
        this.discoveryUsedFallback = true;
        console.info(
          `keryx discovery: diagnostic stream ok model=${CAPACITY_DIAGNOSTIC_MODEL}`,
        );
        return {
          ...diagnostic.value,
          model: CAPACITY_DIAGNOSTIC_MODEL,
          promptId: built.promptId,
          promptVersion: built.promptVersion,
          attempts: diagnostic.attempts,
          usedFallback: true,
        };
      }
    }

    try {
      console.info("keryx discovery: interactions start");
      const retried = await withBoundedRetries(
        "discovery:interactions",
        () => this.discoverViaInteractions(built.input, model),
        {
          maxAttempts: INTERACTIONS_MAX_ATTEMPTS,
          onRetry: (info) => console.warn(info),
        },
      );
      this.discoveryUsedFallback = false;
      console.info(
        `keryx discovery: interactions ok attempts=${retried.attempts}`,
      );
      return {
        ...retried.value,
        promptId: built.promptId,
        promptVersion: built.promptVersion,
        attempts: retried.attempts,
        usedFallback: false,
      };
    } catch (interactionsError) {
      const status = extractHttpStatus(interactionsError);
      if (status != null && [400, 401, 403, 404].includes(status)) {
        throw interactionsError;
      }

      // Capacity / hang / transient exhaustion of Interactions → generateContent fallback
      console.warn(
        "Interactions discovery blocked by transient/capacity/timeout; trying generateContentStream fallback.",
      );
      const retried = await withBoundedRetries(
        "discovery:generateContentStream",
        () => this.discoverViaGenerateContentStream(built.input, model),
        {
          maxAttempts: GENERATE_CONTENT_MAX_ATTEMPTS,
          onRetry: (info) => console.warn(info),
        },
      );
      this.discoveryUsedFallback = true;
      console.info(
        `keryx discovery: stream fallback ok attempts=${retried.attempts}`,
      );
      return {
        ...retried.value,
        promptId: built.promptId,
        promptVersion: built.promptVersion,
        attempts: retried.attempts,
        usedFallback: true,
      };
    }
  }

  private async normalizeViaInteractions(
    prompt: string,
    model: string,
  ): Promise<{ rawOutputText: string }> {
    const interaction = (await withTimeout(
      this.client.interactions.create({
        model,
        input: prompt,
        store: false,
        response_format: {
          type: "text",
          mime_type: "application/json",
          schema: agoraEventJsonSchema,
        },
      }) as Promise<InteractionLike>,
      INTERACTIONS_CALL_TIMEOUT_MS,
      "normalization:interactions",
    ));
    return { rawOutputText: readOutputText(interaction) };
  }

  private async normalizeViaGenerateContent(
    prompt: string,
    model: string,
  ): Promise<{ rawOutputText: string }> {
    const response = (await withTimeout(
      this.client.models.generateContent({
        model,
        contents: prompt,
        config: {
          responseMimeType: "application/json",
          responseJsonSchema: agoraEventJsonSchema,
        },
      }) as Promise<unknown>,
      GENERATE_CONTENT_CALL_TIMEOUT_MS,
      "normalization:generateContent",
    )) as Record<string, unknown>;
    return { rawOutputText: readGenerateContentText(response) };
  }

  async normalizeGroundedFindings(params: {
    request: ScanRequest;
    discovery: GroundedDiscoveryResult;
  }): Promise<NormalizationOutcome> {
    const verifiedAtIso = new Date().toISOString();
    const prompt = buildNormalizationPrompt({
      request: params.request,
      groundedFindingsText: params.discovery.outputText,
      citationSummary: citationSummary(params.discovery.citations),
      verifiedAtIso,
    });
    const model = this.config.normalizationModel;
    const preferFallback =
      this.discoveryUsedFallback || params.discovery.usedFallback;

    if (!preferFallback) {
      try {
        console.info("keryx normalization: interactions start");
        const retried = await withBoundedRetries(
          "normalization:interactions",
          () => this.normalizeViaInteractions(prompt, model),
          {
            maxAttempts: INTERACTIONS_MAX_ATTEMPTS,
            onRetry: (info) => console.warn(info),
          },
        );
        const parsed = parseNormalization(retried.value.rawOutputText);
        console.info(
          `keryx normalization: interactions ok attempts=${retried.attempts}`,
        );
        return {
          model,
          apiPath: "interactions+structured_output",
          ...parsed,
          rawOutputText: retried.value.rawOutputText,
          attempts: retried.attempts,
          usedFallback: false,
        };
      } catch (error) {
        if (!isRetryableError(error) && !/BLOCKED after/i.test(String(error))) {
          const status = extractHttpStatus(error);
          if (status != null && [400, 401, 403, 404].includes(status)) {
            throw error;
          }
        }
        console.warn(
          "Interactions normalization blocked; trying generateContent structured fallback.",
        );
      }
    }

    console.info("keryx normalization: generateContent start");
    const retried = await withBoundedRetries(
      "normalization:generateContent",
      () => this.normalizeViaGenerateContent(prompt, model),
      {
        maxAttempts: this.config.forceGenerateContentPath
          ? CLOUD_GENERATE_CONTENT_MAX_ATTEMPTS
          : GENERATE_CONTENT_MAX_ATTEMPTS,
        onRetry: (info) => console.warn(info),
      },
    );
    const parsed = parseNormalization(retried.value.rawOutputText);
    console.info(
      `keryx normalization: generateContent ok attempts=${retried.attempts}`,
    );
    return {
      model,
      apiPath: "generateContent+structured_output",
      ...parsed,
      rawOutputText: retried.value.rawOutputText,
      attempts: retried.attempts,
      usedFallback: true,
    };
  }
}
