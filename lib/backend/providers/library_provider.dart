import 'package:flutter/foundation.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/services/local_storage_service.dart';
import 'package:lumen/backend/services/open_library_service.dart';

/// Favoritos e histórico ("Estou lendo") do usuário logado.
/// Só os IDs são gravados no SharedPreferences; os dados dos livros vêm da API.
class LibraryProvider extends ChangeNotifier {
  LibraryProvider(this._storage, this._service);

  final LocalStorageService _storage;
  final OpenLibraryService _service;

  final Map<String, Book> _cache = {};
  String? _email;
  List<String> _favoriteIds = [];
  List<String> _historyIds = [];
  List<Book> _favorites = [];
  List<Book> _history = [];
  bool _loading = false;
  String? _error;

  List<Book> get favorites => _favorites;
  List<Book> get history => _history;
  int get favoriteCount => _favoriteIds.length;
  int get historyCount => _historyIds.length;
  bool get loading => _loading;
  String? get error => _error;

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void _rebuild() {
    _favorites = _favoriteIds.map((id) => _cache[id]).whereType<Book>().toList();
    _history = _historyIds.map((id) => _cache[id]).whereType<Book>().toList();
  }

  Future<void> load(String email) async {
    _email = email;
    _favoriteIds = List<String>.of(_storage.favorites(email));
    _historyIds = List<String>.of(_storage.history(email));
    _error = null;
    _rebuild();
    notifyListeners();
    await refresh();
  }

  /// Busca na API os livros salvos que ainda não estão em memória.
  Future<void> refresh() async {
    final email = _email;
    if (email == null) return;
    final missing = {..._favoriteIds, ..._historyIds}
        .where((id) => !_cache.containsKey(id))
        .toList();
    if (missing.isEmpty) {
      _error = null;
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    var failed = 0;
    final results = await Future.wait(
      missing.map((id) async {
        try {
          return await _service.getBookById(id);
        } on ApiException {
          failed++;
          return null;
        }
      }),
    );
    if (_email != email) return;

    for (final book in results) {
      if (book != null) _cache[book.id] = book;
    }
    _loading = false;
    _error = failed > 0
        ? 'Não foi possível carregar $failed livro(s). Verifique sua conexão.'
        : null;
    _rebuild();
    notifyListeners();
  }

  Future<void> toggleFavorite(Book book) async {
    final email = _email;
    if (email == null) return;
    _cache[book.id] = book;
    if (!_favoriteIds.remove(book.id)) _favoriteIds.insert(0, book.id);
    _rebuild();
    notifyListeners();
    await _storage.saveFavorites(email, List<String>.of(_favoriteIds));
  }

  Future<void> addToHistory(Book book) async {
    final email = _email;
    if (email == null) return;
    _cache[book.id] = book;
    _historyIds.remove(book.id);
    _historyIds.insert(0, book.id);
    _rebuild();
    notifyListeners();
    await _storage.saveHistory(email, List<String>.of(_historyIds));
  }

  Future<void> removeFromHistory(String id) async {
    final email = _email;
    if (email == null) return;
    _historyIds.remove(id);
    _rebuild();
    notifyListeners();
    await _storage.saveHistory(email, List<String>.of(_historyIds));
  }

  void clear() {
    _email = null;
    _favoriteIds = [];
    _historyIds = [];
    _favorites = [];
    _history = [];
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
