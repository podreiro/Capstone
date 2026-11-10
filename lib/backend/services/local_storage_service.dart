import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistência local (SharedPreferences): contas, favoritos, histórico e tema.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _usersKey = 'lumen_users';
  static const _sessionKey = 'lumen_session';
  static const _themeKey = 'lumen_reading_theme';
  static const _favoritesPrefix = 'favorites_';
  static const _historyPrefix = 'historyPreferences_';

  static String _norm(String email) => email.trim().toLowerCase();

  // ---- Contas (e-mail -> hash da senha) ----
  Map<String, String> _readUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return {};
  }

  bool userExists(String email) => _readUsers().containsKey(_norm(email));

  String? passwordHash(String email) => _readUsers()[_norm(email)];

  String? get sessionEmail {
    final email = _prefs.getString(_sessionKey);
    if (email == null || !userExists(email)) return null;
    return _norm(email);
  }

  Future<void> saveSession(String email) =>
      _prefs.setString(_sessionKey, _norm(email));

  Future<void> clearSession() => _prefs.remove(_sessionKey);

  Future<void> saveUser(String email, String hash) async {
    final users = _readUsers();
    users[_norm(email)] = hash;
    await _prefs.setString(_usersKey, jsonEncode(users));
  }

  // ---- Favoritos e histórico (somente IDs, separados por usuário) ----
  List<String> favorites(String email) =>
      _prefs.getStringList('$_favoritesPrefix${_norm(email)}') ?? <String>[];

  Future<void> saveFavorites(String email, List<String> ids) =>
      _prefs.setStringList('$_favoritesPrefix${_norm(email)}', ids);

  List<String> history(String email) =>
      _prefs.getStringList('$_historyPrefix${_norm(email)}') ?? <String>[];

  Future<void> saveHistory(String email, List<String> ids) =>
      _prefs.setStringList('$_historyPrefix${_norm(email)}', ids);

  // ---- Tema de leitura ----
  String? get themeName => _prefs.getString(_themeKey);

  Future<void> saveThemeName(String name) => _prefs.setString(_themeKey, name);
}
