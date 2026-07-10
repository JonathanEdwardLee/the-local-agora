import type { AgoraEvent } from "../schema/agora_event";
import {
  auditEventEvidence,
  isOutsideWindow,
  isPastRelativeToWindow,
  stripUnsupportedFacts,
  type EventEvidenceAudit,
} from "./audit";
import type {
  GroundedDiscoveryResult,
  KeryxEngine,
  NormalizationOutcome,
} from "./keryx_engine";
import type { ScanRequest } from "./request_builder";

export interface FeasibilityRunResult {
  request: ScanRequest;
  discovery: GroundedDiscoveryResult;
  normalization: NormalizationOutcome;
  audits: EventEvidenceAudit[];
  acceptedAfterAudit: AgoraEvent[];
  rejectedTitles: string[];
  unsupportedAcceptedFacts: number;
  pastExcluded: number;
  outsideWindowExcluded: number;
  duplicateTitleDatePairs: string[];
}

function dedupeKey(event: AgoraEvent): string {
  return [
    event.eventTitle.trim().toLowerCase(),
    event.startDate ?? "unknown-date",
    (event.venueName ?? event.city ?? "").trim().toLowerCase(),
  ].join("|");
}

/**
 * Two-pass feasibility pipeline: discovery → normalization → evidence audit.
 */
export async function runFeasibilityScan(
  engine: KeryxEngine,
  request: ScanRequest,
): Promise<FeasibilityRunResult> {
  const discovery = await engine.discoverPublicEvents(request);
  const normalization = await engine.normalizeGroundedFindings({
    request,
    discovery,
  });

  const audits: EventEvidenceAudit[] = [];
  const acceptedAfterAudit: AgoraEvent[] = [];
  const rejectedTitles: string[] = [];
  let pastExcluded = 0;
  let outsideWindowExcluded = 0;
  let unsupportedAcceptedFacts = 0;

  for (const event of normalization.accepted) {
    if (isPastRelativeToWindow(event, request.windowStartDate)) {
      pastExcluded += 1;
      rejectedTitles.push(`${event.eventTitle} (past)`);
      continue;
    }
    if (
      isOutsideWindow(event, request.windowStartDate, request.windowEndDate)
    ) {
      outsideWindowExcluded += 1;
      rejectedTitles.push(`${event.eventTitle} (outside window)`);
      continue;
    }

    const audit = auditEventEvidence(event, discovery);
    audits.push(audit);

    if (audit.fields.some((f) => f.field === "eventTitle" && f.status === "UNSUPPORTED")) {
      rejectedTitles.push(`${event.eventTitle} (unsupported title)`);
      continue;
    }

    const cleaned = stripUnsupportedFacts(event, audit);
    const reaudit = auditEventEvidence(cleaned, discovery);
    unsupportedAcceptedFacts += reaudit.unsupportedCount;
    if (reaudit.unsupportedCount > 0) {
      rejectedTitles.push(`${event.eventTitle} (residual unsupported facts)`);
      continue;
    }
    acceptedAfterAudit.push(cleaned);
  }

  const seen = new Map<string, number>();
  const duplicateTitleDatePairs: string[] = [];
  for (const event of acceptedAfterAudit) {
    const key = dedupeKey(event);
    const count = (seen.get(key) ?? 0) + 1;
    seen.set(key, count);
    if (count === 2) duplicateTitleDatePairs.push(key);
  }

  return {
    request,
    discovery,
    normalization,
    audits,
    acceptedAfterAudit,
    rejectedTitles,
    unsupportedAcceptedFacts,
    pastExcluded,
    outsideWindowExcluded,
    duplicateTitleDatePairs,
  };
}
