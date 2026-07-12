import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_oled_toast.dart';
import '../../design/jf_panel.dart';
import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/agora_event_signal.dart';
import '../../services/keryx/event_location_privacy.dart';
import '../../services/source_launch.dart';

/// SCREEN 4 — OPEN RECORD (dedicated route).
class OpenRecordScreen extends StatelessWidget {
  const OpenRecordScreen({super.key, required this.signal});

  final AgoraEventSignal signal;

  Future<void> _openSource(BuildContext context) async {
    final result = await openOriginalSource(signal.sourceUrl);
    if (!context.mounted) return;
    switch (result) {
      case SourceLaunchResult.opened:
        break;
      case SourceLaunchResult.invalid:
        showJfOledToast(
          context,
          'SOURCE UNAVAILABLE',
          detail: 'This signal has no valid original source URL.',
          warning: true,
        );
      case SourceLaunchResult.failed:
        showJfOledToast(
          context,
          'SOURCE LAUNCH FAILED',
          detail: 'Could not open the original source in an external browser.',
          warning: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canLaunch =
        signal.sourceUrl.hasScheme &&
        (signal.sourceUrl.isScheme('https') ||
            signal.sourceUrl.isScheme('http'));

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
                      'OPEN RECORD',
                      style: JfTypography.controlLabel.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: JfSpacing.md),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              signal.title.toUpperCase(),
                              style: JfTypography.deviceTitle.copyWith(
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: JfSpacing.md),
                            _line('WHEN', signal.whenLine),
                            _line('LOCATION', signal.locationLine),
                            _line('PRIVACY', signal.privacy.label),
                            if (signal.category != null)
                              _line('TYPE', signal.category!),
                            if (signal.summary != null)
                              _line('SUMMARY', signal.summary!),
                            _line('SOURCE', signal.sourceLabel),
                            if (signal.lastCheckedAt != null)
                              _line(
                                'LAST CHECKED',
                                SignalDateFmt.ymd(signal.lastCheckedAt!),
                              ),
                            if (signal.uncertainties.isNotEmpty) ...[
                              const SizedBox(height: JfSpacing.sm),
                              Text(
                                'UNCERTAINTY',
                                style: JfTypography.controlLabel.copyWith(
                                  color: JfColors.amber,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: JfSpacing.xs),
                              Text(
                                signal.uncertainties.join('\n'),
                                style: JfTypography.supporting.copyWith(
                                  color: JfColors.amber,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: JfSpacing.md),
                    JfDeviceButton(
                      key: const ValueKey('agora-open-source'),
                      label: 'OPEN ORIGINAL SOURCE',
                      semanticLabel: 'Open original source',
                      onPressed: canLaunch ? () => _openSource(context) : null,
                    ),
                    if (!canLaunch) ...[
                      const SizedBox(height: JfSpacing.xs),
                      Text(
                        'SOURCE URL NOT AVAILABLE',
                        style: JfTypography.micro.copyWith(
                          color: JfColors.amber,
                        ),
                      ),
                    ],
                    const SizedBox(height: JfSpacing.sm),
                    JfDeviceButton(
                      key: const ValueKey('agora-record-back'),
                      label: 'BACK TO INDEX',
                      semanticLabel: 'Back to signal index',
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

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: JfSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: JfTypography.micro),
          Text(value, style: JfTypography.supporting),
        ],
      ),
    );
  }
}

abstract final class SignalDateFmt {
  static String ymd(DateTime d) {
    final l = d.toLocal();
    return '${l.year.toString().padLeft(4, '0')}.'
        '${l.month.toString().padLeft(2, '0')}.'
        '${l.day.toString().padLeft(2, '0')}';
  }
}
