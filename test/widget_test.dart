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
    expect(find.textContaining('AGORA MK-I'), findsWidgets);
    expect(find.textContaining('V0.1.0'), findsWidgets);
    expect(find.textContaining('FREE'), findsWidgets);
    expect(find.byType(JfRetroDateDisplay), findsOneWidget);
    expect(
      find.text('JUNKFEATHERS TECH // CIVIC RECEIVER 01'),
      findsNothing,
    );
  });

  testWidgets('monitor is CRT assembly without product title', (tester) async {
    await _pumpScanControl(tester);
    expect(find.byType(JfCrtMonitor), findsOneWidget);
    expect(find.textContaining('AWAITING LOCATION INPUT'), findsOneWidget);
    expect(find.textContaining('ENGINE LINK // NOT CONNECTED'), findsOneWidget);
    final clip = tester.widgetList<ClipRRect>(find.byType(ClipRRect));
    expect(clip.any((c) => c.borderRadius != BorderRadius.zero), isTrue);
  });

  testWidgets('monitor scrollbar hides thumb when content fits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: const Scaffold(
          body: JfCrtMonitor(
            lines: ['ONE', 'TWO'],
            height: 160,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(JfMachineScrollbar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('monitor scrollbar enables when content overflows', (tester) async {
    final lines = List<String>.generate(40, (i) => 'LINE // $i');
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: Scaffold(
          body: JfCrtMonitor(lines: lines, height: 120),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(JfMachineScrollbar), findsOneWidget);
    expect(find.text('LINE // 0'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.textContaining('LINE //'), findsWidgets);
  });

  testWidgets('triple-ring coil renders compact', (tester) async {
    await _pumpScanControl(tester);
    final coil = tester.widget<JfSignalCoil>(find.byType(JfSignalCoil));
    expect(coil.height, lessThanOrEqualTo(80));
    expect(find.byType(JfSignalCoil), findsOneWidget);
  });

  testWidgets('reduced-motion coil is static', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: const Scaffold(
          body: JfSignalCoil(forceStatic: true, height: 72),
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

  test('scan performs no network call', () {
    final source = File(
      'lib/features/scan_control/scan_control_screen.dart',
    ).readAsStringSync();
    expect(source.contains('http'), isFalse);
    expect(source.toLowerCase().contains('firebase'), isFalse);
  });

  test('no forbidden dependencies in pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync().toLowerCase();
    expect(pubspec.contains('firebase'), isFalse);
    expect(pubspec.contains('google_maps'), isFalse);
    expect(pubspec.contains('google_fonts'), isFalse);
    expect(pubspec.contains('carousel'), isFalse);
    expect(pubspec.contains('animations:'), isFalse);
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
