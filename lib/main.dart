import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design/junkfeathers_theme.dart';
import 'features/scan_control/scan_control_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-only on mobile platforms. Web has no phone orientation lock.
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
  runApp(const TheLocalAgoraApp());
}

class TheLocalAgoraApp extends StatelessWidget {
  const TheLocalAgoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Local Agora',
      debugShowCheckedModeBanner: false,
      theme: buildJunkfeathersTheme(),
      home: const ScanControlScreen(),
    );
  }
}
