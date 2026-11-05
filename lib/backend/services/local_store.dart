import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumen/backend/models/book.dart';

/// Camada de persistência: só fala com SharedPreferences.
class LocalStore {
  static const _favoritesKey = 'favorite_books';
  static const _historyKey = 'history_books';
  static const _usersKey = 'users';
  static const _sessionKey = 'session_email';
  static const _themeKey = 'reading_theme';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---------- livros (favoritos e histórico) ----------

  Future<List<AppBook>> getFavorites() => _readBooks(_favoritesKey);
  Future<void> saveFavorites(List<AppBook> books) =>
      _writeBooks(_favoritesKey, books);

  Future<List<AppBook>> getHistory() => _readBooks(_historyKey);
  Future<void> saveHistory(List<AppBook> books) =>
      _writeBooks(_historyKey, books);

  Future<List<AppBook>> _readBooks(String key) async {
    final raw = (await _prefs).getStringList(key) ?? const <String>[];
    final books = <AppBook>[];
    for (final item in raw) {
      try {
        books.add(AppBook.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {
        // registro corrompido: ignora
      }
    }
    return books;
  }

  Future<void> _writeBooks(String key, List<AppBook> books) async {
    await (await _prefs).setStringList(
      key,
      books.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }

  // ---------- usuários e sessão ----------

  Future<Map<String, String>> _readUsers() async {
    final raw = (await _prefs).getString(_usersKey);
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, '$v'));
    } catch (_) {
      return {};
    }
  }

  Future<bool> userExists(String email) async =>
      (await _readUsers()).containsKey(email);

  Future<bool> checkPassword(String email, String password) async =>
      (await _readUsers())[email] == password;

  Future<void> saveUser(String email, String password) async {
    final users = await _readUsers();
    users[email] = password;
    await (await _prefs).setString(_usersKey, jsonEncode(users));
  }

  Future<String?> getSession() async => (await _prefs).getString(_sessionKey);

  Future<void> setSession(String? email) async {
    final prefs = await _prefs;
    if (email == null) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setString(_sessionKey, email);
    }
  }

  // ---------- tema ----------

  Future<String?> getTheme() async => (await _prefs).getString(_themeKey);
  Future<void> setTheme(String name) async =>
      (await _prefs).setString(_themeKey, name);
}
