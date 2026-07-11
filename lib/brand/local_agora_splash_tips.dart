/// Local Agora–specific splash tips (outside the universal Junkfeathers splash).
///
/// Display strings are founder-approved. Identifiers (`tip01`…) are stable keys.
library;

/// Stable tip identifiers for Local Agora splash tips.
abstract final class LocalAgoraSplashTipIds {
  static const tip01 = 'tip01';
  static const tip02 = 'tip02';
  static const tip03 = 'tip03';
  static const tip04 = 'tip04';
  static const tip05 = 'tip05';
  static const tip06 = 'tip06';
  static const tip07 = 'tip07';
  static const tip08 = 'tip08';
}

/// Founder-approved tip copy keyed by [LocalAgoraSplashTipIds].
const Map<String, String> kLocalAgoraSplashTipCopy = {
  LocalAgoraSplashTipIds.tip01: 'CHOOSE A PLACE AND TIME TO SCAN FOR EVENTS.',
  LocalAgoraSplashTipIds.tip02:
      'CHECK THE ORIGINAL SOURCE BEFORE MAKING PLANS.',
  LocalAgoraSplashTipIds.tip03:
      'EVENT DETAILS CAN CHANGE. VERIFY BEFORE YOU GO.',
  LocalAgoraSplashTipIds.tip04: 'MISSING EVENT? HELP YOUR LOCAL SCENE GROW.',
  LocalAgoraSplashTipIds.tip05: 'UPLOAD A FLYER TO QUICKLY ADD EVENT.',
  LocalAgoraSplashTipIds.tip06: 'ADD AN EVENT TO HELP GROW YOUR SCENE.',
  LocalAgoraSplashTipIds.tip07: 'PRIVATE EVENT LOCATIONS SHOULD STAY PRIVATE.',
  LocalAgoraSplashTipIds.tip08: 'FIND YOUR SCENE. GROW YOUR SCENE.',
};

/// Ordered display strings for the universal splash tip picker (one per launch).
const List<String> kLocalAgoraSplashTips = [
  'CHOOSE A PLACE AND TIME TO SCAN FOR EVENTS.',
  'CHECK THE ORIGINAL SOURCE BEFORE MAKING PLANS.',
  'EVENT DETAILS CAN CHANGE. VERIFY BEFORE YOU GO.',
  'MISSING EVENT? HELP YOUR LOCAL SCENE GROW.',
  'UPLOAD A FLYER TO QUICKLY ADD EVENT.',
  'ADD AN EVENT TO HELP GROW YOUR SCENE.',
  'PRIVATE EVENT LOCATIONS SHOULD STAY PRIVATE.',
  'FIND YOUR SCENE. GROW YOUR SCENE.',
];
