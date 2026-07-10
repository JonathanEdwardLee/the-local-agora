import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';
import 'jf_device_button.dart';

/// Square OLED dialog — no rounded Material card shape.
Future<T?> showJfOledDialog<T>({
  required BuildContext context,
  required String title,
  required String body,
  String confirmLabel = 'ACKNOWLEDGE',
  VoidCallback? onConfirm,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: JfColors.black.withValues(alpha: 0.72),
    builder: (ctx) {
      return Dialog(
        backgroundColor: JfColors.black,
        elevation: 0,
        insetPadding: const EdgeInsets.all(JfSpacing.xl),
        shape: const Border.fromBorderSide(
          BorderSide(color: JfColors.white, width: 2),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(JfSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: JfTypography.controlLabel.copyWith(fontSize: 13)),
                const SizedBox(height: JfSpacing.sm),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(body, style: JfTypography.supporting),
                  ),
                ),
                const SizedBox(height: JfSpacing.lg),
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
