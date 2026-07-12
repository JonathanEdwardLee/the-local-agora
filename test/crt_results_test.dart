import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/design/junkfeathers_tokens.dart';
import 'package:the_local_agora/features/discovery/open_record_screen.dart';
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

void main() {
  Future<void> pumpScan(
    WidgetTester tester, {
    required KeryxService service,
  }) async {
    tester.view.physicalSize = const Size(400, 1600);
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

  Future<void> fillSpringfield(WidgetTester tester) async {
    await _tap(tester, find.byKey(const ValueKey('jf-open-params')));
    await _pumpDialog(tester);
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    await _tap(tester, find.byKey(const ValueKey('jf-param-close')));
    await _pumpDialog(tester);
  }

  testWidgets('successful scan stays on Scan Control with CRT results', (
    tester,
  ) async {
    await pumpScan(
      tester,
      service: DemoKeryxService(searchDelay: Duration.zero),
    );
    await fillSpringfield(tester);
    await _tap(tester, find.byKey(const ValueKey('jf-scan-agora')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(ScanControlScreen), findsOneWidget);
    expect(find.text('CITY INDEX'), findsNothing);
    expect(find.textContaining('SIGNALS FOUND'), findsOneWidget);
    expect(find.text('OPEN RECORD'), findsWidgets);
    expect(find.textContaining('VERIFIED KERYX SIGNALS'), findsOneWidget);
  });

  testWidgets('searching state appears inside CRT before results', (
    tester,
  ) async {
    await pumpScan(
      tester,
      service: DemoKeryxService(searchDelay: const Duration(milliseconds: 400)),
    );
    await fillSpringfield(tester);
    await _tap(tester, find.byKey(const ValueKey('jf-scan-agora')));
    expect(find.text('SEARCHING THE AGORA'), findsOneWidget);
    expect(find.byType(ScanControlScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump();
    expect(find.text('SEARCHING THE AGORA'), findsNothing);
    expect(find.textContaining('SIGNALS FOUND'), findsOneWidget);
  });

  testWidgets('OPEN RECORD pushes detail and back preserves results', (
    tester,
  ) async {
    final svc = DemoKeryxService(searchDelay: Duration.zero);
    await pumpScan(tester, service: svc);
    await fillSpringfield(tester);
    await _tap(tester, find.byKey(const ValueKey('jf-scan-agora')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(svc.callCount, 1);
    expect(find.textContaining('SIGNALS FOUND'), findsOneWidget);

    await _tap(tester, find.text('OPEN RECORD').first);
    await _pumpDialog(tester);
    expect(find.byType(OpenRecordScreen), findsOneWidget);

    await _tap(tester, find.byKey(const ValueKey('agora-record-back')));
    await _pumpDialog(tester);
    expect(find.byType(ScanControlScreen), findsOneWidget);
    expect(find.textContaining('SIGNALS FOUND'), findsOneWidget);
    expect(svc.callCount, 1);
  });

  testWidgets('empty CRT state for theater demo', (tester) async {
    await pumpScan(
      tester,
      service: DemoKeryxService(searchDelay: Duration.zero),
    );
    await _tap(tester, find.byKey(const ValueKey('jf-open-params')));
    await _pumpDialog(tester);
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    await _tap(tester, find.byKey(const ValueKey('jf-dial-next-WHAT')));
    await _tap(tester, find.byKey(const ValueKey('jf-dial-next-WHAT')));
    expect(find.text('THEATER'), findsWidgets);
    await _tap(tester, find.byKey(const ValueKey('jf-param-close')));
    await _pumpDialog(tester);
    await _tap(tester, find.byKey(const ValueKey('jf-scan-agora')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('NO SUPPORTED SIGNALS FOUND'), findsOneWidget);
    expect(find.text('CITY INDEX'), findsNothing);
  });

  testWidgets('CRT body scroll host exists for results', (tester) async {
    await pumpScan(
      tester,
      service: DemoKeryxService(searchDelay: Duration.zero),
    );
    await fillSpringfield(tester);
    await _tap(tester, find.byKey(const ValueKey('jf-scan-agora')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const ValueKey('jf-crt-body-scroll')), findsOneWidget);
  });

  testWidgets('beta error text appears in CRT', (tester) async {
    await pumpScan(tester, service: _BlockingService());
    await fillSpringfield(tester);
    await _tap(tester, find.byKey(const ValueKey('jf-scan-agora')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      find.text('ERR // ONLY ONE SCAN ALLOWED FOR BETA'),
      findsOneWidget,
    );
  });

  testWidgets('double tap creates one service call', (tester) async {
    final svc = DemoKeryxService(
      searchDelay: const Duration(milliseconds: 300),
    );
    await pumpScan(tester, service: svc);
    await fillSpringfield(tester);
    await tester.tap(find.byKey(const ValueKey('jf-scan-agora')));
    await tester.tap(find.byKey(const ValueKey('jf-scan-agora')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    expect(svc.callCount, 1);
  });
}

class _BlockingService implements KeryxService {
  @override
  Future<KeryxScanResult> scan(KeryxScanRequest request) async {
    return KeryxScanResult(
      outcome: KeryxScanOutcome.error,
      request: request,
      errorKind: KeryxScanErrorKind.betaScanConsumed,
      machineTitle: 'ERR // ONLY ONE SCAN ALLOWED FOR BETA',
      supportText: 'Beta scan already used.',
    );
  }
}
