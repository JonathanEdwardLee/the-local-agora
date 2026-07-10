/**
 * Provider-agnostic Keryx interface.
 * Flutter must never call model providers directly; callable wrappers will use this later.
 */
import type { AgoraEvent } from "../schema/agora_event";
import type { ScanRequest } from "./request_builder";

export interface CitationAnnotation {
  title: string | null;
  url: string;
  citedText: string | null;
}

export interface GroundedDiscoveryResult {
  model: string;
  promptId: string;
  promptVersion: string;
  outputText: string;
  citations: CitationAnnotation[];
  searchQueries: string[];
  rawStepTypes: string[];
}

export interface NormalizationOutcome {
  model: string;
  accepted: AgoraEvent[];
  rejected: Array<{ reason: string; partialTitle: string | null }>;
  invalidStructuredOutputCount: number;
  rawOutputText: string;
}

export interface KeryxEngine {
  discoverPublicEvents(request: ScanRequest): Promise<GroundedDiscoveryResult>;
  normalizeGroundedFindings(params: {
    request: ScanRequest;
    discovery: GroundedDiscoveryResult;
  }): Promise<NormalizationOutcome>;
}
