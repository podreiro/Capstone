import 'package:flutter/material.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/book_card.dart';

/// Grid com rolagem infinita: pede a próxima página perto do fim da lista.
class PagedBookGrid extends StatefulWidget {
  const PagedBookGrid({
    super.key,
    required this.books,
    required this.hasMore,
    required this.loadingMore,
    required this.moreError,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final List<Book> books;
  final bool hasMore;
  final bool loadingMore;
  final String? moreError;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  @override
  State<PagedBookGrid> createState() => _PagedBookGridState();
}

class _PagedBookGridState extends State<PagedBookGrid> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkEnd);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkEnd() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final nearEnd = position.pixels >= position.maxScrollExtent - 500;
    if (nearEnd &&
        widget.hasMore &&
        !widget.loadingMore &&
        widget.moreError == null) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;

    // Em telas grandes a primeira página pode não preencher a área visível.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkEnd();
    });

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: colors.accent,
            backgroundColor: colors.surface,
            onRefresh: widget.onRefresh,
            child: GridView.builder(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
              ),
              itemCount: widget.books.length,
              itemBuilder: (_, i) => BookCard(
                book: widget.books[i],
                heroTag: 'grid-book-${widget.books[i].id}',
              ),
            ),
          ),
        ),
        if (widget.loadingMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.accent,
              ),
            ),
          ),
        if (widget.moreError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 20, color: Color(0xFFCF6679)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.moreError!,
                    style: const TextStyle(color: Color(0xFFCF6679)),
                  ),
                ),
                TextButton(
                  onPressed: widget.onLoadMore,
                  child: Text(
                    'Tentar',
                    style: TextStyle(color: colors.accent),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
