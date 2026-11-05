import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/Componentes.dart';
import 'package:lumen/providers/library_provider.dart';

/// Tela 4 — Livros que estou lendo (histórico salvo em SharedPreferences).
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final books = library.history;

    return Scaffold(
      appBar: AppBar(title: const Text('Estou lendo')),
      body: !library.loaded
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const EmptyState(
                  icon: Icons.auto_stories_outlined,
                  title: 'Sua estante está vazia',
                  message:
                      'Toque em "Começar leitura" em um livro para ele aparecer aqui.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => HistoryCard(book: books[i]),
                ),
    );
  }
}
