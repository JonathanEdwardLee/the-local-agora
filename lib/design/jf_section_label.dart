import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

class JfSectionLabel extends StatelessWidget {
  const JfSectionLabel(this.text, {super.key, this.secondary = false});

  final String text;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: JfTypography.controlLabel.copyWith(
        color: secondary ? JfColors.white54 : JfColors.white,
      ),
    );
  }
}
