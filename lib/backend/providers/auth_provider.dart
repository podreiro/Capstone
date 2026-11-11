import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'package:lumen/backend/services/local_storage_service.dart';

/// Autenticação local com sessão persistida até o usuário sair da conta.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._storage) : _email = _storage.sessionEmail;

  final LocalStorageService _storage;
  String? _email;

  String? get email => _email;
  bool get isLoggedIn => _email != null;

  String _hash(String email, String password) {
    final input = 'lumen|${email.trim().toLowerCase()}|$password';
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Retorna `null` em caso de sucesso, ou a mensagem de erro.
  Future<String?> register(String email, String password) async {
    if (_storage.userExists(email)) {
      return 'Este e-mail já está cadastrado. Use a opção "Entrar".';
    }
    await _storage.saveUser(email, _hash(email, password));
    final normalizedEmail = email.trim().toLowerCase();
    await _storage.saveSession(normalizedEmail);
    _email = normalizedEmail;
    notifyListeners();
    return null;
  }

  /// Retorna `null` em caso de sucesso, ou a mensagem de erro.
  Future<String?> login(String email, String password) async {
    final saved = _storage.passwordHash(email);
    if (saved == null || saved != _hash(email, password)) {
      return 'E-mail ou senha incorretos. Ainda não tem conta? Cadastre-se.';
    }
    final normalizedEmail = email.trim().toLowerCase();
    await _storage.saveSession(normalizedEmail);
    _email = normalizedEmail;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await _storage.clearSession();
    _email = null;
    notifyListeners();
  }
}
