/**
 * Firebase Cloud Functions 2nd generation entrypoints.
 * Pass 02B.2A: status + App Check–protected debug live scan.
 */
import { initializeApp } from "firebase-admin/app";
import { defineSecret } from "firebase-functions/params";
import { setGlobalOptions } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";

import { handleKeryxScanDebug } from "./callables/keryx_scan_debug";

initializeApp();

setGlobalOptions({
  region: "us-central1",
  maxInstances: 10,
});

/** Bound only to keryxScanDebug — never to status or disabled seams. */
const geminiApiKey = defineSecret("GEMINI_API_KEY");

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
 * Placeholder seam for a future public HTTPS callable scan.
 * Intentionally rejects — public live scan is not enabled.
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

/**
 * Debug-only live Keryx two-pass scan. App Check enforced. Secret-bound.
 * Not connected to ordinary SCAN THE AGORA.
 */
export const keryxScanDebug = onCall(
  {
    enforceAppCheck: true,
    secrets: [geminiApiKey],
    region: "us-central1",
    minInstances: 0,
    maxInstances: 1,
    timeoutSeconds: 120,
    memory: "512MiB",
    concurrency: 1,
  },
  async (request) => {
    return handleKeryxScanDebug(request, geminiApiKey.value());
  },
);
