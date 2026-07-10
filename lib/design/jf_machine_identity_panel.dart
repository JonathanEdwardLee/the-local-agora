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
}

/// Compact retro numeric date window (calculator / early digital clock).
class JfRetroDateDisplay extends StatelessWidget {
  const JfRetroDateDisplay({super.key, this.now});

  final DateTime? now;

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
          padding: const EdgeInsets.symmetric(
            horizontal: JfSpacing.sm,
            vertical: JfSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'LOCAL DATE',
                style: JfTypography.micro.copyWith(
                  color: JfColors.white54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: JfSpacing.xs),
              Text(
                date,
                style: JfTypography.numericDisplay.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 01 — identity and technical specification module.
class JfMachineIdentityPanel extends StatelessWidget {
  const JfMachineIdentityPanel({
    super.key,
    this.now,
    this.forceDevIndicator,
  });

  final DateTime? now;
  final bool? forceDevIndicator;

  @override
  Widget build(BuildContext context) {
    final showDev = forceDevIndicator ?? kDebugMode;
    final specs = <String>[
      'MODEL // ${AgoraMachineIdentity.model}',
      'VERSION // ${AgoraMachineIdentity.versionLabel}',
      'ACCESS // ${AgoraMachineIdentity.accessTier}',
      'MODE // ${AgoraMachineIdentity.mode}',
      'ENGINE // ${AgoraMachineIdentity.engine}',
      if (showDev) 'STATE // DEV',
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: JfColors.black,
        border: Border.all(color: JfColors.white, width: JfBorders.primary),
        borderRadius: JfBorders.square,
      ),
      child: Padding(
        padding: const EdgeInsets.all(JfSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 340;
            final identity = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AgoraMachineIdentity.productTitle,
                  style: JfTypography.deviceTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: JfSpacing.sm),
                for (final line in specs) ...[
                  Text(
                    line,
                    style: JfTypography.micro.copyWith(
                      color: JfColors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ],
            );

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  identity,
                  const SizedBox(height: JfSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: JfRetroDateDisplay(now: now),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: identity),
                const SizedBox(width: JfSpacing.sm),
                JfRetroDateDisplay(now: now),
              ],
            );
          },
        ),
      ),
    );
  }
}
