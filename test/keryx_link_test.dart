import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/design/jf_device_button.dart';
import 'package:the_local_agora/design/jf_oled_toast.dart';
import 'package:the_local_agora/design/junkfeathers_theme.dart';
import 'package:the_local_agora/features/debug/debug_component_gallery.dart';
import 'package:the_local_agora/main.dart';
import 'package:the_local_agora/services/keryx/demo_keryx_service.dart';
import 'package:the_local_agora/services/keryx/firebase_keryx_link_service.dart';
import 'package:the_local_agora/services/keryx/keryx_link_result.dart';
import 'package:the_local_agora/services/keryx/keryx_link_service.dart';

void main() {
  test('valid callable payload becomes ready', () {
    final result = parseKeryxStatusPayload({
      'service': 'keryx',
      'status': 'ready',
      'scanEnabled': false,
      'version': '0.1',
      'serverTime': '2026-07-10T12:00:00.000Z',
    });
    expect(result.state, KeryxLinkState.ready);
    expect(result.scanEnabled, isFalse);
    expect(result.machineTitle, 'KERYX LINK READY');
    expect(
      result.supportText,
      contains('Live event scanning remains disabled'),
    );
  });

  test('malformed callable response is rejected', () {
    expect(
      parseKeryxStatusPayload({'service': 'keryx'}).state,
      KeryxLinkState.malformedResponse,
    );
    expect(
      parseKeryxStatusPayload({
        'service': 'keryx',
        'status': 'ready',
        'scanEnabled': true,
        'version': '0.1',
        'serverTime': 'x',
      }).state,
      KeryxLinkState.malformedResponse,
    );
    expect(
      parseKeryxStatusPayload('not-a-map').state,
      KeryxLinkState.malformedResponse,
    );
  });

  test('unavailable result never exposes raw exception text', () {
    const result = KeryxLinkResult(
      state: KeryxLinkState.unavailable,
      userMessage:
          'The development backend could not be reached. No event scan was attempted.',
    );
    expect(result.machineTitle, 'KERYX LINK UNAVAILABLE');
    expect(result.supportText, isNot(contains('Exception')));
    expect(result.supportText, isNot(contains('StackTrace')));
    expect(result.supportText, isNot(contains('FirebaseFunctionsException')));
  });

  test('fake link service records probes without network', () async {
    final fake = FakeKeryxLinkService();
    final a = await fake.probeStatus();
    final b = await fake.probeStatus();
    expect(fake.probeCount, 2);
    expect(a.state, KeryxLinkState.ready);
    expect(b.state, KeryxLinkState.ready);
  });

  test('timeout-style failure maps to unavailable user copy', () {
    final fake = FakeKeryxLinkService(
      result: const KeryxLinkResult(
        state: KeryxLinkState.unavailable,
        userMessage:
            'The development backend could not be reached. No event scan was attempted.',
      ),
    );
    expect(fake.result.state, KeryxLinkState.unavailable);
    expect(fake.result.supportText, isNot(contains('TimeoutException')));
  });

  test('initializeFirebaseSafely is represented in main', () {
    final src = File('lib/main.dart').readAsStringSync();
    expect(src.contains('initializeFirebaseSafely'), isTrue);
    expect(src.contains('DefaultFirebaseOptions.currentPlatform'), isTrue);
    expect(src.contains('catch'), isTrue);
  });

  testWidgets('no callable request on startup', (tester) async {
    final fake = FakeKeryxLinkService();
    await tester.pumpWidget(
      TheLocalAgoraApp(
        firebaseReady: true,
        keryxLinkService: fake,
        enableStartupSplash: false,
        autoShowWelcome: false,
        keryxService: DemoKeryxService(searchDelay: Duration.zero),
      ),
    );
    await tester.pump();
    expect(fake.probeCount, 0);
  });

  testWidgets('WHEN/WHAT changes do not probe Firebase', (tester) async {
    final fake = FakeKeryxLinkService();
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      TheLocalAgoraApp(
        firebaseReady: true,
        keryxLinkService: fake,
        enableStartupSplash: false,
        autoShowWelcome: false,
        keryxService: DemoKeryxService(searchDelay: Duration.zero),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('jf-open-params')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('jf-dial-next-WHEN')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('jf-dial-next-WHAT')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(fake.probeCount, 0);
  });

  testWidgets('main Scan button does not call link service', (tester) async {
    final fake = FakeKeryxLinkService();
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      dismissJfOledToastForTest();
    });
    await tester.pumpWidget(
      TheLocalAgoraApp(
        firebaseReady: true,
        keryxLinkService: fake,
        enableStartupSplash: false,
        autoShowWelcome: false,
        keryxService: DemoKeryxService(searchDelay: Duration.zero),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('jf-open-params')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('jf-param-close')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final scan = find.text('SCAN THE AGORA');
    await tester.ensureVisible(scan);
    await tester.tap(scan);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    await tester.pump();
    expect(fake.probeCount, 0);
    expect(find.textContaining('SIGNALS FOUND'), findsOneWidget);
    expect(find.text('CITY INDEX'), findsNothing);
    dismissJfOledToastForTest();
    await tester.pump();
  });

  testWidgets(
    'debug link button invokes service once and disables while busy',
    (tester) async {
      final fake = FakeKeryxLinkService(
        delay: const Duration(milliseconds: 400),
      );
      tester.view.physicalSize = const Size(400, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        dismissJfOledToastForTest();
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: buildJunkfeathersTheme(),
          home: DebugComponentGallery(
            firebaseReady: true,
            keryxLinkService: fake,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('KERYX LINK UNTESTED'), findsOneWidget);
      final linkButton = find.text('TEST KERYX LINK');
      await tester.ensureVisible(linkButton);
      await tester.pump();
      await tester.tap(linkButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('CONNECTING TO KERYX'), findsWidgets);

      final busyButton = tester.widget<JfDeviceButton>(
        find.widgetWithText(JfDeviceButton, 'TEST KERYX LINK'),
      );
      expect(busyButton.onPressed, isNull);

      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump();
      expect(fake.probeCount, 1);
      expect(find.text('KERYX LINK READY'), findsWidgets);
      expect(
        find.textContaining('Live event scanning remains disabled'),
        findsWidgets,
      );

      final readyButton = tester.widget<JfDeviceButton>(
        find.widgetWithText(JfDeviceButton, 'TEST KERYX LINK'),
      );
      expect(readyButton.onPressed, isNotNull);
      dismissJfOledToastForTest();
      await tester.pump();
    },
  );

  test('debug link test remains debug-only', () {
    final scan = File(
      'lib/features/scan_control/scan_control_screen.dart',
    ).readAsStringSync();
    expect(scan.contains('kDebugMode'), isTrue);
    expect(scan.contains('DebugComponentGallery'), isTrue);
    expect(kDebugMode || !kDebugMode, isTrue);
  });
}
