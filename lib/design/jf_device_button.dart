import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'junkfeathers_tokens.dart';

enum JfButtonVariant { primary, compact, selectable }

/// Square Junkfeathers device button with idle / active / pressed / disabled / locked states.
class JfDeviceButton extends StatefulWidget {
  const JfDeviceButton({
    super.key,
    required this.label,
    this.onPressed,
    this.selected = false,
    this.locked = false,
    this.lockedMessage,
    this.variant = JfButtonVariant.primary,
    this.expanded = true,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final bool locked;
  final String? lockedMessage;
  final JfButtonVariant variant;
  final bool expanded;
  final String? semanticLabel;

  bool get enabled => onPressed != null && !locked;

  @override
  State<JfDeviceButton> createState() => _JfDeviceButtonState();
}

class _JfDeviceButtonState extends State<JfDeviceButton> {
  bool _pressed = false;

  Future<void> _handleTap() async {
    if (widget.locked) {
      final message =
          widget.lockedMessage ?? 'LOCKED — unavailable in this pass.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: JfMotion.toast,
          backgroundColor: JfColors.black,
          shape: Border.all(color: JfColors.white38, width: 2),
          content: Text(
            message,
            style: JfTypography.controlLabel.copyWith(color: JfColors.white38),
          ),
        ),
      );
      return;
    }
    if (!widget.enabled) return;
    setState(() => _pressed = true);
    await Future<void>.delayed(JfMotion.press);
    if (mounted) setState(() => _pressed = false);
    HapticFeedback.selectionClick();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final inverted = widget.selected || _pressed;
    final disabled = !widget.enabled && !widget.locked;
    final locked = widget.locked;

    Color borderColor;
    Color fill;
    Color textColor;
    double borderWidth;

    if (locked || disabled) {
      borderColor = JfColors.white38;
      fill = JfColors.black;
      textColor = JfColors.white38;
      borderWidth = JfBorders.secondary;
    } else if (inverted) {
      borderColor = JfColors.white;
      fill = JfColors.white;
      textColor = JfColors.black;
      borderWidth = widget.variant == JfButtonVariant.primary
          ? JfBorders.major
          : JfBorders.primary;
    } else {
      borderColor = widget.variant == JfButtonVariant.primary
          ? JfColors.white70
          : JfColors.white54;
      fill = JfColors.black;
      textColor = JfColors.white;
      borderWidth = widget.variant == JfButtonVariant.primary
          ? JfBorders.primary
          : JfBorders.secondary;
    }

    final labelStyle = (widget.variant == JfButtonVariant.primary
            ? JfTypography.primaryButton
            : JfTypography.controlLabel)
        .copyWith(color: textColor);

    final child = AnimatedContainer(
      duration: JfMotion.press,
      curve: Curves.linear,
      width: widget.expanded ? double.infinity : null,
      constraints: const BoxConstraints(minHeight: JfControlSizes.minTap),
      padding: EdgeInsets.symmetric(
        horizontal: JfSpacing.md,
        vertical: widget.variant == JfButtonVariant.primary
            ? JfControlSizes.fullWidthVerticalPadding
            : JfSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: JfBorders.square,
      ),
      alignment: Alignment.center,
      child: Text(
        widget.label,
        textAlign: TextAlign.center,
        style: labelStyle,
      ),
    );

    return Semantics(
      button: true,
      enabled: widget.enabled || widget.locked,
      selected: widget.selected,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onHighlightChanged: (v) {
            if (widget.enabled) setState(() => _pressed = v);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}
