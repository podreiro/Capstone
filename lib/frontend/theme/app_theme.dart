import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen/backend/providers/theme_provider.dart';

/// Extension de cores do Lúmen para suportar tanto o tema Noturno quanto o Creme.
class LumenColors extends ThemeExtension<LumenColors> {
  const LumenColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.accent,
    required this.accentText,
    required this.textPrimary,
    required this.textMuted,
    required this.cardGradientEnd,
  });

  final Color bg;
  final Color surface;
  final Color card;
  final Color border;
  final Color accent;
  final Color accentText;
  final Color textPrimary;
  final Color textMuted;
  final Color cardGradientEnd;

  static const dark = LumenColors(
    bg: Color(0xFF0A0A0F),
    surface: Color(0xFF141420),
    card: Color(0xFF1C1C2A),
    border: Color(0xFF2A2A3A),
    accent: Color(0xFFE8A838),
    accentText: Color(0xFF1A1200),
    textPrimary: Color(0xFFF0EDE8),
    textMuted: Color(0xFF7A7A8A),
    cardGradientEnd: Color(0xEE0A0A0F),
  );

  static const creme = LumenColors(
    bg: Color(0xFFF6F0E2),
    surface: Color(0xFFFFFBF2),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE5DDD0),
    accent: Color(0xFF6D5135),
    accentText: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF3F342A),
    textMuted: Color(0xFF7D6E60),
    cardGradientEnd: Color(0xEE3F342A),
  );

  @override
  ThemeExtension<LumenColors> copyWith({
    Color? bg,
    Color? surface,
    Color? card,
    Color? border,
    Color? accent,
    Color? accentText,
    Color? textPrimary,
    Color? textMuted,
    Color? cardGradientEnd,
  }) {
    return LumenColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentText: accentText ?? this.accentText,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      cardGradientEnd: cardGradientEnd ?? this.cardGradientEnd,
    );
  }

  @override
  ThemeExtension<LumenColors> lerp(ThemeExtension<LumenColors>? other, double t) {
    if (other is! LumenColors) return this;
    return LumenColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      cardGradientEnd: Color.lerp(cardGradientEnd, other.cardGradientEnd, t)!,
    );
  }
}

extension LumenContext on BuildContext {
  LumenColors get lumen =>
      Theme.of(this).extension<LumenColors>() ?? LumenColors.dark;
}

class AppTheme {
  static ThemeData build(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.noturno:
      case ReadingTheme.branco:
        return _buildDark();
      case ReadingTheme.creme:
        return _buildCreme();
    }
  }

  // ── Dark Theme (âmbar-noir) ───────────────────────────────────────────────

  static ThemeData _buildDark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme, LumenColors.dark.textPrimary);

    return base.copyWith(
      extensions: const [LumenColors.dark],
      colorScheme: ColorScheme.dark(
        brightness: Brightness.dark,
        primary: LumenColors.dark.accent,
        onPrimary: LumenColors.dark.accentText,
        surface: LumenColors.dark.surface,
        onSurface: LumenColors.dark.textPrimary,
        surfaceContainerHighest: LumenColors.dark.card,
        outline: LumenColors.dark.border,
        error: const Color(0xFFCF6679),
        onError: const Color(0xFF1A0010),
      ),
      scaffoldBackgroundColor: LumenColors.dark.bg,
      cardColor: LumenColors.dark.card,
      dividerColor: LumenColors.dark.border,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: LumenColors.dark.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: LumenColors.dark.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LumenColors.dark.bg,
        indicatorColor: const Color(0x33E8A838),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: LumenColors.dark.textMuted),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: LumenColors.dark.card,
        labelStyle: TextStyle(
          color: LumenColors.dark.textPrimary.withAlpha(200),
          fontSize: 12,
        ),
        side: BorderSide(color: LumenColors.dark.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LumenColors.dark.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LumenColors.dark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LumenColors.dark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LumenColors.dark.accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: LumenColors.dark.textMuted),
        prefixIconColor: LumenColors.dark.textMuted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LumenColors.dark.accent,
          foregroundColor: LumenColors.dark.accentText,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  // ── Creme Theme ───────────────────────────────────────────────────────────

  static ThemeData _buildCreme() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme, LumenColors.creme.textPrimary);

    return base.copyWith(
      extensions: const [LumenColors.creme],
      colorScheme: ColorScheme.fromSeed(
        seedColor: LumenColors.creme.accent,
        brightness: Brightness.light,
      ).copyWith(
        primary: LumenColors.creme.accent,
        onPrimary: LumenColors.creme.accentText,
        surface: LumenColors.creme.surface,
        onSurface: LumenColors.creme.textPrimary,
        surfaceContainerHighest: LumenColors.creme.card,
        outline: LumenColors.creme.border,
      ),
      scaffoldBackgroundColor: LumenColors.creme.bg,
      cardColor: LumenColors.creme.card,
      dividerColor: LumenColors.creme.border,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: LumenColors.creme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: LumenColors.creme.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LumenColors.creme.bg,
        indicatorColor: const Color(0x336D5135),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: LumenColors.creme.textMuted),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LumenColors.creme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LumenColors.creme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LumenColors.creme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LumenColors.creme.accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: LumenColors.creme.textMuted),
        prefixIconColor: LumenColors.creme.textMuted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LumenColors.creme.accent,
          foregroundColor: LumenColors.creme.accentText,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  // ── Tipografia ────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    final inter = GoogleFonts.interTextTheme(base).apply(
      bodyColor: textColor,
      displayColor: textColor,
    );

    return inter.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        textStyle: inter.displayLarge,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        textStyle: inter.displayMedium,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        textStyle: inter.displaySmall,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        textStyle: inter.headlineLarge,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        textStyle: inter.headlineMedium,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        textStyle: inter.headlineSmall,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: inter.titleLarge,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: inter.titleMedium,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
