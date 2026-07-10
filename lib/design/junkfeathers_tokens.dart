import 'package:flutter/material.dart';

/// Junkfeathers Tech design tokens — company visual baseline.
abstract final class JfColors {
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white54 = Colors.white54;
  static const Color white38 = Colors.white38;
  static const Color white24 = Colors.white24;
  static const Color white12 = Colors.white12;

  /// Restrained amber — warnings, uncertainty, missing info, review only.
  static const Color amber = Color(0xFFC9A227);
}

abstract final class JfTypography {
  static const String fontFamily = 'monospace';

  static const TextStyle deviceTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
    color: JfColors.white,
    height: 1.2,
  );

  static const TextStyle numericDisplay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 3.0,
    color: JfColors.white,
    height: 1.1,
  );

  static const TextStyle primaryButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
    color: JfColors.white,
    height: 1.2,
  );

  static const TextStyle controlLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.8,
    color: JfColors.white,
    height: 1.2,
  );

  static const TextStyle supporting = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
    color: JfColors.white70,
    height: 1.35,
  );

  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 8,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    color: JfColors.white54,
    height: 1.25,
  );

  static const TextStyle fieldInput = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    color: JfColors.white,
    height: 1.3,
  );

  static const TextStyle warning = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.6,
    color: JfColors.amber,
    height: 1.3,
  );
}

abstract final class JfSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 48;
}

abstract final class JfBorders {
  static const double major = 3;
  static const double primary = 2;
  static const double secondary = 1;

  static const BorderRadius square = BorderRadius.zero;

  static BorderSide majorSide({Color color = JfColors.white}) =>
      BorderSide(color: color, width: major);

  static BorderSide primarySide({Color color = JfColors.white70}) =>
      BorderSide(color: color, width: primary);

  static BorderSide secondarySide({Color color = JfColors.white54}) =>
      BorderSide(color: color, width: secondary);
}

abstract final class JfMotion {
  static const Duration press = Duration(milliseconds: 50);
  static const Duration toast = Duration(milliseconds: 2300);
}

abstract final class JfControlSizes {
  static const double minTap = 44;
  static const double fullWidthVerticalPadding = 16;
  static const Size transport = Size(70, 60);
  static const Size compact = Size(36, 36);
}
