import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Safe client-facing live debug scan result (no secrets / stack traces).
class KeryxLiveScanResult {
  const KeryxLiveScanResult({
    required this.ok,
    required this.machineTitle,
    this.supportText = '',
    this.signalCount = 0,
    this.events = const [],
    this.sources = const [],
    this.warnings = const [],
    this.elapsedMs,
    this.cacheStatus = 'not_implemented',
    this.requestId,
    this.stage,
  });

  final bool ok;
  final String machineTitle;
  final String supportText;
  final int signalCount;
  final List<KeryxLiveScanEvent> events;
  final List<KeryxLiveScanSource> sources;
  final List<String> warnings;
  final int? elapsedMs;
  final String cacheStatus;
  final String? requestId;
  final String? stage;

  static const untested = KeryxLiveScanResult(
    ok: false,
    machineTitle: 'LIVE KERYX UNTESTED',
    supportText: 'No live debug scan has been run in this session.',
  );

  static const unavailable = KeryxLiveScanResult(
    ok: false,
    machineTitle: 'LIVE KERYX UNAVAILABLE',
    supportText:
        'App Check or Firebase is not ready. Live debug scan stays blocked.',
  );
}

class KeryxLiveScanEvent {
  const KeryxLiveScanEvent({
    required this.title,
    this.date,
    this.startTime,
    this.venue,
    this.city,
    this.sourceUrl,
  });

  final String title;
  final String? date;
  final String? startTime;
  final String? venue;
  final String? city;
  final String? sourceUrl;
}

class KeryxLiveScanSource {
  const KeryxLiveScanSource({this.title, required this.url});

  final String? title;
  final String url;
}

abstract class KeryxLiveScanService {
  Future<KeryxLiveScanResult> runDebugScan({
    required String location,
    required String timeWindow,
    required String category,
    String? clientRequestId,
    void Function(String stage)? onStage,
  });
}

class FakeKeryxLiveScanService implements KeryxLiveScanService {
  FakeKeryxLiveScanService({this.result, this.delay = Duration.zero});

  final KeryxLiveScanResult? result;
  final Duration delay;
  int callCount = 0;
  Map<String, dynamic>? lastRequest;

  @override
  Future<KeryxLiveScanResult> runDebugScan({
    required String location,
    required String timeWindow,
    required String category,
    String? clientRequestId,
    void Function(String stage)? onStage,
  }) async {
    callCount += 1;
    lastRequest = {
      'location': location,
      'timeWindow': timeWindow,
      'category': category,
      'clientRequestId': clientRequestId,
    };
    onStage?.call('CONTACTING KERYX');
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return result ??
        KeryxLiveScanResult(
          ok: true,
          machineTitle: 'LIVE KERYX RESULT READY',
          supportText: 'Fake debug result.',
          signalCount: 1,
          events: const [
            KeryxLiveScanEvent(title: 'FAKE SIGNAL', date: '2026-07-11'),
          ],
          cacheStatus: 'not_implemented',
          elapsedMs: delay.inMilliseconds,
        );
  }
}

/// Calls deployed `keryxScanDebug` in us-central1. Debug-only. Billable.
class FirebaseKeryxLiveScanService implements KeryxLiveScanService {
  FirebaseKeryxLiveScanService({
    FirebaseFunctions? functions,
    this.timeout = const Duration(seconds: 120),
  }) : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;
  final Duration timeout;

  @override
  Future<KeryxLiveScanResult> runDebugScan({
    required String location,
    required String timeWindow,
    required String category,
    String? clientRequestId,
    void Function(String stage)? onStage,
  }) async {
    final started = DateTime.now();
    try {
      onStage?.call('CONTACTING KERYX');
      final callable = _functions.httpsCallable(
        'keryxScanDebug',
        options: HttpsCallableOptions(timeout: timeout),
      );
      onStage?.call('SEARCHING PUBLIC SIGNALS');
      final response = await callable.call(<String, dynamic>{
        'location': location,
        'timeWindow': timeWindow,
        'category': category,
        'clientRequestId': ?clientRequestId,
      });
      onStage?.call('CHECKING SOURCES');
      onStage?.call('NORMALIZING RECORDS');
      return parseKeryxLiveScanPayload(
        response.data,
        elapsedMs: DateTime.now().difference(started).inMilliseconds,
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('keryxScanDebug Functions error: ${e.code}');
      return KeryxLiveScanResult(
        ok: false,
        machineTitle: 'LIVE KERYX FAILED',
        supportText: _sanitizeUserMessage(e.message ?? e.code),
        elapsedMs: DateTime.now().difference(started).inMilliseconds,
      );
    } catch (e) {
      debugPrint('keryxScanDebug failed: ${e.runtimeType}');
      return KeryxLiveScanResult(
        ok: false,
        machineTitle: 'LIVE KERYX FAILED',
        supportText: 'The live debug scan could not complete.',
        elapsedMs: DateTime.now().difference(started).inMilliseconds,
      );
    }
  }
}

String _sanitizeUserMessage(String raw) {
  return raw
      .replaceAll(RegExp(r'AIza[0-9A-Za-z_-]{10,}'), '[REDACTED]')
      .replaceAll(RegExp(r'GEMINI_API_KEY', caseSensitive: false), '[REDACTED]')
      .trim();
}

KeryxLiveScanResult parseKeryxLiveScanPayload(
  Object? raw, {
  int? elapsedMs,
}) {
  if (raw is! Map) {
    return const KeryxLiveScanResult(
      ok: false,
      machineTitle: 'LIVE KERYX MALFORMED',
      supportText: 'The server returned an unexpected payload.',
    );
  }
  final map = Map<String, dynamic>.from(raw);
  final schemaVersion = map['schemaVersion'];
  final eventsRaw = map['events'];
  if (schemaVersion is! String || eventsRaw is! List) {
    return const KeryxLiveScanResult(
      ok: false,
      machineTitle: 'LIVE KERYX MALFORMED',
      supportText: 'The server returned an unexpected payload.',
    );
  }

  final events = <KeryxLiveScanEvent>[];
  for (final item in eventsRaw.take(12)) {
    if (item is! Map) continue;
    final e = Map<String, dynamic>.from(item);
    final title = e['title'];
    if (title is! String || title.trim().isEmpty) continue;
    events.add(
      KeryxLiveScanEvent(
        title: title,
        date: e['date'] is String ? e['date'] as String : null,
        startTime: e['startTime'] is String ? e['startTime'] as String : null,
        venue: e['venue'] is String ? e['venue'] as String : null,
        city: e['city'] is String ? e['city'] as String : null,
        sourceUrl: e['sourceUrl'] is String ? e['sourceUrl'] as String : null,
      ),
    );
  }

  final sources = <KeryxLiveScanSource>[];
  final sourcesRaw = map['sources'];
  if (sourcesRaw is List) {
    for (final item in sourcesRaw.take(24)) {
      if (item is! Map) continue;
      final s = Map<String, dynamic>.from(item);
      final url = s['url'];
      if (url is! String || url.isEmpty) continue;
      sources.add(
        KeryxLiveScanSource(
          title: s['title'] is String ? s['title'] as String : null,
          url: url,
        ),
      );
    }
  }

  final warnings = <String>[];
  final warningsRaw = map['warnings'];
  if (warningsRaw is List) {
    for (final w in warningsRaw) {
      if (w is String && w.trim().isNotEmpty) warnings.add(w.trim());
    }
  }

  return KeryxLiveScanResult(
    ok: true,
    machineTitle: 'LIVE KERYX RESULT READY',
    supportText: '${events.length} signal(s) returned. Cache not implemented.',
    signalCount: events.length,
    events: events,
    sources: sources,
    warnings: warnings,
    elapsedMs: elapsedMs,
    cacheStatus: map['cacheStatus'] is String
        ? map['cacheStatus'] as String
        : 'not_implemented',
    requestId: map['requestId'] is String ? map['requestId'] as String : null,
  );
}
