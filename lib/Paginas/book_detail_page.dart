import 'package:flutter/material.dart';

import 'package:lumen/Componentes.dart';
<<<<<<< HEAD
import 'package:lumen/Dados.dart';

class BookDetailPage extends StatefulWidget {
  final AppBook book;
  final CatalogoLocal service;
=======
import 'package:lumen/Integracoes.dart';

class BookDetailPage extends StatefulWidget {
  final AppBook book;
  final OpenLibraryService service;
>>>>>>> a495bb009f4d4a7dc3e927ee7eb5c4c85bcd8aba
  final LocalStore store;

  const BookDetailPage({
    super.key,
    required this.book,
    required this.service,
    required this.store,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<AppBook> future;
  bool favorite = false;

  @override
  void initState() {
    super.initState();
    future = widget.service.getBook(widget.book.id);
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final ids = await widget.store.getFavorites();
    if (mounted) setState(() => favorite = ids.contains(widget.book.id));
  }

  Future<void> _toggleFavorite() async {
    await widget.store.toggleFavorite(widget.book.id);
    if (mounted) setState(() => favorite = !favorite);
  }

  Future<void> _startReading() async {
    await widget.store.addHistory(widget.book.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livro adicionado à sua lista de leitura.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do livro'),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: FutureBuilder<AppBook>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              onRetry: () => setState(
                () => future = widget.service.getBook(widget.book.id),
              ),
            );
          }

          final book = snapshot.data ?? widget.book;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Center(
                child: SizedBox(
                  height: 330,
                  width: 220,
                  child: BookCover(url: book.coverUrl),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                book.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                book.authors.isEmpty
                    ? 'Autor desconhecido'
                    : book.authors.join(', '),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (book.year != null) ...[
                const SizedBox(height: 4),
                Text('Publicação: ${book.year}'),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _startReading,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Começar leitura'),
              ),
              const SizedBox(height: 24),
              Text(
                'Sobre o livro',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                book.description?.trim().isNotEmpty == true
                    ? book.description!
<<<<<<< HEAD
                    : 'Não há descrição disponível para este título no catálogo.',
=======
                    : 'Não há descrição disponível para este título na Open Library.',
>>>>>>> a495bb009f4d4a7dc3e927ee7eb5c4c85bcd8aba
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.55,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
