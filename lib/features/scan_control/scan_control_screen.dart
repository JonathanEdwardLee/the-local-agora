import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_machine_identity_panel.dart';
import '../../design/jf_monitor_module.dart';
import '../../design/jf_oled_dialog.dart';
import '../../design/jf_panel.dart';
import '../../design/jf_search_parameter_dialog.dart';
import '../../design/jf_signal_coil.dart';
import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/agora_event_signal.dart';
import '../../services/keryx/demo_keryx_service.dart';
import '../../services/keryx/keryx_link_service.dart';
import '../../services/keryx/keryx_live_scan_service.dart';
import '../../services/keryx/keryx_service.dart';
import '../debug/debug_component_gallery.dart';
import '../discovery/agora_scan_phase.dart';
import '../discovery/crt_signal_record.dart';
import '../discovery/open_record_screen.dart';
import 'scan_control_state.dart';

/// SCREEN 1 — SCAN CONTROL
/// Compact Panel 04 + Search Parameter dialog.
/// Pass 03.1: CRT hosts idle / searching / results / empty / error.
class ScanControlScreen extends StatefulWidget {
  const ScanControlScreen({
    super.key,
    this.firebaseReady = false,
    this.appCheckReady = false,
    this.keryxLinkService,
    this.keryxLiveScanService,
    this.keryxService,
    this.onOpenAbout,
  });

  final bool firebaseReady;
  final bool appCheckReady;
  final KeryxLinkService? keryxLinkService;
  final KeryxLiveScanService? keryxLiveScanService;

  /// Contest discovery path (injected by [main] / tests).
  final KeryxService? keryxService;

  /// Opens the About surface (not Welcome).
  final Future<void> Function()? onOpenAbout;

  @override
  State<ScanControlScreen> createState() => _ScanControlScreenState();
}

class _ScanControlScreenState extends State<ScanControlScreen> {
  late final TextEditingController _locationController;
  late final FocusNode _locationFocus;
  late final KeryxService _keryx;
  late final ScrollController _crtScroll;
  ScanControlState _state = const ScanControlState();
  AgoraScanPhase _phase = AgoraScanPhase.idle;
  KeryxScanResult? _lastResult;
  bool _fieldFocused = false;
  bool _paramDialogOpen = false;
  bool _scanInFlight = false;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _locationFocus = FocusNode();
    _crtScroll = ScrollController();
    _keryx = widget.keryxService ?? DemoKeryxService();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocus.dispose();
    _crtScroll.dispose();
    super.dispose();
  }

  JfSignalCoilMode get _coilMode {
    if (_phase == AgoraScanPhase.searching || _scanInFlight) {
      return JfSignalCoilMode.ready;
    }
    if (_phase == AgoraScanPhase.error) return JfSignalCoilMode.warning;
    if (_fieldFocused) return JfSignalCoilMode.focused;
    return JfSignalCoilMode.idle;
  }

  List<String> get _idleMonitorLines {
    final lines = <String>[
      _state.hasLocation
          ? 'LOCATION // ${_state.locationText.trim().toUpperCase()}'
          : 'AWAITING LOCATION INPUT',
      'WINDOW // ${_state.timeWindow.label}',
      'SIGNAL TYPE // ${_state.category.label}',
      if (_keryx is DemoKeryxService)
        'MODE // VERIFIED DEMO SIGNALS'
      else
        'MODE // LIVE KERYX SCAN',
    ];
    if (_state.locationError != null) {
      lines.add('ERR // LOCATION REQUIRED');
    }
    return lines;
  }

  String? get _parameterSummary {
    final loc = _state.locationText.trim();
    if (loc.isEmpty) return null;
    return '${loc.toUpperCase()} // ${_state.timeWindow.label} // '
        '${_state.category.label}';
  }

  void _onLocationChanged(String value) {
    setState(() {
      _state = _state.copyWith(locationText: value, clearLocationError: true);
    });
  }

  void _selectTime(TimeWindow window) {
    setState(() => _state = _state.copyWith(timeWindow: window));
  }

  void _selectCategory(EventCategory category) {
    setState(() => _state = _state.copyWith(category: category));
  }

  Future<void> _openParameterDialog() async {
    if (_paramDialogOpen) return;
    _paramDialogOpen = true;
    await showJfSearchParameterDialog(
      context: context,
      locationController: _locationController,
      locationFocus: _locationFocus,
      timeWindow: _state.timeWindow,
      category: _state.category,
      locationError: _state.locationError,
      onLocationChanged: _onLocationChanged,
      onTimeChanged: _selectTime,
      onCategoryChanged: _selectCategory,
      onFocusChange: (focused) {
        setState(() => _fieldFocused = focused);
      },
    );
    if (mounted) {
      setState(() {});
      _paramDialogOpen = false;
    } else {
      _paramDialogOpen = false;
    }
  }

  Future<void> _openRecord(AgoraEventSignal signal) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OpenRecordScreen(signal: signal)),
    );
    // Results + scroll remain; do not re-run scan.
    if (mounted) setState(() {});
  }

  Future<void> _onScanPressed() async {
    if (_scanInFlight) return;

    final trimmed = _locationController.text.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _phase = AgoraScanPhase.validating;
        _state = _state.copyWith(
          locationText: '',
          locationError: 'LOCATION REQUIRED — enter a city or ZIP code.',
        );
      });
      await showJfOledDialog<void>(
        context: context,
        title: 'LOCATION REQUIRED',
        body: 'Enter a city or ZIP code before scanning the Agora.',
        confirmLabel: 'ACKNOWLEDGE',
        validationError: true,
        secondaryLabel: 'INPUT SEARCH PARAMETERS',
        onSecondary: () {
          _openParameterDialog();
        },
      );
      if (mounted) {
        setState(() => _phase = AgoraScanPhase.idle);
      }
      return;
    }

    setState(() {
      _state = _state.copyWith(locationText: trimmed, clearLocationError: true);
      _scanInFlight = true;
      _phase = AgoraScanPhase.searching;
      _lastResult = null;
    });

    final request = KeryxScanRequest(
      location: trimmed,
      timeWindow: _state.timeWindow,
      category: _state.category,
    );

    final result = await _keryx.scan(request);
    if (!mounted) return;

    setState(() {
      _scanInFlight = false;
      _lastResult = result;
      switch (result.outcome) {
        case KeryxScanOutcome.results:
          _phase = AgoraScanPhase.results;
        case KeryxScanOutcome.empty:
          _phase = AgoraScanPhase.empty;
        case KeryxScanOutcome.error:
          _phase = AgoraScanPhase.error;
      }
    });

    // Preserve prior scroll only when still on results; reset for new payload.
    if (_crtScroll.hasClients) {
      _crtScroll.jumpTo(0);
    }
  }

  Widget? _crtBody() {
    switch (_phase) {
      case AgoraScanPhase.idle:
      case AgoraScanPhase.validating:
        return null;
      case AgoraScanPhase.searching:
        return _SearchingCrtBody(
          location: _state.locationText.trim(),
          windowLabel: _state.timeWindow.label,
          categoryLabel: _state.category.label,
        );
      case AgoraScanPhase.results:
        final result = _lastResult;
        if (result == null) return null;
        return _ResultsCrtBody(result: result, onOpenRecord: _openRecord);
      case AgoraScanPhase.empty:
        final result = _lastResult;
        return _StatusCrtBody(
          title: result?.machineTitle.isNotEmpty == true
              ? result!.machineTitle
              : 'NO SUPPORTED SIGNALS FOUND',
          support: result?.supportText ?? '',
          provenance: result?.provenanceLines ?? const [],
        );
      case AgoraScanPhase.error:
        final result = _lastResult;
        final title = result?.machineTitle.isNotEmpty == true
            ? result!.machineTitle
            : 'ERR // SCAN ERROR';
        return _StatusCrtBody(
          title: title.startsWith('ERR //') ? title : 'ERR // $title',
          support: result?.supportText ?? 'The Agora scan could not complete.',
          provenance: const [],
          emphasizeError: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final monitorHeight = JfMonitorModule.resolveMonitorHeight(context);
    final summary = _parameterSummary;
    final crtBody = _crtBody();
    final warning =
        _phase == AgoraScanPhase.error || _state.locationError != null;

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
                    const JfMachineIdentityPanel(),
                    const SizedBox(height: JfSpacing.sm),
                    JfMonitorModule(
                      lines: crtBody == null ? _idleMonitorLines : const [],
                      crtBody: crtBody,
                      monitorHeight: monitorHeight,
                      bandHeight: JfMonitorModule.defaultBandHeight,
                      coilMode: _coilMode,
                      warning: warning,
                      crtScrollController: _crtScroll,
                    ),
                    const SizedBox(height: JfSpacing.sm),
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
                              'Search for an event',
                              style: JfTypography.supporting,
                            ),
                            if (summary != null) ...[
                              const SizedBox(height: JfSpacing.sm),
                              Text(
                                summary,
                                style: JfTypography.micro.copyWith(
                                  color: JfColors.white70,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                            const SizedBox(height: JfSpacing.md),
                            JfDeviceButton(
                              key: const ValueKey('jf-open-params'),
                              label: 'INPUT SEARCH PARAMETERS',
                              semanticLabel: 'Input search parameters',
                              onPressed: _scanInFlight
                                  ? null
                                  : _openParameterDialog,
                            ),
                            const SizedBox(height: JfSpacing.sm),
                            JfDeviceButton(
                              key: const ValueKey('jf-scan-agora'),
                              label: 'SCAN THE AGORA',
                              semanticLabel: 'Scan the Agora',
                              onPressed: _scanInFlight ? null : _onScanPressed,
                            ),
                            const SizedBox(height: JfSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: JfDeviceButton(
                                    key: const ValueKey('agora-add-event'),
                                    label: 'ADD EVENT',
                                    locked: true,
                                    lockedMessage: 'FLYER CHANNEL — LATER PASS',
                                    semanticLabel:
                                        'Add Event — flyer channel later pass',
                                    variant: JfButtonVariant.compact,
                                  ),
                                ),
                                const SizedBox(width: JfSpacing.sm),
                                Expanded(
                                  child: JfDeviceButton(
                                    key: const ValueKey('agora-open-about'),
                                    label: 'ABOUT',
                                    semanticLabel: 'Open About',
                                    variant: JfButtonVariant.compact,
                                    onPressed: widget.onOpenAbout == null
                                        ? null
                                        : () {
                                            widget.onOpenAbout?.call();
                                          },
                                  ),
                                ),
                              ],
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
                                        appCheckReady: widget.appCheckReady,
                                        keryxLinkService:
                                            widget.keryxLinkService,
                                        keryxLiveScanService:
                                            widget.keryxLiveScanService,
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

class _SearchingCrtBody extends StatelessWidget {
  const _SearchingCrtBody({
    required this.location,
    required this.windowLabel,
    required this.categoryLabel,
  });

  final String location;
  final String windowLabel;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'SEARCHING THE AGORA',
          style: JfTypography.controlLabel.copyWith(
            color: JfColors.signalGreen,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: JfSpacing.sm),
        Text(
          'LOCATION // ${location.toUpperCase()}',
          style: JfTypography.supporting.copyWith(fontSize: 11),
        ),
        Text(
          'WINDOW // $windowLabel',
          style: JfTypography.supporting.copyWith(fontSize: 11),
        ),
        Text(
          'SIGNAL TYPE // $categoryLabel',
          style: JfTypography.supporting.copyWith(fontSize: 11),
        ),
        const SizedBox(height: JfSpacing.sm),
        Text(
          'STATUS // SCANNING PUBLIC SIGNALS',
          style: JfTypography.micro.copyWith(color: JfColors.signalGreen),
        ),
      ],
    );
  }
}

class _ResultsCrtBody extends StatelessWidget {
  const _ResultsCrtBody({required this.result, required this.onOpenRecord});

  final KeryxScanResult result;
  final Future<void> Function(AgoraEventSignal signal) onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final count = result.signalCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in result.provenanceLines)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              line,
              style: JfTypography.micro.copyWith(
                color: JfColors.signalGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Text(
          '$count SIGNAL${count == 1 ? '' : 'S'} FOUND',
          style: JfTypography.controlLabel.copyWith(fontSize: 12),
        ),
        Text(
          result.request.location.trim().toUpperCase(),
          style: JfTypography.micro.copyWith(color: JfColors.white70),
        ),
        Text(
          '${result.request.timeWindowLabel} // ${result.request.categoryLabel}',
          style: JfTypography.micro.copyWith(color: JfColors.white54),
        ),
        const SizedBox(height: JfSpacing.sm),
        for (final signal in result.signals)
          CrtSignalRecord(
            signal: signal,
            onOpenRecord: () {
              onOpenRecord(signal);
            },
          ),
      ],
    );
  }
}

class _StatusCrtBody extends StatelessWidget {
  const _StatusCrtBody({
    required this.title,
    required this.support,
    required this.provenance,
    this.emphasizeError = false,
  });

  final String title;
  final String support;
  final List<String> provenance;
  final bool emphasizeError;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: emphasizeError
          ? BoxDecoration(
              border: Border.all(
                color: JfColors.white,
                width: JfBorders.primary,
              ),
            )
          : const BoxDecoration(),
      child: Padding(
        padding: emphasizeError
            ? const EdgeInsets.all(JfSpacing.sm)
            : EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final line in provenance)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  line,
                  style: JfTypography.micro.copyWith(
                    color: JfColors.signalGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              title,
              style: JfTypography.controlLabel.copyWith(fontSize: 12),
            ),
            if (support.isNotEmpty) ...[
              const SizedBox(height: JfSpacing.sm),
              Text(
                support,
                style: JfTypography.supporting.copyWith(fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
