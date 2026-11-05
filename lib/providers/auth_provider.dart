import 'package:flutter/foundation.dart';

import 'package:lumen/backend/services/local_store.dart';

class AuthProvider extends ChangeNotifier {
  final LocalStore _store;

  AuthProvider(this._store);

  bool initialized = false;
  bool loading = false;
  String? email;
  String? error;

  bool get isLoggedIn => email != null;

  /// Restaura a sessão salva ao abrir o app.
  Future<void> init() async {
    email = await _store.getSession();
    initialized = true;
    notifyListeners();
  }

  void clearError() {
    if (error == null) return;
    error = null;
    notifyListeners();
  }

  Future<bool> login(String rawEmail, String password) async {
    final mail = rawEmail.trim().toLowerCase();
    return _run(() async {
      if (!await _store.userExists(mail)) {
        error = 'Conta não encontrada. Use a aba "Cadastrar".';
        return false;
      }
      if (!await _store.checkPassword(mail, password)) {
        error = 'Senha incorreta.';
        return false;
      }
      await _store.setSession(mail);
      email = mail;
      return true;
    });
  }

  Future<bool> register(String rawEmail, String password) async {
    final mail = rawEmail.trim().toLowerCase();
    return _run(() async {
      if (await _store.userExists(mail)) {
        error = 'Este e-mail já está cadastrado. Use a aba "Entrar".';
        return false;
      }
      await _store.saveUser(mail, password);
      await _store.setSession(mail);
      email = mail;
      return true;
    });
  }

  Future<void> logout() async {
    await _store.setSession(null);
    email = null;
    notifyListeners();
  }

  Future<bool> _run(Future<bool> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      return await action();
    } catch (_) {
      error = 'Não foi possível concluir. Tente novamente.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
