import 'package:flutter/material.dart';

import 'package:lumen/backend/models/book.dart';

/// Tela de leitura (Navigator.push a partir dos detalhes; pop para voltar).
class ReadingPage extends StatefulWidget {
  final AppBook book;

  const ReadingPage({super.key, required this.book});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  double fontSize = 18;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final text = book.description?.trim().isNotEmpty == true
        ? book.description!
        : 'Este título não possui trecho disponível na Open Library.';

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Diminuir fonte',
            onPressed: fontSize > 14 ? () => setState(() => fontSize -= 2) : null,
            icon: const Icon(Icons.text_decrease),
          ),
          IconButton(
            tooltip: 'Aumentar fonte',
            onPressed: fontSize < 30 ? () => setState(() => fontSize += 2) : null,
            icon: const Icon(Icons.text_increase),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          Text(
            book.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            book.authors.isEmpty ? 'Autor desconhecido' : book.authors.join(', '),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Text(text, style: TextStyle(fontSize: fontSize, height: 1.7)),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar aos detalhes'),
          ),
        ],
      ),
    );
  }
}
