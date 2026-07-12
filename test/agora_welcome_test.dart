import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_local_agora/design/junkfeathers_tokens.dart';
import 'package:the_local_agora/features/welcome/agora_about_copy.dart';
import 'package:the_local_agora/features/welcome/agora_about_dialog.dart';
import 'package:the_local_agora/features/welcome/agora_welcome_copy.dart';
import 'package:the_local_agora/features/welcome/agora_welcome_dialog.dart';
import 'package:the_local_agora/features/welcome/welcome_suppression_store.dart';
import 'package:the_local_agora/main.dart';

Future<void> _pumpDialogTransition(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('automatic Welcome appears when suppression is false', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = InMemoryWelcomeStore();
    await tester.pumpWidget(
      TheLocalAgoraApp(
        enableStartupSplash: false,
        autoShowWelcome: true,
        welcomeStore: store,
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(AgoraWelcomeDialog), findsOneWidget);
    expect(find.text(AgoraWelcomeCopy.welcomeHeadline), findsOneWidget);
    expect(
      find.text('Discover music, comedy, and theater events near you.'),
      findsOneWidget,
    );
    expect(find.textContaining('art, and creative'), findsNothing);
    expect(find.text('SEARCH FOR AN EVENT'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('ADD EVENT'), findsOneWidget);
  });

  testWidgets('CLOSE dismisses without permanent suppression', (tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = InMemoryWelcomeStore();
    await tester.pumpWidget(
      TheLocalAgoraApp(
        enableStartupSplash: false,
        autoShowWelcome: true,
        welcomeStore: store,
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('agora-welcome-close')));
    await _pumpDialogTransition(tester);

    expect(find.byType(AgoraWelcomeDialog), findsNothing);
    expect(await store.isPermanentlyDismissed(), isFalse);
    expect(await store.isShowWelcomeOnStartup(), isTrue);
  });

  testWidgets("DON'T SHOW AGAIN disables automatic Welcome", (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPreferencesWelcomeStore();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  showAgoraWelcomeDialog(context: context, store: store);
                },
                child: const Text('OPEN'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('OPEN'));
    await _pumpDialogTransition(tester);

    await tester.tap(find.byKey(const ValueKey('agora-welcome-dont-show')));
    await _pumpDialogTransition(tester);

    expect(await store.isPermanentlyDismissed(), isTrue);
    expect(await store.isShowWelcomeOnStartup(), isFalse);
  });

  testWidgets('future startup skips automatic Welcome after suppression', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = InMemoryWelcomeStore(permanentlyDismissed: true);
    await tester.pumpWidget(
      TheLocalAgoraApp(
        enableStartupSplash: false,
        autoShowWelcome: true,
        welcomeStore: store,
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(AgoraWelcomeDialog), findsNothing);
    expect(find.text(AgoraWelcomeCopy.welcomeHeadline), findsNothing);
  });

  testWidgets('ABOUT opens real About content not Welcome', (tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = InMemoryWelcomeStore(permanentlyDismissed: true);
    await tester.pumpWidget(
      TheLocalAgoraApp(
        enableStartupSplash: false,
        autoShowWelcome: false,
        welcomeStore: store,
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('agora-open-about')), findsOneWidget);
    expect(find.byKey(const ValueKey('agora-add-event')), findsOneWidget);
    // No identity-area ABOUT key from Pass 02C.
    expect(find.byKey(const ValueKey('agora-open-welcome')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('agora-open-about')));
    await _pumpDialogTransition(tester);
    await tester.pump();

    expect(find.byType(AgoraAboutDialog), findsOneWidget);
    expect(find.byType(AgoraWelcomeDialog), findsNothing);
    expect(find.text(AgoraAboutCopy.productTitle), findsWidgets);
    expect(find.text(AgoraAboutCopy.tagline), findsOneWidget);
    expect(find.text(AgoraAboutCopy.statement), findsOneWidget);
    expect(find.text(AgoraAboutCopy.showWelcomeOnStartupLabel), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('agora-about-close')));
    await _pumpDialogTransition(tester);
    expect(find.byType(AgoraAboutDialog), findsNothing);
  });

  testWidgets('About switch can re-enable and disable automatic Welcome', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = InMemoryWelcomeStore(permanentlyDismissed: true);
    await tester.pumpWidget(
      TheLocalAgoraApp(
        enableStartupSplash: false,
        autoShowWelcome: false,
        welcomeStore: store,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('agora-open-about')));
    await _pumpDialogTransition(tester);
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('agora-welcome-startup-on')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('agora-welcome-startup-on')));
    await tester.pump(JfMotion.press);
    await tester.pump();
    expect(await store.isShowWelcomeOnStartup(), isTrue);
    expect(await store.isPermanentlyDismissed(), isFalse);

    await tester.tap(find.byKey(const ValueKey('agora-welcome-startup-off')));
    await tester.pump(JfMotion.press);
    await tester.pump();
    expect(await store.isShowWelcomeOnStartup(), isFalse);
    expect(await store.isPermanentlyDismissed(), isTrue);
  });

  testWidgets('ADD EVENT and ABOUT sit beneath SEARCH FOR AN EVENT', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const TheLocalAgoraApp(
        enableStartupSplash: false,
        autoShowWelcome: false,
      ),
    );
    await tester.pump();

    final scanY = tester.getTopLeft(find.text('SEARCH FOR AN EVENT')).dy;
    final addY = tester.getTopLeft(find.text('ADD EVENT')).dy;
    final aboutY = tester.getTopLeft(find.text('ABOUT')).dy;
    expect(addY, greaterThan(scanY));
    expect(aboutY, greaterThan(scanY));
    expect((addY - aboutY).abs(), lessThan(2));
  });

  testWidgets('scaled Welcome content keeps controls reachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 560);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = InMemoryWelcomeStore();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: TheLocalAgoraApp(
          enableStartupSplash: false,
          autoShowWelcome: true,
          welcomeStore: store,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(const ValueKey('agora-welcome-close')),
    );
    expect(find.byKey(const ValueKey('agora-welcome-close')), findsOneWidget);

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.elevation, 0);
    final shape = dialog.shape! as Border;
    expect(shape.top.width, JfBorders.primary);
  });
}
