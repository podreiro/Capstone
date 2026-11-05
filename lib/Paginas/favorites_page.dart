import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/Componentes.dart';
import 'package:lumen/providers/library_provider.dart';

/// Aberta pelo Perfil com Navigator.push.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final books = context.watch<LibraryProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus favoritos')),
      body: books.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'Nenhum favorito ainda',
              message: 'Toque no coração de um livro para guardá-lo aqui.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: books.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HistoryCard(book: books[i]),
              ),
            ),
    );
  }
}
