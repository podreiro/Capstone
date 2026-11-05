import 'package:flutter/material.dart';

import 'package:lumen/Tema.dart';
import 'package:lumen/backend/services/local_store.dart';

class ThemeProvider extends ChangeNotifier {
  final LocalStore _store;

  ThemeProvider(this._store);

  ReadingTheme current = ReadingTheme.creme;

  ThemeData get themeData => buildReadingTheme(current);

  Future<void> load() async {
    final saved = await _store.getTheme();
    current = ReadingTheme.values.firstWhere(
      (t) => t.name == saved,
      orElse: () => ReadingTheme.creme,
    );
    notifyListeners();
  }

  Future<void> set(ReadingTheme value) async {
    current = value;
    notifyListeners();
    await _store.setTheme(value.name);
  }
}
