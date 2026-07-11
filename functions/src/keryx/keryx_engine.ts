/**
 * Provider-agnostic Keryx interface.
 * Flutter must never call model providers directly; callable wrappers will use this later.
 */
import type { AgoraEvent } from "../schema/agora_event";
import type { ScanRequest } from "./request_builder";

export type KeryxApiPath =
  | "interactions+google_search"
  | "generateContent+googleSearch"
  | "generateContentStream+googleSearch"
  | "interactions+structured_output"
  | "generateContent+structured_output";

export interface CitationAnnotation {
  title: string | null;
  url: string;
  citedText: string | null;
}

export interface GroundedDiscoveryResult {
  model: string;
  apiPath: KeryxApiPath;
  promptId: string;
  promptVersion: string;
  outputText: string;
  citations: CitationAnnotation[];
  searchQueries: string[];
  rawStepTypes: string[];
  attempts: number;
  usedFallback: boolean;
}

export interface NormalizationOutcome {
  model: string;
  apiPath: KeryxApiPath;
  accepted: AgoraEvent[];
  rejected: Array<{ reason: string; partialTitle: string | null }>;
  invalidStructuredOutputCount: number;
  rawOutputText: string;
  attempts: number;
  usedFallback: boolean;
}

export interface KeryxEngine {
  discoverPublicEvents(request: ScanRequest): Promise<GroundedDiscoveryResult>;
  normalizeGroundedFindings(params: {
    request: ScanRequest;
    discovery: GroundedDiscoveryResult;
  }): Promise<NormalizationOutcome>;
}
