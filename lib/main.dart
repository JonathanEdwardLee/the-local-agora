import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'brand/local_agora_splash_tips.dart';
import 'design/junkfeathers_theme.dart';
import 'features/scan_control/scan_control_screen.dart';
import 'features/startup/startup_gate.dart';
import 'features/welcome/welcome_suppression_store.dart';
import 'firebase_options.dart';
import 'services/keryx/demo_keryx_service.dart';
import 'services/keryx/firebase_keryx_link_service.dart';
import 'services/keryx/keryx_link_service.dart';
import 'services/keryx/keryx_live_scan_service.dart';
import 'services/keryx/keryx_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Known limitation (Pass 02C): Firebase + App Check still initialize before
  // runApp. The splash itself is network-independent; this may delay first
  // paint until local SDK init finishes. Do not gate splash on network success.
  final firebaseReady = await initializeFirebaseSafely();
  final appCheckReady = firebaseReady
      ? await initializeAppCheckSafely()
      : false;

  runApp(
    TheLocalAgoraApp(
      firebaseReady: firebaseReady,
      appCheckReady: appCheckReady,
      keryxLinkService: firebaseReady ? FirebaseKeryxLinkService() : null,
      keryxLiveScanService: firebaseReady && appCheckReady && !kIsWeb
          ? FirebaseKeryxLiveScanService()
          : null,
      keryxService: DemoKeryxService(),
    ),
  );
}

/// Initializes Firebase without crashing the UI on failure.
Future<bool> initializeFirebaseSafely() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (e) {
    debugPrint('Firebase initialization failed: ${e.runtimeType}');
    return false;
  }
}

/// Initializes App Check after Firebase. Failure leaves the app usable.
Future<bool> initializeAppCheckSafely() async {
  try {
    await FirebaseAppCheck.instance.activate(
      // Debug builds use the official debug provider. Release prepares Play Integrity.
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      // Web live scan stays disabled in this pass — no invented reCAPTCHA key.
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestProvider(),
    );
    return true;
  } catch (e) {
    debugPrint('App Check initialization failed: ${e.runtimeType}');
    return false;
  }
}

class TheLocalAgoraApp extends StatelessWidget {
  const TheLocalAgoraApp({
    super.key,
    this.firebaseReady = false,
    this.appCheckReady = false,
    this.keryxLinkService,
    this.keryxLiveScanService,
    this.keryxService,
    this.welcomeStore,
    this.enableStartupSplash = true,
    this.autoShowWelcome = true,
    this.splashTips = kLocalAgoraSplashTips,
    this.deterministicTipIndex,
  });

  final bool firebaseReady;
  final bool appCheckReady;
  final KeryxLinkService? keryxLinkService;
  final KeryxLiveScanService? keryxLiveScanService;
  final KeryxService? keryxService;
  final WelcomeSuppressionStore? welcomeStore;
  final bool enableStartupSplash;
  final bool autoShowWelcome;
  final List<String> splashTips;
  final int? deterministicTipIndex;

  @override
  Widget build(BuildContext context) {
    final store = welcomeStore ?? SharedPreferencesWelcomeStore();

    return MaterialApp(
      title: 'The Local Agora',
      debugShowCheckedModeBanner: false,
      theme: buildJunkfeathersTheme(),
      home: StartupGate(
        welcomeStore: store,
        tips: splashTips,
        enableStartupSplash: enableStartupSplash,
        autoShowWelcome: autoShowWelcome,
        deterministicTipIndex: deterministicTipIndex,
        builder: (context, openAbout) {
          return ScanControlScreen(
            firebaseReady: firebaseReady,
            appCheckReady: appCheckReady,
            keryxLinkService: keryxLinkService,
            keryxLiveScanService: keryxLiveScanService,
            keryxService: keryxService ?? DemoKeryxService(),
            onOpenAbout: openAbout,
          );
        },
      ),
    );
  }
}
