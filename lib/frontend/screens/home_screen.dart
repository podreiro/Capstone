import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/frontend/screens/catalog_screen.dart';
import 'package:lumen/frontend/screens/profile_screen.dart';
import 'package:lumen/frontend/screens/reading_screen.dart';
import 'package:lumen/frontend/screens/search_screen.dart';

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

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          CatalogScreen(onOpenSearch: () => _goTo(1)),
          const SearchScreen(),
          const ReadingScreen(),
          ProfileScreen(email: widget.email, onOpenReading: () => _goTo(2)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Início',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: reading > 0,
              label: Text('$reading'),
              child: const Icon(Icons.auto_stories_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: reading > 0,
              label: Text('$reading'),
              child: const Icon(Icons.auto_stories),
            ),
            label: 'Lendo',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
