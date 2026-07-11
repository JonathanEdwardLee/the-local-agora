import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/junkfeathers_tokens.dart';
import 'agora_welcome_copy.dart';
import 'welcome_suppression_store.dart';

/// Shows the Local Agora Welcome dialog over the current route (not a route itself).
///
/// When [manual] is true, the dialog opens regardless of permanent suppression.
Future<void> showAgoraWelcomeDialog({
  required BuildContext context,
  required WelcomeSuppressionStore store,
  bool manual = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: JfColors.black.withValues(alpha: 0.72),
    builder: (ctx) {
      return AgoraWelcomeDialog(store: store, manual: manual);
    },
  );
}

/// Square OLED Welcome dialog — design-system machine face, not a Material card.
class AgoraWelcomeDialog extends StatelessWidget {
  const AgoraWelcomeDialog({
    super.key,
    required this.store,
    this.manual = false,
  });

  final WelcomeSuppressionStore store;
  final bool manual;

  Future<void> _close(BuildContext context) async {
    Navigator.of(context).pop();
  }

  Future<void> _dontShowAgain(BuildContext context) async {
    await store.setPermanentlyDismissed(true);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.82;

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
                    label: manual
                        ? 'Local Agora welcome manual'
                        : 'Local Agora welcome',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AgoraWelcomeCopy.sectionWelcome,
                          style: JfTypography.controlLabel.copyWith(
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: JfSpacing.sm),
                        Text(
                          AgoraWelcomeCopy.welcomeHeadline,
                          style: JfTypography.deviceTitle.copyWith(
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: JfSpacing.xs),
                        const Text(
                          AgoraWelcomeCopy.welcomeBody,
                          style: JfTypography.supporting,
                        ),
                        const SizedBox(height: JfSpacing.lg),
                        Text(
                          AgoraWelcomeCopy.sectionHelp,
                          style: JfTypography.controlLabel.copyWith(
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: JfSpacing.sm),
                        const Text(
                          AgoraWelcomeCopy.helpBody,
                          style: JfTypography.supporting,
                        ),
                        const SizedBox(height: JfSpacing.lg),
                        Text(
                          AgoraWelcomeCopy.sectionTogether,
                          style: JfTypography.controlLabel.copyWith(
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: JfSpacing.sm),
                        const Text(
                          AgoraWelcomeCopy.togetherBody,
                          style: JfTypography.supporting,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: JfSpacing.lg),
              JfDeviceButton(
                key: const ValueKey('agora-welcome-close'),
                label: AgoraWelcomeCopy.closeLabel,
                semanticLabel: 'Close welcome dialog',
                variant: JfButtonVariant.compact,
                onPressed: () => _close(context),
              ),
              const SizedBox(height: JfSpacing.sm),
              JfDeviceButton(
                key: const ValueKey('agora-welcome-dont-show'),
                label: AgoraWelcomeCopy.dontShowAgainLabel,
                semanticLabel: "Don't show welcome again",
                variant: JfButtonVariant.compact,
                onPressed: () => _dontShowAgain(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
