import '../../data/fixtures/springfield_keryx_demo_signals.dart';
import '../../features/scan_control/scan_control_state.dart';
import 'event_signal_sort.dart';
import 'keryx_service.dart';

/// Deterministic verified-fixture discovery (tests / offline / web fallback).
///
/// Springfield / ZIP 65806 location matching stays inside this service only.
class DemoKeryxService implements KeryxService {
  DemoKeryxService({this.searchDelay = const Duration(milliseconds: 1100)});

  /// Short intentional searching transition (0.8–1.5 s).
  final Duration searchDelay;

  int callCount = 0;
  KeryxScanRequest? lastRequest;
  bool _inFlight = false;

  @override
  Future<KeryxScanResult> scan(KeryxScanRequest request) async {
    if (_inFlight) {
      return KeryxScanResult(
        outcome: KeryxScanOutcome.error,
        request: request,
        errorKind: KeryxScanErrorKind.serviceUnavailable,
        machineTitle: 'ERR // SCAN ALREADY IN PROGRESS',
        supportText: 'Wait for the current Agora scan to finish.',
        origin: KeryxResultOrigin.none,
      );
    }
    _inFlight = true;
    callCount += 1;
    lastRequest = request;
    try {
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

      await Future<void>.delayed(searchDelay);

      if (!_isSpringfieldDemoPlace(place)) {
        return KeryxScanResult(
          outcome: KeryxScanOutcome.empty,
          request: request,
          machineTitle: 'NO SUPPORTED SIGNALS FOUND',
          supportText:
              'TRY ANOTHER TIME WINDOW OR CATEGORY.\n'
              'YOU CAN ALSO ADD A PUBLIC EVENT FLYER.\n'
              'Demo fixture covers Springfield, Missouri / 65806.',
          origin: KeryxResultOrigin.verifiedDemo,
          lastCheckedAt: kSpringfieldDemoLastChecked,
          elapsedMs: searchDelay.inMilliseconds,
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
          origin: KeryxResultOrigin.verifiedDemo,
          lastCheckedAt: kSpringfieldDemoLastChecked,
          elapsedMs: searchDelay.inMilliseconds,
        );
      }

      final wanted = request.categoryWire == 'STAGE'
          ? 'THEATER'
          : request.category.label;
      final all = springfieldDemoSignalsWithLastChecked();
      final matched = all.where((s) {
        final cat = (s.category ?? '').toUpperCase();
        if (wanted == 'THEATER') {
          return cat == 'THEATER' || cat == 'STAGE';
        }
        return cat == wanted;
      }).toList();

      final sorted = sortAgoraSignalsChronologically(matched);
      if (sorted.isEmpty) {
        return KeryxScanResult(
          outcome: KeryxScanOutcome.empty,
          request: request,
          machineTitle: 'NO SUPPORTED SIGNALS FOUND',
          supportText:
              'TRY ANOTHER TIME WINDOW OR CATEGORY.\n'
              'YOU CAN ALSO ADD A PUBLIC EVENT FLYER.',
          origin: KeryxResultOrigin.verifiedDemo,
          lastCheckedAt: kSpringfieldDemoLastChecked,
          elapsedMs: searchDelay.inMilliseconds,
        );
      }

      return KeryxScanResult(
        outcome: KeryxScanOutcome.results,
        request: request,
        signals: sorted,
        machineTitle: 'AGORA SIGNALS READY',
        supportText:
            'Chronological index from verified Keryx demonstration signals.',
        origin: KeryxResultOrigin.verifiedDemo,
        lastCheckedAt: kSpringfieldDemoLastChecked,
        elapsedMs: searchDelay.inMilliseconds,
      );
    } finally {
      _inFlight = false;
    }
  }

  static bool _isV01Category(EventCategory category) {
    return category == EventCategory.music ||
        category == EventCategory.comedy ||
        category == EventCategory.stage;
  }

  static bool _isSpringfieldDemoPlace(String raw) {
    final n = raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (n.contains('65806')) return true;
    if (n.contains('springfield') && n.contains('missouri')) return true;
    if (n == 'springfield, mo') return true;
    if (n == 'springfield mo') return true;
    if (n == 'springfield') return true;
    return false;
  }
}
