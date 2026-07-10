import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design/junkfeathers_theme.dart';
import 'features/scan_control/scan_control_screen.dart';
import 'firebase_options.dart';
import 'services/keryx/firebase_keryx_link_service.dart';
import 'services/keryx/keryx_link_service.dart';

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
  runApp(
    TheLocalAgoraApp(
      firebaseReady: firebaseReady,
      keryxLinkService:
          firebaseReady ? FirebaseKeryxLinkService() : null,
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

class TheLocalAgoraApp extends StatelessWidget {
  const TheLocalAgoraApp({
    super.key,
    this.firebaseReady = false,
    this.keryxLinkService,
  });

  final bool firebaseReady;
  final KeryxLinkService? keryxLinkService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Local Agora',
      debugShowCheckedModeBanner: false,
      theme: buildJunkfeathersTheme(),
      home: ScanControlScreen(
        firebaseReady: firebaseReady,
        keryxLinkService: keryxLinkService,
      ),
    );
  }
}
