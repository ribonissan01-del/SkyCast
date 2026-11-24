import 'package:flutter/material.dart';

class AppTheme {
  static const _accent = Color(0xFFEB7959);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: brightness,
      surface: isDark ? const Color(0xFF14242A) : const Color(0xFFF4F6F2),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0F1D22)
          : const Color(0xFFF4F6F2),
      fontFamily: 'Avenir',
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
        bodyColor: isDark ? const Color(0xFFE9F0EF) : const Color(0xFF182A30),
        displayColor: isDark
            ? const Color(0xFFE9F0EF)
            : const Color(0xFF182A30),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF192B31) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
