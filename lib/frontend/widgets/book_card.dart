import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/frontend/screens/book_detail_screen.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/book_cover.dart';
import 'package:lumen/frontend/widgets/feedback.dart';

/// Card minimalista estilo streaming: capa 2:3 com Hero animation,
/// gradiente legível, tipografia confortável e microinteração de favorito.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    this.heroTag,
  });

  final Book book;
  final String? heroTag;

  String get _tag => heroTag ?? 'book-cover-${book.id}';

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;
    final favorite = context.select<LibraryProvider, bool>(
      (library) => library.isFavorite(book.id),
    );

    return GestureDetector(
      onTap: () => BookDetailScreen.open(context, book, heroTag: _tag),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Capa do livro com transição Hero
              Hero(
                tag: _tag,
                child: BookCover(url: book.coverUrl),
              ),

              // Gradiente de contraste no rodapé para legibilidade do texto
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                      colors: [
                        Colors.transparent,
                        colors.cardGradientEnd,
                      ],
                    ),
                  ),
                ),
              ),

              // Título e autor no rodapé com tipografia aumentada e legível
              Positioned(
                left: 9,
                right: 9,
                bottom: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        shadows: [
                          Shadow(blurRadius: 6, color: Colors.black87),
                        ],
                      ),
                    ),
                    if (book.authorsLabel.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        book.authorsLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withAlpha(210),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          shadows: const [
                            Shadow(blurRadius: 4, color: Colors.black87),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Selo "ONLINE"
              if (book.canReadOnline)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(blurRadius: 4, color: Colors.black38),
                      ],
                    ),
                    child: Text(
                      'ONLINE',
                      style: TextStyle(
                        color: colors.accentText,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

              // Botão favorito com microinteração de escala e haptic feedback
              Positioned(
                top: 6,
                right: 6,
                child: _FavoriteButton(
                  favorite: favorite,
                  accentColor: colors.accent,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    toggleFavoriteWithFeedback(context, book);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({
    required this.favorite,
    required this.accentColor,
    required this.onTap,
  });

  final bool favorite;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  double _scale = 1.0;

  void _handleTap() {
    setState(() => _scale = 1.35);
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _scale = 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(150),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(blurRadius: 4, color: Colors.black45),
            ],
          ),
          child: Icon(
            widget.favorite ? Icons.favorite : Icons.favorite_border,
            color: widget.favorite ? widget.accentColor : Colors.white,
            size: 17,
          ),
        ),
      ),
    );
  }
}
