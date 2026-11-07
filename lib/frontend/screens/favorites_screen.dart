import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/frontend/widgets/book_list_tile.dart';
import 'package:lumen/frontend/widgets/feedback.dart';
import 'package:lumen/frontend/widgets/state_views.dart';

/// Lista de favoritos (aberta a partir do Perfil com Navigator.push).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final books = library.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus favoritos')),
      body: _body(context, library, books),
    );
  }

  Widget _body(BuildContext context,
    LibraryProvider library,
    List<Book> books,
  ) {
    if (library.loading && books.isEmpty) {
      return const LoadingView(message: 'Carregando favoritos…');
    }
    if (library.error != null && books.isEmpty) {
      return ErrorState(message: library.error!, onRetry: library.refresh);
    }
    if (books.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        title: 'Nenhum favorito ainda',
        message: 'Toque no coração de um livro para guardá-lo aqui.',
      );
    }

    final hasBanner = library.error != null;
    return RefreshIndicator(
      onRefresh: library.refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: books.length + (hasBanner ? 1 : 0),
        itemBuilder: (context, i) {
          if (hasBanner && i == 0) {
            return ErrorBanner(
              message: library.error!,
              onRetry: library.refresh,
            );
          }
          final book = books[i - (hasBanner ? 1 : 0)];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BookListTile(
              book: book,
              trailing: IconButton(
                tooltip: 'Remover dos favoritos',
                onPressed: () => toggleFavoriteWithFeedback(context, book),
                icon: const Icon(Icons.favorite),
              ),
            ),
          );
        },
      ),
    );
  }
}
