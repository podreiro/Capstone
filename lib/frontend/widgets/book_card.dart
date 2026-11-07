import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/frontend/screens/book_detail_screen.dart';
import 'package:lumen/frontend/widgets/book_cover.dart';
import 'package:lumen/frontend/widgets/feedback.dart';

/// Card do grid: capa, título, autor, favorito e selo "Ler online".
class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final favorite = context.select<LibraryProvider, bool>(
      (library) => library.isFavorite(book.id),
    );
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => BookDetailScreen.open(context, book),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BookCover(url: book.coverUrl),
                  if (book.canReadOnline)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Ler online',
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.black.withAlpha(110),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip:
                            favorite ? 'Remover dos favoritos' : 'Favoritar',
                        onPressed: () =>
                            toggleFavoriteWithFeedback(context, book),
                        icon: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
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
                book.authorsLabel,
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
