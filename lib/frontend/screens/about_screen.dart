import 'package:flutter/material.dart';

/// Tela "Sobre" (aberta a partir do Perfil com Navigator.push).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  static const _members = [
    'Jade Schoenstatt (líder)',
    'Pedro Henrique Vivas',
    'Rafael Barbieri',
    'Rubens Gabriel',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Lúmen')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Lúmen',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Seus livros na palma da mão.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Squad Foorteen Books',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final member in _members)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text(member),
            ),
          const SizedBox(height: 16),
          Text(
            'Dados dos livros',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Catálogo, capas e links de leitura fornecidos pela API pública '
            'da Open Library (openlibrary.org). As edições digitais são '
            'hospedadas pelo Internet Archive.',
          ),
        ],
      ),
    );
  }
}
