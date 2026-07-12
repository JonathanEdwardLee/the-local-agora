import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/features/scan_control/scan_control_state.dart';
import 'package:the_local_agora/main.dart';
import 'package:the_local_agora/services/keryx/beta_scan_allowance_store.dart';
import 'package:the_local_agora/services/keryx/demo_keryx_service.dart';
import 'package:the_local_agora/services/keryx/keryx_live_scan_service.dart';
import 'package:the_local_agora/services/keryx/keryx_service.dart';
import 'package:the_local_agora/services/keryx/live_callable_keryx_service.dart';
import 'package:the_local_agora/services/keryx/one_scan_beta_keryx_service.dart';

void main() {
  const musicReq = KeryxScanRequest(
    location: 'Springfield, Missouri',
    timeWindow: TimeWindow.nextSevenDays,
    category: EventCategory.music,
  );

  test('fresh installation can scan once', () async {
    final store = MemoryBetaScanStore();
    final inner = DemoKeryxService(searchDelay: Duration.zero);
    final svc = OneScanBetaKeryxService(inner: inner, allowance: store);
    final first = await svc.scan(musicReq);
    expect(first.outcome, KeryxScanOutcome.results);
    expect(await store.hasUsedBetaScan(), isTrue);
  });

  test('invalid input does not consume scan', () async {
    final store = MemoryBetaScanStore();
    final inner = DemoKeryxService(searchDelay: Duration.zero);
    final svc = OneScanBetaKeryxService(inner: inner, allowance: store);
    final bad = await svc.scan(
      const KeryxScanRequest(
        location: '',
        timeWindow: TimeWindow.nextSevenDays,
        category: EventCategory.music,
      ),
    );
    expect(bad.outcome, KeryxScanOutcome.error);
    expect(bad.errorKind, KeryxScanErrorKind.invalidPlace);
    expect(await store.hasUsedBetaScan(), isFalse);
  });

  test('network failure does not consume scan', () async {
    final store = MemoryBetaScanStore();
    final live = FakeKeryxLiveScanService(
      result: const KeryxLiveScanResult(
        ok: false,
        machineTitle: 'LIVE KERYX FAILED',
        supportText: 'network unavailable',
      ),
    );
    final svc = OneScanBetaKeryxService(
      inner: LiveCallableKeryxService(liveScan: live),
      allowance: store,
    );
    final result = await svc.scan(musicReq);
    expect(result.outcome, KeryxScanOutcome.error);
    expect(result.errorKind, KeryxScanErrorKind.noNetwork);
    expect(await store.hasUsedBetaScan(), isFalse);
  });

  test('timeout does not consume scan', () async {
    final store = MemoryBetaScanStore();
    final live = FakeKeryxLiveScanService(
      result: const KeryxLiveScanResult(
        ok: false,
        machineTitle: 'LIVE KERYX FAILED',
        supportText: 'deadline timeout exceeded',
      ),
    );
    final svc = OneScanBetaKeryxService(
      inner: LiveCallableKeryxService(liveScan: live),
      allowance: store,
    );
    final result = await svc.scan(musicReq);
    expect(result.errorKind, KeryxScanErrorKind.timedOut);
    expect(await store.hasUsedBetaScan(), isFalse);
  });

  test('completed non-empty result consumes scan', () async {
    final store = MemoryBetaScanStore();
    final live = FakeKeryxLiveScanService(
      result: const KeryxLiveScanResult(
        ok: true,
        machineTitle: 'LIVE KERYX RESULT READY',
        signalCount: 1,
        events: [
          KeryxLiveScanEvent(
            title: 'Live Show',
            date: '2026-07-12',
            sourceUrl: 'https://www.example.org/show',
          ),
        ],
      ),
    );
    final svc = OneScanBetaKeryxService(
      inner: LiveCallableKeryxService(liveScan: live),
      allowance: store,
    );
    final result = await svc.scan(musicReq);
    expect(result.outcome, KeryxScanOutcome.results);
    expect(result.isLive, isTrue);
    expect(result.signals.first.hasLaunchableSource, isTrue);
    expect(await store.hasUsedBetaScan(), isTrue);
  });

  test('completed empty result consumes scan', () async {
    final store = MemoryBetaScanStore();
    final live = FakeKeryxLiveScanService(
      result: const KeryxLiveScanResult(
        ok: true,
        machineTitle: 'LIVE KERYX RESULT READY',
        signalCount: 0,
        events: [],
      ),
    );
    final svc = OneScanBetaKeryxService(
      inner: LiveCallableKeryxService(liveScan: live),
      allowance: store,
    );
    final result = await svc.scan(musicReq);
    expect(result.outcome, KeryxScanOutcome.empty);
    expect(await store.hasUsedBetaScan(), isTrue);
  });

  test('second attempt shows exact beta error', () async {
    final store = MemoryBetaScanStore();
    final inner = DemoKeryxService(searchDelay: Duration.zero);
    final svc = OneScanBetaKeryxService(inner: inner, allowance: store);
    await svc.scan(musicReq);
    final second = await svc.scan(musicReq);
    expect(second.outcome, KeryxScanOutcome.error);
    expect(second.errorKind, KeryxScanErrorKind.betaScanConsumed);
    expect(second.machineTitle, 'ERR // ONLY ONE SCAN ALLOWED FOR BETA');
    expect(inner.callCount, 1);
  });

  test('preference persists across service reconstruction', () async {
    final store = MemoryBetaScanStore()..used = true;
    final svc = OneScanBetaKeryxService(
      inner: DemoKeryxService(searchDelay: Duration.zero),
      allowance: store,
    );
    final result = await svc.scan(musicReq);
    expect(result.machineTitle, 'ERR // ONLY ONE SCAN ALLOWED FOR BETA');
  });

  test('web resolve uses demo; android-ready uses one-scan live', () {
    final demo = resolveContestKeryxService(
      liveScanService: FakeKeryxLiveScanService(),
      isWeb: true,
    );
    expect(demo, isA<DemoKeryxService>());

    final live = resolveContestKeryxService(
      liveScanService: FakeKeryxLiveScanService(),
      isWeb: false,
      allowanceStore: MemoryBetaScanStore(),
    );
    expect(live, isA<OneScanBetaKeryxService>());

    final fallback = resolveContestKeryxService(
      liveScanService: null,
      isWeb: false,
    );
    expect(fallback, isA<DemoKeryxService>());
  });

  test('live mapping preserves source URL without showing host as title', () async {
    final live = FakeKeryxLiveScanService(
      result: const KeryxLiveScanResult(
        ok: true,
        machineTitle: 'LIVE KERYX RESULT READY',
        events: [
          KeryxLiveScanEvent(
            title: 'Night Show',
            date: '2026-07-11',
            venue: 'The Regency Live',
            sourceUrl:
                'https://vertexaisearch.cloud.google.com/grounding-api-redirect/abc',
          ),
        ],
        sources: [
          KeryxLiveScanSource(
            title: 'Venue calendar',
            url:
                'https://vertexaisearch.cloud.google.com/grounding-api-redirect/abc',
          ),
        ],
      ),
    );
    final svc = LiveCallableKeryxService(liveScan: live);
    final result = await svc.scan(musicReq);
    expect(result.signals.single.sourceLabel, 'Venue calendar');
    expect(
      result.signals.single.sourceUrl.toString(),
      contains('grounding-api-redirect'),
    );
  });
}
