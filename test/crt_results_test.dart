import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/design/junkfeathers_tokens.dart';
import 'package:the_local_agora/features/discovery/crt_searching_animation.dart';
import 'package:the_local_agora/features/scan_control/scan_control_screen.dart';
import 'package:the_local_agora/main.dart';
import 'package:the_local_agora/services/keryx/demo_keryx_service.dart';
import 'package:the_local_agora/services/keryx/keryx_service.dart';

Future<void> _pumpDialog(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump(JfMotion.press);
  await tester.pump();
}

Future<void> _fillAndScan(
  WidgetTester tester, {
  String location = 'Springfield, Missouri',
  String whenKey = 'jf-when-nextSevenDays',
  String whatKey = 'jf-what-music',
}) async {
  await _tap(tester, find.byKey(const ValueKey('jf-open-params')));
  await _pumpDialog(tester);
  await tester.enterText(find.byType(TextField), location);
  await tester.pump();
  await _tap(tester, find.byKey(ValueKey(whenKey)));
  await _tap(tester, find.byKey(ValueKey(whatKey)));
  await _tap(tester, find.byKey(const ValueKey('jf-param-scan')));
  await _pumpDialog(tester);
}

void main() {
  Future<void> pumpScan(
    WidgetTester tester, {
    required KeryxService service,
  }) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      TheLocalAgoraApp(
        enableStartupSplash: false,
        autoShowWelcome: false,
        keryxService: service,
      ),
    );
    await tester.pump();
  }

  testWidgets('welcome CRT and SEARCH FOR AN EVENT primary control', (
    tester,
  ) async {
    await pumpScan(
      tester,
      service: DemoKeryxService(searchDelay: Duration.zero),
    );
    expect(find.text('WELCOME'), findsOneWidget);
    expect(find.text('SEARCH FOR AN EVENT NEAR YOU'), findsOneWidget);
    expect(find.text('SEARCH FOR AN EVENT'), findsOneWidget);
    expect(find.text('SCAN THE AGORA'), findsNothing);
    expect(find.textContaining('SPRINGFIELD'), findsNothing);
    expect(find.textContaining('WINDOW //'), findsNothing);
    expect(find.textContaining('SIGNAL TYPE'), findsNothing);
  });

  testWidgets('overlay cancel does not scan', (tester) async {
    final svc = DemoKeryxService(searchDelay: Duration.zero);
    await pumpScan(tester, service: svc);
    await _tap(tester, find.byKey(const ValueKey('jf-open-params')));
    await _pumpDialog(tester);
    expect(find.text('SEARCH FOR AN EVENT'), findsWidgets);
    await _tap(tester, find.byKey(const ValueKey('jf-param-close')));
    await _pumpDialog(tester);
    expect(svc.callCount, 0);
    expect(find.text('WELCOME'), findsOneWidget);
  });

  testWidgets('invalid location keeps overlay open', (tester) async {
    await pumpScan(
      tester,
      service: DemoKeryxService(searchDelay: Duration.zero),
    );
    await _tap(tester, find.byKey(const ValueKey('jf-open-params')));
    await _pumpDialog(tester);
    await _tap(tester, find.byKey(const ValueKey('jf-when-nextSevenDays')));
    await _tap(tester, find.byKey(const ValueKey('jf-what-music')));
    await _tap(tester, find.byKey(const ValueKey('jf-param-scan')));
    await tester.pump();
    expect(find.textContaining('LOCATION REQUIRED'), findsWidgets);
    expect(find.byKey(const ValueKey('jf-param-scan')), findsOneWidget);
  });

  testWidgets('missing time frame keeps overlay open', (tester) async {
    await pumpScan(
      tester,
      service: DemoKeryxService(searchDelay: Duration.zero),
    );
    await _tap(tester, find.byKey(const ValueKey('jf-open-params')));
    await _pumpDialog(tester);
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    await _tap(tester, find.byKey(const ValueKey('jf-what-music')));
    await _tap(tester, find.byKey(const ValueKey('jf-param-scan')));
    await tester.pump();
    expect(find.text('TIME FRAME REQUIRED'), findsOneWidget);
    expect(find.byKey(const ValueKey('jf-param-scan')), findsOneWidget);
  });

  testWidgets('valid scan shows CRT events without Open Record', (
    tester,
  ) async {
    await pumpScan(
      tester,
      service: DemoKeryxService(searchDelay: Duration.zero),
    );
    await _fillAndScan(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(ScanControlScreen), findsOneWidget);
    expect(find.text('UPCOMING EVENTS'), findsOneWidget);
    expect(find.textContaining('EVENTS FOUND'), findsOneWidget);
    expect(find.textContaining('VERIFIED DEMO RESULTS'), findsOneWidget);
    expect(find.text('OPEN RECORD'), findsNothing);
    expect(find.text('CITY INDEX'), findsNothing);
    expect(find.text('LIVE KERYX SIGNALS'), findsNothing);
    expect(find.text('ADD TO CALENDAR // SOON'), findsWidgets);
    expect(find.text('SOURCE NOT AVAILABLE'), findsWidgets);
  });

  testWidgets('searching animation appears during scan', (tester) async {
    await pumpScan(
      tester,
      service: DemoKeryxService(searchDelay: const Duration(milliseconds: 400)),
    );
    await _fillAndScan(tester);
    expect(find.byType(CrtSearchingAnimation), findsOneWidget);
    expect(find.textContaining('SEARCHING'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump();
    expect(find.byType(CrtSearchingAnimation), findsNothing);
    expect(find.textContaining('EVENTS FOUND'), findsOneWidget);
  });

  testWidgets('theater empty uses public language', (tester) async {
    await pumpScan(
      tester,
      service: DemoKeryxService(searchDelay: Duration.zero),
    );
    await _fillAndScan(tester, whatKey: 'jf-what-stage');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('NO SUPPORTED EVENTS FOUND'), findsOneWidget);
  });

  testWidgets('beta lock on SEARCH shows exact error', (tester) async {
    await pumpScan(tester, service: _BlockingService());
    await _tap(tester, find.byKey(const ValueKey('jf-open-params')));
    await tester.pump();
    expect(find.text('ERR // ONLY ONE SCAN ALLOWED FOR BETA'), findsOneWidget);
    expect(find.byKey(const ValueKey('jf-param-scan')), findsNothing);
  });

  testWidgets('double scan tap creates one service call', (tester) async {
    final svc = DemoKeryxService(
      searchDelay: const Duration(milliseconds: 300),
    );
    await pumpScan(tester, service: svc);
    await _tap(tester, find.byKey(const ValueKey('jf-open-params')));
    await _pumpDialog(tester);
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    await _tap(tester, find.byKey(const ValueKey('jf-when-nextSevenDays')));
    await _tap(tester, find.byKey(const ValueKey('jf-what-music')));
    await tester.tap(find.byKey(const ValueKey('jf-param-scan')));
    await tester.tap(find.byKey(const ValueKey('jf-param-scan')));
    await _pumpDialog(tester);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    expect(svc.callCount, 1);
  });
}

class _BlockingService implements KeryxService {
  @override
  Future<bool> hasConsumedBetaAllowance() async => true;

  @override
  Future<KeryxScanResult> scan(KeryxScanRequest request) async {
    fail('scan should not be called when beta is consumed');
  }
}
