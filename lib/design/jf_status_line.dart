import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

enum JfStatusTone { normal, secondary, warning, error }

class JfStatusLine extends StatelessWidget {
  const JfStatusLine(this.text, {super.key, this.tone = JfStatusTone.normal});

  final String text;
  final JfStatusTone tone;

  Color get _color {
    switch (tone) {
      case JfStatusTone.normal:
        return JfColors.white;
      case JfStatusTone.secondary:
        return JfColors.white54;
      case JfStatusTone.warning:
      case JfStatusTone.error:
        return JfColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        text,
        style: JfTypography.micro.copyWith(
          color: _color,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }
}
