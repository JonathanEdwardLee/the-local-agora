import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_local_agora/design/junkfeathers_tokens.dart';
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
    expect(find.text(AgoraWelcomeCopy.welcomeBody), findsOneWidget);
    expect(find.text(AgoraWelcomeCopy.sectionHelp), findsOneWidget);
    expect(find.text(AgoraWelcomeCopy.helpBody), findsOneWidget);
    expect(find.text(AgoraWelcomeCopy.sectionTogether), findsOneWidget);
    expect(find.text(AgoraWelcomeCopy.togetherBody), findsOneWidget);
    expect(find.text('SCAN THE AGORA'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
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
  });

  testWidgets("DON'T SHOW AGAIN persists suppression", (tester) async {
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
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(SharedPreferencesWelcomeStore.preferenceKey), isTrue);
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
    expect(find.text('SCAN THE AGORA'), findsOneWidget);
  });

  testWidgets('manual ABOUT reopen works after permanent suppression', (
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
    await tester.tap(find.byKey(const ValueKey('agora-open-welcome')));
    await _pumpDialogTransition(tester);

    expect(find.byType(AgoraWelcomeDialog), findsOneWidget);
    expect(find.text(AgoraWelcomeCopy.welcomeHeadline), findsOneWidget);
    expect(await store.isPermanentlyDismissed(), isTrue);
  });

  testWidgets('dialog does not appear twice from rebuild', (tester) async {
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
  });

  testWidgets('scaled content keeps controls reachable', (tester) async {
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
    await tester.ensureVisible(
      find.byKey(const ValueKey('agora-welcome-dont-show')),
    );
    expect(find.byKey(const ValueKey('agora-welcome-close')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('agora-welcome-dont-show')),
      findsOneWidget,
    );

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.elevation, 0);
    final shape = dialog.shape! as Border;
    expect(shape.top.width, JfBorders.primary);
  });
}
