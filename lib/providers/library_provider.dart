import 'package:flutter/foundation.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/services/local_store.dart';

/// Favoritos e histórico de leitura. É a única fonte de verdade para as
/// "estrelas": card, detalhes e perfil leem daqui e por isso ficam sempre
/// em sincronia e persistem ao reabrir o app.
class LibraryProvider extends ChangeNotifier {
  final LocalStore _store;

  LibraryProvider(this._store);

  List<AppBook> _favorites = [];
  List<AppBook> _history = [];
  bool loaded = false;

  List<AppBook> get favorites => List.unmodifiable(_favorites);

  /// Mais recente primeiro.
  List<AppBook> get history => List.unmodifiable(_history);

  bool isFavorite(String id) => _favorites.any((b) => b.id == id);

  Future<void> load() async {
    _favorites = await _store.getFavorites();
    _history = await _store.getHistory();
    loaded = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(AppBook book) async {
    if (isFavorite(book.id)) {
      _favorites = _favorites.where((b) => b.id != book.id).toList();
    } else {
      _favorites = [book, ..._favorites];
    }
    notifyListeners(); // atualiza a UI na hora
    await _store.saveFavorites(_favorites);
  }

  Future<void> addHistory(AppBook book) async {
    _history = [book, ..._history.where((b) => b.id != book.id)];
    notifyListeners();
    await _store.saveHistory(_history);
  }
}
