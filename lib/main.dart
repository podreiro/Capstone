import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/services/local_store.dart';
import 'package:lumen/backend/services/open_library_service.dart';
import 'package:lumen/Paginas/home_page.dart';
import 'package:lumen/Paginas/login_page.dart';
import 'package:lumen/providers/auth_provider.dart';
import 'package:lumen/providers/books_provider.dart';
import 'package:lumen/providers/library_provider.dart';
import 'package:lumen/providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LumenApp());
}

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LocalStore();
    final api = OpenLibraryService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(store)..init()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(store)..load()),
        ChangeNotifierProvider(create: (_) => LibraryProvider(store)..load()),
        ChangeNotifierProvider(create: (_) => BooksProvider(api)),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, theme, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Lúmen',
            theme: theme.themeData,
            home: !auth.initialized
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : auth.isLoggedIn
                    ? const HomePage()
                    : const LoginPage(),
          );
        },
      ),
    );
  }
}
