import 'package:flutter/material.dart';

import '../features/scan_control/scan_control_state.dart';
import 'jf_device_button.dart';
import 'jf_machine_field.dart';
import 'junkfeathers_tokens.dart';

/// Result of the Pass 03.2 search overlay.
enum SearchOverlayAction { cancelled, scan }

class SearchOverlayResult {
  const SearchOverlayResult({
    required this.action,
    this.location = '',
    this.timeWindow,
    this.category,
  });

  final SearchOverlayAction action;
  final String location;
  final TimeWindow? timeWindow;
  final EventCategory? category;
}

/// Modal search overlay — LOCATION + TIME FRAME + EVENT TYPE.
Future<SearchOverlayResult?> showJfSearchParameterDialog({
  required BuildContext context,
  required TextEditingController locationController,
  FocusNode? locationFocus,
  TimeWindow? timeWindow,
  EventCategory? category,
  String? locationError,
  String? timeWindowError,
  String? categoryError,
  ValueChanged<bool>? onFocusChange,
}) {
  return showDialog<SearchOverlayResult>(
    context: context,
    barrierDismissible: false,
    barrierColor: JfColors.black.withValues(alpha: 0.72),
    builder: (ctx) {
      return _JfSearchParameterDialogBody(
        locationController: locationController,
        locationFocus: locationFocus,
        timeWindow: timeWindow,
        category: category,
        locationError: locationError,
        timeWindowError: timeWindowError,
        categoryError: categoryError,
        onFocusChange: onFocusChange,
      );
    },
  );
}

class _JfSearchParameterDialogBody extends StatefulWidget {
  const _JfSearchParameterDialogBody({
    required this.locationController,
    this.locationFocus,
    this.timeWindow,
    this.category,
    this.locationError,
    this.timeWindowError,
    this.categoryError,
    this.onFocusChange,
  });

  final TextEditingController locationController;
  final FocusNode? locationFocus;
  final TimeWindow? timeWindow;
  final EventCategory? category;
  final String? locationError;
  final String? timeWindowError;
  final String? categoryError;
  final ValueChanged<bool>? onFocusChange;

  @override
  State<_JfSearchParameterDialogBody> createState() =>
      _JfSearchParameterDialogBodyState();
}

class _JfSearchParameterDialogBodyState
    extends State<_JfSearchParameterDialogBody> {
  TimeWindow? _when;
  EventCategory? _what;
  String? _locationError;
  String? _timeError;
  String? _typeError;
  late final ScrollController _scrollController;
  final GlobalKey _locationFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _when = widget.timeWindow;
    _what = widget.category;
    _locationError = widget.locationError;
    _timeError = widget.timeWindowError;
    _typeError = widget.categoryError;
    _scrollController = ScrollController();
    widget.locationFocus?.addListener(_onLocationFocusChanged);
  }

  @override
  void dispose() {
    widget.locationFocus?.removeListener(_onLocationFocusChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onLocationFocusChanged() {
    if (widget.locationFocus?.hasFocus ?? false) {
      _ensureLocationVisible();
    }
  }

  void _onFieldFocusChange(bool focused) {
    widget.onFocusChange?.call(focused);
    if (focused) _ensureLocationVisible();
  }

  void _ensureLocationVisible() {
    void reveal() {
      if (!mounted) return;
      final ctx = _locationFieldKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: JfMotion.press,
        alignment: 0.05,
        curve: Curves.easeOut,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      reveal();
      WidgetsBinding.instance.addPostFrameCallback((_) => reveal());
    });
  }

  void _onKeyboardAction() {
    widget.locationFocus?.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  double _keyboardBottom(BuildContext context) {
    return MediaQueryData.fromView(View.of(context)).viewInsets.bottom;
  }

  double _maxDialogHeight(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final keyboard = _keyboardBottom(context);
    const verticalChrome = JfSpacing.md * 2;
    final available = size.height - keyboard - verticalChrome;
    return available.clamp(240.0, size.height * 0.86);
  }

  bool _validate() {
    final loc = widget.locationController.text.trim();
    var ok = true;
    setState(() {
      _locationError = loc.isEmpty
          ? 'LOCATION REQUIRED — enter a city or ZIP code.'
          : null;
      _timeError = _when == null ? 'TIME FRAME REQUIRED' : null;
      _typeError = _what == null ? 'EVENT TYPE REQUIRED' : null;
      ok = _locationError == null && _timeError == null && _typeError == null;
    });
    return ok;
  }

  void _cancel() {
    Navigator.of(context, rootNavigator: true).pop(
      SearchOverlayResult(
        action: SearchOverlayAction.cancelled,
        location: widget.locationController.text.trim(),
        timeWindow: _when,
        category: _what,
      ),
    );
  }

  void _scan() {
    if (!_validate()) return;
    Navigator.of(context, rootNavigator: true).pop(
      SearchOverlayResult(
        action: SearchOverlayAction.scan,
        location: widget.locationController.text.trim(),
        timeWindow: _when,
        category: _what,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = _maxDialogHeight(context);

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
          padding: const EdgeInsets.all(JfSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SEARCH FOR AN EVENT',
                style: JfTypography.controlLabel.copyWith(fontSize: 13),
              ),
              const SizedBox(height: JfSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KeyedSubtree(
                        key: _locationFieldKey,
                        child: JfMachineField(
                          key: const ValueKey('jf-param-location'),
                          label: 'LOCATION',
                          controller: widget.locationController,
                          focusNode: widget.locationFocus,
                          hintText: 'City and state, or ZIP code',
                          errorText: _locationError,
                          onChanged: (_) {
                            setState(() => _locationError = null);
                          },
                          onFocusChange: _onFieldFocusChange,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _onKeyboardAction,
                        ),
                      ),
                      const SizedBox(height: JfSpacing.md),
                      Text(
                        _when == null
                            ? 'TIME FRAME // SELECT'
                            : 'TIME FRAME // ${_when!.label}',
                        style: JfTypography.micro.copyWith(
                          color: _timeError != null
                              ? JfColors.validationPhosphor
                              : JfColors.white70,
                        ),
                      ),
                      if (_timeError != null)
                        Text(_timeError!, style: JfTypography.validationError),
                      const SizedBox(height: JfSpacing.xs),
                      Wrap(
                        key: const ValueKey('jf-when-options'),
                        spacing: JfSpacing.xs,
                        runSpacing: JfSpacing.xs,
                        children: [
                          for (final w in TimeWindow.values)
                            JfDeviceButton(
                              key: ValueKey('jf-when-${w.name}'),
                              label: w.label,
                              selected: _when == w,
                              variant: JfButtonVariant.compact,
                              expanded: false,
                              semanticLabel: 'Time frame ${w.label}',
                              onPressed: () {
                                setState(() {
                                  _when = w;
                                  _timeError = null;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: JfSpacing.md),
                      Text(
                        _what == null
                            ? 'EVENT TYPE // SELECT'
                            : 'EVENT TYPE // ${_what!.label}',
                        style: JfTypography.micro.copyWith(
                          color: _typeError != null
                              ? JfColors.validationPhosphor
                              : JfColors.white70,
                        ),
                      ),
                      if (_typeError != null)
                        Text(_typeError!, style: JfTypography.validationError),
                      const SizedBox(height: JfSpacing.xs),
                      Wrap(
                        key: const ValueKey('jf-what-options'),
                        spacing: JfSpacing.xs,
                        runSpacing: JfSpacing.xs,
                        children: [
                          for (final c in kV01EventCategories)
                            JfDeviceButton(
                              key: ValueKey('jf-what-${c.name}'),
                              label: c.label,
                              selected: _what == c,
                              variant: JfButtonVariant.compact,
                              expanded: false,
                              semanticLabel: 'Event type ${c.label}',
                              onPressed: () {
                                setState(() {
                                  _what = c;
                                  _typeError = null;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: JfSpacing.xl),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: JfSpacing.lg),
              JfDeviceButton(
                key: const ValueKey('jf-param-scan'),
                label: 'SCAN FOR EVENTS',
                semanticLabel: 'Scan for events',
                onPressed: _scan,
              ),
              const SizedBox(height: JfSpacing.sm),
              JfDeviceButton(
                key: const ValueKey('jf-param-close'),
                label: 'CANCEL',
                semanticLabel: 'Cancel search',
                variant: JfButtonVariant.compact,
                onPressed: _cancel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
