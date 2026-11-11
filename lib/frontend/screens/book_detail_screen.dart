import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lumen/backend/models/book.dart';
import 'package:lumen/backend/providers/book_detail_provider.dart';
import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/backend/services/open_library_service.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/book_cover.dart';
import 'package:lumen/frontend/widgets/feedback.dart';
import 'package:lumen/frontend/widgets/state_views.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, this.heroTag});

  final String? heroTag;

  /// Abre os detalhes com Navigator.push; o botão voltar faz o pop.
  static Future<void> open(BuildContext context, Book book, {String? heroTag}) {
    final service = context.read<OpenLibraryService>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => BookDetailProvider(service, book)..load(),
          child: BookDetailScreen(heroTag: heroTag),
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
    final colors = context.lumen;
    final tag = heroTag ?? 'book-cover-${book.id}';

    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(
        slivers: [
          // Header com capa full-bleed e gradiente
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: colors.bg,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: colors.surface.withAlpha(180),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.textPrimary, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundColor: colors.surface.withAlpha(180),
                  child: IconButton(
                    tooltip: favorite ? 'Remover dos favoritos' : 'Favoritar',
                    onPressed: () => toggleFavoriteWithFeedback(context, book),
                    icon: Icon(
                      favorite ? Icons.favorite : Icons.favorite_border,
                      color: favorite ? colors.accent : colors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Capa do livro com transição Hero
                  Hero(
                    tag: tag,
                    child: BookCover(url: book.largeCoverUrl, fit: BoxFit.cover),
                  ),

                  // Gradiente escuro no topo para contraste dos botões
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withAlpha(160),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Gradiente escuro na base mesclando com o fundo do tema
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 1.0],
                          colors: [
                            Colors.transparent,
                            colors.bg,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Informações do livro e conteúdo
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge se puder ler online
                      if (book.canReadOnline)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book.access == ReadAccess.free
                                ? 'DISPONÍVEL PARA LEITURA'
                                : 'EMPRÉSTIMO DIGITAL',
                            style: TextStyle(
                              color: colors.accentText,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),

                      // Título
                      Text(
                        book.title,
                        style: textTheme.headlineMedium?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Autor
                      Text(
                        book.authorsLabel,
                        style: GoogleFonts.inter(
                          color: colors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Ano de publicação
                      if (book.year != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Primeira publicação: ${book.year}',
                          style: GoogleFonts.inter(
                            color: colors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      // Chips de Assuntos
                      if (book.subjects.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final subject in book.subjects.take(6))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Text(
                                  subject,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Bloco Ler Agora
                      _ReadCard(book: book),

                      const SizedBox(height: 28),

                      // Descrição / Sinopse
                      Text(
                        'Sinopse',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Description(detail: detail),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloco "Ler agora": link e botões de leitura
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
      return 'Não encontramos uma edição digital direta para este título. '
          'Você pode consultar a página da obra na Open Library.';
    }
    return book.access == ReadAccess.free
        ? 'Leia online pelo Internet Archive diretamente, sem custo.'
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
    final colors = context.lumen;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  book.canReadOnline
                      ? Icons.chrome_reader_mode
                      : Icons.info_outline,
                  color: colors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colors.textMuted,
              height: 1.4,
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
                    size: 20,
                  ),
                  label: Text(
                    book.canReadOnline ? 'Ler agora' : 'Ver na Open Library',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.accentText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Copiar link',
                onPressed: () => _copy(context),
                icon: Icon(Icons.copy, color: colors.textPrimary, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: colors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colors.border),
                  ),
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.detail});

  final BookDetailProvider detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;

    if (detail.loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Carregando sinopse…',
              style: TextStyle(color: colors.textMuted),
            ),
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
      style: GoogleFonts.inter(
        fontSize: 14,
        color: colors.textPrimary.withAlpha(220),
        height: 1.6,
      ),
    );
  }
}
