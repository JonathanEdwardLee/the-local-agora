/**
 * Keryx configuration — model names live here, not in Flutter widgets.
 * ADR-006: Pass A uses Interactions API + Google Search; default model gemini-3.5-flash.
 */
export interface KeryxConfig {
  discoveryModel: string;
  normalizationModel: string;
  apiKey: string | undefined;
  modelOverrideReason: string | undefined;
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
  return config.apiKey;
}
