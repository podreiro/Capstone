import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/providers/library_provider.dart';

void showSnack(BuildContext context, String message, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: const Duration(seconds: 3),
      ),
    );
}

/// Favorita/desfavorita e avisa o usuário.
Future<void> toggleFavoriteWithFeedback(BuildContext context, Book book) async {
  final library = context.read<LibraryProvider>();
  final wasFavorite = library.isFavorite(book.id);
  showSnack(
    context,
    wasFavorite ? 'Removido dos favoritos.' : 'Adicionado aos favoritos.',
  );
  await library.toggleFavorite(book);
}
