import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/agora_event_signal.dart';

/// Compact chronological signal row for the CRT result index.
class CrtSignalRecord extends StatelessWidget {
  const CrtSignalRecord({
    super.key,
    required this.signal,
    required this.onOpenRecord,
  });

  final AgoraEventSignal signal;
  final VoidCallback onOpenRecord;

  @override
  Widget build(BuildContext context) {
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
                Text('TYPE // ${signal.category}', style: JfTypography.micro),
              Text(
                'SOURCE // ${signal.sourceLabel}',
                style: JfTypography.micro.copyWith(color: JfColors.white54),
              ),
              if (signal.uncertainties.isNotEmpty)
                Text(
                  signal.uncertainties.join(' // '),
                  style: JfTypography.micro.copyWith(color: JfColors.white70),
                ),
              const SizedBox(height: JfSpacing.xs),
              JfDeviceButton(
                key: ValueKey('crt-open-record-${signal.id}'),
                label: 'OPEN RECORD',
                semanticLabel: 'Open record ${signal.title}',
                variant: JfButtonVariant.compact,
                onPressed: onOpenRecord,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
