/// Permanent Junkfeathers Tech splash timing and identity seam.
///
/// Runtime animation lives in `lib/brand/junkfeathers_splash/` (canonical
/// universal package integrated in Pass 02C). Logo artwork, procedural
/// geometry, and these timing constants must not change without an explicit
/// founder policy update (ADR-009 / ADR-039).
abstract final class JunkfeathersSplashSpec {
  static const String brandName = 'JUNKFEATHERS TECH';
  static const String productName = 'THE LOCAL AGORA';

  /// Reveal / glitch-in phase.
  static const Duration revealMs = Duration(milliseconds: 990);

  /// Clean full-logo hold.
  static const Duration holdMs = Duration(milliseconds: 1000);

  /// Hide / glitch-out phase.
  static const Duration hideMs = Duration(milliseconds: 880);

  /// Total branded sequence: 990 + 1000 + 880.
  static const Duration totalBrandedSequence = Duration(milliseconds: 2870);

  /// Canonical tip list lives in `local_agora_splash_tips.dart`.
  /// Kept here only as a pointer for older tests / docs cross-refs.
  static const List<String> rotatingTips = <String>[
    'CHOOSE A PLACE AND TIME TO SCAN FOR EVENTS.',
    'CHECK THE ORIGINAL SOURCE BEFORE MAKING PLANS.',
    'EVENT DETAILS CAN CHANGE. VERIFY BEFORE YOU GO.',
    'MISSING EVENT? HELP YOUR LOCAL SCENE GROW.',
    'UPLOAD A FLYER TO QUICKLY ADD EVENT.',
    'ADD AN EVENT TO HELP GROW YOUR SCENE.',
    'PRIVATE EVENT LOCATIONS SHOULD STAY PRIVATE.',
    'FIND YOUR SCENE. GROW YOUR SCENE.',
  ];

  /// Universal splash widget is integrated (Pass 02C).
  static const bool animationImplemented = true;
}
