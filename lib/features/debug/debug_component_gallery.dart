import 'package:flutter/material.dart';

import '../../design/jf_crt_monitor.dart';
import '../../design/jf_device_button.dart';
import '../../design/jf_dial_selector.dart';
import '../../design/jf_machine_field.dart';
import '../../design/jf_machine_identity_panel.dart';
import '../../design/jf_numeric_display.dart';
import '../../design/jf_oled_dialog.dart';
import '../../design/jf_oled_toast.dart';
import '../../design/jf_section_label.dart';
import '../../design/jf_signal_coil.dart';
import '../../design/jf_status_line.dart';
import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/keryx_link_result.dart';
import '../../services/keryx/keryx_link_service.dart';
import '../scan_control/scan_control_state.dart';

/// Debug-only visual review surface. Not linked from release builds.
class DebugComponentGallery extends StatefulWidget {
  const DebugComponentGallery({
    super.key,
    this.firebaseReady = false,
    this.keryxLinkService,
  });

  final bool firebaseReady;
  final KeryxLinkService? keryxLinkService;

  @override
  State<DebugComponentGallery> createState() => _DebugComponentGalleryState();
}

class _DebugComponentGalleryState extends State<DebugComponentGallery> {
  final _fieldController = TextEditingController(text: 'Springfield, Missouri');
  TimeWindow _when = TimeWindow.tonight;
  EventCategory _what = EventCategory.allSignals;
  bool _selected = true;
  KeryxLinkResult _linkResult = KeryxLinkResult.untested;
  bool _linkBusy = false;

  @override
  void dispose() {
    _fieldController.dispose();
    super.dispose();
  }

  Future<void> _testKeryxLink() async {
    final service = widget.keryxLinkService;
    if (service == null || _linkBusy) return;
    setState(() {
      _linkBusy = true;
      _linkResult = KeryxLinkResult.connecting;
    });
    showJfOledToast(context, 'CONNECTING TO KERYX...');
    final result = await service.probeStatus();
    if (!mounted) return;
    setState(() {
      _linkResult = result;
      _linkBusy = false;
    });
    showJfOledToast(
      context,
      result.machineTitle,
      detail: result.supportText,
      warning: result.state != KeryxLinkState.ready,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canTest = widget.firebaseReady && widget.keryxLinkService != null;

    return Scaffold(
      backgroundColor: JfColors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                JfSpacing.lg,
                JfSpacing.lg,
                JfSpacing.lg,
                JfSpacing.lg + bottomInset,
              ),
              children: [
                Text(
                  'DEBUG // COMPONENT GALLERY',
                  style: JfTypography.deviceTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: JfSpacing.xs),
                const Text(
                  'Pass 02B.1 geometry + Firebase link probe. Debug only.',
                  style: JfTypography.supporting,
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('FIREBASE LINK'),
                const SizedBox(height: JfSpacing.sm),
                Text(
                  _linkResult.machineTitle,
                  style: JfTypography.controlLabel,
                ),
                const SizedBox(height: JfSpacing.xs),
                Text(
                  _linkResult.supportText,
                  style: JfTypography.supporting,
                ),
                const SizedBox(height: JfSpacing.sm),
                JfDeviceButton(
                  label: 'TEST KERYX LINK',
                  semanticLabel: 'Test Keryx Firebase link',
                  onPressed: canTest && !_linkBusy ? _testKeryxLink : null,
                ),
                if (!canTest) ...[
                  const SizedBox(height: JfSpacing.xs),
                  const Text(
                    'Firebase is not initialized in this session.',
                    style: JfTypography.warning,
                  ),
                ],
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('PANEL 01 IDENTITY'),
                const SizedBox(height: JfSpacing.sm),
                const JfMachineIdentityPanel(),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('PANEL 02 CRT MONITOR'),
                const SizedBox(height: JfSpacing.sm),
                const JfCrtMonitor(
                  lines: [
                    'AWAITING LOCATION INPUT',
                    'WINDOW // TONIGHT',
                    'SIGNAL TYPE // ALL SIGNALS',
                    'ENGINE LINK // NOT CONNECTED',
                    'LINE // SCROLL SAMPLE 01',
                    'LINE // SCROLL SAMPLE 02',
                    'LINE // SCROLL SAMPLE 03',
                    'LINE // SCROLL SAMPLE 04',
                    'LINE // SCROLL SAMPLE 05',
                    'LINE // SCROLL SAMPLE 06',
                  ],
                  height: 180,
                ),
                const SizedBox(height: JfSpacing.sm),
                const Text('STATIC WAITING PROMPT', style: JfTypography.micro),
                const SizedBox(height: JfSpacing.xs),
                const JfCrtMonitor(
                  lines: ['ENGINE LINK // NOT CONNECTED'],
                  height: 100,
                  forceStaticPrompt: true,
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('PANEL 03 TRIPLE RING'),
                const SizedBox(height: JfSpacing.sm),
                const JfSignalCoil(height: 60),
                const SizedBox(height: JfSpacing.sm),
                const Text('REDUCED MOTION / STATIC', style: JfTypography.micro),
                const SizedBox(height: JfSpacing.xs),
                const JfSignalCoil(height: 60, forceStatic: true),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('PANEL 04 DIALS + FIELD'),
                const SizedBox(height: JfSpacing.sm),
                JfMachineField(
                  label: 'CITY OR ZIP CODE',
                  controller: _fieldController,
                  hintText: 'Enter location',
                ),
                const SizedBox(height: JfSpacing.md),
                JfDialSelector<TimeWindow>(
                  label: 'WHEN',
                  values: TimeWindow.values,
                  value: _when,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _when = v),
                ),
                const SizedBox(height: JfSpacing.md),
                JfDialSelector<EventCategory>(
                  label: 'WHAT',
                  values: EventCategory.values,
                  value: _what,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _what = v),
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('TOP OLED TOASTS'),
                const SizedBox(height: JfSpacing.sm),
                JfDeviceButton(
                  label: 'TOP INFO TOAST',
                  variant: JfButtonVariant.compact,
                  onPressed: () => showJfOledToast(
                    context,
                    'SCAN CONTROL READY',
                    detail:
                        'Live Keryx connection arrives in the next governed pass.',
                  ),
                ),
                const SizedBox(height: JfSpacing.sm),
                JfDeviceButton(
                  label: 'TOP WARNING TOAST',
                  variant: JfButtonVariant.compact,
                  onPressed: () => showJfOledToast(
                    context,
                    'LOCATION REQUIRED',
                    detail: 'Enter a city or ZIP code.',
                    warning: true,
                  ),
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('LEGACY STATES'),
                const SizedBox(height: JfSpacing.sm),
                const JfNumericDisplay('12', label: 'SIGNALS'),
                const SizedBox(height: JfSpacing.sm),
                Wrap(
                  spacing: JfSpacing.sm,
                  runSpacing: JfSpacing.sm,
                  children: [
                    JfDeviceButton(
                      label: 'SELECTED',
                      variant: JfButtonVariant.selectable,
                      expanded: false,
                      selected: _selected,
                      onPressed: () => setState(() => _selected = !_selected),
                    ),
                    const JfDeviceButton(
                      label: 'DISABLED',
                      variant: JfButtonVariant.compact,
                      expanded: false,
                      onPressed: null,
                    ),
                    const JfDeviceButton(
                      label: 'LOCKED',
                      variant: JfButtonVariant.compact,
                      expanded: false,
                      locked: true,
                      lockedMessage: 'LOCKED EXAMPLE',
                    ),
                  ],
                ),
                const SizedBox(height: JfSpacing.sm),
                JfDeviceButton(
                  label: 'SHOW SQUARE DIALOG',
                  variant: JfButtonVariant.compact,
                  onPressed: () => showJfOledDialog<void>(
                    context: context,
                    title: 'SQUARE DIALOG',
                    body: '2 px white frame.',
                  ),
                ),
                const SizedBox(height: JfSpacing.sm),
                const JfStatusLine('LOADING // SEARCHING PUBLIC SIGNALS'),
                const JfStatusLine(
                  'EMPTY // NO CURRENT SIGNALS FOUND',
                  tone: JfStatusTone.secondary,
                ),
                const JfStatusLine(
                  'ERROR // LOCATION REQUIRED',
                  tone: JfStatusTone.error,
                ),
                const JfStatusLine(
                  'OFFLINE // NETWORK UNAVAILABLE',
                  tone: JfStatusTone.secondary,
                ),
                const SizedBox(height: JfSpacing.xl),
                JfDeviceButton(
                  label: 'RETURN TO SCAN CONTROL',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
