import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/providers/book_detail_provider.dart';
import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/backend/services/open_library_service.dart';
import 'package:lumen/frontend/widgets/book_cover.dart';
import 'package:lumen/frontend/widgets/feedback.dart';
import 'package:lumen/frontend/widgets/state_views.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  /// Abre os detalhes com Navigator.push; o botão voltar faz o pop.
  static Future<void> open(BuildContext context, Book book) {
    final service = context.read<OpenLibraryService>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => BookDetailProvider(service, book)..load(),
          child: const BookDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<BookDetailProvider>();
    final book = detail.book;
    final favorite = context.select<LibraryProvider, bool>(
      (l) => l.isFavorite(book.id),
    );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do livro'),
        actions: [
          IconButton(
            tooltip: favorite ? 'Remover dos favoritos' : 'Favoritar',
            onPressed: () => toggleFavoriteWithFeedback(context, book),
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Center(
                child: SizedBox(
                  height: 330,
                  width: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BookCover(url: book.largeCoverUrl),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                book.title,
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(book.authorsLabel, style: textTheme.titleMedium),
              if (book.year != null) ...[
                const SizedBox(height: 4),
                Text('Primeira publicação: ${book.year}'),
              ],
              if (book.subjects.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final subject in book.subjects.take(6))
                      Chip(label: Text(subject)),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              _ReadCard(book: book),
              const SizedBox(height: 24),
              Text(
                'Sobre o livro',
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _Description(detail: detail),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bloco "Ler agora": mostra o link de leitura devolvido pela API.
class _ReadCard extends StatelessWidget {
  const _ReadCard({required this.book});

  final Book book;

  String get _title {
    if (!book.canReadOnline) return 'Leitura online indisponível';
    return book.access == ReadAccess.free
        ? 'Leitura online gratuita'
        : 'Disponível para empréstimo digital';
  }

  String get _subtitle {
    if (!book.canReadOnline) {
      return 'Não encontramos uma edição digital para este título. '
          'Veja a página da obra na Open Library.';
    }
    return book.access == ReadAccess.free
        ? 'Leia online pelo Internet Archive, sem precisar de conta.'
        : 'Leia online pelo Internet Archive. Pode ser necessário entrar '
            'com uma conta gratuita.';
  }

  Future<void> _read(BuildContext context) async {
    final library = context.read<LibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    if (book.canReadOnline) {
      library.addToHistory(book);
    }
    try {
      final opened = await launchUrl(
        Uri.parse(book.readUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw Exception('launch failed');
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: book.readUrl));
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o navegador. Link copiado.'),
          ),
        );
    }
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: book.readUrl));
    if (context.mounted) showSnack(context, 'Link copiado.');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  book.canReadOnline
                      ? Icons.chrome_reader_mode
                      : Icons.info_outline,
                  color: scheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _title,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_subtitle),
            const SizedBox(height: 12),
            Text('Link:', style: textTheme.labelMedium),
            const SizedBox(height: 2),
            SelectableText(
              book.readUrl,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _read(context),
                    icon: Icon(
                      book.canReadOnline
                          ? Icons.play_arrow_rounded
                          : Icons.open_in_new,
                    ),
                    label: Text(
                      book.canReadOnline ? 'Ler agora' : 'Ver na Open Library',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: 'Copiar link',
                  onPressed: () => _copy(context),
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.detail});

  final BookDetailProvider detail;

  @override
  Widget build(BuildContext context) {
    if (detail.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Carregando descrição…'),
          ],
        ),
      );
    }
    if (detail.error != null) {
      return ErrorState(message: detail.error!, onRetry: detail.load);
    }
    final description = detail.book.description;
    return Text(
      description != null && description.isNotEmpty
          ? description
          : 'Não há descrição disponível para este título.',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
    );
  }
}
