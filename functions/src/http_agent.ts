/**
 * Node 18+ fetch (undici) defaults headersTimeout to ~30s.
 * Grounded Gemini calls often need longer before response headers arrive.
 * Lazy dynamic import so Firebase deploy analysis does not hang on module load.
 */

let installed = false;
let installPromise: Promise<void> | null = null;

export async function ensureLongLivedFetchAgent(): Promise<void> {
  if (installed) return;
  if (installPromise) {
    await installPromise;
    return;
  }
  installPromise = (async () => {
    const { Agent, setGlobalDispatcher } = await import("undici");
    setGlobalDispatcher(
      new Agent({
        headersTimeout: 330_000,
        bodyTimeout: 660_000,
        connectTimeout: 60_000,
      }),
    );
    installed = true;
  })();
  await installPromise;
}
