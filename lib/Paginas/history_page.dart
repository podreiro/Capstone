import 'package:flutter/material.dart';

import 'package:lumen/Componentes.dart';
<<<<<<< HEAD
import 'package:lumen/Dados.dart';

class HistoryPage extends StatefulWidget {
  final CatalogoLocal service;
=======
import 'package:lumen/Integracoes.dart';

class HistoryPage extends StatefulWidget {
  final OpenLibraryService service;
>>>>>>> a495bb009f4d4a7dc3e927ee7eb5c4c85bcd8aba
  final LocalStore store;

  const HistoryPage({super.key, required this.service, required this.store});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<AppBook>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<AppBook>> _load() async {
    final ids = (await widget.store.getHistory()).toList().reversed.toList();
    final books = <AppBook>[];
    for (final id in ids) {
      try {
        books.add(await widget.service.getBook(id));
      } catch (_) {}
    }
    return books;
  }

  void reload() => setState(() => future = _load());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(title: const Text('Estou lendo')),
          Expanded(
            child: FutureBuilder<List<AppBook>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ErrorState(onRetry: reload);
                }
                final books = snapshot.data ?? [];
                if (books.isEmpty) {
                  return const EmptyState(
                    icon: Icons.auto_stories_outlined,
                    title: 'Sua estante está vazia',
                    message:
                        'Abra um livro para ele aparecer aqui e continue de onde parou.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => HistoryCard(book: books[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
