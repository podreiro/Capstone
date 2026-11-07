import 'package:flutter/material.dart';

import 'package:lumen/backend/providers/theme_provider.dart';

class AppTheme {
  static ThemeData build(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.creme:
        return _build(
          background: const Color(0xFFF6F0E2),
          surface: const Color(0xFFFFFBF2),
          primary: const Color(0xFF6D5135),
          text: const Color(0xFF3F342A),
        );
      case ReadingTheme.branco:
        return _build(
          background: const Color(0xFFF8F8F8),
          surface: Colors.white,
          primary: const Color(0xFF4A5568),
          text: const Color(0xFF202124),
        );
      case ReadingTheme.noturno:
        return _build(
          background: const Color(0xFF171513),
          surface: const Color(0xFF24201D),
          primary: const Color(0xFFD9B982),
          text: const Color(0xFFF2E9D8),
          brightness: Brightness.dark,
        );
    }
  }

  static ThemeData _build({
    required Color background,
    required Color surface,
    required Color primary,
    required Color text,
    Brightness brightness = Brightness.light,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(primary: primary, surface: surface),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      textTheme: ThemeData(brightness: brightness)
          .textTheme
          .apply(bodyColor: text, displayColor: text),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
