import '../../features/scan_control/scan_control_state.dart';
import 'agora_event_signal.dart';

/// App-owned scan request (never built inside raw Firebase widgets).
class KeryxScanRequest {
  const KeryxScanRequest({
    required this.location,
    required this.timeWindow,
    required this.category,
    this.clientRequestId,
  });

  final String location;
  final TimeWindow timeWindow;
  final EventCategory category;
  final String? clientRequestId;

  String get timeWindowWire {
    switch (timeWindow) {
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

  String get categoryWire {
    switch (category) {
      case EventCategory.music:
        return 'MUSIC';
      case EventCategory.comedy:
        return 'COMEDY';
      case EventCategory.stage:
        return 'STAGE';
      case EventCategory.allSignals:
      case EventCategory.art:
      case EventCategory.gatherings:
        return 'MUSIC'; // V0.1 public surface never sends these
    }
  }

  String get categoryLabel => category.label;
  String get timeWindowLabel => timeWindow.label;
}

enum KeryxScanOutcome { results, empty, error }

enum KeryxScanErrorKind {
  invalidPlace,
  serviceUnavailable,
  timedOut,
  noNetwork,
  noSupportedSignals,
  malformedResponse,
  betaScanConsumed,
  unknown,
}

/// Honest result provenance for CRT / Open Record labeling.
enum KeryxResultOrigin {
  /// Fresh protected live callable response.
  live,

  /// Deterministic verified demonstration fixture.
  verifiedDemo,

  /// No completed discovery payload (errors / pre-scan failures).
  none,
}

class KeryxScanResult {
  const KeryxScanResult({
    required this.outcome,
    required this.request,
    this.signals = const [],
    this.errorKind,
    this.machineTitle = '',
    this.supportText = '',
    this.origin = KeryxResultOrigin.none,
    this.lastCheckedAt,
    this.elapsedMs,
  });

  final KeryxScanOutcome outcome;
  final KeryxScanRequest request;
  final List<AgoraEventSignal> signals;
  final KeryxScanErrorKind? errorKind;
  final String machineTitle;
  final String supportText;
  final KeryxResultOrigin origin;
  final DateTime? lastCheckedAt;
  final int? elapsedMs;

  int get signalCount => signals.length;

  bool get isDemo => origin == KeryxResultOrigin.verifiedDemo;
  bool get isLive => origin == KeryxResultOrigin.live;

  /// Restrained CRT provenance lines (no internal architecture jargon).
  List<String> get provenanceLines {
    switch (origin) {
      case KeryxResultOrigin.live:
        return [
          'LIVE KERYX SIGNALS',
          if (lastCheckedAt != null) 'LAST CHECKED ${_fmt(lastCheckedAt!)}',
        ];
      case KeryxResultOrigin.verifiedDemo:
        return [
          'VERIFIED KERYX SIGNALS',
          if (lastCheckedAt != null) 'LAST CHECKED ${_fmt(lastCheckedAt!)}',
        ];
      case KeryxResultOrigin.none:
        return const [];
    }
  }

  static String _fmt(DateTime d) {
    final l = d.toUtc();
    final y = l.year.toString().padLeft(4, '0');
    final m = l.month.toString().padLeft(2, '0');
    final day = l.day.toString().padLeft(2, '0');
    return '$y.$m.$day';
  }
}

/// Contest discovery service boundary (ADR-041 / ADR-042).
abstract interface class KeryxService {
  Future<KeryxScanResult> scan(KeryxScanRequest request);
}
