/**
 * Keryx configuration — model names live here, not in Flutter widgets.
 * ADR-006: Pass A uses Interactions API + Google Search; default model gemini-3.5-flash.
 */
export interface KeryxConfig {
  discoveryModel: string;
  normalizationModel: string;
  apiKey: string | undefined;
  modelOverrideReason: string | undefined;
  /**
   * When true, cloud debug path skips Interactions and uses generateContent
   * (streaming when forceStreamDiscovery is also true).
   */
  forceGenerateContentPath?: boolean;
  /** Prefer streaming discovery so idle sockets stay alive during grounding. */
  forceStreamDiscovery?: boolean;
}

export function loadKeryxConfig(
  env: NodeJS.ProcessEnv = process.env,
): KeryxConfig {
  return {
    discoveryModel:
      env.KERYX_DISCOVERY_MODEL?.trim() || "gemini-3.5-flash",
    normalizationModel:
      env.KERYX_NORMALIZATION_MODEL?.trim() || "gemini-3.5-flash",
    apiKey: env.GEMINI_API_KEY?.trim() || undefined,
    modelOverrideReason: env.KERYX_MODEL_OVERRIDE_REASON?.trim() || undefined,
  };
}

export function assertApiKey(config: KeryxConfig): string {
  if (!config.apiKey) {
    throw new Error(
      "GEMINI_API_KEY is not set. Copy functions/.env.example to functions/.env and provide a key.",
    );
  }
  const key = config.apiKey;
  if (key.length < 20) {
    throw new Error(
      "GEMINI_API_KEY is present but too short to be a valid Google AI key.",
    );
  }
  return key;
}
