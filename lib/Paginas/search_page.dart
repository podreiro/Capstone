import 'package:flutter/material.dart';

import 'package:lumen/Componentes.dart';
import 'package:lumen/Integracoes.dart';

class SearchPage extends StatefulWidget {
  final OpenLibraryService service;
  final LocalStore store;

  const SearchPage({super.key, required this.service, required this.store});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  Future<List<AppBook>>? result;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void search() {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => result = widget.service.searchBooks(controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(title: const Text('Buscar livros')),
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
          Expanded(
            child: result == null
                ? _SearchEmpty()
                : FutureBuilder<List<AppBook>>(
                    future: result,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return ErrorState(
                          onRetry: search,
                          message: 'Não foi possível realizar a busca.',
                        );
                      }
                      final books = snapshot.data ?? [];
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisExtent: 310,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: books.length,
                        itemBuilder: (_, i) => BookCard(
                          book: books[i],
                          store: widget.store,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.manage_search_rounded,
      title: 'O que você quer ler?',
      message: 'Pesquise por título, autor ou assunto para encontrar seu próximo livro.',
    );
  }
}
