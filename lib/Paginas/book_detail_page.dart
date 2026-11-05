import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/Componentes.dart';
import 'package:lumen/Paginas/reading_page.dart';
import 'package:lumen/backend/models/book.dart';
import 'package:lumen/providers/books_provider.dart';
import 'package:lumen/providers/library_provider.dart';

/// Tela 6 — Detalhes do livro (GET /works/{id}.json).
class BookDetailPage extends StatefulWidget {
  final AppBook book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Future<AppBook> future;

  @override
  void initState() {
    super.initState();
    future = context.read<BooksProvider>().loadDetail(widget.book);
  }

  void _retry() {
    setState(() {
      future = context.read<BooksProvider>().loadDetail(widget.book);
    });
  }

  Future<void> _startReading(AppBook book) async {
    await context.read<LibraryProvider>().addHistory(book);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReadingPage(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do livro'),
        actions: [FavoriteButton(book: widget.book)],
      ),
      body: FutureBuilder<AppBook>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              message: '${snapshot.error}',
              onRetry: _retry,
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
                Text('Primeira publicação: ${book.year}'),
              ],
              if (book.subjects.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: book.subjects
                      .take(5)
                      .map((s) => Chip(label: Text(s)))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _startReading(book),
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
                    : 'Não há descrição disponível para este título.',
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
