import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/book_card.dart';

/// Linha horizontal de livros estilo Netflix com:
/// - Setas flutuantes de navegação lateral (esquerda/direita) com clique suave
/// - Suporte a Top 10 com numerais gigantes
/// - Responsividade dinâmica de tamanho de cards conforme largura da tela
class BookShelfRow extends StatefulWidget {
  const BookShelfRow({
    super.key,
    required this.title,
    required this.books,
    this.isTop10 = false,
    this.onLoadMore,
  });

  final String title;
  final List<Book> books;
  final bool isTop10;
  final VoidCallback? onLoadMore;

  @override
  State<BookShelfRow> createState() => _BookShelfRowState();
}

class _BookShelfRowState extends State<BookShelfRow> {
  late final ScrollController _controller;
  bool _canScrollLeft = false;
  bool _canScrollRight = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollButtons());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!_controller.hasClients) return;
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;

    final canLeft = currentScroll > 20;
    final canRight = currentScroll < (maxScroll - 20);

    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      if (mounted) {
        setState(() {
          _canScrollLeft = canLeft;
          _canScrollRight = canRight;
        });
      }
    }

    if (widget.onLoadMore != null && currentScroll >= maxScroll - 300) {
      widget.onLoadMore!();
    }
  }

  void _scroll(bool forward, double scrollAmount) {
    if (!_controller.hasClients) return;
    final target = forward
        ? (_controller.offset + scrollAmount).clamp(
            0.0, _controller.position.maxScrollExtent)
        : (_controller.offset - scrollAmount).clamp(
            0.0, _controller.position.maxScrollExtent);

    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final displayBooks =
        widget.isTop10 ? widget.books.take(10).toList() : widget.books;

    // Cálculo responsivo de largura e altura dos cards
    final double cardWidth;
    final double cardHeight;
    final double numberOffset;

    if (screenWidth > 1200) {
      cardWidth = widget.isTop10 ? 190.0 : 160.0;
      cardHeight = widget.isTop10 ? 255.0 : 240.0;
      numberOffset = 55.0;
    } else if (screenWidth > 768) {
      cardWidth = widget.isTop10 ? 175.0 : 142.0;
      cardHeight = widget.isTop10 ? 230.0 : 215.0;
      numberOffset = 48.0;
    } else {
      cardWidth = widget.isTop10 ? 160.0 : 125.0;
      cardHeight = widget.isTop10 ? 205.0 : 190.0;
      numberOffset = 42.0;
    }

    final scrollStep = cardWidth * 2.8;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              children: [
                if (widget.isTop10) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  widget.title,
                  style: GoogleFonts.inter(
                    fontSize: screenWidth > 768 ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: cardHeight,
            child: Stack(
              children: [
                // Lista horizontal de cards
                ListView.separated(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: displayBooks.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: widget.isTop10 ? 14 : 10),
                  itemBuilder: (context, index) {
                    final book = displayBooks[index];
                    final heroTag = widget.isTop10
                        ? 'top10-cover-${book.id}'
                        : 'shelf-${widget.title}-${book.id}';

                    if (widget.isTop10) {
                      return SizedBox(
                        width: cardWidth,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Número gigante estilo Netflix
                            Positioned(
                              left: -6,
                              bottom: -16,
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: cardHeight * 0.48,
                                  fontWeight: FontWeight.w900,
                                  color: colors.textPrimary.withAlpha(50),
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
                            // Capa deslocada à direita do numeral
                            Positioned(
                              left: numberOffset,
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

                // Seta de navegação lateral ESQUERDA
                if (_canScrollLeft)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: _ScrollArrowButton(
                      direction: Icons.chevron_left,
                      isHovering: _isHovering,
                      colors: colors,
                      onTap: () => _scroll(false, scrollStep),
                    ),
                  ),

                // Seta de navegação lateral DIREITA
                if (_canScrollRight)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: _ScrollArrowButton(
                      direction: Icons.chevron_right,
                      isHovering: _isHovering,
                      colors: colors,
                      onTap: () => _scroll(true, scrollStep),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollArrowButton extends StatelessWidget {
  const _ScrollArrowButton({
    required this.direction,
    required this.isHovering,
    required this.colors,
    required this.onTap,
  });

  final IconData direction;
  final bool isHovering;
  final LumenColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLeft = direction == Icons.chevron_left;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isHovering ? 1.0 : 0.65,
        child: Container(
          width: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [
                colors.bg.withAlpha(220),
                colors.bg.withAlpha(0),
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.surface.withAlpha(210),
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
                boxShadow: const [
                  BoxShadow(blurRadius: 6, color: Colors.black45),
                ],
              ),
              child: Icon(
                direction,
                color: colors.accent,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
