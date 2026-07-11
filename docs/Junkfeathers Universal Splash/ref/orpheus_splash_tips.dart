import 'dart:math';

/// One splash tip per app launch — expand [kOrpheusSplashTips] as needed.
const List<String> kOrpheusSplashTips = [
  'USE WIRED HEADPHONES FOR BEST OVERDUBS',
  'RUN LATENCY TEST BEFORE SERIOUS RECORDING',
  'USB HEADPHONES + PHONE MIC = CLEAN OVERDUBS',
  'ADJUST LATENCY IN SETTINGS IF LAYERS LOOK MISALIGNED',
  'TAP BPM TO ENTER AN EXACT TEMPO',
  'LONG-PRESS CLICK FOR SETTINGS',
  'LONG-PRESS BEAT DOTS FOR CLICK VOL',
  'CLICK VOL CAN BE MUTED WHILE DOTS STAY VISUAL',
  'EXPORT RAW MIX FOR UNPROCESSED AUDIO',
  'EXPORT MASTERMIX FOR A LOUDER SHAREABLE WAV',
  'SOLO A TRACK BEFORE EXPORTING ONLY THAT PART',
  'LONG-PRESS TRACK TITLE FOR TRACK OPTIONS',
  'RENAME TRACKS FROM TRACK OPTIONS',
];

/// Picks a stable tip for this process (one per app launch).
String pickOrpheusSplashTipForLaunch() {
  if (kOrpheusSplashTips.isEmpty) {
    return '';
  }
  return kOrpheusSplashTips[Random().nextInt(kOrpheusSplashTips.length)];
}
