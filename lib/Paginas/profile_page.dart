import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/Paginas/favorites_page.dart';
import 'package:lumen/Tema.dart';
import 'package:lumen/providers/auth_provider.dart';
import 'package:lumen/providers/library_provider.dart';
import 'package:lumen/providers/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _themeLabel(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.creme:
        return 'Creme — leitura longa';
      case ReadingTheme.branco:
        return 'Branco — leitura objetiva';
      case ReadingTheme.noturno:
        return 'Noturno — baixa luminosidade';
    }
  }

  String _themeHint(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.creme:
        return 'Contraste suave, inspirado no papel creme.';
      case ReadingTheme.branco:
        return 'Maior contraste para estudos e consultas rápidas.';
      case ReadingTheme.noturno:
        return 'Fundo escuro e texto suave para ambientes com pouca luz.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().email ?? '';
    final library = context.watch<LibraryProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 26,
                child: Text(email.isNotEmpty ? email[0].toUpperCase() : 'L'),
              ),
              title: const Text(
                'Leitor Lúmen',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(email),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Conforto de leitura',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha a aparência que combina com seu momento de leitura.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ...ReadingTheme.values.map(
            (theme) => RadioListTile<ReadingTheme>(
              value: theme,
              groupValue: themeProvider.current,
              onChanged: (value) {
                if (value != null) context.read<ThemeProvider>().set(value);
              },
              title: Text(_themeLabel(theme)),
              subtitle: Text(_themeHint(theme)),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Favoritos'),
              subtitle: Text('${library.favorites.length} livro(s) salvo(s)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico'),
              subtitle: Text(
                '${library.history.length} livro(s) iniciado(s) — veja na aba “Lendo”.',
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
