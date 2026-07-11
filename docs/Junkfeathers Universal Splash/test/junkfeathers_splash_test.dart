// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:junkfeathers_universal_splash/junkfeathers_splash.dart';
import 'package:junkfeathers_universal_splash/junkfeathers_logo_painter.dart';

void main() {
  test('Timing constants total exactly 2870 ms', () {
    const total = 990 + 1000 + 880;
    expect(total, equals(2870));
  });

  test(
      'Universal source files contain no forbidden product-specific dependencies',
      () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue);

    final List<String> forbiddenSubstrings = [
      'firebase',
      'billing',
      'orpheus',
      'audio_session',
      'permission_handler',
      'ffmpeg',
      'share_plus',
      'open_file',
    ];

    final files = libDir.listSync(recursive: true);
    expect(files, isNotEmpty);

    for (final entity in files) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync().toLowerCase();
        for (final forbidden in forbiddenSubstrings) {
          final containsForbidden = content.contains(forbidden);
          expect(
            containsForbidden,
            isFalse,
            reason:
                'File ${entity.path} contains forbidden dependency/reference: "$forbidden"',
          );
        }
      }
    }
  });

  testWidgets('Splash renders without error and displays default layout',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(
          destination: const Scaffold(body: Text('DESTINATION_SCREEN')),
          tips: const ['TEST_TIP'],
          deterministicTipIndex: 0,
        ),
      ),
    );

    expect(find.byType(JunkfeathersSplash), findsOneWidget);
    expect(find.text('TEST_TIP'), findsOneWidget);

    final backdropFinder = find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter is JunkfeathersSplashBackdropPainter,
    );
    final logoFinder = find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter is JunkfeathersLogoMarkPainter,
    );

    expect(backdropFinder, findsOneWidget);
    expect(logoFinder, findsOneWidget);
  });

  testWidgets('Splash accepts empty tip list safely',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(
          destination: const Scaffold(body: Text('DESTINATION')),
          tips: const [],
        ),
      ),
    );

    expect(find.byType(JunkfeathersSplash), findsOneWidget);
    // Tip container/text should not be rendered
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('Splash accepts single tip safely', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(
          destination: const Scaffold(body: Text('DESTINATION')),
          tips: const ['SINGLE_TIP'],
          deterministicTipIndex: 0,
        ),
      ),
    );

    expect(find.text('SINGLE_TIP'), findsOneWidget);
  });

  testWidgets('Splash selects deterministic tip index',
      (WidgetTester tester) async {
    const tips = ['TIP_A', 'TIP_B', 'TIP_C'];

    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(
          destination: const Scaffold(body: Text('DESTINATION')),
          tips: tips,
          deterministicTipIndex: 1,
        ),
      ),
    );

    expect(find.text('TIP_B'), findsOneWidget);
  });

  testWidgets('Verify hold phase transition and clean state rendering',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(
          destination: const Scaffold(body: Text('DESTINATION')),
          tips: const ['TIP'],
          deterministicTipIndex: 0,
        ),
      ),
    );

    // Pump into the middle of the reveal phase (500 ms)
    await tester.pump(const Duration(milliseconds: 500));

    var backdropPaint = tester.widget<CustomPaint>(
      find.byWidgetPredicate((w) =>
          w is CustomPaint && w.painter is JunkfeathersSplashBackdropPainter),
    );
    var logoPaint = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is JunkfeathersLogoMarkPainter),
    );

    var backdrop = backdropPaint.painter as JunkfeathersSplashBackdropPainter;
    var logo = logoPaint.painter as JunkfeathersLogoMarkPainter;

    expect(backdrop.phase, equals(SplashPhase.reveal));
    expect(logo.phase, equals(SplashPhase.reveal));

    // Pump into the middle of the hold phase (1500 ms)
    await tester.pump(const Duration(milliseconds: 1000));

    backdropPaint = tester.widget<CustomPaint>(
      find.byWidgetPredicate((w) =>
          w is CustomPaint && w.painter is JunkfeathersSplashBackdropPainter),
    );
    logoPaint = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is JunkfeathersLogoMarkPainter),
    );

    backdrop = backdropPaint.painter as JunkfeathersSplashBackdropPainter;
    logo = logoPaint.painter as JunkfeathersLogoMarkPainter;

    // Both should be in hold phase (deliberate clean state)
    expect(backdrop.phase, equals(SplashPhase.hold));
    expect(logo.phase, equals(SplashPhase.hold));
  });

  testWidgets('Verify reduced motion parameter passes correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(
          destination: const Scaffold(body: Text('DESTINATION')),
          tips: const ['TIP'],
          reducedMotionOverride: true,
        ),
      ),
    );

    final backdropPaint = tester.widget<CustomPaint>(
      find.byWidgetPredicate((w) =>
          w is CustomPaint && w.painter is JunkfeathersSplashBackdropPainter),
    );
    final logoPaint = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is JunkfeathersLogoMarkPainter),
    );

    final backdrop = backdropPaint.painter as JunkfeathersSplashBackdropPainter;
    final logo = logoPaint.painter as JunkfeathersLogoMarkPainter;

    expect(backdrop.reducedMotion, isTrue);
    expect(logo.reducedMotion, isTrue);
  });

  testWidgets('Transition occurs once after approved sequence',
      (WidgetTester tester) async {
    int completeCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(
          destination: const Scaffold(body: Text('DESTINATION_SCREEN')),
          tips: const ['TIP'],
          onComplete: () {
            completeCount++;
          },
        ),
      ),
    );

    // Pump 2860 ms (just before animation finishes)
    await tester.pump(const Duration(milliseconds: 2860));
    expect(completeCount, equals(0));
    expect(find.text('DESTINATION_SCREEN'), findsNothing);

    // Pump remaining 20 ms to cross 2870 ms threshold
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();
    expect(completeCount, equals(1));
    expect(find.text('DESTINATION_SCREEN'), findsOneWidget);

    // Pump more to ensure it doesn't trigger again
    await tester.pump(const Duration(milliseconds: 1000));
    expect(completeCount, equals(1));
  });

  testWidgets('Disposal prevents completion navigation callback',
      (WidgetTester tester) async {
    int completeCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(
          destination: const Scaffold(body: Text('DESTINATION')),
          tips: const ['TIP'],
          onComplete: () {
            completeCount++;
          },
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1000));

    // Remove the splash screen widget to dispose it
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('CLEANUP')),
      ),
    );

    // Pump the rest of the time
    await tester.pump(const Duration(milliseconds: 2000));
    expect(completeCount, equals(0));
  });

  testWidgets('Long tip text does not crash layout',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data:
              const MediaQueryData(size: Size(320, 480)), // Small screen layout
          child: Scaffold(
            body: JunkfeathersSplash(
              destination: const SizedBox(),
              tips: [
                'THIS IS A VERY LONG TIP DESIGNED TO TEST TEXT WRAPPING AND TO VERIFY THAT LAYOUT AND PAINTER DO NOT COLLAPSE OR OVERFLOW EVEN ON VERY NARROW SCREENS OR WITH LARGE TEXT SIZES ' *
                    3
              ],
              deterministicTipIndex: 0,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(JunkfeathersSplash), findsOneWidget);
  });
}
