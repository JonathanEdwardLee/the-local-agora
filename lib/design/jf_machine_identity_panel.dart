import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

/// Local Agora machine identity constants (no network).
abstract final class AgoraMachineIdentity {
  static const String productTitle = 'THE LOCAL AGORA';
  static const String model = 'AGORA MK-I';
  static const String versionLabel = 'V0.1.0';
  static const String accessTier = 'FREE';
  static const String mode = 'LOCAL SIGNAL INDEX';
  static const String engine = 'KERYX';

  static String formatLocalDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  static String compactSpecLine({bool includeDev = false}) {
    final base = '$model // $versionLabel // $accessTier // $engine';
    if (includeDev) return '$base // DEV';
    return base;
  }
}

/// Compact retro numeric date window.
class JfRetroDateDisplay extends StatelessWidget {
  const JfRetroDateDisplay({super.key, this.now, this.compact = true});

  final DateTime? now;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final date = AgoraMachineIdentity.formatLocalDate(now ?? DateTime.now());
    return Semantics(
      label: 'Local date $date',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: JfColors.black,
          border: Border.all(color: JfColors.white, width: JfBorders.primary),
          borderRadius: JfBorders.square,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: JfSpacing.sm,
            vertical: compact ? JfSpacing.xs : JfSpacing.sm,
          ),
          child: Text(
            date,
            style: JfTypography.numericDisplay.copyWith(
              fontSize: compact ? 13 : 16,
              letterSpacing: 1.2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

/// 01 — compact identity plate: title + date on top, specs on bottom.
class JfMachineIdentityPanel extends StatelessWidget {
  const JfMachineIdentityPanel({super.key, this.now, this.forceDevIndicator});

  final DateTime? now;
  final bool? forceDevIndicator;

  /// Approximate content height target for compactness tests.
  static const double compactTargetHeight = 72;

  @override
  Widget build(BuildContext context) {
    final showDev = forceDevIndicator ?? kDebugMode;
    final specs = AgoraMachineIdentity.compactSpecLine(includeDev: showDev);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: JfColors.black,
        border: Border.all(color: JfColors.white, width: JfBorders.primary),
        borderRadius: JfBorders.square,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: JfSpacing.sm,
          vertical: JfSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    AgoraMachineIdentity.productTitle,
                    style: JfTypography.deviceTitle.copyWith(fontSize: 15),
                  ),
                ),
                const SizedBox(width: JfSpacing.sm),
                JfRetroDateDisplay(now: now),
              ],
            ),
            const SizedBox(height: JfSpacing.sm),
            Text(
              specs,
              style: JfTypography.micro.copyWith(
                color: JfColors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 9,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
