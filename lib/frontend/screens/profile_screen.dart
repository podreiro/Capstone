import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/auth_provider.dart';
import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/backend/providers/theme_provider.dart';
import 'package:lumen/frontend/screens/about_screen.dart';
import 'package:lumen/frontend/screens/favorites_screen.dart';
import 'package:lumen/frontend/theme/app_theme.dart';

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
        return 'Creme: contraste suave inspirado no papel, ideal para leitura prolongada.';
      case ReadingTheme.branco:
      case ReadingTheme.noturno:
        return 'Noturno Âmbar: paleta cinematográfica com acentos dourados e pretos profundos.';
    }
  }

  Future<void> _logout(BuildContext context) async {
    final colors = context.lumen;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('Sair da conta?', style: TextStyle(color: colors.textPrimary)),
        content: Text(
          'Você precisará entrar novamente para continuar.',
          style: TextStyle(color: colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: TextStyle(color: colors.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFCF6679)),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
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
    final themeProvider = context.watch<ThemeProvider>();
    final colors = context.lumen;
    final favorites = context.select<LibraryProvider, int>(
      (l) => l.favoriteCount,
    );
    final reading = context.select<LibraryProvider, int>(
      (l) => l.historyCount,
    );

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          'Meu perfil',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Cartão do Usuário
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.accent,
                  child: Text(
                    email.isNotEmpty ? email[0].toUpperCase() : 'L',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.accentText,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leitor Lúmen',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Cards de Estatísticas (Favoritos / Lendo)
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
          const SizedBox(height: 28),

          // Conforto de leitura
          Text(
            'Conforto de leitura',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Escolha a aparência que combina com seu momento de leitura. '
            'Sua escolha fica salva neste dispositivo.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          SegmentedButton<ReadingTheme>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              backgroundColor: colors.surface,
              selectedBackgroundColor: colors.accent,
              selectedForegroundColor: colors.accentText,
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.border),
            ),
            segments: const [
              ButtonSegment(
                value: ReadingTheme.creme,
                icon: Icon(Icons.wb_sunny_outlined),
                label: Text('Creme'),
              ),
              ButtonSegment(
                value: ReadingTheme.noturno,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Noturno'),
              ),
            ],
            selected: {
              themeProvider.theme == ReadingTheme.creme
                  ? ReadingTheme.creme
                  : ReadingTheme.noturno
            },
            onSelectionChanged: (value) => themeProvider.setTheme(value.first),
          ),
          const SizedBox(height: 10),
          Text(
            _themeDescription(themeProvider.theme),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Botão Sobre
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: ListTile(
              onTap: () => AboutScreen.open(context),
              leading: Icon(Icons.info_outline, color: colors.accent),
              title: Text('Sobre o Lúmen', style: TextStyle(color: colors.textPrimary)),
              subtitle: Text(
                'Squad, créditos e fonte dos dados.',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
              trailing: Icon(Icons.chevron_right, color: colors.textMuted),
            ),
          ),
          const SizedBox(height: 24),

          // Sair da Conta
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, size: 18, color: Color(0xFFCF6679)),
            label: const Text(
              'Sair da conta',
              style: TextStyle(color: Color(0xFFCF6679)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCF6679)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
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
    final colors = context.lumen;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: colors.accent, size: 24),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
