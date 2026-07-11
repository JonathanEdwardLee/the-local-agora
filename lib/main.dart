import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design/junkfeathers_theme.dart';
import 'features/scan_control/scan_control_screen.dart';
import 'firebase_options.dart';
import 'services/keryx/firebase_keryx_link_service.dart';
import 'services/keryx/keryx_link_service.dart';
import 'services/keryx/keryx_live_scan_service.dart';

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

  final firebaseReady = await initializeFirebaseSafely();
  final appCheckReady =
      firebaseReady ? await initializeAppCheckSafely() : false;

  runApp(
    TheLocalAgoraApp(
      firebaseReady: firebaseReady,
      appCheckReady: appCheckReady,
      keryxLinkService: firebaseReady ? FirebaseKeryxLinkService() : null,
      keryxLiveScanService: firebaseReady && appCheckReady && !kIsWeb
          ? FirebaseKeryxLiveScanService()
          : null,
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
  });

  final bool firebaseReady;
  final bool appCheckReady;
  final KeryxLinkService? keryxLinkService;
  final KeryxLiveScanService? keryxLiveScanService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Local Agora',
      debugShowCheckedModeBanner: false,
      theme: buildJunkfeathersTheme(),
      home: ScanControlScreen(
        firebaseReady: firebaseReady,
        appCheckReady: appCheckReady,
        keryxLinkService: keryxLinkService,
        keryxLiveScanService: keryxLiveScanService,
      ),
    );
  }
}
