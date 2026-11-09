import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/catalog_provider.dart';
import 'package:lumen/backend/services/open_library_service.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/book_shelf_row.dart';
import 'package:lumen/frontend/widgets/hero_carousel.dart';
import 'package:lumen/frontend/widgets/state_views.dart';

/// Tela principal: hero em carrossel cinematográfico + prateleiras horizontais
/// com carregamento preguiçoso (lazy) e visual estilo Netflix (Top 10 + Shimmer).
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.onOpenSearch});

  final VoidCallback onOpenSearch;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final List<ShelfProvider> _shelves;

  @override
  void initState() {
    super.initState();
    final service = context.read<OpenLibraryService>();
    _shelves = CatalogProvider.categories
        .map((cat) => ShelfProvider(service, cat))
        .toList();

    // Carrega apenas a primeira prateleira (Destaques) inicialmente
    _shelves[0].ensureLoaded();
  }

  @override
  void dispose() {
    for (final shelf in _shelves) {
      shelf.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;

    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(
        slivers: [
          // AppBar flutuante integrada ao tema
          SliverAppBar(
            pinned: false,
            floating: true,
            backgroundColor: Colors.transparent,
            expandedHeight: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.bg.withAlpha(200),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            title: Text(
              'Lúmen',
              style: TextStyle(
                color: colors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Buscar livros',
                onPressed: widget.onOpenSearch,
                icon: Icon(Icons.search, color: colors.textPrimary),
              ),
            ],
          ),

          // Hero Carousel com Shimmer placeholder
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _shelves[0],
              builder: (context, _) {
                final shelf = _shelves[0];
                if (shelf.loading && shelf.items.isEmpty) {
                  return const ShimmerHero();
                }
                if (shelf.error != null && shelf.items.isEmpty) {
                  return SizedBox(
                    height: 320,
                    child: ErrorState(
                      message: shelf.error!,
                      onRetry: shelf.reload,
                    ),
                  );
                }
                if (shelf.items.isEmpty) {
                  return const SizedBox.shrink();
                }
                return HeroCarousel(books: shelf.items);
              },
            ),
          ),

          // Espaço entre hero e prateleiras
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Prateleiras por categoria carregadas preguiçosamente
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = CatalogProvider.categories[index];
                final shelf = _shelves[index];

                // Lazy load: dispara a requisição quando a prateleira entra no viewport
                shelf.ensureLoaded();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: AnimatedBuilder(
                    animation: shelf,
                    builder: (context, _) {
                      if (shelf.loading && shelf.items.isEmpty) {
                        return ShimmerShelf(title: category.label);
                      }
                      if (shelf.error != null && shelf.items.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      if (shelf.items.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return BookShelfRow(
                        title: category.label,
                        books: shelf.items,
                        isTop10: index == 0, // Destaques ganha estilo Top 10
                        onLoadMore: shelf.hasMore ? shelf.loadMore : null,
                      );
                    },
                  ),
                );
              },
              childCount: CatalogProvider.categories.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
