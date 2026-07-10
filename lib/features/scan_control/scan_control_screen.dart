import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_machine_field.dart';
import '../../design/jf_oled_dialog.dart';
import '../../design/jf_oled_toast.dart';
import '../../design/jf_panel.dart';
import '../../design/jf_section_label.dart';
import '../../design/jf_status_line.dart';
import '../../design/junkfeathers_tokens.dart';
import '../debug/debug_component_gallery.dart';
import 'scan_control_state.dart';

/// SCREEN 1 — SCAN CONTROL
/// Permanent Local Agora entry machine. No live Keryx in Pass 02A.
class ScanControlScreen extends StatefulWidget {
  const ScanControlScreen({super.key});

  @override
  State<ScanControlScreen> createState() => _ScanControlScreenState();
}

class _ScanControlScreenState extends State<ScanControlScreen> {
  late final TextEditingController _locationController;
  ScanControlState _state = const ScanControlState();

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _onLocationChanged(String value) {
    setState(() {
      _state = _state.copyWith(
        locationText: value,
        clearLocationError: true,
      );
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
      });
      showJfOledToast(
        context,
        'LOCATION REQUIRED — enter a city or ZIP code.',
        warning: true,
      );
      return;
    }

    setState(() {
      _state = _state.copyWith(
        locationText: trimmed,
        clearLocationError: true,
      );
    });

    showJfOledDialog<void>(
      context: context,
      title: 'SCAN CONTROL READY',
      body:
          'Live Keryx connection arrives in the next governed pass.\n\n'
          'Location: $trimmed\n'
          'Window: ${_state.timeWindow.label}\n'
          'Category: ${_state.category.label}\n\n'
          'No network search was performed.',
      confirmLabel: 'ACKNOWLEDGE',
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
                    JfSpacing.lg,
                    JfSpacing.lg,
                    JfSpacing.lg + bottomInset,
                  ),
                  child: JfPanel(
                    weight: JfPanelWeight.major,
                    padding: const EdgeInsets.all(JfSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'JUNKFEATHERS TECH // CIVIC RECEIVER 01',
                          style: JfTypography.micro.copyWith(
                            color: JfColors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: JfSpacing.sm),
                        const Divider(color: JfColors.white24, height: 1),
                        const SizedBox(height: JfSpacing.md),
                        Text(
                          'THE LOCAL AGORA',
                          style: JfTypography.deviceTitle,
                        ),
                        const SizedBox(height: JfSpacing.md),
                        Text(
                          'WHAT IS HAPPENING HERE?',
                          style: JfTypography.controlLabel.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: JfSpacing.xs),
                        const Text(
                          'Choose a city or ZIP code, a time window, and an optional event type.',
                          style: JfTypography.supporting,
                        ),
                        const SizedBox(height: JfSpacing.lg),
                        JfMachineField(
                          label: 'CITY OR ZIP CODE',
                          controller: _locationController,
                          hintText: 'Springfield, Missouri',
                          errorText: _state.locationError,
                          onChanged: _onLocationChanged,
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
                          lockedMessage:
                              'FLYER CHANNEL — LATER PASS',
                          semanticLabel: 'Add Signal — flyer channel later pass',
                        ),
                        const SizedBox(height: JfSpacing.md),
                        const JfStatusLine(
                          'STATUS // SCAN CONTROL ONLINE — KERYX LINK PENDING',
                          tone: JfStatusTone.secondary,
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
