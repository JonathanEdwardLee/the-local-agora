/// Permanent Junkfeathers Tech splash timing and identity seam.
///
/// Full animation implementation is deferred until after the core Keryx loop.
/// Logo artwork, procedural geometry, and these timing constants must not change
/// without an explicit founder policy update (ADR-009).
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

  /// App-specific rotating tips may change; logo/geometry/timing may not.
  static const List<String> rotatingTips = <String>[
    'Choose a place. Choose a time. Scan the Agora.',
    'Public signals start the index. The community completes it.',
    'Unknown facts remain unknown. Origins stay visible.',
  ];

  /// Placeholder until approved logo assets and procedural geometry land.
  static const bool animationImplemented = false;
}
