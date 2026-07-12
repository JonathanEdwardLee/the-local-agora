import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/design/junkfeathers_theme.dart';
import 'package:the_local_agora/features/discovery/city_index_screen.dart';
import 'package:the_local_agora/features/discovery/open_record_screen.dart';
import 'package:the_local_agora/features/scan_control/scan_control_state.dart';
import 'package:the_local_agora/services/keryx/agora_event_signal.dart';
import 'package:the_local_agora/services/keryx/keryx_service.dart';
import 'package:the_local_agora/services/source_launch.dart';

void main() {
  final sample = AgoraEventSignal(
    id: 't1',
    title: 'Sample Signal',
    displayedDate: '2026-07-11',
    displayedTime: '20:00',
    venueName: 'The Regency Live',
    city: 'Springfield, Missouri',
    category: 'MUSIC',
    summary: 'Demo summary',
    sourceUrl: Uri.parse('https://example.com/agora-demo/sample'),
    sourceLabel: 'Venue calendar (demo provenance)',
  );

  testWidgets('City Index opens Open Record route', (tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final result = KeryxScanResult(
      outcome: KeryxScanOutcome.results,
      request: const KeryxScanRequest(
        location: 'Springfield, Missouri',
        timeWindow: TimeWindow.nextSevenDays,
        category: EventCategory.music,
      ),
      signals: [sample],
      demoProvenanceBanner: 'VERIFIED KERYX SIGNALS // DEMO FIXTURE',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: CityIndexScreen(result: result),
      ),
    );
    expect(find.text('1 SIGNAL FOUND'), findsOneWidget);
    expect(find.textContaining('vertexaisearch'), findsNothing);
    expect(
      find.text('SOURCE // Venue calendar (demo provenance)'),
      findsOneWidget,
    );

    await tester.tap(find.text('SAMPLE SIGNAL'));
    await tester.pumpAndSettle();
    expect(find.byType(OpenRecordScreen), findsOneWidget);
    expect(find.text('OPEN ORIGINAL SOURCE'), findsOneWidget);
    expect(find.textContaining('https://example.com'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('agora-record-back')));
    await tester.pumpAndSettle();
    expect(find.byType(CityIndexScreen), findsOneWidget);
  });

  test('invalid source URL is rejected without throwing', () async {
    expect(await openOriginalSource(null), SourceLaunchResult.invalid);
    expect(
      await openOriginalSource(Uri.parse('ftp://bad.example')),
      SourceLaunchResult.invalid,
    );
  });
}
