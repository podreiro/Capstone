import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/catalog_provider.dart';
import 'package:lumen/backend/services/open_library_service.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/book_shelf_row.dart';
import 'package:lumen/frontend/widgets/hero_carousel.dart';
import 'package:lumen/frontend/widgets/state_views.dart';

/// Tela principal: hero em carrossel cinematográfico + pílulas de navegação rápida
/// + prateleiras horizontais com lazy-load e setas laterais no desktop.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.onOpenSearch});

  final VoidCallback onOpenSearch;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final ScrollController _scrollController;
  late final List<ShelfProvider> _shelves;
  late final List<GlobalKey> _shelfKeys;
  int _selectedCategory = -1; // -1 = Todos

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final service = context.read<OpenLibraryService>();
    _shelves = CatalogProvider.categories
        .map((cat) => ShelfProvider(service, cat))
        .toList();

    _shelfKeys = List.generate(
      CatalogProvider.categories.length,
      (_) => GlobalKey(),
    );

    // Carrega apenas a primeira prateleira (Destaques) inicialmente
    _shelves[0].ensureLoaded();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final shelf in _shelves) {
      shelf.dispose();
    }
    super.dispose();
  }

  void _scrollToCategory(int index) {
    setState(() => _selectedCategory = index);

    if (index == -1) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      return;
    }

    _shelves[index].ensureLoaded();

    final targetContext = _shelfKeys[index].currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
        alignment: 0.1,
      );
    } else {
      // Estimativa caso ainda não tenha sido montado na árvore
      final size = MediaQuery.sizeOf(context);
      final heroHeight = (size.height * 0.54).clamp(320.0, 520.0);
      final estimatedOffset = heroHeight + 60.0 + (index * 260.0);
      _scrollController.animateTo(
        estimatedOffset,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;

    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar flutuante com logo e busca
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: colors.bg.withAlpha(230),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: CatalogProvider.categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final isAll = i == 0;
                    final categoryIndex = i - 1;
                    final isSelected = isAll
                        ? _selectedCategory == -1
                        : _selectedCategory == categoryIndex;
                    final label = isAll
                        ? 'Todos'
                        : CatalogProvider.categories[categoryIndex].label;

                    return GestureDetector(
                      onTap: () => _scrollToCategory(categoryIndex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.accent : colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? colors.accent : colors.border,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colors.accent.withAlpha(60),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? colors.accentText
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
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

          // Prateleiras por categoria
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = CatalogProvider.categories[index];
                final shelf = _shelves[index];

                // Lazy load: dispara a requisição quando a prateleira entra no viewport
                shelf.ensureLoaded();

                return Padding(
                  key: _shelfKeys[index],
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
                        isTop10: index == 0,
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
