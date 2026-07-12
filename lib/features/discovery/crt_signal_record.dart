import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_oled_toast.dart';
import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/agora_event_signal.dart';
import '../../services/source_launch.dart';

/// Compact chronological event row for the CRT result index.
class CrtSignalRecord extends StatelessWidget {
  const CrtSignalRecord({super.key, required this.signal});

  final AgoraEventSignal signal;

  Future<void> _checkSource(BuildContext context) async {
    final result = await openOriginalSource(signal.sourceUrl);
    if (!context.mounted) return;
    switch (result) {
      case SourceLaunchResult.opened:
        break;
      case SourceLaunchResult.invalid:
        showJfOledToast(
          context,
          'SOURCE NOT AVAILABLE',
          detail: 'This event has no valid public source URL.',
          warning: true,
        );
      case SourceLaunchResult.failed:
        showJfOledToast(
          context,
          'SOURCE NOT AVAILABLE',
          detail: 'Could not open the public source in an external browser.',
          warning: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSource = signal.hasLaunchableSource;

    return Padding(
      padding: const EdgeInsets.only(bottom: JfSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: JfColors.black,
          border: Border.all(
            color: JfColors.white54,
            width: JfBorders.secondary,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(JfSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                signal.title.toUpperCase(),
                style: JfTypography.controlLabel.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                signal.whenLine,
                style: JfTypography.micro.copyWith(color: JfColors.white70),
              ),
              Text(
                signal.locationLine,
                style: JfTypography.micro.copyWith(color: JfColors.white70),
              ),
              if (signal.category != null)
                Text(
                  'EVENT TYPE // ${signal.category}',
                  style: JfTypography.micro,
                ),
              if (signal.summary != null && signal.summary!.trim().isNotEmpty)
                Text(
                  signal.summary!,
                  style: JfTypography.supporting.copyWith(fontSize: 10),
                ),
              Text(
                hasSource
                    ? 'SOURCE // ${signal.sourceLabel}'
                    : 'SOURCE NOT AVAILABLE',
                style: JfTypography.micro.copyWith(color: JfColors.white54),
              ),
              if (signal.uncertainties.isNotEmpty)
                Text(
                  signal.uncertainties.join(' // '),
                  style: JfTypography.micro.copyWith(color: JfColors.white70),
                ),
              const SizedBox(height: JfSpacing.xs),
              if (hasSource)
                JfDeviceButton(
                  key: ValueKey('crt-check-source-${signal.id}'),
                  label: 'CHECK SOURCE',
                  semanticLabel: 'Check source for ${signal.title}',
                  variant: JfButtonVariant.compact,
                  onPressed: () => _checkSource(context),
                )
              else
                Text(
                  'SOURCE NOT AVAILABLE',
                  key: ValueKey('crt-source-unavailable-${signal.id}'),
                  style: JfTypography.micro.copyWith(color: JfColors.white38),
                ),
              const SizedBox(height: JfSpacing.xs),
              const JfDeviceButton(
                label: 'ADD TO CALENDAR // SOON',
                semanticLabel: 'Add to calendar — coming soon, unavailable',
                variant: JfButtonVariant.compact,
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
