import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/Paginas/book_detail_page.dart';
import 'package:lumen/providers/library_provider.dart';

/// Botão de favorito. Lê e grava no [LibraryProvider], então o estado é o
/// mesmo em qualquer tela e persiste ao reabrir o app.
class FavoriteButton extends StatelessWidget {
  final AppBook book;
  final Color? color;

  const FavoriteButton({super.key, required this.book, this.color});

  @override
  Widget build(BuildContext context) {
    final favorite = context.select<LibraryProvider, bool>(
      (lib) => lib.isFavorite(book.id),
    );
    return IconButton(
      tooltip: favorite ? 'Remover favorito' : 'Favoritar',
      onPressed: () => context.read<LibraryProvider>().toggleFavorite(book),
      icon: Icon(
        favorite ? Icons.favorite : Icons.favorite_border,
        color: color,
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final AppBook book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailPage(book: book)),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BookCover(url: book.coverUrl),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: const Color.fromRGBO(0, 0, 0, .42),
                      shape: const CircleBorder(),
                      child: FavoriteButton(book: book, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                book.authors.isEmpty
                    ? 'Autor desconhecido'
                    : book.authors.take(2).join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final AppBook book;

  const HistoryCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailPage(book: book)),
        ),
        contentPadding: const EdgeInsets.all(10),
        leading: SizedBox(
          width: 52,
          height: 72,
          child: BookCover(url: book.coverUrl),
        ),
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          book.authors.isEmpty ? 'Autor desconhecido' : book.authors.join(', '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class BookCover extends StatelessWidget {
  final String? url;

  const BookCover({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.menu_book_rounded, size: 48),
      );
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.menu_book_rounded, size: 48),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }
}

class ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const ErrorState({
    super.key,
    required this.onRetry,
    this.message = 'Não foi possível carregar os livros.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
