import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

/// Short OLED-style toast / notice panel.
void showJfOledToast(
  BuildContext context,
  String message, {
  bool warning = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: JfMotion.toast,
      backgroundColor: JfColors.black,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(JfSpacing.lg),
      elevation: 0,
      shape: Border.all(
        color: warning ? JfColors.amber : JfColors.white,
        width: 2,
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: JfTypography.controlLabel.copyWith(
              color: warning ? JfColors.amber : JfColors.white,
              fontSize: 11,
              letterSpacing: 0.6,
              height: 1.25,
            ),
          ),
        ),
      ),
    ),
  );
}
