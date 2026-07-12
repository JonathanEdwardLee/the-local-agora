import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_panel.dart';
import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/keryx_service.dart';
import 'open_record_screen.dart';
import 'signal_record_tile.dart';

/// Legacy full-page City Index — retained for component-gallery / tests only.
/// Pass 03.1 ordinary Scan shows results inside the CRT monitor instead.
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
                    for (final line in result.provenanceLines)
                      Text(
                        line,
                        style: JfTypography.micro.copyWith(
                          color: JfColors.signalGreen,
                        ),
                      ),
                    Text(
                      header,
                      style: JfTypography.deviceTitle.copyWith(fontSize: 16),
                    ),
                    Text(
                      req.location.trim().toUpperCase(),
                      style: JfTypography.micro.copyWith(
                        color: JfColors.white70,
                      ),
                    ),
                    const SizedBox(height: JfSpacing.md),
                    Expanded(
                      child: empty
                          ? Text(
                              result.supportText.isEmpty
                                  ? 'NO SUPPORTED SIGNALS FOUND'
                                  : result.supportText,
                              style: JfTypography.supporting,
                            )
                          : ListView.separated(
                              itemCount: result.signals.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: JfSpacing.sm),
                              itemBuilder: (context, index) {
                                final signal = result.signals[index];
                                return SignalRecordTile(
                                  signal: signal,
                                  onOpen: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            OpenRecordScreen(signal: signal),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: JfSpacing.md),
                    JfDeviceButton(
                      label: 'BACK',
                      semanticLabel: 'Back',
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
}
