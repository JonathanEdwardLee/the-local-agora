/**
 * Firebase Cloud Functions 2nd generation entrypoints.
 * Pass 02B.1: status callable only — no Gemini, no live scan.
 */
import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

initializeApp();

setGlobalOptions({
  region: "us-central1",
  maxInstances: 10,
});

/**
 * Health/status callable for Flutter ↔ Firebase wiring checks.
 * Does not invoke Gemini, require secrets, or enable scanning.
 */
export const keryxStatus = onCall(
  {
    enforceAppCheck: false,
    region: "us-central1",
    minInstances: 0,
    maxInstances: 1,
    timeoutSeconds: 15,
    memory: "256MiB",
  },
  () => {
    return {
      service: "keryx",
      status: "ready",
      scanEnabled: false,
      version: "0.1",
      serverTime: new Date().toISOString(),
    };
  },
);

/**
 * Placeholder seam for a future HTTPS callable scan.
 * Intentionally rejects — live scan is not enabled in Pass 02B.1.
 */
export const keryxScanNotEnabled = onCall(
  {
    enforceAppCheck: false,
    region: "us-central1",
    minInstances: 0,
    maxInstances: 1,
    timeoutSeconds: 10,
    memory: "256MiB",
  },
  () => {
    throw new HttpsError(
      "failed-precondition",
      "Keryx scan callable is not enabled. Live scanning arrives in a later governed pass.",
    );
  },
);
