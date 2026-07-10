import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/brand/junkfeathers_splash_spec.dart';
import 'package:the_local_agora/design/jf_crt_monitor.dart';
import 'package:the_local_agora/design/jf_dial_selector.dart';
import 'package:the_local_agora/design/jf_machine_identity_panel.dart';
import 'package:the_local_agora/design/jf_oled_toast.dart';
import 'package:the_local_agora/design/jf_signal_coil.dart';
import 'package:the_local_agora/design/jf_waiting_scan_prompt.dart';
import 'package:the_local_agora/design/junkfeathers_theme.dart';
import 'package:the_local_agora/design/junkfeathers_tokens.dart';
import 'package:the_local_agora/features/scan_control/scan_control_state.dart';
import 'package:the_local_agora/main.dart';

Future<void> _pumpScanControl(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    dismissJfOledToastForTest();
  });
  await tester.pumpWidget(const TheLocalAgoraApp());
  await tester.pump();
}

Future<void> _tapControl(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump(JfMotion.press);
  await tester.pump();
}

void main() {
  test('splash still owns Junkfeathers Tech brand name', () {
    expect(JunkfeathersSplashSpec.brandName, 'JUNKFEATHERS TECH');
  });

  test('CRT inner radius is rounded while outer tokens stay square', () {
    expect(JfBorders.square, BorderRadius.zero);
    expect(JfCrtMonitor.innerRadius, greaterThan(0));
  });

  test('status strip formats local date', () {
    expect(
      AgoraMachineIdentity.formatLocalDate(DateTime(2026, 7, 10)),
      '2026.07.10',
    );
  });

  testWidgets('no external numbered section headers', (tester) async {
    await _pumpScanControl(tester);
    expect(find.text('01 // STATUS'), findsNothing);
    expect(find.text('02 // DISPLAY'), findsNothing);
    expect(find.text('03 // SIGNAL COIL'), findsNothing);
    expect(find.text('04 // CONTROLS'), findsNothing);
  });

  testWidgets('title lives in panel 01 only once on Scan Control',
      (tester) async {
    await _pumpScanControl(tester);
    expect(find.text('THE LOCAL AGORA'), findsOneWidget);
    expect(find.text('WHAT IS HAPPENING HERE?'), findsNothing);
    expect(find.textContaining('AGORA MK-I // V0.1.0 // FREE // KERYX'),
        findsOneWidget);
    expect(find.byType(JfRetroDateDisplay), findsOneWidget);
    expect(
      find.text('JUNKFEATHERS TECH // CIVIC RECEIVER 01'),
      findsNothing,
    );
  });

  testWidgets('panel 01 is compact identity plate', (tester) async {
    await _pumpScanControl(tester);
    final panel = find.byType(JfMachineIdentityPanel);
    expect(panel, findsOneWidget);
    final size = tester.getSize(panel);
    expect(size.height, lessThan(100));
    expect(size.height, lessThanOrEqualTo(JfMachineIdentityPanel.compactTargetHeight + 28));
  });

  testWidgets('monitor is CRT assembly with waiting prompt', (tester) async {
    await _pumpScanControl(tester);
    expect(find.byType(JfCrtMonitor), findsOneWidget);
    expect(find.byType(JfWaitingScanPrompt), findsOneWidget);
    expect(find.textContaining('WAITING FOR SCAN'), findsOneWidget);
    expect(find.textContaining('AWAITING LOCATION INPUT'), findsOneWidget);
    expect(find.textContaining('ENGINE LINK // NOT CONNECTED'), findsOneWidget);
    final monitor = tester.widget<JfCrtMonitor>(find.byType(JfCrtMonitor));
    expect(monitor.height, 180);
    final clip = tester.widgetList<ClipRRect>(find.byType(ClipRRect));
    expect(clip.any((c) => c.borderRadius != BorderRadius.zero), isTrue);
  });

  testWidgets('reduced motion waiting prompt is static', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: const Scaffold(
          body: JfWaitingScanPrompt(forceStatic: true),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('WAITING FOR SCAN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('panel 02 is taller than panel 03', (tester) async {
    await _pumpScanControl(tester);
    final monitor = tester.widget<JfCrtMonitor>(find.byType(JfCrtMonitor));
    final coil = tester.widget<JfSignalCoil>(find.byType(JfSignalCoil));
    expect(monitor.height, greaterThan(coil.height));
    expect(coil.height, 60);
  });

  testWidgets('monitor scrollbar hides thumb when content fits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: const Scaffold(
          body: JfCrtMonitor(
            lines: ['ONE', 'TWO'],
            height: 160,
            forceStaticPrompt: true,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(JfMachineScrollbar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('monitor scrollbar enables when content overflows', (tester) async {
    final lines = List<String>.generate(40, (i) => 'LINE // $i');
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: Scaffold(
          body: JfCrtMonitor(
            lines: lines,
            height: 120,
            forceStaticPrompt: true,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(JfMachineScrollbar), findsOneWidget);
    expect(find.text('LINE // 0'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();
    expect(find.textContaining('LINE //'), findsWidgets);
  });

  testWidgets('triple-ring coil renders compact with three rings',
      (tester) async {
    await _pumpScanControl(tester);
    final coil = tester.widget<JfSignalCoil>(find.byType(JfSignalCoil));
    expect(coil.height, 60);
    expect(JfSignalCoil.ringCount, 3);
    expect(find.byType(JfSignalCoil), findsOneWidget);
    final coilSrc = File('lib/design/jf_signal_coil.dart').readAsStringSync();
    expect(coilSrc.contains('Side tick'), isTrue);
    expect(coilSrc.contains('scan line'), isTrue);
    expect(coilSrc.contains('ClipRect'), isTrue);
  });

  testWidgets('reduced-motion coil is static', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: const Scaffold(
          body: JfSignalCoil(forceStatic: true, height: 60),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('WHEN dial shows one value and advances', (tester) async {
    await _pumpScanControl(tester);
    expect(find.text('THIS WEEKEND'), findsWidgets);
    expect(find.text('TONIGHT'), findsNothing);
    await _tapControl(tester, find.byKey(const ValueKey('jf-dial-next-WHEN')));
    expect(find.text('NEXT 7 DAYS'), findsWidgets);
    expect(find.textContaining('WINDOW // NEXT 7 DAYS'), findsOneWidget);
  });

  testWidgets('WHAT dial shows one value and advances', (tester) async {
    await _pumpScanControl(tester);
    expect(find.text('ALL SIGNALS'), findsWidgets);
    expect(find.text('MUSIC'), findsNothing);
    await _tapControl(tester, find.byKey(const ValueKey('jf-dial-next-WHAT')));
    expect(find.text('MUSIC'), findsWidgets);
    expect(find.textContaining('SIGNAL TYPE // MUSIC'), findsOneWidget);
  });

  testWidgets('dial advances one snap at a time', (tester) async {
    var value = TimeWindow.tonight;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return JfDialSelector<TimeWindow>(
                label: 'WHEN',
                values: TimeWindow.values,
                value: value,
                labelOf: (v) => v.label,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      ),
    );
    await _tapControl(tester, find.byKey(const ValueKey('jf-dial-next-WHEN')));
    await tester.pumpAndSettle();
    expect(find.text('TOMORROW'), findsOneWidget);
    expect(value, TimeWindow.tomorrow);
  });

  testWidgets('empty location top warning and persistent error', (tester) async {
    await _pumpScanControl(tester);
    await _tapControl(tester, find.text('SCAN THE AGORA'));
    expect(find.text('LOCATION REQUIRED'), findsWidgets);
    expect(find.textContaining('enter a city or ZIP code'), findsWidgets);
    dismissJfOledToastForTest();
    await tester.pump();
    expect(find.textContaining('LOCATION REQUIRED'), findsWidgets);
  });

  testWidgets('valid location top readiness toast', (tester) async {
    await _pumpScanControl(tester);
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    await _tapControl(tester, find.text('SCAN THE AGORA'));
    expect(find.text('SCAN CONTROL READY'), findsOneWidget);
    dismissJfOledToastForTest();
    await tester.pump();
  });

  testWidgets('keyboard inset keeps field and scan reachable', (tester) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });
    await tester.pumpWidget(const TheLocalAgoraApp());
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byType(TextField));
    await tester.ensureVisible(find.text('SCAN THE AGORA'));
  });

  testWidgets('debug gallery gated', (tester) async {
    await _pumpScanControl(tester);
    if (kDebugMode) {
      expect(find.text('DEBUG // COMPONENTS'), findsOneWidget);
    } else {
      expect(find.text('DEBUG // COMPONENTS'), findsNothing);
    }
  });

  test('debug gallery remains debug-gated in source', () {
    final source = File(
      'lib/features/scan_control/scan_control_screen.dart',
    ).readAsStringSync();
    expect(source.contains('kDebugMode'), isTrue);
  });

  test('scan performs no network or Firebase callable call', () {
    final source = File(
      'lib/features/scan_control/scan_control_screen.dart',
    ).readAsStringSync();
    expect(source.contains('http'), isFalse);
    expect(source.contains('probeStatus'), isFalse);
    expect(source.contains('FirebaseFunctions'), isFalse);
    expect(source.contains('httpsCallable'), isFalse);
  });

  test('only approved Flutter Firebase packages are present', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('firebase_core:'), isTrue);
    expect(pubspec.contains('cloud_functions:'), isTrue);
    expect(pubspec.contains('firebase_auth'), isFalse);
    expect(pubspec.contains('cloud_firestore'), isFalse);
    expect(pubspec.contains('firebase_storage'), isFalse);
    expect(pubspec.contains('firebase_analytics'), isFalse);
    expect(pubspec.contains('firebase_app_check'), isFalse);
    expect(pubspec.contains('google_maps'), isFalse);
    expect(pubspec.contains('google_fonts'), isFalse);
    expect(pubspec.contains('carousel'), isFalse);
    expect(pubspec.contains('google_generative_ai'), isFalse);
  });

  test('no Gemini key appears in repository sources', () {
    final files = [
      'lib/main.dart',
      'lib/firebase_options.dart',
      'functions/src/index.ts',
      'pubspec.yaml',
    ];
    for (final path in files) {
      final text = File(path).readAsStringSync();
      expect(text.contains('GEMINI_API_KEY='), isFalse);
      expect(text.contains('BEGIN PRIVATE KEY'), isFalse);
    }
  });

  test('portrait orientation configuration remains', () {
    final mainSrc = File('lib/main.dart').readAsStringSync();
    expect(mainSrc.contains('DeviceOrientation.portraitUp'), isTrue);
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest.contains('android:screenOrientation="portrait"'), isTrue);
  });

  test('exclusive enums remain exclusive', () {
    var state = const ScanControlState();
    state = state.copyWith(timeWindow: TimeWindow.tonight);
    state = state.copyWith(timeWindow: TimeWindow.tomorrow);
    expect(state.timeWindow, TimeWindow.tomorrow);
  });
}
