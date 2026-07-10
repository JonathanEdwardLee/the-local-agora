import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_machine_field.dart';
import '../../design/jf_machine_status_strip.dart';
import '../../design/jf_oled_toast.dart';
import '../../design/jf_panel.dart';
import '../../design/jf_section_label.dart';
import '../../design/jf_signal_coil.dart';
import '../../design/junkfeathers_tokens.dart';
import '../debug/debug_component_gallery.dart';
import 'scan_control_state.dart';

/// SCREEN 1 — SCAN CONTROL
/// Four-level machine shell Stage 1. No live Keryx in Pass 02A.1.
class ScanControlScreen extends StatefulWidget {
  const ScanControlScreen({super.key});

  @override
  State<ScanControlScreen> createState() => _ScanControlScreenState();
}

class _ScanControlScreenState extends State<ScanControlScreen> {
  late final TextEditingController _locationController;
  late final FocusNode _locationFocus;
  ScanControlState _state = const ScanControlState();
  bool _fieldFocused = false;
  bool _readinessShown = false;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _locationFocus = FocusNode();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  JfSignalCoilMode get _coilMode {
    if (_state.locationError != null) return JfSignalCoilMode.warning;
    if (_readinessShown) return JfSignalCoilMode.ready;
    if (_fieldFocused) return JfSignalCoilMode.focused;
    return JfSignalCoilMode.idle;
  }

  void _onLocationChanged(String value) {
    setState(() {
      _state = _state.copyWith(
        locationText: value,
        clearLocationError: true,
      );
      _readinessShown = false;
    });
  }

  void _selectTime(TimeWindow window) {
    setState(() => _state = _state.copyWith(timeWindow: window));
  }

  void _selectCategory(EventCategory category) {
    setState(() => _state = _state.copyWith(category: category));
  }

  void _onScanPressed() {
    final trimmed = _locationController.text.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _state = _state.copyWith(
          locationText: '',
          locationError: 'LOCATION REQUIRED — enter a city or ZIP code.',
        );
        _readinessShown = false;
      });
      _locationFocus.requestFocus();
      showJfOledToast(
        context,
        'LOCATION REQUIRED',
        detail: 'Enter a city or ZIP code.',
        warning: true,
      );
      return;
    }

    setState(() {
      _state = _state.copyWith(
        locationText: trimmed,
        clearLocationError: true,
      );
      _readinessShown = true;
    });

    // Honest local readiness only — no network / Keryx call.
    showJfOledToast(
      context,
      'SCAN CONTROL READY',
      detail: 'Live Keryx connection arrives in the next governed pass.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: JfColors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    JfSpacing.lg,
                    JfSpacing.sm,
                    JfSpacing.lg,
                    JfSpacing.lg + bottomInset,
                  ),
                  child: JfPanel(
                    weight: JfPanelWeight.major,
                    padding: const EdgeInsets.all(JfSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 01 — Status / spec strip
                        const JfSectionLabel('01 // STATUS'),
                        const SizedBox(height: JfSpacing.xs),
                        const JfMachineStatusStrip(),
                        const SizedBox(height: JfSpacing.md),

                        // 02 — Main display
                        const JfSectionLabel('02 // DISPLAY'),
                        const SizedBox(height: JfSpacing.xs),
                        JfPanel(
                          weight: JfPanelWeight.primary,
                          padding: const EdgeInsets.all(JfSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'THE LOCAL AGORA',
                                style: JfTypography.deviceTitle.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: JfSpacing.sm),
                              Text(
                                'WHAT IS HAPPENING HERE?',
                                style: JfTypography.controlLabel.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: JfSpacing.xs),
                              Text(
                                _state.hasLocation
                                    ? 'LOCATION // ${_state.locationText.trim().toUpperCase()}'
                                    : 'AWAITING LOCATION INPUT',
                                style: JfTypography.supporting.copyWith(
                                  color: _state.locationError != null
                                      ? JfColors.amber
                                      : JfColors.white70,
                                ),
                              ),
                              const SizedBox(height: JfSpacing.sm),
                              Text(
                                'WINDOW // ${_state.timeWindow.label}',
                                style: JfTypography.micro.copyWith(
                                  color: JfColors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: JfSpacing.xs),
                              Text(
                                'SIGNAL TYPE // ${_state.category.label}',
                                style: JfTypography.micro.copyWith(
                                  color: JfColors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: JfSpacing.md),

                        // 03 — Signal coil
                        const JfSectionLabel('03 // SIGNAL COIL'),
                        const SizedBox(height: JfSpacing.xs),
                        JfSignalCoil(mode: _coilMode, height: 112),
                        const SizedBox(height: JfSpacing.md),

                        // 04 — Controls
                        const JfSectionLabel('04 // CONTROLS'),
                        const SizedBox(height: JfSpacing.xs),
                        const Text(
                          'Choose a city or ZIP code, a time window, and an optional event type.',
                          style: JfTypography.supporting,
                        ),
                        const SizedBox(height: JfSpacing.md),
                        JfMachineField(
                          label: 'CITY OR ZIP CODE',
                          controller: _locationController,
                          focusNode: _locationFocus,
                          hintText: 'Springfield, Missouri',
                          errorText: _state.locationError,
                          onChanged: _onLocationChanged,
                          onFocusChange: (focused) {
                            setState(() => _fieldFocused = focused);
                          },
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: JfSpacing.lg),
                        const JfSectionLabel('TIME WINDOW'),
                        const SizedBox(height: JfSpacing.sm),
                        _ChoiceWrap(
                          children: TimeWindow.values.map((window) {
                            return JfDeviceButton(
                              label: window.label,
                              variant: JfButtonVariant.selectable,
                              expanded: false,
                              selected: _state.timeWindow == window,
                              onPressed: () => _selectTime(window),
                              semanticLabel: 'Time window ${window.label}',
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: JfSpacing.lg),
                        const JfSectionLabel('EVENT TYPE'),
                        const SizedBox(height: JfSpacing.sm),
                        _ChoiceWrap(
                          children: EventCategory.values.map((category) {
                            return JfDeviceButton(
                              label: category.label,
                              variant: JfButtonVariant.selectable,
                              expanded: false,
                              selected: _state.category == category,
                              onPressed: () => _selectCategory(category),
                              semanticLabel: 'Event category ${category.label}',
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: JfSpacing.xl),
                        JfDeviceButton(
                          label: 'SCAN THE AGORA',
                          semanticLabel: 'Scan the Agora',
                          onPressed: _onScanPressed,
                        ),
                        const SizedBox(height: JfSpacing.sm),
                        const JfDeviceButton(
                          label: 'ADD SIGNAL',
                          locked: true,
                          lockedMessage: 'FLYER CHANNEL — LATER PASS',
                          semanticLabel:
                              'Add Signal — flyer channel later pass',
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: JfSpacing.lg),
                          JfDeviceButton(
                            label: 'DEBUG // COMPONENTS',
                            variant: JfButtonVariant.compact,
                            semanticLabel: 'Open debug component gallery',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const DebugComponentGallery(),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: JfSpacing.sm,
      runSpacing: JfSpacing.sm,
      children: children,
    );
  }
}
