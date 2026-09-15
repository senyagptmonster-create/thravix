import 'package:flutter/material.dart';

class ThravixTheme {
  static const bg = Color(0xFF0D0E13);
  static const surface = Color(0xFF151720);
  static const edge = Color(0xFF212431);
  static const accent = Color(0xFF38BDF8); // Sky Blue
  static const accentLight = Color(0xFF7DD3FC);
  static const ink = Color(0xFFF0F9FF);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const muted = Color(0xFF64748B);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      fontFamily: 'AppFont',
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: ink,
      ),
    );
  }
}
