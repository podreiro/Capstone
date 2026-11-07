import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/search_provider.dart';
import 'package:lumen/frontend/widgets/paged_book_grid.dart';
import 'package:lumen/frontend/widgets/state_views.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<SearchProvider>().query;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<SearchProvider>().submit(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar livros')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Form(
              key: _formKey,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) => TextFormField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Nome do livro, autor ou assunto',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (value.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Limpar',
                            onPressed: _controller.clear,
                            icon: const Icon(Icons.close),
                          ),
                        IconButton(
                          tooltip: 'Buscar',
                          onPressed: _submit,
                          icon: const Icon(Icons.arrow_forward_rounded),
                        ),
                      ],
                    ),
                  ),
                  validator: (text) {
                    if (text == null || text.trim().length < 2) {
                      return 'Digite pelo menos 2 caracteres.';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                avatar: const Icon(Icons.chrome_reader_mode_outlined, size: 18),
                label: const Text('Só com leitura online'),
                selected: search.onlyReadable,
                onSelected: search.setOnlyReadable,
              ),
            ),
          ),
          Expanded(child: _results(search)),
        ],
      ),
    );
  }

  Widget _results(SearchProvider search) {
    if (!search.hasSearched) {
      return const EmptyState(
        icon: Icons.manage_search_rounded,
        title: 'O que você quer ler?',
        message:
            'Pesquise por título, autor ou assunto para encontrar seu próximo livro.',
      );
    }
    if (search.loading) {
      return const LoadingView(message: 'Buscando…');
    }
    if (search.error != null) {
      return ErrorState(
        message: search.error!,
        onRetry: search.reload,
      );
    }
    if (search.items.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Nenhum resultado',
        message: 'Confira a grafia ou tente buscar por outro termo.',
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${search.total} resultado(s) para "${search.query}"',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(
          child: PagedBookGrid(
            books: search.items,
            hasMore: search.hasMore,
            loadingMore: search.loadingMore,
            moreError: search.moreError,
            onLoadMore: search.loadMore,
            onRefresh: search.reload,
          ),
        ),
      ],
    );
  }
}
