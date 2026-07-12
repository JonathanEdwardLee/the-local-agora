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
  final withSource = AgoraEventSignal(
    id: 't1',
    title: 'Sample Signal',
    displayedDate: '2026-07-11',
    displayedTime: '20:00',
    venueName: 'The Regency Live',
    city: 'Springfield, Missouri',
    category: 'MUSIC',
    summary: 'Demo summary',
    sourceUrl: Uri.parse('https://www.springfieldcomedyclub.com/events'),
    sourceLabel: 'Springfield Comedy Club',
  );

  final withoutSource = AgoraEventSignal(
    id: 't2',
    title: 'No Source Signal',
    displayedDate: '2026-07-12',
    category: 'MUSIC',
    sourceUrl: null,
    sourceLabel: 'SOURCE NOT AVAILABLE IN THIS RECORD',
  );

  testWidgets('Open Record hides raw URL and launches labeled source', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: OpenRecordScreen(signal: withSource),
      ),
    );
    expect(find.text('OPEN ORIGINAL SOURCE'), findsOneWidget);
    expect(find.textContaining('https://'), findsNothing);
    expect(find.text('Springfield Comedy Club'), findsOneWidget);
  });

  testWidgets('missing source omits open action', (tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: OpenRecordScreen(signal: withoutSource),
      ),
    );
    expect(find.text('OPEN ORIGINAL SOURCE'), findsNothing);
    expect(find.text('SOURCE NOT AVAILABLE IN THIS RECORD'), findsOneWidget);
  });

  testWidgets('legacy City Index still opens Open Record', (tester) async {
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
      signals: [withSource],
      origin: KeryxResultOrigin.verifiedDemo,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: CityIndexScreen(result: result),
      ),
    );
    await tester.tap(find.text('SAMPLE SIGNAL'));
    await tester.pumpAndSettle();
    expect(find.byType(OpenRecordScreen), findsOneWidget);
  });

  test('invalid source URL is rejected without throwing', () async {
    expect(await openOriginalSource(null), SourceLaunchResult.invalid);
    expect(
      await openOriginalSource(Uri.parse('ftp://bad.example')),
      SourceLaunchResult.invalid,
    );
  });
}
