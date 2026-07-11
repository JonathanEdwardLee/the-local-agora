import 'package:flutter/material.dart';

import '../features/scan_control/scan_control_state.dart';
import 'jf_device_button.dart';
import 'jf_dial_selector.dart';
import 'jf_machine_field.dart';
import 'junkfeathers_tokens.dart';

/// Machine-style Search Parameter dialog — location + WHEN + WHAT.
Future<void> showJfSearchParameterDialog({
  required BuildContext context,
  required TextEditingController locationController,
  FocusNode? locationFocus,
  required TimeWindow timeWindow,
  required EventCategory category,
  required ValueChanged<String> onLocationChanged,
  required ValueChanged<TimeWindow> onTimeChanged,
  required ValueChanged<EventCategory> onCategoryChanged,
  String? locationError,
  ValueChanged<bool>? onFocusChange,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: JfColors.black.withValues(alpha: 0.72),
    builder: (ctx) {
      return _JfSearchParameterDialogBody(
        locationController: locationController,
        locationFocus: locationFocus,
        timeWindow: timeWindow,
        category: category,
        onLocationChanged: onLocationChanged,
        onTimeChanged: onTimeChanged,
        onCategoryChanged: onCategoryChanged,
        locationError: locationError,
        onFocusChange: onFocusChange,
      );
    },
  );
}

class _JfSearchParameterDialogBody extends StatefulWidget {
  const _JfSearchParameterDialogBody({
    required this.locationController,
    required this.timeWindow,
    required this.category,
    required this.onLocationChanged,
    required this.onTimeChanged,
    required this.onCategoryChanged,
    this.locationFocus,
    this.locationError,
    this.onFocusChange,
  });

  final TextEditingController locationController;
  final FocusNode? locationFocus;
  final TimeWindow timeWindow;
  final EventCategory category;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<TimeWindow> onTimeChanged;
  final ValueChanged<EventCategory> onCategoryChanged;
  final String? locationError;
  final ValueChanged<bool>? onFocusChange;

  @override
  State<_JfSearchParameterDialogBody> createState() =>
      _JfSearchParameterDialogBodyState();
}

class _JfSearchParameterDialogBodyState
    extends State<_JfSearchParameterDialogBody> {
  late TimeWindow _when;
  late EventCategory _what;
  String? _error;

  @override
  void initState() {
    super.initState();
    _when = widget.timeWindow;
    _what = widget.category;
    _error = widget.locationError;
  }

  @override
  void didUpdateWidget(covariant _JfSearchParameterDialogBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locationError != widget.locationError) {
      _error = widget.locationError;
    }
    if (oldWidget.timeWindow != widget.timeWindow) {
      _when = widget.timeWindow;
    }
    if (oldWidget.category != widget.category) {
      _what = widget.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.86;

    return Dialog(
      backgroundColor: JfColors.black,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: JfSpacing.lg,
        vertical: JfSpacing.md,
      ),
      shape: const Border.fromBorderSide(
        BorderSide(color: JfColors.white, width: 2),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            JfSpacing.lg,
            JfSpacing.lg,
            JfSpacing.lg,
            JfSpacing.lg + bottomInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SEARCH PARAMETERS',
                style: JfTypography.controlLabel.copyWith(fontSize: 13),
              ),
              const SizedBox(height: JfSpacing.sm),
              const Text(
                'Choose a city or ZIP code, then set WHEN and WHAT.',
                style: JfTypography.supporting,
              ),
              const SizedBox(height: JfSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      JfMachineField(
                        key: const ValueKey('jf-param-location'),
                        label: 'CITY OR ZIP CODE',
                        controller: widget.locationController,
                        focusNode: widget.locationFocus,
                        hintText: 'Springfield, Missouri',
                        errorText: _error,
                        onChanged: (value) {
                          setState(() => _error = null);
                          widget.onLocationChanged(value);
                        },
                        onFocusChange: widget.onFocusChange,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: JfSpacing.md),
                      JfDialSelector<TimeWindow>(
                        key: const ValueKey('jf-when-dial'),
                        label: 'WHEN',
                        values: TimeWindow.values,
                        value: _when,
                        labelOf: (v) => v.label,
                        onChanged: (v) {
                          setState(() => _when = v);
                          widget.onTimeChanged(v);
                        },
                        semanticPrefix: 'When',
                      ),
                      const SizedBox(height: JfSpacing.md),
                      JfDialSelector<EventCategory>(
                        key: const ValueKey('jf-what-dial'),
                        label: 'WHAT',
                        values: EventCategory.values,
                        value: _what,
                        labelOf: (v) => v.label,
                        onChanged: (v) {
                          setState(() => _what = v);
                          widget.onCategoryChanged(v);
                        },
                        semanticPrefix: 'What',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: JfSpacing.lg),
              JfDeviceButton(
                key: const ValueKey('jf-param-close'),
                label: 'CLOSE',
                semanticLabel: 'Close search parameters',
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
