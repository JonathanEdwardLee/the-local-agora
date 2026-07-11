import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/brand/junkfeathers_splash/junkfeathers_logo_painter.dart';
import 'package:the_local_agora/brand/junkfeathers_splash/junkfeathers_splash.dart';
import 'package:the_local_agora/brand/junkfeathers_splash_spec.dart';
import 'package:the_local_agora/brand/local_agora_splash_tips.dart';
import 'package:the_local_agora/features/startup/startup_gate.dart';
import 'package:the_local_agora/features/welcome/welcome_suppression_store.dart';
import 'package:the_local_agora/main.dart';

void main() {
  test('Timing constants total exactly 2870 ms', () {
    expect(
      JunkfeathersSplashSpec.revealMs.inMilliseconds +
          JunkfeathersSplashSpec.holdMs.inMilliseconds +
          JunkfeathersSplashSpec.hideMs.inMilliseconds,
      2870,
    );
    expect(JunkfeathersSplashSpec.totalBrandedSequence.inMilliseconds, 2870);
  });

  test('Interference intensity progresses upward overall', () {
    final early = splashInterferenceIntensity(SplashPhase.reveal, 0.1);
    final lateReveal = splashInterferenceIntensity(SplashPhase.reveal, 0.95);
    final midHold = splashInterferenceIntensity(SplashPhase.hold, 0.5);
    final lateHold = splashInterferenceIntensity(SplashPhase.hold, 0.95);
    final midHide = splashInterferenceIntensity(SplashPhase.hide, 0.5);
    final end = splashInterferenceIntensity(SplashPhase.hide, 1.0);

    expect(early, lessThan(lateReveal));
    expect(lateReveal, lessThan(midHold));
    expect(midHold, lessThan(lateHold));
    expect(lateHold, lessThan(midHide));
    expect(midHide, lessThanOrEqualTo(end));
    expect(end, greaterThan(0.9));
    expect(splashUsesCleanStaticHold(SplashPhase.hold, 0.5), isFalse);
  });

  test('Mid-hold is not a clean static envelope', () {
    expect(
      splashInterferenceIntensity(SplashPhase.hold, 0.5),
      greaterThan(0.2),
    );
    expect(splashUsesCleanStaticHold(SplashPhase.hold, 0.5), isFalse);
  });

  test('Local Agora tip list has eight approved tips', () {
    expect(kLocalAgoraSplashTips, hasLength(8));
    expect(
      kLocalAgoraSplashTips,
      contains('FIND YOUR SCENE. GROW YOUR SCENE.'),
    );
  });

  testWidgets('Splash renders with Local Agora tip', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(
          tips: kLocalAgoraSplashTips,
          deterministicTipIndex: 0,
          onComplete: () {},
        ),
      ),
    );

    expect(find.byType(JunkfeathersSplash), findsOneWidget);
    expect(find.text(kLocalAgoraSplashTips.first), findsOneWidget);
  });

  testWidgets('Empty tips are safe', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(tips: const [], onComplete: () {}),
      ),
    );
    expect(find.byType(JunkfeathersSplash), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('Reduced motion is safe', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(
          tips: const ['TIP'],
          reducedMotionOverride: true,
          onComplete: () {},
        ),
      ),
    );
    final backdrop =
        tester
                .widget<CustomPaint>(
                  find.byWidgetPredicate(
                    (w) =>
                        w is CustomPaint &&
                        w.painter is JunkfeathersSplashBackdropPainter,
                  ),
                )
                .painter!
            as JunkfeathersSplashBackdropPainter;
    expect(backdrop.reducedMotion, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hold midpoint is not a deliberate clean static paint', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JunkfeathersSplash(tips: const ['TIP'], onComplete: () {}),
      ),
    );

    // 1500 ms is middle of former "hold" segment.
    await tester.pump(const Duration(milliseconds: 1500));
    final backdrop =
        tester
                .widget<CustomPaint>(
                  find.byWidgetPredicate(
                    (w) =>
                        w is CustomPaint &&
                        w.painter is JunkfeathersSplashBackdropPainter,
                  ),
                )
                .painter!
            as JunkfeathersSplashBackdropPainter;
    expect(backdrop.phase, SplashPhase.hold);
    expect(
      splashInterferenceIntensity(backdrop.phase, backdrop.progress),
      greaterThan(0.2),
    );
    expect(
      splashUsesCleanStaticHold(backdrop.phase, backdrop.progress),
      isFalse,
    );
  });

  testWidgets('StartupGate shows destination after splash once', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StartupGate(
          welcomeStore: InMemoryWelcomeStore(permanentlyDismissed: true),
          autoShowWelcome: false,
          tips: const ['TIP_A'],
          deterministicTipIndex: 0,
          builder: (context, openAbout) {
            return const Scaffold(body: Text('MAIN_SHELL'));
          },
        ),
      ),
    );

    expect(find.byType(JunkfeathersSplash), findsOneWidget);
    expect(find.text('MAIN_SHELL'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2860));
    expect(find.text('MAIN_SHELL'), findsNothing);

    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();
    expect(find.text('MAIN_SHELL'), findsOneWidget);
    expect(find.byType(JunkfeathersSplash), findsNothing);

    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('MAIN_SHELL'), findsOneWidget);
  });

  testWidgets('TheLocalAgoraApp splash then main shell', (tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      TheLocalAgoraApp(
        enableStartupSplash: true,
        autoShowWelcome: false,
        welcomeStore: InMemoryWelcomeStore(permanentlyDismissed: true),
        splashTips: const ['LA_TIP'],
        deterministicTipIndex: 0,
      ),
    );

    expect(find.byType(JunkfeathersSplash), findsOneWidget);
    expect(find.text('LA_TIP'), findsOneWidget);
    expect(find.text('SCAN THE AGORA'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2860));
    expect(find.text('SCAN THE AGORA'), findsNothing);

    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('SCAN THE AGORA'), findsOneWidget);
    expect(find.byType(JunkfeathersSplash), findsNothing);
  });
}
