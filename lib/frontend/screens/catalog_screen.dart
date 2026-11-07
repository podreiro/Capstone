import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/catalog_provider.dart';
import 'package:lumen/frontend/widgets/paged_book_grid.dart';
import 'package:lumen/frontend/widgets/state_views.dart';

/// Grid principal: livros da API filtrados por categoria.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.onOpenSearch});

  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lúmen',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Buscar livros',
            onPressed: onOpenSearch,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              'Encontre sua próxima história.',
              style: textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              'Escolha uma categoria e leia direto pelo navegador.',
              style: textTheme.bodyMedium,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: CatalogProvider.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text(CatalogProvider.categories[i].label),
                selected: catalog.selected == i,
                onSelected: (_) => catalog.selectCategory(i),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _content(catalog)),
        ],
      ),
    );
  }

  Widget _content(CatalogProvider catalog) {
    if (catalog.loading) {
      return const LoadingView(message: 'Buscando livros…');
    }
    if (catalog.error != null) {
      return ErrorState(message: catalog.error!, onRetry: catalog.reload);
    }
    if (catalog.items.isEmpty) {
      return const EmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Nenhum livro encontrado',
        message: 'Tente outra categoria.',
      );
    }
    return PagedBookGrid(
      books: catalog.items,
      hasMore: catalog.hasMore,
      loadingMore: catalog.loadingMore,
      moreError: catalog.moreError,
      onLoadMore: catalog.loadMore,
      onRefresh: catalog.reload,
    );
  }
}
