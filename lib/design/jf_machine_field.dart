import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';
import 'jf_section_label.dart';

/// Square monospaced machine text field.
class JfMachineField extends StatelessWidget {
  const JfMachineField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.onFocusChange,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onFocusChange;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JfSectionLabel(label),
        const SizedBox(height: JfSpacing.xs),
        Focus(
          onFocusChange: onFocusChange,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            style: JfTypography.fieldInput,
            cursorColor: JfColors.white,
            textInputAction: textInputAction ?? TextInputAction.done,
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              errorStyle: JfTypography.warning.copyWith(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
