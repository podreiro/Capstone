import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/frontend/widgets/book_list_tile.dart';
import 'package:lumen/frontend/widgets/feedback.dart';
import 'package:lumen/frontend/widgets/state_views.dart';

/// "Estou lendo": livros cuja leitura foi iniciada (ID salvo no SharedPreferences).
class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Estou lendo')),
      body: _body(context, library),
    );
  }

  Widget _body(BuildContext context, LibraryProvider library) {
    final books = library.history;
    if (library.loading && books.isEmpty) {
      return const LoadingView(message: 'Carregando sua estante…');
    }
    if (library.error != null && books.isEmpty) {
      return ErrorState(message: library.error!, onRetry: library.refresh);
    }
    if (books.isEmpty) {
      return const EmptyState(
        icon: Icons.auto_stories_outlined,
        title: 'Sua estante está vazia',
        message:
            'Toque em "Ler agora" em um livro para ele aparecer aqui e continue de onde parou.',
      );
    }

    final hasBanner = library.error != null;
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
            child: Dismissible(
              key: ValueKey(book.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              onDismissed: (_) {
                library.removeFromHistory(book.id);
                showSnack(
                  context,
                  'Removido de "Estou lendo".',
                  action: SnackBarAction(
                    label: 'Desfazer',
                    onPressed: () => library.addToHistory(book),
                  ),
                );
              },
              child: BookListTile(book: book),
            ),
          );
        },
      ),
    );
  }
}
