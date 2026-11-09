import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/frontend/screens/book_detail_screen.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/book_cover.dart';
import 'package:lumen/frontend/widgets/feedback.dart';

/// Hero em carrossel cinematográfico estilo Netflix:
/// - Barras de progresso lineares por slide
/// - Efeito Ken Burns (zoom lento contínuo na capa)
/// - Pausa interativa ao segurar / tocar
/// - Fundo desfocado com gradiente dinâmico
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    super.key,
    required this.books,
    this.slideDuration = const Duration(milliseconds: 5500),
  });

  final List<Book> books;
  final Duration slideDuration;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressController;
  int _current = 0;

  List<Book> get _heroBooks => widget.books.take(5).toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.slideDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextPage();
        }
      });

    if (_heroBooks.length > 1) {
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!mounted || _heroBooks.isEmpty) return;
    final next = (_current + 1) % _heroBooks.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _current = index);
    _progressController.reset();
    _progressController.forward();
  }

  void _pause() {
    if (_progressController.isAnimating) {
      _progressController.stop();
    }
  }

  void _resume() {
    if (!_progressController.isAnimating && _heroBooks.length > 1) {
      _progressController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_heroBooks.isEmpty) return const SizedBox.shrink();

    final size = MediaQuery.sizeOf(context);
    final heroHeight = (size.height * 0.54).clamp(320.0, 520.0);
    final colors = context.lumen;

    return GestureDetector(
      onTapDown: (_) => _pause(),
      onTapUp: (_) => _resume(),
      onTapCancel: () => _resume(),
      child: SizedBox(
        height: heroHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Carrossel com transição de páginas
            PageView.builder(
              controller: _pageController,
              itemCount: _heroBooks.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _HeroPage(
                  book: _heroBooks[index],
                  progressController: _progressController,
                  isActive: index == _current,
                );
              },
            ),

            // Barras de progresso segmentadas no estilo Netflix Stories
            if (_heroBooks.length > 1)
              Positioned(
                bottom: 12,
                left: 24,
                right: 24,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return Row(
                      children: List.generate(_heroBooks.length, (i) {
                        double progress = 0.0;
                        if (i < _current) {
                          progress = 1.0;
                        } else if (i == _current) {
                          progress = _progressController.value;
                        }

                        return Expanded(
                          child: Container(
                            height: 3.5,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            decoration: BoxDecoration(
                              color: colors.textMuted.withAlpha(55),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colors.accent,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.accent.withAlpha(120),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroPage extends StatelessWidget {
  const _HeroPage({
    required this.book,
    required this.progressController,
    required this.isActive,
  });

  final Book book;
  final AnimationController progressController;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;
    final favorite = context.select<LibraryProvider, bool>(
      (l) => l.isFavorite(book.id),
    );
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final coverHeight = (size.height * 0.24).clamp(140.0, 220.0);

    return AnimatedBuilder(
      animation: progressController,
      builder: (context, child) {
        // Efeito Ken Burns: escala de 1.0 a 1.07 durante a exibição
        final kenBurnsScale = isActive
            ? 1.0 + (progressController.value * 0.07)
            : 1.0;
        final bgKenBurnsScale = isActive
            ? 1.16 + (progressController.value * 0.06)
            : 1.16;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Fundo desfocado com suave zoom contínuo
            ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Transform.scale(
                  scale: bgKenBurnsScale,
                  child: BookCover(
                    url: book.largeCoverUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // 2. Escurecimento do fundo para legibilidade
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(95),
              ),
            ),

            // 3. Gradiente mesclando suavemente com a cor do tema
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.42, 1.0],
                  colors: [
                    Colors.black.withAlpha(70),
                    Colors.transparent,
                    colors.bg,
                  ],
                ),
              ),
            ),

            // 4. Capa nítida 2:3 com Ken Burns Zoom e sombra projetada
            Align(
              alignment: const Alignment(0, -0.48),
              child: Transform.scale(
                scale: kenBurnsScale,
                child: Container(
                  height: coverHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(200),
                        blurRadius: 20,
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
                        child: BookCover(
                          url: book.largeCoverUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 5. Metadados e botões
            Positioned(
              left: 20,
              right: 20,
              bottom: 26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 140,
                          maxWidth: 220,
                        ),
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
      },
    );
  }
}
