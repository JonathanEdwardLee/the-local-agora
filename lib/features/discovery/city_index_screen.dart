import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_panel.dart';
import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/agora_event_signal.dart';
import '../../services/keryx/keryx_service.dart';
import 'open_record_screen.dart';
import 'signal_record_tile.dart';

/// SCREEN 3 — CITY INDEX (chronological Agora results).
class CityIndexScreen extends StatelessWidget {
  const CityIndexScreen({super.key, required this.result, this.empty = false});

  final KeryxScanResult result;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final req = result.request;
    final count = result.signalCount;
    final header = empty
        ? '0 SIGNALS FOUND'
        : '$count SIGNAL${count == 1 ? '' : 'S'} FOUND';

    return Scaffold(
      backgroundColor: JfColors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(JfSpacing.sm),
              child: JfPanel(
                weight: JfPanelWeight.major,
                padding: const EdgeInsets.all(JfSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'CITY INDEX',
                      style: JfTypography.controlLabel.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: JfSpacing.sm),
                    Text(
                      header,
                      style: JfTypography.deviceTitle.copyWith(fontSize: 16),
                    ),
                    Text(
                      req.location.trim().toUpperCase(),
                      style: JfTypography.supporting,
                    ),
                    Text(
                      '${req.timeWindowLabel} // ${req.categoryLabel}',
                      style: JfTypography.micro.copyWith(
                        color: JfColors.white70,
                      ),
                    ),
                    if (result.demoProvenanceBanner != null) ...[
                      const SizedBox(height: JfSpacing.xs),
                      Text(
                        result.demoProvenanceBanner!,
                        style: JfTypography.micro.copyWith(
                          color: JfColors.white54,
                        ),
                      ),
                    ],
                    const SizedBox(height: JfSpacing.md),
                    Expanded(
                      child: empty
                          ? _EmptyBody(supportText: result.supportText)
                          : ListView.separated(
                              itemCount: result.signals.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: JfSpacing.sm),
                              itemBuilder: (context, index) {
                                final signal = result.signals[index];
                                return SignalRecordTile(
                                  key: ValueKey(signal.id),
                                  signal: signal,
                                  onOpen: () => _openRecord(context, signal),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: JfSpacing.md),
                    JfDeviceButton(
                      key: const ValueKey('agora-index-back'),
                      label: 'BACK TO SCAN CONTROL',
                      semanticLabel: 'Back to scan control',
                      variant: JfButtonVariant.compact,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openRecord(BuildContext context, AgoraEventSignal signal) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OpenRecordScreen(signal: signal)),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.supportText});

  final String supportText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'NO SUPPORTED SIGNALS FOUND',
          style: JfTypography.controlLabel.copyWith(fontSize: 12),
        ),
        const SizedBox(height: JfSpacing.sm),
        Text(
          supportText.isEmpty
              ? 'TRY ANOTHER TIME WINDOW OR CATEGORY.\n'
                    'YOU CAN ALSO ADD A PUBLIC EVENT FLYER.'
              : supportText,
          style: JfTypography.supporting,
        ),
      ],
    );
  }
}
