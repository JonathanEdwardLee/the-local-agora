import { describe, expect, it } from "vitest";

import { assertApiKey, loadKeryxConfig } from "../src/config/keryx_config";

describe("keryx config", () => {
  it("defaults to gemini-3.5-flash", () => {
    const config = loadKeryxConfig({
      GEMINI_API_KEY: "test-key",
    } as NodeJS.ProcessEnv);
    expect(config.discoveryModel).toBe("gemini-3.5-flash");
    expect(config.normalizationModel).toBe("gemini-3.5-flash");
    expect(config.apiKey).toBe("test-key");
  });

  it("allows model override via env", () => {
    const config = loadKeryxConfig({
      GEMINI_API_KEY: "test-key",
      KERYX_DISCOVERY_MODEL: "gemini-2.5-flash",
      KERYX_MODEL_OVERRIDE_REASON: "temporary compatibility test",
    } as NodeJS.ProcessEnv);
    expect(config.discoveryModel).toBe("gemini-2.5-flash");
    expect(config.modelOverrideReason).toBe("temporary compatibility test");
  });

  it("rejects too-short api keys without revealing them", () => {
    expect(() =>
      assertApiKey({
        discoveryModel: "gemini-3.5-flash",
        normalizationModel: "gemini-3.5-flash",
        apiKey: "short",
        modelOverrideReason: undefined,
      }),
    ).toThrow(/too short/);
  });
});
