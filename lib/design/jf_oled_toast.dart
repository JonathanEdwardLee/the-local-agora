import 'dart:async';

import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

/// Top-edge OLED toast / transient machine notice.
///
/// Appears below the safe-area inset. Not a bottom SnackBar.
OverlayEntry? _activeToast;
Timer? _activeToastTimer;

void showJfOledToast(
  BuildContext context,
  String message, {
  String? detail,
  bool warning = false,
  Duration? duration,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  dismissJfOledToastForTest();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) {
      final top = MediaQuery.paddingOf(ctx).top + JfSpacing.sm;
      final borderColor = JfColors.white;
      final textColor = JfColors.white;
      final borderWidth = warning ? JfBorders.major : JfBorders.primary;

      return Positioned(
        top: top,
        left: JfSpacing.lg,
        right: JfSpacing.lg,
        child: Semantics(
          liveRegion: true,
          label: detail == null ? message : '$message. $detail',
          child: Material(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: JfColors.black,
                    border: Border.all(color: borderColor, width: borderWidth),
                    borderRadius: JfBorders.square,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: JfSpacing.md,
                      vertical: JfSpacing.sm + 2,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: JfTypography.controlLabel.copyWith(
                            color: textColor,
                            fontSize: 11,
                            letterSpacing: 0.6,
                            height: 1.25,
                          ),
                        ),
                        if (detail != null) ...[
                          const SizedBox(height: JfSpacing.xs),
                          Text(
                            detail,
                            textAlign: TextAlign.center,
                            style: JfTypography.supporting.copyWith(
                              color: JfColors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  _activeToast = entry;
  overlay.insert(entry);

  final hold = duration ?? JfMotion.toast;
  _activeToastTimer = Timer(hold, () {
    if (_activeToast == entry) {
      entry.remove();
      _activeToast = null;
      _activeToastTimer = null;
    }
  });
}

/// Dismiss any active top toast and cancel its timer.
@visibleForTesting
void dismissJfOledToastForTest() {
  _activeToastTimer?.cancel();
  _activeToastTimer = null;
  _activeToast?.remove();
  _activeToast = null;
}
