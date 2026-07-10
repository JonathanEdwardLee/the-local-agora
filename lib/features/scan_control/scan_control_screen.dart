import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design/jf_crt_monitor.dart';
import '../../design/jf_device_button.dart';
import '../../design/jf_dial_selector.dart';
import '../../design/jf_machine_field.dart';
import '../../design/jf_machine_identity_panel.dart';
import '../../design/jf_oled_toast.dart';
import '../../design/jf_panel.dart';
import '../../design/jf_signal_coil.dart';
import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/keryx_link_service.dart';
import '../debug/debug_component_gallery.dart';
import 'scan_control_state.dart';

/// SCREEN 1 — SCAN CONTROL
/// Integrated four-panel machine face. Live Keryx not enabled in Pass 02B.1.
class ScanControlScreen extends StatefulWidget {
  const ScanControlScreen({
    super.key,
    this.firebaseReady = false,
    this.keryxLinkService,
  });

  final bool firebaseReady;
  final KeryxLinkService? keryxLinkService;

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

  List<String> get _monitorLines {
    final lines = <String>[
      _state.hasLocation
          ? 'LOCATION // ${_state.locationText.trim().toUpperCase()}'
          : 'AWAITING LOCATION INPUT',
      'WINDOW // ${_state.timeWindow.label}',
      'SIGNAL TYPE // ${_state.category.label}',
      'ENGINE LINK // NOT CONNECTED',
    ];
    if (_state.locationError != null) {
      lines.add('ERROR // LOCATION REQUIRED');
    }
    if (_readinessShown) {
      lines.add('STATUS // SCAN CONTROL READY');
      lines.add('NOTE // LIVE KERYX ARRIVES NEXT PASS');
    }
    return lines;
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
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                JfSpacing.sm,
                JfSpacing.sm,
                JfSpacing.sm,
                JfSpacing.lg + bottomInset,
              ),
              child: JfPanel(
                weight: JfPanelWeight.major,
                padding: const EdgeInsets.all(JfSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 01 — Identity / specification (no external header)
                    const JfMachineIdentityPanel(),
                    const SizedBox(height: JfSpacing.sm),

                    // 02 — CRT monitor only
                    JfCrtMonitor(
                      lines: _monitorLines,
                      height: 180,
                      warning: _state.locationError != null,
                    ),
                    const SizedBox(height: JfSpacing.sm),

                    // 03 — Compact triple-ring art
                    JfSignalCoil(mode: _coilMode, height: 60),
                    const SizedBox(height: JfSpacing.sm),

                    // 04 — Integrated control chassis
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: JfColors.black,
                        border: Border.all(
                          color: JfColors.white,
                          width: JfBorders.primary,
                        ),
                        borderRadius: JfBorders.square,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(JfSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Choose a city or ZIP code, then set WHEN and WHAT.',
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
                            const SizedBox(height: JfSpacing.md),
                            JfDialSelector<TimeWindow>(
                              label: 'WHEN',
                              values: TimeWindow.values,
                              value: _state.timeWindow,
                              labelOf: (v) => v.label,
                              onChanged: _selectTime,
                              semanticPrefix: 'When',
                            ),
                            const SizedBox(height: JfSpacing.md),
                            JfDialSelector<EventCategory>(
                              label: 'WHAT',
                              values: EventCategory.values,
                              value: _state.category,
                              labelOf: (v) => v.label,
                              onChanged: _selectCategory,
                              semanticPrefix: 'What',
                            ),
                            const SizedBox(height: JfSpacing.lg),
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
                              const SizedBox(height: JfSpacing.md),
                              JfDeviceButton(
                                label: 'DEBUG // COMPONENTS',
                                variant: JfButtonVariant.compact,
                                semanticLabel: 'Open debug component gallery',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => DebugComponentGallery(
                                        firebaseReady: widget.firebaseReady,
                                        keryxLinkService:
                                            widget.keryxLinkService,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
