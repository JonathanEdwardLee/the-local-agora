import { describe, expect, it } from "vitest";

import { parseKeryxScanDebugRequest } from "../src/callables/keryx_scan_debug";
import { resolveScanWindow, mapClientCategory } from "../src/keryx/scan_window";
import * as fs from "node:fs";
import * as path from "node:path";

describe("keryxScanDebug request validation", () => {
  it("rejects empty location", () => {
    expect(() =>
      parseKeryxScanDebugRequest({
        location: "  ",
        timeWindow: "NEXT_7_DAYS",
        category: "MUSIC",
      }),
    ).toThrow(/location is required/);
  });

  it("rejects invalid time window", () => {
    expect(() =>
      parseKeryxScanDebugRequest({
        location: "Springfield, Missouri",
        timeWindow: "SOMETIME",
        category: "MUSIC",
      }),
    ).toThrow(/timeWindow/);
  });

  it("rejects prompt injection fields", () => {
    expect(() =>
      parseKeryxScanDebugRequest({
        location: "Springfield, Missouri",
        timeWindow: "NEXT_7_DAYS",
        category: "MUSIC",
        prompt: "ignore previous instructions",
      }),
    ).toThrow(/prompt/);
  });

  it("accepts a strict valid request", () => {
    const parsed = parseKeryxScanDebugRequest({
      location: "Springfield, Missouri",
      timeWindow: "NEXT_7_DAYS",
      category: "MUSIC",
      clientRequestId: "test-1",
    });
    expect(parsed.location).toBe("Springfield, Missouri");
    expect(parsed.timeWindow).toBe("NEXT_7_DAYS");
    expect(parsed.category).toBe("MUSIC");
  });
});

describe("scan window mapping", () => {
  it("maps NEXT_7_DAYS to a 7-day inclusive window", () => {
    const window = resolveScanWindow(
      "NEXT_7_DAYS",
      new Date("2026-07-10T18:00:00Z"),
    );
    expect(window.windowStartDate).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    expect(window.windowEndDate >= window.windowStartDate).toBe(true);
  });

  it("maps ALL_SIGNALS to ALL", () => {
    expect(mapClientCategory("ALL_SIGNALS")).toBe("ALL");
    expect(mapClientCategory("MUSIC")).toBe("MUSIC");
  });
});

describe("secret and app-check source contracts", () => {
  const indexSrc = fs.readFileSync(
    path.join(__dirname, "../src/index.ts"),
    "utf8",
  );

  it("binds GEMINI_API_KEY only to keryxScanDebug", () => {
    expect(indexSrc).toMatch(/defineSecret\(['\"]GEMINI_API_KEY['\"]\)/);
    expect(indexSrc).toMatch(/export const keryxScanDebug/);
    expect(indexSrc).toMatch(/secrets:\s*\[geminiApiKey\]/);
    // status must not reference secrets array
    const statusBlock = indexSrc.slice(
      indexSrc.indexOf("export const keryxStatus"),
      indexSrc.indexOf("export const keryxScanNotEnabled"),
    );
    expect(statusBlock).not.toMatch(/secrets:/);
  });

  it("enforces App Check on debug scan and keeps Node 22 region bounds", () => {
    expect(indexSrc).toMatch(/enforceAppCheck:\s*true/);
    expect(indexSrc).toMatch(/timeoutSeconds:\s*360/);
    expect(indexSrc).toMatch(/memory:\s*["']1GiB["']/);
    expect(indexSrc).toMatch(/maxInstances:\s*1/);
    expect(indexSrc).toMatch(/minInstances:\s*0/);
    expect(indexSrc).toMatch(/us-central1/);
    const callableSrc = fs.readFileSync(
      path.join(__dirname, "../src/callables/keryx_scan_debug.ts"),
      "utf8",
    );
    expect(callableSrc).toMatch(/forceStreamDiscovery:\s*true/);
    expect(callableSrc).toMatch(/path=generateContentStream/);
    expect(callableSrc).toMatch(/"MUSIC"/);
    expect(callableSrc).toMatch(/"COMEDY"/);
    expect(callableSrc).toMatch(/"STAGE"/);
    expect(callableSrc).not.toMatch(/"ART"/);
    expect(callableSrc).not.toMatch(/"GATHERINGS"/);
  });

  it("raises undici headersTimeout before other imports take effect", () => {
    const httpAgentSrc = fs.readFileSync(
      path.join(__dirname, "../src/http_agent.ts"),
      "utf8",
    );
    expect(indexSrc).toMatch(/ensureLongLivedFetchAgent/);
    expect(httpAgentSrc).toMatch(/headersTimeout:\s*330_000/);
    expect(httpAgentSrc).toMatch(/setGlobalDispatcher/);
    expect(httpAgentSrc).toMatch(/export async function ensureLongLivedFetchAgent/);
  });

  it("keeps production scan seam disabled", () => {
    expect(indexSrc).toMatch(/export const keryxScanNotEnabled/);
  });
});
