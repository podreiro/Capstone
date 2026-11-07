import 'package:flutter/foundation.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/services/open_library_service.dart';

/// Base para listas paginadas vindas da API (catálogo e busca):
/// controla loading, erro e "carregar mais".
abstract class PagedBooksProvider extends ChangeNotifier {
  PagedBooksProvider(this.service);

  final OpenLibraryService service;

  static const pageSize = 24;

  final List<Book> _items = [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;
  String? _moreError;
  int _page = 0;
  int _total = 0;
  int _token = 0;

  List<Book> get items => _items;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String? get moreError => _moreError;
  int get total => _total;

  /// Cada subclasse define qual requisição faz para a página pedida.
  Future<SearchResult> fetchPage(int page);

  Future<void> reload() async {
    final token = ++_token;
    _items.clear();
    _page = 0;
    _total = 0;
    _hasMore = false;
    _error = null;
    _moreError = null;
    _loadingMore = false;
    _loading = true;
    notifyListeners();

    try {
      final result = await fetchPage(1);
      if (token != _token) return;
      _items.addAll(result.books);
      _page = 1;
      _total = result.total;
      _hasMore = result.books.isNotEmpty && _page * pageSize < result.total;
    } on ApiException catch (e) {
      if (token != _token) return;
      _error = e.message;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    final token = _token;
    _loadingMore = true;
    _moreError = null;
    notifyListeners();

    try {
      final result = await fetchPage(_page + 1);
      if (token != _token) return;
      final known = _items.map((b) => b.id).toSet();
      _items.addAll(result.books.where((b) => !known.contains(b.id)));
      _page++;
      _hasMore = result.books.isNotEmpty && _page * pageSize < result.total;
    } on ApiException catch (e) {
      if (token != _token) return;
      _moreError = e.message;
    }
    _loadingMore = false;
    notifyListeners();
  }
}
