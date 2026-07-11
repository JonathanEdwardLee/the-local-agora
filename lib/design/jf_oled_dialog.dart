import 'package:flutter/material.dart';

import 'jf_device_button.dart';
import 'junkfeathers_tokens.dart';

/// Square OLED dialog — no rounded Material card shape.
Future<T?> showJfOledDialog<T>({
  required BuildContext context,
  required String title,
  required String body,
  String confirmLabel = 'ACKNOWLEDGE',
  VoidCallback? onConfirm,
  bool validationError = false,
  String? secondaryLabel,
  VoidCallback? onSecondary,
}) {
  final accent =
      validationError ? JfColors.validationPhosphor : JfColors.white;
  final bodyStyle = validationError
      ? JfTypography.validationError
      : JfTypography.supporting;
  final titleStyle = JfTypography.controlLabel.copyWith(
    fontSize: 13,
    color: accent,
  );

  return showDialog<T>(
    context: context,
    barrierColor: JfColors.black.withValues(alpha: 0.72),
    builder: (ctx) {
      return Dialog(
        backgroundColor: JfColors.black,
        elevation: 0,
        insetPadding: const EdgeInsets.all(JfSpacing.xl),
        shape: Border.fromBorderSide(
          BorderSide(color: accent, width: 2),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(JfSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: JfSpacing.sm),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(body, style: bodyStyle),
                  ),
                ),
                const SizedBox(height: JfSpacing.lg),
                if (secondaryLabel != null) ...[
                  JfDeviceButton(
                    label: secondaryLabel,
                    semanticLabel: secondaryLabel,
                    variant: JfButtonVariant.compact,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onSecondary?.call();
                    },
                  ),
                  const SizedBox(height: JfSpacing.sm),
                ],
                JfDeviceButton(
                  label: confirmLabel,
                  semanticLabel: confirmLabel,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onConfirm?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
