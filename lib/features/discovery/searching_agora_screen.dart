import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_panel.dart';
import '../../design/junkfeathers_tokens.dart';

/// Short searching surface shown while DemoKeryxService runs.
class SearchingAgoraScreen extends StatelessWidget {
  const SearchingAgoraScreen({
    super.key,
    required this.location,
    required this.windowLabel,
    required this.categoryLabel,
    this.statusLines = const [
      'KERYX IS SCANNING PUBLIC SIGNALS',
      'CHECKING SOURCES',
      'READING EVENT DETAILS',
      'SORTING SIGNALS',
    ],
  });

  final String location;
  final String windowLabel;
  final String categoryLabel;
  final List<String> statusLines;

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(JfSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'INDEXING',
                      style: JfTypography.controlLabel.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: JfSpacing.md),
                    Text(
                      location.toUpperCase(),
                      style: JfTypography.supporting,
                    ),
                    Text(
                      '$windowLabel // $categoryLabel',
                      style: JfTypography.micro,
                    ),
                    const SizedBox(height: JfSpacing.lg),
                    for (final line in statusLines) ...[
                      Text(line, style: JfTypography.controlLabel),
                      const SizedBox(height: JfSpacing.sm),
                    ],
                    const SizedBox(height: JfSpacing.md),
                    Text(
                      'THIS PASS DOES NOT PROMISE COMPLETE COVERAGE.',
                      style: JfTypography.micro.copyWith(
                        color: JfColors.white54,
                      ),
                    ),
                    const SizedBox(height: JfSpacing.lg),
                    JfDeviceButton(
                      key: const ValueKey('agora-search-cancel'),
                      label: 'RETURN TO SCAN CONTROL',
                      semanticLabel: 'Return to scan control',
                      variant: JfButtonVariant.compact,
                      onPressed: () => Navigator.of(context).maybePop(),
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
