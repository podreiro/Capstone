import 'package:flutter/foundation.dart';

import 'package:lumen/backend/services/local_storage_service.dart';

enum ReadingTheme { creme, branco, noturno }

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage) {
    final saved = _storage.themeName;
    _theme = ReadingTheme.values.firstWhere(
      (t) => t.name == saved,
      orElse: () => ReadingTheme.creme,
    );
  }

  final LocalStorageService _storage;
  ReadingTheme _theme = ReadingTheme.creme;

  ReadingTheme get theme => _theme;

  Future<void> setTheme(ReadingTheme value) async {
    if (value == _theme) return;
    _theme = value;
    notifyListeners();
    await _storage.saveThemeName(value.name);
  }
}
