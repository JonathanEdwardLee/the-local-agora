import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/design/jf_oled_toast.dart';
import 'package:the_local_agora/design/junkfeathers_tokens.dart';
import 'package:the_local_agora/features/debug/debug_component_gallery.dart';
import 'package:the_local_agora/services/keryx/keryx_live_scan_service.dart';

void main() {
  test('parse live scan payload accepts versioned events', () {
    final result = parseKeryxLiveScanPayload({
      'schemaVersion': '0.1.0-debug',
      'requestId': 'abc',
      'events': [
        {
          'title': 'Signal One',
          'date': '2026-07-11',
          'sourceUrl': 'https://example.com/event',
        },
      ],
      'sources': [
        {'title': 'Example', 'url': 'https://example.com/event'},
      ],
      'warnings': ['cache not implemented'],
      'cacheStatus': 'not_implemented',
    });
    expect(result.ok, isTrue);
    expect(result.signalCount, 1);
    expect(result.events.first.title, 'Signal One');
    expect(result.cacheStatus, 'not_implemented');
  });

  test('parse live scan payload rejects malformed body', () {
    final result = parseKeryxLiveScanPayload({'nope': true});
    expect(result.ok, isFalse);
    expect(result.machineTitle, contains('MALFORMED'));
  });

  test('main initializes App Check after Firebase in source', () {
    final mainSrc = File('lib/main.dart').readAsStringSync();
    expect(mainSrc.contains('initializeFirebaseSafely'), isTrue);
    expect(mainSrc.contains('initializeAppCheckSafely'), isTrue);
    expect(
      mainSrc.indexOf('initializeFirebaseSafely') <
          mainSrc.indexOf('initializeAppCheckSafely'),
      isTrue,
    );
    expect(mainSrc.contains('AndroidDebugProvider'), isTrue);
    expect(mainSrc.contains('AndroidPlayIntegrityProvider'), isTrue);
    expect(mainSrc.contains('FirebaseKeryxLiveScanService'), isTrue);
    expect(mainSrc.contains('kIsWeb'), isTrue);
  });

  test('no App Check debug token appears in source', () {
    final files = [
      'lib/main.dart',
      'lib/features/debug/debug_component_gallery.dart',
      'android/app/build.gradle.kts',
    ];
    for (final path in files) {
      final text = File(path).readAsStringSync();
      expect(text.contains('firebase_app_check_debug_token'), isFalse);
      expect(text.contains('X-Firebase-AppCheck'), isFalse);
    }
  });

  testWidgets('debug gallery shows live scan control only when ready',
      (tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      dismissJfOledToastForTest();
    });

    final fake = FakeKeryxLiveScanService();
    await tester.pumpWidget(
      MaterialApp(
        home: DebugComponentGallery(
          firebaseReady: true,
          appCheckReady: true,
          keryxLiveScanService: fake,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('TEST LIVE KERYX SCAN'), findsOneWidget);
    expect(find.text('LIVE KERYX UNTESTED'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('jf-test-live-keryx')));
    await tester.pump(JfMotion.press);
    await tester.pump();
    expect(find.text('LIVE KERYX TEST'), findsOneWidget);
    expect(fake.callCount, 0);

    await tester.tap(find.text('CANCEL'));
    await tester.pump(JfMotion.press);
    await tester.pump(const Duration(milliseconds: 300));
    expect(fake.callCount, 0);
  });

  testWidgets('confirmed live scan invokes service once', (tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      dismissJfOledToastForTest();
    });

    final fake = FakeKeryxLiveScanService(
      delay: const Duration(milliseconds: 50),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: DebugComponentGallery(
          firebaseReady: true,
          appCheckReady: true,
          keryxLiveScanService: fake,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('jf-test-live-keryx')));
    await tester.pump(JfMotion.press);
    await tester.pump();
    await tester.tap(find.text('RUN ONE TEST'));
    await tester.pump(JfMotion.press);
    await tester.pump();
    expect(fake.callCount, 1);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pump(const Duration(milliseconds: 300));
    dismissJfOledToastForTest();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('LIVE KERYX RESULT READY'), findsWidgets);
    expect(fake.lastRequest?['location'], 'Springfield, Missouri');
    expect(fake.lastRequest?['timeWindow'], 'NEXT_7_DAYS');
    expect(fake.lastRequest?['category'], 'MUSIC');
  });

  test('web does not get live scan service in main wiring', () {
    final mainSrc = File('lib/main.dart').readAsStringSync();
    expect(
      mainSrc.contains('firebaseReady && appCheckReady && !kIsWeb'),
      isTrue,
    );
  });

  test('debug live control remains debug-gated', () {
    expect(kDebugMode, isTrue);
    final scan = File(
      'lib/features/scan_control/scan_control_screen.dart',
    ).readAsStringSync();
    expect(scan.contains('kDebugMode'), isTrue);
    expect(scan.contains('TEST LIVE KERYX SCAN'), isFalse);
    expect(scan.contains('keryxScanDebug'), isFalse);
  });
}
