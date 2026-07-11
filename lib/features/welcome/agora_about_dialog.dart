import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/junkfeathers_tokens.dart';
import 'agora_about_copy.dart';
import 'welcome_suppression_store.dart';

/// Shows the Local Agora About dialog (product info + Welcome startup switch).
Future<void> showAgoraAboutDialog({
  required BuildContext context,
  required WelcomeSuppressionStore store,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: JfColors.black.withValues(alpha: 0.72),
    builder: (ctx) => AgoraAboutDialog(store: store),
  );
}

/// Square OLED About surface — not a Welcome reopen shortcut.
class AgoraAboutDialog extends StatefulWidget {
  const AgoraAboutDialog({super.key, required this.store});

  final WelcomeSuppressionStore store;

  @override
  State<AgoraAboutDialog> createState() => _AgoraAboutDialogState();
}

class _AgoraAboutDialogState extends State<AgoraAboutDialog> {
  bool? _showWelcomeOnStartup;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final show = await widget.store.isShowWelcomeOnStartup();
    if (!mounted) return;
    setState(() => _showWelcomeOnStartup = show);
  }

  Future<void> _setShowWelcome(bool value) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _showWelcomeOnStartup = value;
    });
    await widget.store.setShowWelcomeOnStartup(value);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.82;
    final showWelcome = _showWelcomeOnStartup;

    return Dialog(
      backgroundColor: JfColors.black,
      elevation: 0,
      insetPadding: const EdgeInsets.all(JfSpacing.xl),
      shape: const Border.fromBorderSide(
        BorderSide(color: JfColors.white, width: JfBorders.primary),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 440, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.all(JfSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Semantics(
                    label: 'Local Agora about',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AgoraAboutCopy.productTitle,
                          style: JfTypography.controlLabel.copyWith(
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: JfSpacing.sm),
                        Text(
                          AgoraAboutCopy.tagline,
                          style: JfTypography.deviceTitle.copyWith(
                            fontSize: 16,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: JfSpacing.md),
                        const Text(
                          AgoraAboutCopy.statement,
                          style: JfTypography.supporting,
                        ),
                        const SizedBox(height: JfSpacing.lg),
                        Text(
                          AgoraAboutCopy.showWelcomeOnStartupLabel,
                          style: JfTypography.controlLabel.copyWith(
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: JfSpacing.sm),
                        if (showWelcome == null)
                          const Text('LOADING…', style: JfTypography.micro)
                        else
                          Row(
                            children: [
                              Expanded(
                                child: JfDeviceButton(
                                  key: const ValueKey(
                                    'agora-welcome-startup-on',
                                  ),
                                  label: 'ON',
                                  semanticLabel: 'Show welcome on startup on',
                                  variant: JfButtonVariant.compact,
                                  selected: showWelcome,
                                  onPressed: _busy
                                      ? null
                                      : () => _setShowWelcome(true),
                                ),
                              ),
                              const SizedBox(width: JfSpacing.sm),
                              Expanded(
                                child: JfDeviceButton(
                                  key: const ValueKey(
                                    'agora-welcome-startup-off',
                                  ),
                                  label: 'OFF',
                                  semanticLabel: 'Show welcome on startup off',
                                  variant: JfButtonVariant.compact,
                                  selected: !showWelcome,
                                  onPressed: _busy
                                      ? null
                                      : () => _setShowWelcome(false),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: JfSpacing.lg),
              JfDeviceButton(
                key: const ValueKey('agora-about-close'),
                label: AgoraAboutCopy.closeLabel,
                semanticLabel: 'Close about dialog',
                variant: JfButtonVariant.compact,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
