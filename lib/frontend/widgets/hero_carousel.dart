import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/frontend/screens/book_detail_screen.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/book_cover.dart';
import 'package:lumen/frontend/widgets/feedback.dart';

/// Hero em carrossel automático: capa nítida 2:3 em primeiro plano
/// sobreposta a fundo desfocado (blur) com gradiente dinâmico.
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    super.key,
    required this.books,
    this.autoPlayDuration = const Duration(seconds: 5),
  });

  final List<Book> books;
  final Duration autoPlayDuration;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _current = 0;
  bool _isPaused = false;

  List<Book> get _heroBooks => widget.books.take(5).toList();

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_heroBooks.length <= 1) return;
    _timer = Timer.periodic(widget.autoPlayDuration, (_) {
      if (!mounted || _isPaused) return;
      final next = (_current + 1) % _heroBooks.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_heroBooks.isEmpty) return const SizedBox.shrink();

    final size = MediaQuery.sizeOf(context);
    final heroHeight = (size.height * 0.54).clamp(320.0, 520.0);
    final colors = context.lumen;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPaused = true),
      onTapUp: (_) => setState(() => _isPaused = false),
      onTapCancel: () => setState(() => _isPaused = false),
      child: SizedBox(
        height: heroHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Carrossel
            PageView.builder(
              controller: _controller,
              itemCount: _heroBooks.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (context, index) =>
                  _HeroPage(book: _heroBooks[index]),
            ),

            // Indicadores de ponto
            if (_heroBooks.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _heroBooks.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _current ? 22 : 6,
                      height: 5,
                      decoration: BoxDecoration(
                        color: i == _current
                            ? colors.accent
                            : colors.textMuted.withAlpha(90),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroPage extends StatelessWidget {
  const _HeroPage({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;
    final favorite = context.select<LibraryProvider, bool>(
      (l) => l.isFavorite(book.id),
    );
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final coverHeight = (size.height * 0.24).clamp(140.0, 220.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Fundo com a mesma capa desfocada via ImageFiltered
        ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Transform.scale(
              scale: 1.18,
              child: BookCover(url: book.largeCoverUrl, fit: BoxFit.cover),
            ),
          ),
        ),

        // 2. Overlay escurecido sutil para uniformidade de contraste
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(90),
          ),
        ),

        // 3. Gradiente vertical de baixo para cima mesclando suavemente com a cor de fundo do tema
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.45, 1.0],
              colors: [
                Colors.black.withAlpha(60),
                Colors.transparent,
                colors.bg,
              ],
            ),
          ),
        ),

        // 4. Capa nítida 2:3 em destaque central com elevação
        Align(
          alignment: const Alignment(0, -0.48),
          child: Container(
            height: coverHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(190),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: 'hero-carousel-${book.id}',
                  child: BookCover(url: book.largeCoverUrl, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),

        // 5. Informações e botões na parte inferior
        Positioned(
          left: 20,
          right: 20,
          bottom: 26,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge de leitura
              if (book.canReadOnline)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(blurRadius: 4, color: Colors.black38),
                    ],
                  ),
                  child: Text(
                    'LEITURA GRATUITA',
                    style: TextStyle(
                      color: colors.accentText,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

              // Título centralizado
              Text(
                book.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  shadows: const [
                    Shadow(blurRadius: 8, color: Colors.black87),
                  ],
                ),
              ),

              const SizedBox(height: 3),
              Text(
                book.authorsLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textMuted,
                  shadows: const [
                    Shadow(blurRadius: 4, color: Colors.black87),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Botões de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
                    child: FilledButton.icon(
                      onPressed: () => BookDetailScreen.open(
                        context,
                        book,
                        heroTag: 'hero-carousel-${book.id}',
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: const Text('Ver livro'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.accentText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => toggleFavoriteWithFeedback(context, book),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.surface.withAlpha(160),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border),
                        boxShadow: const [
                          BoxShadow(blurRadius: 4, color: Colors.black26),
                        ],
                      ),
                      child: Icon(
                        favorite ? Icons.favorite : Icons.favorite_border,
                        color: favorite ? colors.accent : colors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
