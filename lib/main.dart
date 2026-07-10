import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/pass01/pass01_foundation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF0A0A0A),
          primary: Color(0xFFE8E4D9),
          onPrimary: Color(0xFF0A0A0A),
          secondary: Color(0xFF9A968A),
        ),
        useMaterial3: true,
      ),
      home: const Pass01FoundationScreen(),
    );
  }
}
