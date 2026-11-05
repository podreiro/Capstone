import 'package:flutter/foundation.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/services/open_library_service.dart';

enum LoadState { idle, loading, success, error }

/// Estado das chamadas HTTP (catálogo, busca e detalhes).
class BooksProvider extends ChangeNotifier {
  final OpenLibraryService _service;

  BooksProvider(this._service);

  // ----- catálogo -----
  LoadState catalogState = LoadState.idle;
  List<AppBook> catalog = [];
  String catalogError = '';

  Future<void> loadCatalog() async {
    catalogState = LoadState.loading;
    notifyListeners();
    try {
      catalog = await _service.listBooks();
      catalogState = LoadState.success;
    } catch (e) {
      catalogError = '$e';
      catalogState = LoadState.error;
    }
    notifyListeners();
  }

  // ----- busca -----
  LoadState searchState = LoadState.idle;
  List<AppBook> searchResults = [];
  String searchError = '';
  String lastQuery = '';

  Future<void> search(String query) async {
    lastQuery = query.trim();
    searchState = LoadState.loading;
    notifyListeners();
    try {
      searchResults = await _service.searchBooks(lastQuery);
      searchState = LoadState.success;
    } catch (e) {
      searchError = '$e';
      searchState = LoadState.error;
    }
    notifyListeners();
  }

  // ----- detalhes -----
  final Map<String, AppBook> _details = {};

  /// Busca descrição/assuntos do livro (com cache em memória).
  Future<AppBook> loadDetail(AppBook book) async {
    final cached = _details[book.id];
    if (cached != null) return cached;
    final detailed = await _service.getBook(book);
    _details[book.id] = detailed;
    return detailed;
  }
}
