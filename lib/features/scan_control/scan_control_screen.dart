import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design/jf_device_button.dart';
import '../../design/jf_machine_identity_panel.dart';
import '../../design/jf_monitor_module.dart';
import '../../design/jf_panel.dart';
import '../../design/jf_search_parameter_dialog.dart';
import '../../design/jf_signal_coil.dart';
import '../../design/junkfeathers_tokens.dart';
import '../../services/keryx/demo_keryx_service.dart';
import '../../services/keryx/keryx_link_service.dart';
import '../../services/keryx/keryx_live_scan_service.dart';
import '../../services/keryx/keryx_service.dart';
import '../debug/debug_component_gallery.dart';
import '../discovery/agora_scan_phase.dart';
import '../discovery/crt_searching_animation.dart';
import '../discovery/crt_signal_record.dart';
import 'scan_control_state.dart';

/// SCREEN 1 — SCAN CONTROL
/// Pass 03.2: welcome CRT, SEARCH FOR AN EVENT overlay, CRT-hosted results.
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
  final KeryxService? keryxService;
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

  Future<void> _openSearchOverlay() async {
    if (_paramDialogOpen || _scanInFlight) return;

    if (await _keryx.hasConsumedBetaAllowance()) {
      if (!mounted) return;
      setState(() {
        _phase = AgoraScanPhase.error;
        _lastResult = KeryxScanResult(
          outcome: KeryxScanOutcome.error,
          request: KeryxScanRequest(
            location: _state.locationText,
            timeWindow: _state.timeWindow ?? TimeWindow.nextSevenDays,
            category: _state.category ?? EventCategory.music,
          ),
          errorKind: KeryxScanErrorKind.betaScanConsumed,
          machineTitle: 'ERR // ONLY ONE SCAN ALLOWED FOR BETA',
          supportText:
              'This installation has already used its contest beta event search.',
        );
      });
      return;
    }

    if (!mounted) return;
    _paramDialogOpen = true;
    final result = await showJfSearchParameterDialog(
      context: context,
      locationController: _locationController,
      locationFocus: _locationFocus,
      timeWindow: _state.timeWindow,
      category: _state.category,
      locationError: _state.locationError,
      timeWindowError: _state.timeWindowError,
      categoryError: _state.categoryError,
      onFocusChange: (focused) {
        setState(() => _fieldFocused = focused);
      },
    );
    _paramDialogOpen = false;
    if (!mounted) return;

    if (result == null) {
      setState(() {});
      return;
    }

    setState(() {
      _state = _state.copyWith(
        locationText: result.location.isNotEmpty
            ? result.location
            : _locationController.text,
        timeWindow: result.timeWindow,
        category: result.category,
        clearLocationError: true,
        clearTimeWindowError: true,
        clearCategoryError: true,
        clearTimeWindow: result.timeWindow == null,
        clearCategory: result.category == null,
      );
    });

    if (result.action == SearchOverlayAction.cancelled) {
      return;
    }

    await _runScan(
      location: result.location,
      timeWindow: result.timeWindow!,
      category: result.category!,
    );
  }

  Future<void> _runScan({
    required String location,
    required TimeWindow timeWindow,
    required EventCategory category,
  }) async {
    if (_scanInFlight) return;

    setState(() {
      _scanInFlight = true;
      _phase = AgoraScanPhase.searching;
      // Keep prior results visible only until searching replaces CRT body.
      _lastResult = null;
    });

    final request = KeryxScanRequest(
      location: location,
      timeWindow: timeWindow,
      category: category,
    );

    final scanResult = await _keryx.scan(request);
    if (!mounted) return;

    setState(() {
      _scanInFlight = false;
      _lastResult = scanResult;
      switch (scanResult.outcome) {
        case KeryxScanOutcome.results:
          _phase = AgoraScanPhase.results;
        case KeryxScanOutcome.empty:
          _phase = AgoraScanPhase.empty;
        case KeryxScanOutcome.error:
          _phase = AgoraScanPhase.error;
      }
    });

    if (_crtScroll.hasClients) {
      _crtScroll.jumpTo(0);
    }
  }

  Widget _crtBody() {
    switch (_phase) {
      case AgoraScanPhase.idle:
      case AgoraScanPhase.validating:
        return const _WelcomeCrtBody();
      case AgoraScanPhase.searching:
        return CrtSearchingAnimation(
          location: _state.locationText.trim(),
          timeFrameLabel: _state.timeWindow?.label ?? '',
          eventTypeLabel: _state.category?.label ?? '',
        );
      case AgoraScanPhase.results:
        final result = _lastResult;
        if (result == null) return const _WelcomeCrtBody();
        return _ResultsCrtBody(result: result);
      case AgoraScanPhase.empty:
        final result = _lastResult;
        return _StatusCrtBody(
          title: 'NO SUPPORTED EVENTS FOUND',
          support: result?.supportText.isNotEmpty == true
              ? result!.supportText
              : 'TRY ANOTHER TIME FRAME OR EVENT TYPE.',
          provenance: result?.provenanceLines ?? const [],
        );
      case AgoraScanPhase.error:
        final result = _lastResult;
        final raw = result?.machineTitle ?? '';
        final title = raw.contains('ONLY ONE SCAN ALLOWED FOR BETA')
            ? 'ERR // ONLY ONE SCAN ALLOWED FOR BETA'
            : (raw.startsWith('ERR //')
                  ? raw
                  : (raw.isEmpty ? 'EVENT SEARCH FAILED' : raw));
        return _StatusCrtBody(
          title: title,
          support: result?.errorKind == KeryxScanErrorKind.betaScanConsumed
              ? (result?.supportText ?? '')
              : '',
          provenance: const [],
          emphasizeError: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final monitorHeight = JfMonitorModule.resolveMonitorHeight(context);
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
                      lines: const [],
                      crtBody: _crtBody(),
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
                            JfDeviceButton(
                              key: const ValueKey('jf-open-params'),
                              label: 'SEARCH FOR AN EVENT',
                              semanticLabel: 'Search for an event',
                              onPressed: _scanInFlight
                                  ? null
                                  : _openSearchOverlay,
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

class _WelcomeCrtBody extends StatefulWidget {
  const _WelcomeCrtBody();

  @override
  State<_WelcomeCrtBody> createState() => _WelcomeCrtBodyState();
}

class _WelcomeCrtBodyState extends State<_WelcomeCrtBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursor;

  @override
  void initState() {
    super.initState();
    _cursor = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'WELCOME',
          style: JfTypography.controlLabel.copyWith(
            color: JfColors.signalGreen,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: JfSpacing.sm),
        Text(
          'SEARCH FOR AN EVENT NEAR YOU',
          style: JfTypography.supporting.copyWith(fontSize: 12),
        ),
        Text(
          'USING THE CONTROL BELOW.',
          style: JfTypography.supporting.copyWith(fontSize: 12),
        ),
        const SizedBox(height: JfSpacing.md),
        AnimatedBuilder(
          animation: _cursor,
          builder: (context, _) {
            final opacity = reduce ? 1.0 : _cursor.value;
            return Text(
              '█',
              style: JfTypography.supporting.copyWith(
                color: JfColors.signalGreen.withValues(alpha: opacity),
                fontSize: 14,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ResultsCrtBody extends StatelessWidget {
  const _ResultsCrtBody({required this.result});

  final KeryxScanResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'UPCOMING EVENTS',
          style: JfTypography.controlLabel.copyWith(
            color: JfColors.signalGreen,
            fontSize: 12,
          ),
        ),
        for (final line in result.provenanceLines)
          Text(
            line,
            style: JfTypography.micro.copyWith(
              color: JfColors.signalGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          result.eventsFoundLabel(),
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
        for (final signal in result.signals) CrtSignalRecord(signal: signal),
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
