import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/book_card.dart';

/// Linha horizontal de livros estilo Netflix: título de seção + scroll horizontal.
/// Suporta o formato "Top 10" com numerais gigantes atrás das capas.
class BookShelfRow extends StatelessWidget {
  const BookShelfRow({
    super.key,
    required this.title,
    required this.books,
    this.isTop10 = false,
    this.onLoadMore,
    this.cardWidth = 125.0,
    this.cardHeight = 190.0,
  });

  final String title;
  final List<Book> books;
  final bool isTop10;

  /// Chamado quando o scroll chega perto do fim (paginação).
  final VoidCallback? onLoadMore;

  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;
    final displayBooks = isTop10 ? books.take(10).toList() : books;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              if (isTop10) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914), // Netflix Red accent
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TOP 10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: isTop10 ? 205.0 : cardHeight,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (!isTop10 &&
                  onLoadMore != null &&
                  notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                  onLoadMore!();
                }
              }
              return false;
            },
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: displayBooks.length,
              separatorBuilder: (_, __) =>
                  SizedBox(width: isTop10 ? 12 : 10),
              itemBuilder: (context, index) {
                final book = displayBooks[index];
                final heroTag = isTop10
                    ? 'top10-cover-${book.id}'
                    : 'shelf-$title-${book.id}';

                if (isTop10) {
                  return SizedBox(
                    width: 160,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Número gigante estilo Netflix
                        Positioned(
                          left: -4,
                          bottom: -16,
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 98,
                              fontWeight: FontWeight.w900,
                              color: colors.textPrimary.withAlpha(45),
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black.withAlpha(120),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Capa deslocada à direita
                        Positioned(
                          left: 42,
                          top: 0,
                          bottom: 0,
                          right: 0,
                          child: BookCard(book: book, heroTag: heroTag),
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox(
                  width: cardWidth,
                  child: BookCard(book: book, heroTag: heroTag),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
