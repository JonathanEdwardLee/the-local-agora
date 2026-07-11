# Junkfeathers Universal Splash — canonical reference

Founder-supplied canonical implementation reference for Junkfeathers Tech Flutter app startup identity.

**Runtime integration (Local Agora):** `lib/brand/junkfeathers_splash/`  
**Do not** import production code from this `docs/` folder.

## Integration API

`JunkfeathersSplash({
  Widget? destination,
  required List<String> tips,
  VoidCallback? onComplete,
  bool tipsEnabled = true,
  bool? reducedMotionOverride,
  int? deterministicTipIndex,
})`

Local Agora uses `onComplete` via an app-owned `StartupGate` (not `destination` / `Navigator.pushReplacement`).

## Timing

990 ms reveal + 1000 ms hold + 880 ms hide = **2870 ms**

## Tips

Pass app-specific tip display strings into `tips`. Tip lists belong outside this universal component.
