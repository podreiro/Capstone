import 'package:flutter/material.dart';

import 'package:lumen/Paginas/login_page.dart';
import 'package:lumen/Tema.dart';

void main() {
  runApp(const LumenApp());
}

class LumenApp extends StatefulWidget {
  const LumenApp({super.key});

  @override
  State<LumenApp> createState() => _LumenAppState();
}

class _LumenAppState extends State<LumenApp> {
  ReadingTheme readingTheme = ReadingTheme.creme;

  ThemeData get theme {
    switch (readingTheme) {
      case ReadingTheme.creme:
        return _buildTheme(
          background: const Color(0xFFF6F0E2),
          surface: const Color(0xFFFFFBF2),
          primary: const Color(0xFF6D5135),
          text: const Color(0xFF3F342A),
        );
      case ReadingTheme.branco:
        return _buildTheme(
          background: const Color(0xFFF8F8F8),
          surface: Colors.white,
          primary: const Color(0xFF4A5568),
          text: const Color(0xFF202124),
        );
      case ReadingTheme.noturno:
        return _buildTheme(
          background: const Color(0xFF171513),
          surface: const Color(0xFF24201D),
          primary: const Color(0xFFD9B982),
          text: const Color(0xFFF2E9D8),
          brightness: Brightness.dark,
        );
    }
  }

  ThemeData _buildTheme({
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
      colorScheme: scheme.copyWith(
        primary: primary,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: ThemeData(
        brightness: brightness,
      ).textTheme.apply(
            bodyColor: text,
            displayColor: text,
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void setReadingTheme(ReadingTheme value) {
    setState(() => readingTheme = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lúmen',
      theme: theme,
      home: LoginPage(onThemeChanged: setReadingTheme),
    );
  }
}
