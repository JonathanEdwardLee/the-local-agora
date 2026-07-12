import '../../features/scan_control/scan_control_state.dart';
import 'agora_event_signal.dart';
import 'event_location_privacy.dart';
import 'event_signal_sort.dart';
import 'keryx_live_scan_service.dart';
import 'keryx_service.dart';

/// Production/contest live path — one protected `keryxScanDebug` callable via
/// [KeryxLiveScanService]. No Flutter auto-retry.
class LiveCallableKeryxService implements KeryxService {
  LiveCallableKeryxService({required this.liveScan, this.inFlightGuard = true});

  final KeryxLiveScanService liveScan;
  final bool inFlightGuard;

  bool _inFlight = false;
  int callCount = 0;

  @override
  Future<KeryxScanResult> scan(KeryxScanRequest request) async {
    if (inFlightGuard && _inFlight) {
      return KeryxScanResult(
        outcome: KeryxScanOutcome.error,
        request: request,
        errorKind: KeryxScanErrorKind.serviceUnavailable,
        machineTitle: 'ERR // SCAN ALREADY IN PROGRESS',
        supportText: 'Wait for the current Agora scan to finish.',
        origin: KeryxResultOrigin.none,
      );
    }

    final place = request.location.trim();
    if (place.isEmpty) {
      return KeryxScanResult(
        outcome: KeryxScanOutcome.error,
        request: request,
        errorKind: KeryxScanErrorKind.invalidPlace,
        machineTitle: 'LOCATION REQUIRED',
        supportText: 'Enter a city or ZIP code before scanning the Agora.',
        origin: KeryxResultOrigin.none,
      );
    }

    if (!_isV01Category(request.category)) {
      return KeryxScanResult(
        outcome: KeryxScanOutcome.empty,
        request: request,
        machineTitle: 'NO SUPPORTED SIGNALS FOUND',
        supportText:
            'TRY ANOTHER TIME WINDOW OR CATEGORY.\n'
            'YOU CAN ALSO ADD A PUBLIC EVENT FLYER.',
        origin: KeryxResultOrigin.live,
        lastCheckedAt: DateTime.now().toUtc(),
      );
    }

    _inFlight = true;
    callCount += 1;
    try {
      final live = await liveScan.runDebugScan(
        location: place,
        timeWindow: request.timeWindowWire,
        category: request.categoryWire,
        clientRequestId: request.clientRequestId,
      );

      if (!live.ok) {
        return _mapFailure(request, live);
      }

      final checked = DateTime.now().toUtc();
      final signals = <AgoraEventSignal>[];
      for (var i = 0; i < live.events.length; i++) {
        final e = live.events[i];
        final url = _parseHttpUrl(e.sourceUrl);
        signals.add(
          AgoraEventSignal(
            id: 'live-${checked.millisecondsSinceEpoch}-$i',
            title: e.title,
            displayedDate: e.date,
            displayedTime: e.startTime,
            venueName: e.venue,
            city: e.city,
            category: request.categoryLabel,
            sourceUrl: url,
            sourceLabel: _sourceLabel(url, e.sourceUrl, live.sources),
            lastCheckedAt: checked,
            privacy: e.venue != null && e.venue!.trim().isNotEmpty
                ? EventLocationPrivacy.venueOnly
                : EventLocationPrivacy.cityOnly,
            uncertainties: [
              if (e.startTime == null || e.startTime!.trim().isEmpty)
                'TIME NOT CONFIRMED',
              if (e.venue == null || e.venue!.trim().isEmpty)
                'VENUE NOT CONFIRMED',
            ],
          ),
        );
      }

      final sorted = sortAgoraSignalsChronologically(signals);
      if (sorted.isEmpty) {
        return KeryxScanResult(
          outcome: KeryxScanOutcome.empty,
          request: request,
          machineTitle: 'NO SUPPORTED SIGNALS FOUND',
          supportText:
              'TRY ANOTHER TIME WINDOW OR CATEGORY.\n'
              'YOU CAN ALSO ADD A PUBLIC EVENT FLYER.',
          origin: KeryxResultOrigin.live,
          lastCheckedAt: checked,
          elapsedMs: live.elapsedMs,
        );
      }

      return KeryxScanResult(
        outcome: KeryxScanOutcome.results,
        request: request,
        signals: sorted,
        machineTitle: 'AGORA SIGNALS READY',
        supportText: 'Chronological index from a live Keryx scan.',
        origin: KeryxResultOrigin.live,
        lastCheckedAt: checked,
        elapsedMs: live.elapsedMs,
      );
    } finally {
      _inFlight = false;
    }
  }

  static KeryxScanResult _mapFailure(
    KeryxScanRequest request,
    KeryxLiveScanResult live,
  ) {
    final msg = live.supportText.toLowerCase();
    var kind = KeryxScanErrorKind.unknown;
    var title = 'ERR // LIVE KERYX FAILED';
    if (msg.contains('timeout') || msg.contains('deadline')) {
      kind = KeryxScanErrorKind.timedOut;
      title = 'ERR // SCAN TIMED OUT';
    } else if (msg.contains('network') ||
        msg.contains('unavailable') ||
        msg.contains('offline')) {
      kind = KeryxScanErrorKind.noNetwork;
      title = 'ERR // NETWORK UNAVAILABLE';
    } else if (msg.contains('malform') || msg.contains('unexpected payload')) {
      kind = KeryxScanErrorKind.malformedResponse;
      title = 'ERR // MALFORMED RESPONSE';
    } else if (msg.contains('app check') || msg.contains('not ready')) {
      kind = KeryxScanErrorKind.serviceUnavailable;
      title = 'ERR // SERVICE UNAVAILABLE';
    }

    return KeryxScanResult(
      outcome: KeryxScanOutcome.error,
      request: request,
      errorKind: kind,
      machineTitle: title,
      supportText: live.supportText.isEmpty
          ? 'The live Keryx scan could not complete.'
          : live.supportText,
      origin: KeryxResultOrigin.none,
      elapsedMs: live.elapsedMs,
    );
  }

  static Uri? _parseHttpUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;
    if (!(uri.isScheme('https') || uri.isScheme('http'))) return null;
    if (uri.host.isEmpty) return null;
    return uri;
  }

  /// Human-readable label — never dump long grounding redirect URLs as body copy.
  static String _sourceLabel(
    Uri? parsed,
    String? raw,
    List<KeryxLiveScanSource> sources,
  ) {
    if (parsed == null) return 'SOURCE NOT AVAILABLE IN THIS RECORD';
    for (final s in sources) {
      if (s.url == raw && s.title != null && s.title!.trim().isNotEmpty) {
        return s.title!.trim();
      }
    }
    final host = parsed.host.toLowerCase();
    if (host.contains('vertexaisearch') ||
        host.contains('grounding-api-redirect') ||
        host.endsWith('google.com')) {
      return 'Original source';
    }
    return host;
  }

  static bool _isV01Category(EventCategory category) {
    return category == EventCategory.music ||
        category == EventCategory.comedy ||
        category == EventCategory.stage;
  }
}
