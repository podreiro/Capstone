import 'package:flutter/material.dart';

import 'package:lumen/Integracoes.dart';
import 'package:lumen/Tema.dart';
import 'package:lumen/Paginas/catalog_page.dart';
import 'package:lumen/Paginas/history_page.dart';
import 'package:lumen/Paginas/profile_page.dart';
import 'package:lumen/Paginas/search_page.dart';

class HomePage extends StatefulWidget {
  final String userEmail;
  final ValueChanged<ReadingTheme> onThemeChanged;

  const HomePage({
    super.key,
    required this.userEmail,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final service = OpenLibraryService();
  final store = LocalStore();

  @override
  Widget build(BuildContext context) {
    final pages = [
      CatalogPage(service: service, store: store),
      SearchPage(service: service, store: store),
      HistoryPage(service: service, store: store),
      ProfilePage(
        email: widget.userEmail,
        store: store,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Lendo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
