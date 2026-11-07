import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/auth_provider.dart';
import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/backend/providers/theme_provider.dart';
import 'package:lumen/frontend/screens/about_screen.dart';
import 'package:lumen/frontend/screens/favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.email,
    required this.onOpenReading,
  });

  final String email;
  final VoidCallback onOpenReading;

  static String _themeDescription(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.creme:
        return 'Creme: contraste suave, inspirado no papel, ideal para leitura longa.';
      case ReadingTheme.branco:
        return 'Branco: maior contraste para estudos e consultas rápidas.';
      case ReadingTheme.noturno:
        return 'Noturno: fundo escuro e texto suave para ambientes com pouca luz.';
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará entrar novamente para continuar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<LibraryProvider>().clear();
    context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final themeProvider = context.watch<ThemeProvider>();
    final favorites = context.select<LibraryProvider, int>(
      (l) => l.favoriteCount,
    );
    final reading = context.select<LibraryProvider, int>(
      (l) => l.historyCount,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
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
          const SizedBox(height: 12),
          Row(
            children: [
              _StatCard(
                icon: Icons.favorite_outline,
                value: favorites,
                label: 'Favoritos',
                onTap: () => FavoritesScreen.open(context),
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.auto_stories_outlined,
                value: reading,
                label: 'Lendo',
                onTap: onOpenReading,
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            'Conforto de leitura',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha a aparência que combina com seu momento de leitura. '
            'Sua escolha fica salva neste dispositivo.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          SegmentedButton<ReadingTheme>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ReadingTheme.creme,
                icon: Icon(Icons.wb_sunny_outlined),
                label: Text('Creme'),
              ),
              ButtonSegment(
                value: ReadingTheme.branco,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Branco'),
              ),
              ButtonSegment(
                value: ReadingTheme.noturno,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Noturno'),
              ),
            ],
            selected: {themeProvider.theme},
            onSelectionChanged: (value) => themeProvider.setTheme(value.first),
          ),
          const SizedBox(height: 10),
          Text(
            _themeDescription(themeProvider.theme),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              onTap: () => AboutScreen.open(context),
              leading: const Icon(Icons.info_outline),
              title: const Text('Sobre o Lúmen'),
              subtitle: const Text('Squad, créditos e fonte dos dados.'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final int value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Icon(icon),
                const SizedBox(height: 6),
                Text(
                  '$value',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
