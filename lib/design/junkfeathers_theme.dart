import 'package:flutter/material.dart';

import 'junkfeathers_tokens.dart';

/// Company-wide Junkfeathers Flutter theme baseline.
ThemeData buildJunkfeathersTheme() {
  final base = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: JfColors.black,
    colorScheme: const ColorScheme.dark(
      primary: JfColors.white,
      secondary: JfColors.white,
      surface: JfColors.black,
      onPrimary: JfColors.black,
      onSecondary: JfColors.black,
      onSurface: JfColors.white,
      error: JfColors.amber,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: JfTypography.fontFamily,
      bodyColor: JfColors.white,
      displayColor: JfColors.white,
    ),
    primaryTextTheme: base.primaryTextTheme.apply(
      fontFamily: JfTypography.fontFamily,
      bodyColor: JfColors.white,
      displayColor: JfColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: JfColors.black,
      foregroundColor: JfColors.white,
      elevation: 0,
      titleTextStyle: JfTypography.deviceTitle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: JfColors.black,
      hintStyle: JfTypography.supporting,
      labelStyle: JfTypography.controlLabel,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: JfSpacing.md,
        vertical: JfSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: JfBorders.square,
        borderSide: JfBorders.secondarySide(),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: JfBorders.square,
        borderSide: JfBorders.secondarySide(),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: JfBorders.square,
        borderSide: JfBorders.primarySide(color: JfColors.white),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: JfBorders.square,
        borderSide: const BorderSide(color: JfColors.amber, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: JfBorders.square,
        borderSide: const BorderSide(color: JfColors.amber, width: 2),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: JfColors.black,
      elevation: 0,
      shape: const Border.fromBorderSide(
        BorderSide(color: JfColors.white, width: 2),
      ),
      titleTextStyle: JfTypography.controlLabel.copyWith(fontSize: 13),
      contentTextStyle: JfTypography.supporting,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: JfColors.black,
      contentTextStyle: JfTypography.controlLabel,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    dividerColor: JfColors.white24,
    splashFactory: NoSplash.splashFactory,
    highlightColor: JfColors.white12,
  );
}
