/**
 * Firebase Cloud Functions 2nd generation entrypoints.
 * Pass 01 establishes the workspace and Keryx modules.
 * HTTPS callable wrappers for Flutter arrive in a later pass — no production deploy here.
 */
import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { loadKeryxConfig } from "./config/keryx_config";

initializeApp();

setGlobalOptions({
  region: "us-central1",
  maxInstances: 10,
});

/**
 * Health/status callable for wiring checks only.
 * Does not invoke Gemini or expose secrets.
 */
export const keryxStatus = onCall({ enforceAppCheck: false }, () => {
  const config = loadKeryxConfig();
  return {
    product: "The Local Agora",
    engine: "Keryx",
    pass: "01",
    discoveryModelConfigured: Boolean(config.discoveryModel),
    normalizationModelConfigured: Boolean(config.normalizationModel),
    apiKeyConfigured: Boolean(config.apiKey),
    modelOverrideReason: config.modelOverrideReason ?? null,
    note: "Live scan callables are not exposed in Pass 01 foundation.",
  };
});

/**
 * Placeholder seam for a future HTTPS callable scan.
 * Intentionally rejects until Pass 02+ wires auth, App Check, and quotas.
 */
export const keryxScanNotEnabled = onCall({ enforceAppCheck: false }, () => {
  throw new HttpsError(
    "failed-precondition",
    "Keryx scan callable is not enabled in Pass 01. Use the local spike script.",
  );
});
