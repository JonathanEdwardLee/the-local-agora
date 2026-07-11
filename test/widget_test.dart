import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/brand/junkfeathers_splash_spec.dart';
import 'package:the_local_agora/design/jf_crt_monitor.dart';
import 'package:the_local_agora/design/jf_dial_selector.dart';
import 'package:the_local_agora/design/jf_indicator_board.dart';
import 'package:the_local_agora/design/jf_machine_identity_panel.dart';
import 'package:the_local_agora/design/jf_monitor_module.dart';
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
  await tester.pumpWidget(
    const TheLocalAgoraApp(enableStartupSplash: false, autoShowWelcome: false),
  );
  await tester.pump();
}

Future<void> _tapControl(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump(JfMotion.press);
  await tester.pump();
}

/// Advances dialog route forward/reverse transitions without pumpAndSettle
/// (indicator/coil animations repeat forever).
Future<void> _pumpDialogTransition(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _openParams(WidgetTester tester) async {
  await _tapControl(tester, find.byKey(const ValueKey('jf-open-params')));
  await _pumpDialogTransition(tester);
}

Future<void> _closeParams(WidgetTester tester) async {
  await _tapControl(tester, find.byKey(const ValueKey('jf-param-close')));
  await _pumpDialogTransition(tester);
}

void main() {
  test('splash still owns Junkfeathers Tech brand name', () {
    expect(JunkfeathersSplashSpec.brandName, 'JUNKFEATHERS TECH');
  });

  test('CRT inner radius is rounded while outer tokens stay square', () {
    expect(JfBorders.square, BorderRadius.zero);
    expect(JfCrtMonitor.innerRadius, greaterThan(0));
  });

  test('validation phosphor token exists and differs from amber', () {
    expect(JfColors.validationPhosphor, isNot(JfColors.amber));
    expect(JfTypography.validationError.color, JfColors.validationPhosphor);
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

  testWidgets('panel 01 remains locked identity plate', (tester) async {
    await _pumpScanControl(tester);
    expect(find.text('THE LOCAL AGORA'), findsOneWidget);
    expect(
      find.textContaining('AGORA MK-I // V0.1.0 // FREE // KERYX'),
      findsOneWidget,
    );
    expect(find.byType(JfRetroDateDisplay), findsOneWidget);
    expect(find.byKey(const ValueKey('agora-open-about')), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('ADD EVENT'), findsOneWidget);
    expect(find.byKey(const ValueKey('agora-open-welcome')), findsNothing);
    final size = tester.getSize(find.byType(JfMachineIdentityPanel));
    expect(size.height, lessThan(100));
  });

  testWidgets('combined panel 02 keeps art band and taller CRT', (
    tester,
  ) async {
    await _pumpScanControl(tester);
    expect(find.byType(JfMonitorModule), findsOneWidget);
    expect(find.byType(JfCrtMonitor), findsOneWidget);
    expect(find.byType(JfWaitingScanPrompt), findsOneWidget);
    expect(find.byType(JfSignalCoil), findsOneWidget);
    expect(find.byType(JfIndicatorBoard), findsOneWidget);
    expect(find.byType(JfMachineScrollbar), findsOneWidget);
    final module = tester.widget<JfMonitorModule>(find.byType(JfMonitorModule));
    expect(module.monitorHeight, greaterThanOrEqualTo(260));
    expect(module.monitorHeight, greaterThan(module.bandHeight));
    expect(module.bandHeight, JfMonitorModule.defaultBandHeight);
    final coil = tester.widget<JfSignalCoil>(find.byType(JfSignalCoil));
    expect(coil.square, isTrue);
    expect(JfSignalCoil.ringCount, 3);
  });

  testWidgets('main panel 04 is compact search deck', (tester) async {
    await _pumpScanControl(tester);
    expect(find.text('Search for an event'), findsOneWidget);
    expect(find.text('INPUT SEARCH PARAMETERS'), findsOneWidget);
    expect(find.text('SCAN THE AGORA'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byKey(const ValueKey('jf-when-dial')), findsNothing);
    expect(find.byKey(const ValueKey('jf-what-dial')), findsNothing);
  });

  testWidgets('parameter dialog opens with location WHEN WHAT and Close', (
    tester,
  ) async {
    await _pumpScanControl(tester);
    await _openParams(tester);
    expect(find.text('SEARCH PARAMETERS'), findsOneWidget);
    expect(
      find.text('Choose a city or ZIP code, then set WHEN and WHAT.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('jf-param-location')), findsOneWidget);
    expect(find.byKey(const ValueKey('jf-when-dial')), findsOneWidget);
    expect(find.byKey(const ValueKey('jf-what-dial')), findsOneWidget);
    expect(find.byKey(const ValueKey('jf-param-close')), findsOneWidget);
  });

  testWidgets('parameter state persists and updates monitor', (tester) async {
    await _pumpScanControl(tester);
    await _openParams(tester);
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    await _tapControl(tester, find.byKey(const ValueKey('jf-dial-next-WHEN')));
    // WHAT defaults to MUSIC in V0.1 (art/gatherings/all-signals deferred).
    expect(find.textContaining('WINDOW // NEXT 7 DAYS'), findsOneWidget);
    expect(find.textContaining('SIGNAL TYPE // MUSIC'), findsOneWidget);
    await _closeParams(tester);
    expect(find.text('SEARCH PARAMETERS'), findsNothing);
    expect(find.textContaining('WINDOW // NEXT 7 DAYS'), findsOneWidget);
    expect(find.textContaining('SIGNAL TYPE // MUSIC'), findsOneWidget);
    expect(
      find.textContaining('SPRINGFIELD, MISSOURI // NEXT 7 DAYS // MUSIC'),
      findsOneWidget,
    );
    await _openParams(tester);
    expect(find.text('Springfield, Missouri'), findsWidgets);
    expect(find.text('NEXT 7 DAYS'), findsWidgets);
    expect(find.text('MUSIC'), findsWidgets);
    expect(find.text('ALL SIGNALS'), findsNothing);
    expect(find.text('ART'), findsNothing);
    expect(find.text('GATHERINGS'), findsNothing);
    await _tapControl(tester, find.byKey(const ValueKey('jf-dial-next-WHAT')));
    await _tapControl(tester, find.byKey(const ValueKey('jf-dial-next-WHAT')));
    expect(find.text('THEATER'), findsWidgets);
    await _closeParams(tester);
  });

  testWidgets('only one parameter dialog at a time', (tester) async {
    await _pumpScanControl(tester);
    await _openParams(tester);
    expect(find.text('SEARCH PARAMETERS'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('empty Scan shows phosphor validation dialog', (tester) async {
    await _pumpScanControl(tester);
    await _tapControl(tester, find.text('SCAN THE AGORA'));
    expect(find.text('LOCATION REQUIRED'), findsWidgets);
    expect(
      find.text('Enter a city or ZIP code before scanning the Agora.'),
      findsOneWidget,
    );
    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    final shape = dialog.shape! as Border;
    expect(shape.top.color, JfColors.validationPhosphor);
    expect(find.text('SCAN CONTROL READY'), findsNothing);
  });

  testWidgets('valid Scan shows ordinary info toast not phosphor', (
    tester,
  ) async {
    await _pumpScanControl(tester);
    await _openParams(tester);
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    await _closeParams(tester);
    await _tapControl(tester, find.text('SCAN THE AGORA'));
    expect(find.text('SCAN CONTROL READY'), findsOneWidget);
    dismissJfOledToastForTest();
    await tester.pump();
  });

  testWidgets('valid location clears invalid state', (tester) async {
    await _pumpScanControl(tester);
    await _tapControl(tester, find.text('SCAN THE AGORA'));
    expect(find.text('LOCATION REQUIRED'), findsWidgets);
    await _tapControl(tester, find.text('ACKNOWLEDGE'));
    await _pumpDialogTransition(tester);
    await _openParams(tester);
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    expect(
      find.textContaining('LOCATION REQUIRED — enter a city'),
      findsNothing,
    );
  });

  testWidgets('monitor scrollbar enables when content overflows', (
    tester,
  ) async {
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
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();
    expect(find.textContaining('LINE //'), findsWidgets);
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
    expect(find.text('TOMORROW'), findsOneWidget);
    expect(value, TimeWindow.tomorrow);
  });

  testWidgets('keyboard inset keeps scan reachable', (tester) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });
    await tester.pumpWidget(
      const TheLocalAgoraApp(
        enableStartupSplash: false,
        autoShowWelcome: false,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('SCAN THE AGORA'));
  });

  testWidgets('parameter dialog keeps location visible under keyboard inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
      dismissJfOledToastForTest();
    });
    await tester.pumpWidget(
      const TheLocalAgoraApp(
        enableStartupSplash: false,
        autoShowWelcome: false,
      ),
    );
    await tester.pump();
    await _openParams(tester);

    final field = find.byKey(const ValueKey('jf-param-location'));
    await tester.tap(find.byType(TextField));
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 80));

    final fieldRect = tester.getRect(field);
    final screen = tester.view.physicalSize;
    final keyboardTop = screen.height - 320;
    expect(fieldRect.top, greaterThanOrEqualTo(0));
    expect(fieldRect.bottom, lessThanOrEqualTo(keyboardTop + 1));
    expect(find.text('SEARCH PARAMETERS'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    expect(find.text('Springfield, Missouri'), findsWidgets);
    expect(fieldRect.bottom, lessThanOrEqualTo(keyboardTop + 1));

    await tester.ensureVisible(find.byKey(const ValueKey('jf-when-dial')));
    expect(find.byKey(const ValueKey('jf-when-dial')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('jf-what-dial')));
    expect(find.byKey(const ValueKey('jf-what-dial')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('jf-param-close')));
    expect(find.byKey(const ValueKey('jf-param-close')), findsOneWidget);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('SEARCH PARAMETERS'), findsOneWidget);
  });

  testWidgets(
    'parameter dialog stays keyboard-safe on smaller portrait viewport',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
        dismissJfOledToastForTest();
      });
      await tester.pumpWidget(
        const TheLocalAgoraApp(
          enableStartupSplash: false,
          autoShowWelcome: false,
        ),
      );
      await tester.pump();
      await _openParams(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(find.byType(TextField));
      await tester.pump(const Duration(milliseconds: 100));

      final fieldRect = tester.getRect(
        find.byKey(const ValueKey('jf-param-location')),
      );
      final keyboardTop = tester.view.physicalSize.height - 280;
      expect(fieldRect.top, greaterThanOrEqualTo(0));
      expect(fieldRect.bottom, lessThanOrEqualTo(keyboardTop + 1));
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.byKey(const ValueKey('jf-param-close')));
      expect(find.byKey(const ValueKey('jf-param-close')), findsOneWidget);
    },
  );

  testWidgets('dismissing keyboard does not close parameter dialog', (
    tester,
  ) async {
    await _pumpScanControl(tester);
    await _openParams(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump(const Duration(milliseconds: 100));
    FocusManager.instance.primaryFocus?.unfocus();
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('SEARCH PARAMETERS'), findsOneWidget);
    addTearDown(tester.view.resetViewInsets);
  });

  testWidgets('reduced motion waiting prompt is static', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: const Scaffold(body: JfWaitingScanPrompt(forceStatic: true)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('WAITING FOR SCAN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('monitor scrollbar hides thumb when content fits', (
    tester,
  ) async {
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

  testWidgets('decorative indicator board is non-interactive', (tester) async {
    await _pumpScanControl(tester);
    expect(find.byType(JfIndicatorBoard), findsOneWidget);
    expect(find.byType(IgnorePointer), findsWidgets);
  });

  testWidgets('reduced-motion coil is static', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: const Scaffold(body: JfSignalCoil(forceStatic: true, height: 60)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced-motion indicator board is static', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: const Scaffold(body: JfIndicatorBoard(forceStatic: true)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('debug gallery gated', (tester) async {
    await _pumpScanControl(tester);
    if (kDebugMode) {
      expect(find.text('DEBUG // COMPONENTS'), findsOneWidget);
      expect(find.text('TEST KERYX LINK'), findsNothing);
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
    expect(source.contains('probeCount'), isFalse);
    expect(source.contains('probeStatus'), isFalse);
    expect(source.contains('FirebaseFunctions'), isFalse);
  });

  test('empty-location validation path avoids amber', () {
    final scan = File(
      'lib/features/scan_control/scan_control_screen.dart',
    ).readAsStringSync();
    expect(scan.contains('warning: true'), isFalse);
    expect(scan.contains('validationError: true'), isTrue);
    expect(scan.contains('JfColors.amber'), isFalse);
  });

  test('only approved Flutter Firebase packages are present', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('firebase_core:'), isTrue);
    expect(pubspec.contains('cloud_functions:'), isTrue);
    expect(pubspec.contains('firebase_app_check:'), isTrue);
    expect(pubspec.contains('shared_preferences:'), isTrue);
    expect(pubspec.contains('firebase_auth'), isFalse);
    expect(pubspec.contains('google_maps'), isFalse);
    expect(pubspec.contains('google_fonts'), isFalse);
  });

  test('firebase and keryx link service unchanged in this UI pass', () {
    final options = File('lib/firebase_options.dart').readAsStringSync();
    expect(options.contains('gen-lang-client-0718451481'), isTrue);
    final link = File(
      'lib/services/keryx/firebase_keryx_link_service.dart',
    ).readAsStringSync();
    expect(link.contains('keryxStatus'), isTrue);
    final functions = File('functions/src/index.ts').readAsStringSync();
    expect(functions.contains('keryxStatus'), isTrue);
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

  test('no new keyboard-only dependency was added', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('keyboard_actions'), isFalse);
    expect(pubspec.contains('flutter_keyboard_visibility'), isFalse);
  });

  test('portrait orientation configuration remains', () {
    final mainSrc = File('lib/main.dart').readAsStringSync();
    expect(mainSrc.contains('DeviceOrientation.portraitUp'), isTrue);
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest.contains('android:screenOrientation="portrait"'), isTrue);
  });

  test('exclusive enums remain exclusive', () {
    var state = const ScanControlState();
    state = state.copyWith(timeWindow: TimeWindow.tonight);
    state = state.copyWith(timeWindow: TimeWindow.tomorrow);
    expect(state.timeWindow, TimeWindow.tomorrow);
  });
}
