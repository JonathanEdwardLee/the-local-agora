/**
 * Bounded retry for transient provider errors only.
 * Max 4 attempts: immediate, ~2s, ~5s, ~10s with jitter.
 * Never retries 400/401/403/404.
 */

export type RetryableStatus = 408 | 429 | 500 | 502 | 503 | 504;

const RETRYABLE = new Set<number>([408, 429, 500, 502, 503, 504]);
const NON_RETRYABLE = new Set<number>([400, 401, 403, 404]);

const BACKOFF_MS = [0, 2000, 5000, 10000];

export interface RetryResult<T> {
  value: T;
  attempts: number;
}

export function extractHttpStatus(error: unknown): number | null {
  if (!error || typeof error !== "object") {
    const message = String(error);
    const match = message.match(/\b(408|429|500|502|503|504|400|401|403|404)\b/);
    return match ? Number(match[1]) : null;
  }

  const record = error as Record<string, unknown>;
  const direct =
    record.status ??
    record.statusCode ??
    record.code ??
    (record.error as Record<string, unknown> | undefined)?.code;
  if (typeof direct === "number") return direct;
  if (typeof direct === "string" && /^\d+$/.test(direct)) return Number(direct);

  const message =
    error instanceof Error ? error.message : JSON.stringify(record);
  const match = message.match(/\b(408|429|500|502|503|504|400|401|403|404)\b/);
  return match ? Number(match[1]) : null;
}

export function isRetryableError(error: unknown): boolean {
  const status = extractHttpStatus(error);
  if (status != null) {
    if (NON_RETRYABLE.has(status)) return false;
    if (RETRYABLE.has(status)) return true;
  }
  const message = error instanceof Error ? error.message : String(error);
  // Capacity language without a clear non-retryable code
  if (/high demand|try again later|RESOURCE_EXHAUSTED|UNAVAILABLE/i.test(message)) {
    if (/\b(400|401|403|404)\b/.test(message)) return false;
    return true;
  }
  return false;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export async function withBoundedRetries<T>(
  label: string,
  fn: () => Promise<T>,
  options?: {
    maxAttempts?: number;
    onRetry?: (info: string) => void;
    /** Test-only override for backoff schedule (ms before attempts 2..n). */
    backoffScheduleMs?: number[];
  },
): Promise<RetryResult<T>> {
  const maxAttempts = options?.maxAttempts ?? 4;
  const schedule = options?.backoffScheduleMs ?? BACKOFF_MS;
  let lastError: unknown;

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      const value = await fn();
      return { value, attempts: attempt };
    } catch (error) {
      lastError = error;
      const status = extractHttpStatus(error);
      const message = error instanceof Error ? error.message : String(error);
      const retryable = isRetryableError(error);

      if (!retryable || attempt === maxAttempts) {
        const blocked = new Error(
          `BLOCKED after ${attempt} attempt(s)` +
            (status != null ? ` status=${status}` : "") +
            `: ${message}`,
        );
        (blocked as Error & { cause?: unknown }).cause = error;
        throw blocked;
      }

      const base = schedule[attempt] ?? schedule[schedule.length - 1] ?? 10000;
      const jitter =
        base === 0 ? 0 : Math.floor(Math.random() * Math.min(500, base * 0.2));
      const waitMs = base + jitter;
      const info =
        `Retryable error in ${label} (attempt ${attempt}/${maxAttempts})` +
        (status != null ? ` status=${status}` : "") +
        `; waiting ~${waitMs}ms`;
      options?.onRetry?.(info);
      await sleep(waitMs);
    }
  }

  throw lastError;
}
