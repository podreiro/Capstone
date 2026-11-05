import 'package:flutter/material.dart';

import 'package:lumen/Dados.dart';
import 'package:lumen/Tema.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  final LocalStore store;
  final ValueChanged<ReadingTheme> onThemeChanged;

  const ProfilePage({
    super.key,
    required this.email,
    required this.store,
    required this.onThemeChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ReadingTheme selected = ReadingTheme.creme;

  String themeLabel(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.creme:
        return 'Creme — leitura longa';
      case ReadingTheme.branco:
        return 'Branco — leitura objetiva';
      case ReadingTheme.noturno:
        return 'Noturno — baixa luminosidade';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppBar(title: const Text('Meu perfil')),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 26,
                child: Text(
                  widget.email.isNotEmpty ? widget.email[0].toUpperCase() : 'L',
                ),
              ),
              title: const Text(
                'Leitor Lúmen',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(widget.email),
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
              groupValue: selected,
              onChanged: (value) {
                if (value == null) return;
                setState(() => selected = value);
                widget.onThemeChanged(value);
              },
              title: Text(themeLabel(theme)),
              subtitle: Text(
                theme == ReadingTheme.creme
                    ? 'Contraste suave, inspirado no papel creme.'
                    : theme == ReadingTheme.branco
                        ? 'Maior contraste para estudos e consultas rápidas.'
                        : 'Fundo escuro e texto suave para ambientes com pouca luz.',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: const ListTile(
              leading: Icon(Icons.favorite_outline),
              title: Text('Favoritos'),
              subtitle: Text(
                'Os IDs dos seus favoritos são armazenados localmente.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: const ListTile(
              leading: Icon(Icons.history),
              title: Text('Histórico'),
              subtitle: Text(
                'Seus livros iniciados ficam disponíveis na aba “Lendo”.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
