import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/frontend/screens/catalog_screen.dart';
import 'package:lumen/frontend/screens/profile_screen.dart';
import 'package:lumen/frontend/screens/reading_screen.dart';
import 'package:lumen/frontend/screens/search_screen.dart';
import 'package:lumen/frontend/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.email});

  final String email;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Carrega favoritos e histórico do usuário que acabou de entrar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LibraryProvider>().load(widget.email);
    });
  }

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final reading = context.select<LibraryProvider, int>((l) => l.historyCount);
    final colors = context.lumen;

    return Scaffold(
      backgroundColor: colors.bg,
      body: IndexedStack(
        index: _index,
        children: [
          CatalogScreen(onOpenSearch: () => _goTo(1)),
          const SearchScreen(),
          const ReadingScreen(),
          ProfileScreen(email: widget.email, onOpenReading: () => _goTo(2)),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.bg,
          border: Border(
            top: BorderSide(color: colors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: colors.bg,
          surfaceTintColor: Colors.transparent,
          indicatorColor: colors.accent.withAlpha(40),
          selectedIndex: _index,
          onDestinationSelected: _goTo,
          height: 64,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: colors.textMuted),
              selectedIcon: Icon(Icons.home, color: colors.accent),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.search, color: colors.textMuted),
              selectedIcon: Icon(Icons.search, color: colors.accent),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: reading > 0,
                backgroundColor: colors.accent,
                textColor: colors.accentText,
                label: Text('$reading'),
                child: Icon(Icons.auto_stories_outlined, color: colors.textMuted),
              ),
              selectedIcon: Badge(
                isLabelVisible: reading > 0,
                backgroundColor: colors.accent,
                textColor: colors.accentText,
                label: Text('$reading'),
                child: Icon(Icons.auto_stories, color: colors.accent),
              ),
              label: 'Lendo',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: colors.textMuted),
              selectedIcon: Icon(Icons.person, color: colors.accent),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
