import 'package:lumen/backend/providers/paged_books_provider.dart';
import 'package:lumen/backend/services/open_library_service.dart';

class BookCategory {
  const BookCategory(this.label, this.query);
  final String label;
  final String query;
}

/// Catálogo da tela principal: livros por categoria (somente com leitura online).
class CatalogProvider extends PagedBooksProvider {
  CatalogProvider(super.service);

  static const categories = [
    BookCategory('Destaques', 'has_fulltext:true'),
    BookCategory('Clássicos', 'subject:"classic literature" has_fulltext:true'),
    BookCategory('Ficção', 'subject:fiction has_fulltext:true'),
    BookCategory('Fantasia', 'subject:fantasy has_fulltext:true'),
    BookCategory('Romance', 'subject:romance has_fulltext:true'),
    BookCategory('Mistério', 'subject:mystery has_fulltext:true'),
    BookCategory('Ciência', 'subject:science has_fulltext:true'),
    BookCategory('História', 'subject:history has_fulltext:true'),
  ];

  int _selected = 0;
  int get selected => _selected;

  @override
  Future<SearchResult> fetchPage(int page) => service.searchBooks(
        query: categories[_selected].query,
        page: page,
        sort: 'readinglog',
      );

  void selectCategory(int index) {
    if (index == _selected && error == null && items.isNotEmpty) return;
    _selected = index;
    reload();
  }
}

/// Provider para uma prateleira específica (uma linha da tela Netflix).
/// Carrega a categoria de forma preguiçosa (lazy) via [ensureLoaded].
class ShelfProvider extends PagedBooksProvider {
  ShelfProvider(super.service, this.category);

  final BookCategory category;
  bool _hasStarted = false;

  void ensureLoaded() {
    if (_hasStarted) return;
    _hasStarted = true;
    reload();
  }

  @override
  Future<SearchResult> fetchPage(int page) => service.searchBooks(
        query: category.query,
        page: page,
        limit: 20,
        sort: 'readinglog',
      );
}
