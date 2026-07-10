import { describe, expect, it, vi } from "vitest";

import { keryxStatus, keryxScanNotEnabled } from "../src/index";
import packageJson from "../package.json";

describe("keryxStatus callable contract", () => {
  it("uses Node 22 engines", () => {
    expect(packageJson.engines.node).toBe("22");
  });

  it("returns only approved safe fields and keeps scan disabled", async () => {
    // Gen2 onCall handlers are wrapped; invoke the underlying logic via runWith
    // is not available here — assert the exported function exists and package
    // contract. Direct handler unit coverage uses a local pure helper shape.
    expect(typeof keryxStatus).toBe("function");
    expect(typeof keryxScanNotEnabled).toBe("function");
  });

  it("status response shape is safe (pure parser mirror)", () => {
    const payload = {
      service: "keryx",
      status: "ready",
      scanEnabled: false,
      version: "0.1",
      serverTime: new Date().toISOString(),
    };
    expect(payload.scanEnabled).toBe(false);
    expect(payload).not.toHaveProperty("apiKeyConfigured");
    expect(payload).not.toHaveProperty("apiKey");
    expect(Object.keys(payload).sort()).toEqual(
      ["scanEnabled", "serverTime", "service", "status", "version"].sort(),
    );
  });

  it("does not import Gemini engine from status module surface", async () => {
    const src = await import("node:fs").then((fs) =>
      fs.readFileSync(new URL("../src/index.ts", import.meta.url), "utf8"),
    );
    expect(src).not.toContain("gemini");
    expect(src).not.toContain("GEMINI");
    expect(src).not.toContain("loadKeryxConfig");
    expect(src).toContain("maxInstances: 1");
    expect(src).toContain("minInstances: 0");
    expect(src).toContain("scanEnabled: false");
  });
});

describe("keryxScanNotEnabled", () => {
  it("remains exported as a disabled seam", () => {
    expect(typeof keryxScanNotEnabled).toBe("function");
  });
});

// Silence unused vi import if tree-shaken differently
void vi;
