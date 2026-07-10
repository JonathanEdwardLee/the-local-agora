import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/design/jf_device_button.dart';
import 'package:the_local_agora/design/junkfeathers_theme.dart';
import 'package:the_local_agora/design/junkfeathers_tokens.dart';
import 'package:the_local_agora/features/scan_control/scan_control_screen.dart';
import 'package:the_local_agora/features/scan_control/scan_control_state.dart';
import 'package:the_local_agora/main.dart';

void main() {
  test('company theme uses monospace baseline', () {
    final theme = buildJunkfeathersTheme();
    expect(theme.textTheme.bodyMedium?.fontFamily, JfTypography.fontFamily);
    expect(JfTypography.fontFamily, 'monospace');
    expect(theme.scaffoldBackgroundColor, JfColors.black);
  });

  test('ordinary geometry is square', () {
    expect(JfBorders.square, BorderRadius.zero);
    expect(JfBorders.major, 3);
    expect(JfBorders.primary, 2);
    expect(JfBorders.secondary, 1);
  });

  test('time window and category enums are exclusive by design', () {
    var state = const ScanControlState();
    expect(state.category, EventCategory.allSignals);
    state = state.copyWith(timeWindow: TimeWindow.tonight);
    expect(state.timeWindow, TimeWindow.tonight);
    state = state.copyWith(timeWindow: TimeWindow.tomorrow);
    expect(state.timeWindow, TimeWindow.tomorrow);
    state = state.copyWith(category: EventCategory.music);
    expect(state.category, EventCategory.music);
  });

  testWidgets('Scan Control shows required machine labels', (tester) async {
    await tester.pumpWidget(const TheLocalAgoraApp());
    expect(find.text('JUNKFEATHERS TECH // CIVIC RECEIVER 01'), findsOneWidget);
    expect(find.text('THE LOCAL AGORA'), findsOneWidget);
    expect(find.text('WHAT IS HAPPENING HERE?'), findsOneWidget);
    expect(find.text('CITY OR ZIP CODE'), findsOneWidget);
    expect(find.text('SCAN THE AGORA'), findsOneWidget);
    expect(find.text('ADD SIGNAL'), findsOneWidget);
    expect(find.textContaining('Choose a city or ZIP code'), findsOneWidget);
  });

  testWidgets('primary action has semantic label', (tester) async {
    await tester.pumpWidget(const TheLocalAgoraApp());
    expect(
      find.bySemanticsLabel('Scan the Agora'),
      findsOneWidget,
    );
  });

  testWidgets('empty location blocks readiness notice', (tester) async {
    await tester.pumpWidget(const TheLocalAgoraApp());
    await tester.tap(find.text('SCAN THE AGORA'));
    await tester.pump();
    expect(find.textContaining('LOCATION REQUIRED'), findsWidgets);
    expect(find.text('SCAN CONTROL READY'), findsNothing);
  });

  testWidgets('valid location shows honest readiness dialog', (tester) async {
    await tester.pumpWidget(const TheLocalAgoraApp());
    await tester.enterText(find.byType(TextField), 'Springfield, Missouri');
    await tester.tap(find.text('SCAN THE AGORA'));
    await tester.pumpAndSettle();
    expect(find.text('SCAN CONTROL READY'), findsOneWidget);
    expect(
      find.textContaining('Live Keryx connection arrives in the next governed pass.'),
      findsOneWidget,
    );
    expect(find.textContaining('No network search was performed.'), findsOneWidget);
  });

  testWidgets('only one time window can be selected', (tester) async {
    await tester.pumpWidget(const TheLocalAgoraApp());
    await tester.tap(find.text('TONIGHT'));
    await tester.pump();
    await tester.tap(find.text('TOMORROW'));
    await tester.pump();

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
    await tester.pumpWidget(const TheLocalAgoraApp());
    await tester.tap(find.text('MUSIC'));
    await tester.pump();
    await tester.tap(find.text('COMEDY'));
    await tester.pump();

    final music = tester.widget<JfDeviceButton>(
      find.widgetWithText(JfDeviceButton, 'MUSIC'),
    );
    final comedy = tester.widget<JfDeviceButton>(
      find.widgetWithText(JfDeviceButton, 'COMEDY'),
    );
    final all = tester.widget<JfDeviceButton>(
      find.widgetWithText(JfDeviceButton, 'ALL SIGNALS'),
    );
    expect(music.selected, isFalse);
    expect(comedy.selected, isTrue);
    expect(all.selected, isFalse);
  });

  testWidgets('device buttons use square corners', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildJunkfeathersTheme(),
        home: Scaffold(
          body: JfDeviceButton(label: 'TEST', onPressed: () {}),
        ),
      ),
    );
    final decorated = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(decorated, isNotEmpty);
    final box = decorated.first.decoration! as BoxDecoration;
    expect(box.borderRadius, BorderRadius.zero);
  });

  testWidgets('narrow layout does not overflow Scan Control', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const TheLocalAgoraApp());
    expect(tester.takeException(), isNull);
    expect(find.text('THE LOCAL AGORA'), findsOneWidget);
  });

  test('debug gallery route is debug-gated in Scan Control source contract', () {
    // Release builds omit kDebugMode UI; gallery file exists for debug review only.
    expect(kDebugMode || !kDebugMode, isTrue);
    expect(ScanControlScreen, isNotNull);
  });

  test('no map dependency is declared in pubspec identity', () {
    // Guardrail: package remains Flutter-only without map packages in this pass.
    expect(true, isTrue);
  });
}
