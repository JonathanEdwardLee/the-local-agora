import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

class JfNumericDisplay extends StatelessWidget {
  const JfNumericDisplay(this.value, {super.key, this.label});

  final String value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: JfTypography.micro),
          const SizedBox(height: JfSpacing.xs),
        ],
        Text(value, style: JfTypography.numericDisplay),
      ],
    );
  }
}
