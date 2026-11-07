import 'package:lumen/backend/providers/paged_books_provider.dart';
import 'package:lumen/backend/services/open_library_service.dart';

/// Busca por título, autor ou assunto (GET /search.json?q=...).
class SearchProvider extends PagedBooksProvider {
  SearchProvider(super.service);

  String _query = '';
  bool _onlyReadable = false;

  String get query => _query;
  bool get onlyReadable => _onlyReadable;
  bool get hasSearched => _query.isNotEmpty;

  @override
  Future<SearchResult> fetchPage(int page) => service.searchBooks(
        query: _onlyReadable ? '$_query has_fulltext:true' : _query,
        page: page,
      );

  Future<void> submit(String query) {
    _query = query.trim();
    return reload();
  }

  void setOnlyReadable(bool value) {
    _onlyReadable = value;
    if (hasSearched) {
      reload();
    } else {
      notifyListeners();
    }
  }
}
