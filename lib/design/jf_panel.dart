import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

enum JfPanelWeight { major, primary, secondary }

/// Square outlined Junkfeathers panel.
class JfPanel extends StatelessWidget {
  const JfPanel({
    super.key,
    required this.child,
    this.weight = JfPanelWeight.primary,
    this.padding = const EdgeInsets.all(JfSpacing.md),
    this.borderColor,
  });

  final Widget child;
  final JfPanelWeight weight;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  double get _width {
    switch (weight) {
      case JfPanelWeight.major:
        return JfBorders.major;
      case JfPanelWeight.primary:
        return JfBorders.primary;
      case JfPanelWeight.secondary:
        return JfBorders.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: JfColors.black,
        border: Border.all(color: borderColor ?? JfColors.white, width: _width),
        borderRadius: JfBorders.square,
      ),
      child: child,
    );
  }
}
