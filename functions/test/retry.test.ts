import { describe, expect, it } from "vitest";

import {
  extractHttpStatus,
  isRetryableError,
  withBoundedRetries,
} from "../src/keryx/retry";

describe("retry policy", () => {
  it("does not retry 404", () => {
    expect(isRetryableError(new Error("404 model unavailable"))).toBe(false);
  });

  it("retries 500 high demand", () => {
    expect(
      isRetryableError(
        new Error(
          "500 gemini-3.5-flash is currently experiencing high demand",
        ),
      ),
    ).toBe(true);
  });

  it("extracts status codes from messages", () => {
    expect(extractHttpStatus(new Error("ERROR 429 rate limit"))).toBe(429);
  });

  it("bounds attempts to four", async () => {
    let calls = 0;
    await expect(
      withBoundedRetries(
        "unit",
        async () => {
          calls += 1;
          throw new Error("500 temporary");
        },
        { backoffScheduleMs: [0, 0, 0, 0] },
      ),
    ).rejects.toThrow(/BLOCKED after 4/);
    expect(calls).toBe(4);
  });
});
