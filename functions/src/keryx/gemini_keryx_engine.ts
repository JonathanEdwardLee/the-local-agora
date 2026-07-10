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

/**
 * Gemini Interactions API implementation of Keryx.
 * Pass A: google_search tool. Pass B: structured output, no search tool.
 */
export class GeminiKeryxEngine implements KeryxEngine {
  private readonly config: KeryxConfig;
  private readonly client: GoogleGenAI;

  constructor(config: KeryxConfig = loadKeryxConfig()) {
    this.config = config;
    const apiKey = assertApiKey(config);
    this.client = new GoogleGenAI({ apiKey });
  }

  async discoverPublicEvents(
    request: ScanRequest,
  ): Promise<GroundedDiscoveryResult> {
    const built = buildDiscoveryPrompt(request);
    const interaction = (await this.client.interactions.create({
      model: this.config.discoveryModel,
      input: built.input,
      tools: [{ type: "google_search" }],
    })) as InteractionLike;

    return {
      model: this.config.discoveryModel,
      promptId: built.promptId,
      promptVersion: built.promptVersion,
      outputText: readOutputText(interaction),
      citations: extractCitations(interaction),
      searchQueries: extractSearchQueries(interaction),
      rawStepTypes: extractStepTypes(interaction),
    };
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

    const interaction = (await this.client.interactions.create({
      model: this.config.normalizationModel,
      input: prompt,
      // No google_search tool — fact-constrained only.
      response_format: {
        type: "text",
        mime_type: "application/json",
        schema: agoraEventJsonSchema,
      },
    })) as InteractionLike;

    const rawOutputText = readOutputText(interaction);
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

    return {
      model: this.config.normalizationModel,
      accepted,
      rejected,
      invalidStructuredOutputCount,
      rawOutputText,
    };
  }
}
