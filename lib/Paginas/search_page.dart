import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/Componentes.dart';
import 'package:lumen/providers/books_provider.dart';

/// Tela 3 — Busca. Usada como aba e também aberta via Navigator.push
/// a partir do ícone de lupa do catálogo (nesse caso aparece o botão voltar).
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: context.read<BooksProvider>().lastQuery,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void search() {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<BooksProvider>().search(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BooksProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar livros')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => search(),
                decoration: InputDecoration(
                  hintText: 'Nome do livro, autor ou assunto',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Buscar',
                    onPressed: search,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Digite pelo menos 2 caracteres.';
                  }
                  return null;
                },
              ),
            ),
          ),
          Expanded(child: _results(books)),
        ],
      ),
    );
  }

  Widget _results(BooksProvider books) {
    switch (books.searchState) {
      case LoadState.idle:
        return const EmptyState(
          icon: Icons.manage_search_rounded,
          title: 'O que você quer ler?',
          message:
              'Pesquise por título, autor ou assunto para encontrar seu próximo livro.',
        );
      case LoadState.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadState.error:
        return ErrorState(
          message: books.searchError,
          onRetry: search,
        );
      case LoadState.success:
        if (books.searchResults.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Nada encontrado',
            message: 'Tente outro título, autor ou assunto.',
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisExtent: 310,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
          ),
          itemCount: books.searchResults.length,
          itemBuilder: (_, i) => BookCard(book: books.searchResults[i]),
        );
    }
  }
}
