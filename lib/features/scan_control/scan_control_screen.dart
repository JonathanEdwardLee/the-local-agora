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
import '../../services/keryx/demo_keryx_service.dart';
import '../../services/keryx/keryx_link_service.dart';
import '../../services/keryx/keryx_live_scan_service.dart';
import '../../services/keryx/keryx_service.dart';
import '../debug/debug_component_gallery.dart';
import '../discovery/city_index_screen.dart';
import '../discovery/searching_agora_screen.dart';
import 'scan_control_state.dart';

/// SCREEN 1 — SCAN CONTROL
/// Compact Panel 04 + Search Parameter dialog. Main Scan uses DemoKeryxService.
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

  /// Contest discovery path (default: [DemoKeryxService]).
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
  ScanControlState _state = const ScanControlState();
  bool _fieldFocused = false;
  bool _paramDialogOpen = false;
  bool _scanInFlight = false;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _locationFocus = FocusNode();
    _keryx = widget.keryxService ?? DemoKeryxService();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  JfSignalCoilMode get _coilMode {
    if (_scanInFlight) return JfSignalCoilMode.ready;
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
      'ENGINE LINK // DEMO KERYX FIXTURE',
    ];
    if (_state.locationError != null) {
      lines.add('ERROR // LOCATION REQUIRED');
    }
    if (_scanInFlight) {
      lines.add('STATUS // KERYX IS SCANNING PUBLIC SIGNALS');
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

  Future<void> _onScanPressed() async {
    if (_scanInFlight) return;

    final trimmed = _locationController.text.trim();
    if (trimmed.isEmpty) {
      setState(() {
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
      return;
    }

    setState(() {
      _state = _state.copyWith(locationText: trimmed, clearLocationError: true);
      _scanInFlight = true;
    });

    final request = KeryxScanRequest(
      location: trimmed,
      timeWindow: _state.timeWindow,
      category: _state.category,
    );

    // Searching surface (may be popped by user; scan still completes).
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchingAgoraScreen(
          location: trimmed,
          windowLabel: _state.timeWindow.label,
          categoryLabel: _state.category.label,
        ),
      ),
    );

    final result = await _keryx.scan(request);
    if (!mounted) return;

    // Drop searching route if still on top.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    setState(() => _scanInFlight = false);

    switch (result.outcome) {
      case KeryxScanOutcome.results:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CityIndexScreen(result: result),
          ),
        );
      case KeryxScanOutcome.empty:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CityIndexScreen(result: result, empty: true),
          ),
        );
      case KeryxScanOutcome.error:
        await showJfOledDialog<void>(
          context: context,
          title: result.machineTitle.isEmpty
              ? 'SCAN ERROR'
              : result.machineTitle,
          body: result.supportText.isEmpty
              ? 'The Agora scan could not complete.'
              : result.supportText,
          confirmLabel: 'ACKNOWLEDGE',
          validationError: result.errorKind == KeryxScanErrorKind.invalidPlace,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final monitorHeight = JfMonitorModule.resolveMonitorHeight(context);
    final summary = _parameterSummary;

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
                      lines: _monitorLines,
                      monitorHeight: monitorHeight,
                      bandHeight: JfMonitorModule.defaultBandHeight,
                      coilMode: _coilMode,
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
                              onPressed: _openParameterDialog,
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
