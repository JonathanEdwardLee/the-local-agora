import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_dial_selector.dart';
import '../../design/jf_indicator_board.dart';
import '../../design/jf_machine_field.dart';
import '../../design/jf_machine_identity_panel.dart';
import '../../design/jf_monitor_module.dart';
import '../../design/jf_numeric_display.dart';
import '../../design/jf_oled_dialog.dart';
import '../../design/jf_oled_toast.dart';
import '../../design/jf_search_parameter_dialog.dart';
import '../../design/jf_section_label.dart';
import '../../design/jf_status_line.dart';
import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/keryx_link_result.dart';
import '../../services/keryx/keryx_link_service.dart';
import '../../services/keryx/keryx_live_scan_service.dart';
import '../scan_control/scan_control_state.dart';

/// Debug-only visual review surface. Not linked from release builds.
class DebugComponentGallery extends StatefulWidget {
  const DebugComponentGallery({
    super.key,
    this.firebaseReady = false,
    this.appCheckReady = false,
    this.keryxLinkService,
    this.keryxLiveScanService,
  });

  final bool firebaseReady;
  final bool appCheckReady;
  final KeryxLinkService? keryxLinkService;
  final KeryxLiveScanService? keryxLiveScanService;

  @override
  State<DebugComponentGallery> createState() => _DebugComponentGalleryState();
}

class _DebugComponentGalleryState extends State<DebugComponentGallery> {
  final _fieldController = TextEditingController(text: 'Springfield, Missouri');
  final _invalidController = TextEditingController();
  TimeWindow _when = TimeWindow.nextSevenDays;
  EventCategory _what = EventCategory.music;
  bool _selected = true;
  KeryxLinkResult _linkResult = KeryxLinkResult.untested;
  bool _linkBusy = false;
  KeryxLiveScanResult _liveResult = KeryxLiveScanResult.untested;
  bool _liveBusy = false;
  String? _liveStage;

  @override
  void dispose() {
    _fieldController.dispose();
    _invalidController.dispose();
    super.dispose();
  }

  String get _timeWindowWire {
    switch (_when) {
      case TimeWindow.tonight:
        return 'TONIGHT';
      case TimeWindow.tomorrow:
        return 'TOMORROW';
      case TimeWindow.thisWeekend:
        return 'THIS_WEEKEND';
      case TimeWindow.nextSevenDays:
        return 'NEXT_7_DAYS';
    }
  }

  String get _categoryWire {
    switch (_what) {
      case EventCategory.allSignals:
        return 'ALL_SIGNALS';
      case EventCategory.music:
        return 'MUSIC';
      case EventCategory.art:
        return 'ART';
      case EventCategory.stage:
        return 'STAGE';
      case EventCategory.comedy:
        return 'COMEDY';
      case EventCategory.gatherings:
        return 'GATHERINGS';
    }
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

  Future<void> _confirmLiveScan() async {
    final service = widget.keryxLiveScanService;
    if (service == null || _liveBusy) return;

    final confirmed = await showJfOledDialog<bool>(
      context: context,
      title: 'LIVE KERYX TEST',
      body:
          'This performs a real Google AI search and may use cloud credits.\n\n'
          'Parameters: ${_fieldController.text.trim().isEmpty ? "Springfield, Missouri" : _fieldController.text.trim()} // ${_when.label} // ${_what.label}',
      confirmLabel: 'RUN ONE TEST',
      secondaryLabel: 'CANCEL',
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _liveBusy = true;
      _liveStage = 'CONTACTING KERYX';
    });

    final location = _fieldController.text.trim().isEmpty
        ? 'Springfield, Missouri'
        : _fieldController.text.trim();

    final result = await service.runDebugScan(
      location: location,
      timeWindow: _timeWindowWire,
      category: _categoryWire,
      onStage: (stage) {
        if (!mounted) return;
        setState(() => _liveStage = stage);
        showJfOledToast(context, stage);
      },
    );
    if (!mounted) return;
    setState(() {
      _liveResult = result;
      _liveBusy = false;
      _liveStage = null;
    });
    showJfOledToast(
      context,
      result.machineTitle,
      detail: result.supportText,
      warning: !result.ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canTest = widget.firebaseReady && widget.keryxLinkService != null;
    final canLive = widget.firebaseReady &&
        widget.appCheckReady &&
        widget.keryxLiveScanService != null;

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
                  'Pass 02B.2A secure live Keryx debug scan. Debug only.',
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
                const JfSectionLabel('LIVE KERYX DEBUG'),
                const SizedBox(height: JfSpacing.sm),
                Text(
                  _liveStage ?? _liveResult.machineTitle,
                  style: JfTypography.controlLabel,
                ),
                const SizedBox(height: JfSpacing.xs),
                Text(
                  _liveResult.supportText,
                  style: JfTypography.supporting,
                ),
                if (_liveResult.elapsedMs != null) ...[
                  const SizedBox(height: JfSpacing.xs),
                  Text(
                    'ELAPSED // ${_liveResult.elapsedMs} MS // CACHE // ${_liveResult.cacheStatus.toUpperCase()}',
                    style: JfTypography.micro,
                  ),
                ],
                const SizedBox(height: JfSpacing.sm),
                JfDeviceButton(
                  key: const ValueKey('jf-test-live-keryx'),
                  label: 'TEST LIVE KERYX SCAN',
                  semanticLabel: 'Test live Keryx scan',
                  onPressed: canLive && !_liveBusy ? _confirmLiveScan : null,
                ),
                if (!canLive) ...[
                  const SizedBox(height: JfSpacing.xs),
                  Text(
                    widget.appCheckReady
                        ? 'Live debug scan is unavailable in this session.'
                        : 'App Check is not ready. Live debug scan stays blocked.',
                    style: JfTypography.warning,
                  ),
                ],
                if (_liveResult.events.isNotEmpty) ...[
                  const SizedBox(height: JfSpacing.md),
                  Text(
                    'SIGNALS // ${_liveResult.signalCount}',
                    style: JfTypography.controlLabel.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: JfSpacing.sm),
                  for (final event in _liveResult.events) ...[
                    Text(
                      event.title,
                      style: JfTypography.supporting,
                    ),
                    Text(
                      [
                        if (event.date != null) event.date!,
                        if (event.startTime != null) event.startTime!,
                        if (event.venue != null) event.venue!,
                        if (event.city != null) event.city!,
                      ].join(' // '),
                      style: JfTypography.micro,
                    ),
                    if (event.sourceUrl != null)
                      Text(event.sourceUrl!, style: JfTypography.micro),
                    const SizedBox(height: JfSpacing.sm),
                  ],
                ],
                if (_liveResult.warnings.isNotEmpty) ...[
                  const SizedBox(height: JfSpacing.sm),
                  for (final warning in _liveResult.warnings.take(8))
                    Text(warning, style: JfTypography.micro),
                ],
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('PANEL 01 IDENTITY'),
                const SizedBox(height: JfSpacing.sm),
                const JfMachineIdentityPanel(),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('PANEL 02 COMBINED MONITOR'),
                const SizedBox(height: JfSpacing.sm),
                JfMonitorModule(
                  lines: const [
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
                  monitorHeight: JfMonitorModule.resolveMonitorHeight(context),
                ),
                const SizedBox(height: JfSpacing.sm),
                const Text('REDUCED MOTION MODULE', style: JfTypography.micro),
                const SizedBox(height: JfSpacing.xs),
                const JfMonitorModule(
                  lines: ['ENGINE LINK // NOT CONNECTED'],
                  monitorHeight: 160,
                  forceStatic: true,
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('INDICATOR BOARD STATIC'),
                const SizedBox(height: JfSpacing.sm),
                const JfIndicatorBoard(height: 72, forceStatic: true),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('PANEL 04 COMPACT DECK'),
                const SizedBox(height: JfSpacing.sm),
                const Text('Search for an event', style: JfTypography.supporting),
                const SizedBox(height: JfSpacing.md),
                JfDeviceButton(
                  label: 'INPUT SEARCH PARAMETERS',
                  onPressed: () => showJfSearchParameterDialog(
                    context: context,
                    locationController: _fieldController,
                    timeWindow: _when,
                    category: _what,
                    onLocationChanged: (_) {},
                    onTimeChanged: (v) => setState(() => _when = v),
                    onCategoryChanged: (v) => setState(() => _what = v),
                  ),
                ),
                const SizedBox(height: JfSpacing.sm),
                const JfDeviceButton(
                  label: 'SCAN THE AGORA',
                  onPressed: null,
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('VALIDATION FIELD + ERROR DIALOG'),
                const SizedBox(height: JfSpacing.sm),
                JfMachineField(
                  label: 'CITY OR ZIP CODE',
                  controller: _invalidController,
                  errorText: 'LOCATION REQUIRED — enter a city or ZIP code.',
                ),
                const SizedBox(height: JfSpacing.sm),
                JfDeviceButton(
                  label: 'SHOW LOCATION ERROR DIALOG',
                  variant: JfButtonVariant.compact,
                  onPressed: () => showJfOledDialog<void>(
                    context: context,
                    title: 'LOCATION REQUIRED',
                    body:
                        'Enter a city or ZIP code before scanning the Agora.',
                    validationError: true,
                  ),
                ),
                const SizedBox(height: JfSpacing.lg),
                const JfSectionLabel('STANDALONE DIALS'),
                const SizedBox(height: JfSpacing.sm),
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
                  label: 'TOP WARNING TOAST (LEGACY AMBER)',
                  variant: JfButtonVariant.compact,
                  onPressed: () => showJfOledToast(
                    context,
                    'LEGACY WARNING SAMPLE',
                    detail: 'Not used for empty-location validation.',
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
                const JfStatusLine('LOADING // SEARCHING PUBLIC SIGNALS'),
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
