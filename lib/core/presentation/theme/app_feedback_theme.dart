import 'package:flutter/material.dart';

/// Centralized semantic color tokens for feedback UI (snackbars, banners, alerts).
abstract final class AppFeedbackTheme {
  /// Success background color in light theme.
  static const Color successBackgroundLight = Color(0xFFE7F8ED);

  /// Success background color in dark theme.
  static const Color successBackgroundDark = Color(0xFF14291E);

  /// Success text and icon color in light theme.
  static const Color successForegroundLight = Color(0xFF156F35);

  /// Success text and icon color in dark theme.
  static const Color successForegroundDark = Color(0xFF7CE38B);

  /// Error background color in light theme.
  static const Color errorBackgroundLight = Color(0xFFFCE8E6);

  /// Error background color in dark theme.
  static const Color errorBackgroundDark = Color(0xFF2E1517);

  /// Error text and icon color in light theme.
  static const Color errorForegroundLight = Color(0xFFB3261E);

  /// Error text and icon color in dark theme.
  static const Color errorForegroundDark = Color(0xFFF2B8B5);

  /// Warning background color in light theme.
  static const Color warningBackgroundLight = Color(0xFFFEF7E0);

  /// Warning background color in dark theme.
  static const Color warningBackgroundDark = Color(0xFF2A200B);

  /// Warning text and icon color in light theme.
  static const Color warningForegroundLight = Color(0xFF7D5700);

  /// Warning text and icon color in dark theme.
  static const Color warningForegroundDark = Color(0xFFFFD56B);

  /// Info background color in light theme.
  static const Color infoBackgroundLight = Color(0xFFE8F0FE);

  /// Info background color in dark theme.
  static const Color infoBackgroundDark = Color(0xFF121C2B);

  /// Info text and icon color in light theme.
  static const Color infoForegroundLight = Color(0xFF0A56D1);

  /// Info text and icon color in dark theme.
  static const Color infoForegroundDark = Color(0xFFA8C7FA);
}
