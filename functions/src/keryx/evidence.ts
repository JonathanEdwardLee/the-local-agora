import type { AgoraEvent } from "../schema/agora_event";

/** Drop invalid URLs rather than inventing replacements. */
export function sanitizeEventUrls(event: AgoraEvent): AgoraEvent {
  const isValidUrl = (value: string | null): value is string => {
    if (!value) return false;
    try {
      const parsed = new URL(value);
      return parsed.protocol === "http:" || parsed.protocol === "https:";
    } catch {
      return false;
    }
  };

  const sourceUrls = event.sourceUrls.filter(isValidUrl);
  const sourceUrl = isValidUrl(event.sourceUrl) ? event.sourceUrl : null;
  const ticketUrl = isValidUrl(event.ticketUrl) ? event.ticketUrl : null;
  const infoUrl = isValidUrl(event.infoUrl) ? event.infoUrl : null;

  return {
    ...event,
    sourceUrl,
    sourceUrls:
      sourceUrls.length > 0
        ? sourceUrls
        : sourceUrl
          ? [sourceUrl]
          : [],
    ticketUrl,
    infoUrl,
    sourceEvidence: event.sourceEvidence.map((item) => ({
      ...item,
      sourceUrl: isValidUrl(item.sourceUrl) ? item.sourceUrl : null,
    })),
  };
}
