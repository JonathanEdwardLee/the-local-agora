import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/brand/junkfeathers_splash_spec.dart';
import 'package:the_local_agora/design/jf_device_button.dart';
import 'package:the_local_agora/design/jf_machine_status_strip.dart';
import 'package:the_local_agora/design/jf_oled_toast.dart';
import 'package:the_local_agora/design/jf_signal_coil.dart';
import 'package:the_local_agora/design/junkfeathers_theme.dart';
import 'package:the_local_agora/design/junkfeathers_tokens.dart';
import 'package:the_local_agora/features/scan_control/scan_control_state.dart';
import 'package:the_local_agora/main.dart';

Future<void> _pumpScanControl(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1400);
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
  test('company theme uses monospace baseline', () {
    final theme = buildJunkfeathersTheme();
    expect(theme.textTheme.bodyMedium?.fontFamily, JfTypography.fontFamily);
    expect(JfTypography.fontFamily, 'monospace');
  });

  test('splash still owns Junkfeathers Tech brand name', () {
    expect(JunkfeathersSplashSpec.brandName, 'JUNKFEATHERS TECH');
  });

  test('ordinary geometry is square', () {
    expect(JfBorders.square, BorderRadius.zero);
  });

  test('status strip formats local date', () {
    final line = AgoraMachineIdentity.statusLine(
      now: DateTime(2026, 7, 10),
      includeDev: false,
    );
    expect(line, contains('AGORA MK-I'));
    expect(line, contains('V0.1.0'));
    expect(line, contains('FREE'));
    expect(line, contains('2026.07.10'));
  });

  testWidgets('AGORA MK-I appears and old company header does not',
      (tester) async {
    await _pumpScanControl(tester);
    expect(find.textContaining('AGORA MK-I'), findsWidgets);
    expect(
      find.text('JUNKFEATHERS TECH // CIVIC RECEIVER 01'),
      findsNothing,
    );
    expect(find.text('THE LOCAL AGORA'), findsOneWidget);
  });

  testWidgets('four machine levels are represented', (tester) async {
    await _pumpScanControl(tester);
    expect(find.text('01 // STATUS'), findsOneWidget);
    expect(find.text('02 // DISPLAY'), findsOneWidget);
    expect(find.text('03 // SIGNAL COIL'), findsOneWidget);
    expect(find.text('04 // CONTROLS'), findsOneWidget);
  });

  testWidgets('status strip includes version and FREE', (tester) async {
    await _pumpScanControl(tester);
    expect(find.textContaining('V0.1.0'), findsWidgets);
    expect(find.textContaining('FREE'), findsWidgets);
  });

  testWidgets('signal coil renders', (tester) async {
    await _pumpScanControl(tester);
    expect(find.byType(JfSignalCoil), findsOneWidget);
  });

  testWidgets('reduced-motion signal coil renders static', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: const Scaffold(
          body: JfSignalCoil(forceStatic: true),
        ),
      ),
    );
    expect(find.byType(JfSignalCoil), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty location shows top warning toast and persistent error',
      (tester) async {
    await _pumpScanControl(tester);
    await _tapControl(tester, find.text('SCAN THE AGORA'));
    expect(find.text('LOCATION REQUIRED'), findsWidgets);
    expect(find.textContaining('enter a city or ZIP code'), findsWidgets);
    expect(find.text('SCAN CONTROL READY'), findsNothing);
    dismissJfOledToastForTest();
    await tester.pump();
  });

  testWidgets('valid location shows top informational toast', (tester) async {
    await _pumpScanControl(tester);
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.pump();
    await _tapControl(tester, find.text('SCAN THE AGORA'));
    expect(find.text('SCAN CONTROL READY'), findsOneWidget);
    expect(
      find.textContaining(
        'Live Keryx connection arrives in the next governed pass.',
      ),
      findsOneWidget,
    );
    dismissJfOledToastForTest();
    await tester.pump();
  });

  testWidgets('toast uses square geometry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showJfOledToast(context, 'TOAST TEST'),
                  child: const Text('GO'),
                ),
              ),
            );
          },
        ),
      ),
    );
    addTearDown(dismissJfOledToastForTest);
    await tester.tap(find.text('GO'));
    await tester.pump();
    final decorated = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
    final toastBox = decorated
        .map((w) => w.decoration)
        .whereType<BoxDecoration>()
        .where(
          (d) => d.borderRadius == BorderRadius.zero && d.border != null,
        );
    expect(toastBox, isNotEmpty);
    dismissJfOledToastForTest();
    await tester.pump();
  });

  testWidgets('only one time window can be selected', (tester) async {
    await _pumpScanControl(tester);
    await _tapControl(tester, find.text('TONIGHT'));
    await _tapControl(tester, find.text('TOMORROW'));
    final tonight = tester.widget<JfDeviceButton>(
      find.widgetWithText(JfDeviceButton, 'TONIGHT'),
    );
    final tomorrow = tester.widget<JfDeviceButton>(
      find.widgetWithText(JfDeviceButton, 'TOMORROW'),
    );
    expect(tonight.selected, isFalse);
    expect(tomorrow.selected, isTrue);
  });

  testWidgets('only one category can be selected', (tester) async {
    await _pumpScanControl(tester);
    await _tapControl(tester, find.text('MUSIC'));
    await _tapControl(tester, find.text('COMEDY'));
    final comedy = tester.widget<JfDeviceButton>(
      find.widgetWithText(JfDeviceButton, 'COMEDY'),
    );
    final all = tester.widget<JfDeviceButton>(
      find.widgetWithText(JfDeviceButton, 'ALL SIGNALS'),
    );
    expect(comedy.selected, isTrue);
    expect(all.selected, isFalse);
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
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('SCAN THE AGORA'), findsOneWidget);
  });

  testWidgets('primary action reachable under reduced viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 560);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const TheLocalAgoraApp());
    await tester.pump();
    await tester.ensureVisible(find.text('SCAN THE AGORA'));
    expect(find.text('SCAN THE AGORA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('debug gallery control is present in debug builds', (tester) async {
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
    expect(source.contains('DebugComponentGallery'), isTrue);
  });

  test('scan button performs no network call in source', () {
    final source = File(
      'lib/features/scan_control/scan_control_screen.dart',
    ).readAsStringSync();
    expect(source.contains('http'), isFalse);
    expect(source.toLowerCase().contains('firebase'), isFalse);
    expect(source.contains('Gemini'), isFalse);
    expect(source.contains('showJfOledToast'), isTrue);
  });

  test('no map, font, or firebase packages in pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync().toLowerCase();
    expect(pubspec.contains('google_maps'), isFalse);
    expect(pubspec.contains('google_fonts'), isFalse);
    expect(pubspec.contains('firebase'), isFalse);
    expect(pubspec.contains('mapbox'), isFalse);
  });

  test('portrait orientation configuration is present', () {
    final mainSrc = File('lib/main.dart').readAsStringSync();
    expect(mainSrc.contains('DeviceOrientation.portraitUp'), isTrue);
    expect(mainSrc.contains('setPreferredOrientations'), isTrue);

    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest.contains('android:screenOrientation="portrait"'), isTrue);

    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist.contains('UIInterfaceOrientationPortrait'), isTrue);
    expect(plist.contains('UIInterfaceOrientationLandscapeLeft'), isFalse);
  });

  test('exclusive enums remain exclusive by design', () {
    var state = const ScanControlState();
    state = state.copyWith(timeWindow: TimeWindow.tonight);
    state = state.copyWith(timeWindow: TimeWindow.tomorrow);
    expect(state.timeWindow, TimeWindow.tomorrow);
  });
}
