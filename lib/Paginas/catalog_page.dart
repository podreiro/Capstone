import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/Componentes.dart';
import 'package:lumen/Paginas/search_page.dart';
import 'package:lumen/providers/books_provider.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  @override
  void initState() {
    super.initState();
    // Dispara a chamada HTTP depois do primeiro frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BooksProvider>().loadCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BooksProvider>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<BooksProvider>().loadCatalog(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text(
                'Lúmen',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  tooltip: 'Buscar',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchPage(),
                    ),
                  ),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encontre sua próxima história.',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Uma biblioteca pensada para uma leitura mais tranquila.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            ..._content(context, books),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, BooksProvider books) {
    switch (books.catalogState) {
      case LoadState.idle:
      case LoadState.loading:
        return const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
        ];
      case LoadState.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorState(
              message: books.catalogError,
              onRetry: () => context.read<BooksProvider>().loadCatalog(),
            ),
          ),
        ];
      case LoadState.success:
        if (books.catalog.isEmpty) {
          return const [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Nenhum livro encontrado.')),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => BookCard(book: books.catalog[i]),
                childCount: books.catalog.length,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 310,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
              ),
            ),
          ),
        ];
    }
  }
}
