import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/data/fixtures/springfield_keryx_demo_signals.dart';
import 'package:the_local_agora/features/scan_control/scan_control_state.dart';
import 'package:the_local_agora/services/keryx/agora_event_signal.dart';
import 'package:the_local_agora/services/keryx/demo_keryx_service.dart';
import 'package:the_local_agora/services/keryx/event_location_privacy.dart';
import 'package:the_local_agora/services/keryx/event_signal_sort.dart';
import 'package:the_local_agora/services/keryx/keryx_service.dart';

void main() {
  test('empty place rejected by demo service', () async {
    final svc = DemoKeryxService(searchDelay: Duration.zero);
    final result = await svc.scan(
      const KeryxScanRequest(
        location: '   ',
        timeWindow: TimeWindow.nextSevenDays,
        category: EventCategory.music,
      ),
    );
    expect(result.outcome, KeryxScanOutcome.error);
    expect(result.errorKind, KeryxScanErrorKind.invalidPlace);
  });

  test('Springfield MUSIC returns chronological demo signals', () async {
    final svc = DemoKeryxService(searchDelay: Duration.zero);
    final result = await svc.scan(
      const KeryxScanRequest(
        location: 'Springfield, Missouri',
        timeWindow: TimeWindow.nextSevenDays,
        category: EventCategory.music,
      ),
    );
    expect(result.outcome, KeryxScanOutcome.results);
    expect(result.signalCount, greaterThan(0));
    expect(result.isDemo, isTrue);
    expect(result.origin, KeryxResultOrigin.verifiedDemo);
    expect(result.provenanceLines.first, contains('VERIFIED DEMO RESULTS'));
    expect(result.signals.every((s) => s.category == 'MUSIC'), isTrue);
    // Stable chronological order
    final again = await svc.scan(
      const KeryxScanRequest(
        location: '65806',
        timeWindow: TimeWindow.nextSevenDays,
        category: EventCategory.music,
      ),
    );
    expect(
      again.signals.map((s) => s.id).toList(),
      result.signals.map((s) => s.id).toList(),
    );
  });

  test('THEATER returns empty for current demo fixture', () async {
    final svc = DemoKeryxService(searchDelay: Duration.zero);
    final result = await svc.scan(
      const KeryxScanRequest(
        location: 'Springfield, Missouri',
        timeWindow: TimeWindow.nextSevenDays,
        category: EventCategory.stage,
      ),
    );
    expect(result.outcome, KeryxScanOutcome.empty);
  });

  test('COMEDY returns comedy signals only', () async {
    final svc = DemoKeryxService(searchDelay: Duration.zero);
    final result = await svc.scan(
      const KeryxScanRequest(
        location: 'Springfield, Missouri',
        timeWindow: TimeWindow.nextSevenDays,
        category: EventCategory.comedy,
      ),
    );
    expect(result.outcome, KeryxScanOutcome.results);
    expect(result.signals.every((s) => s.category == 'COMEDY'), isTrue);
  });

  test('double-scan prevention while in flight', () async {
    final svc = DemoKeryxService(
      searchDelay: const Duration(milliseconds: 200),
    );
    final first = svc.scan(
      const KeryxScanRequest(
        location: 'Springfield, Missouri',
        timeWindow: TimeWindow.nextSevenDays,
        category: EventCategory.music,
      ),
    );
    final second = await svc.scan(
      const KeryxScanRequest(
        location: 'Springfield, Missouri',
        timeWindow: TimeWindow.nextSevenDays,
        category: EventCategory.music,
      ),
    );
    expect(second.outcome, KeryxScanOutcome.error);
    expect(second.machineTitle, 'ERR // SCAN ALREADY IN PROGRESS');
    await first;
    expect(svc.callCount, 1);
  });

  test('sort puts known starts before unknown times before unknown dates', () {
    final sorted = sortAgoraSignalsChronologically([
      AgoraEventSignal(id: 'u', title: 'Unknown', sourceLabel: 'A'),
      AgoraEventSignal(
        id: 'd',
        title: 'Date only',
        displayedDate: '2026-07-12',
        sourceLabel: 'A',
      ),
      AgoraEventSignal(
        id: 't',
        title: 'Timed',
        startsAt: DateTime(2026, 7, 11, 20),
        displayedDate: '2026-07-11',
        displayedTime: '20:00',
        sourceLabel: 'A',
      ),
    ]);
    expect(sorted.map((s) => s.id).toList(), ['t', 'd', 'u']);
  });

  test('fixture has no example.com placeholder sources', () {
    for (final s in springfieldDemoSignalsWithLastChecked()) {
      expect(s.sourceUrl, isNull);
      expect(s.sourceLabel, 'SOURCE NOT AVAILABLE IN THIS RECORD');
      expect(s.hasLaunchableSource, isFalse);
    }
  });

  test('fixture does not invent ticket prices', () {
    for (final s in springfieldDemoSignalsWithLastChecked()) {
      expect(s.summary?.toLowerCase().contains(r'$'), isFalse);
      expect(s.privacy, isNot(EventLocationPrivacy.askOrganizer));
    }
  });

  test('V0.1 dial categories remain music comedy theater', () {
    expect(kV01EventCategories.map((c) => c.label).toList(), [
      'MUSIC',
      'COMEDY',
      'THEATER',
    ]);
    expect(TimeWindow.values.map((t) => t.label).toList(), [
      'TONIGHT',
      'TOMORROW',
      'THIS WEEKEND',
      'NEXT 7 DAYS',
    ]);
  });
}
