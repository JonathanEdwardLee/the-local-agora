import 'package:flutter/material.dart';

import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/agora_event_signal.dart';

/// One chronological signal row in the City Index.
class SignalRecordTile extends StatelessWidget {
  const SignalRecordTile({
    super.key,
    required this.signal,
    required this.onOpen,
  });

  final AgoraEventSignal signal;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: JfColors.black,
            border: Border.all(
              color: JfColors.white70,
              width: JfBorders.primary,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(JfSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  signal.title.toUpperCase(),
                  style: JfTypography.controlLabel.copyWith(fontSize: 12),
                ),
                const SizedBox(height: JfSpacing.xs),
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
                if (signal.summary != null && signal.summary!.isNotEmpty) ...[
                  const SizedBox(height: JfSpacing.xs),
                  Text(
                    signal.summary!,
                    style: JfTypography.supporting.copyWith(fontSize: 10),
                  ),
                ],
                const SizedBox(height: JfSpacing.xs),
                Text(
                  'SOURCE // ${signal.sourceLabel}',
                  style: JfTypography.micro.copyWith(color: JfColors.white54),
                ),
                if (signal.lastCheckedAt != null)
                  Text(
                    'LAST CHECKED // ${_fmt(signal.lastCheckedAt!)}',
                    style: JfTypography.micro.copyWith(color: JfColors.white54),
                  ),
                if (signal.uncertainties.isNotEmpty)
                  Text(
                    signal.uncertainties.join(' // '),
                    style: JfTypography.micro.copyWith(color: JfColors.white70),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _fmt(DateTime d) {
    final l = d.toLocal();
    final y = l.year.toString().padLeft(4, '0');
    final m = l.month.toString().padLeft(2, '0');
    final day = l.day.toString().padLeft(2, '0');
    return '$y.$m.$day';
  }
}
