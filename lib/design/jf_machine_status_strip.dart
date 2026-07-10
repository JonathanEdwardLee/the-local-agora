import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

/// Local Agora machine identity constants (no network).
abstract final class AgoraMachineIdentity {
  static const String model = 'AGORA MK-I';
  static const String versionLabel = 'V0.1.0';
  static const String accessTier = 'FREE';

  /// Compact local date: YYYY.MM.DD
  static String formatLocalDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  static String statusLine({DateTime? now, bool includeDev = false}) {
    final date = formatLocalDate(now ?? DateTime.now());
    final base = '$model  //  $versionLabel  //  $accessTier  //  $date';
    if (includeDev) return '$base  //  DEV';
    return base;
  }
}

/// 01 — compact status / spec strip.
class JfMachineStatusStrip extends StatelessWidget {
  const JfMachineStatusStrip({
    super.key,
    this.now,
    this.forceDevIndicator,
  });

  /// Injectable clock for tests.
  final DateTime? now;

  /// When null, uses [kDebugMode].
  final bool? forceDevIndicator;

  @override
  Widget build(BuildContext context) {
    final showDev = forceDevIndicator ?? kDebugMode;
    final line = AgoraMachineIdentity.statusLine(
      now: now,
      includeDev: showDev,
    );

    return Semantics(
      label: 'Machine status $line',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: JfColors.black,
          border: Border.all(
            color: JfColors.white54,
            width: JfBorders.secondary,
          ),
          borderRadius: JfBorders.square,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: JfSpacing.sm,
            vertical: JfSpacing.sm,
          ),
          child: Text(
            line,
            style: JfTypography.micro.copyWith(
              color: JfColors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
