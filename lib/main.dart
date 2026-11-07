import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumen/backend/providers/auth_provider.dart';
import 'package:lumen/backend/providers/catalog_provider.dart';
import 'package:lumen/backend/providers/library_provider.dart';
import 'package:lumen/backend/providers/search_provider.dart';
import 'package:lumen/backend/providers/theme_provider.dart';
import 'package:lumen/backend/services/local_storage_service.dart';
import 'package:lumen/backend/services/open_library_service.dart';
import 'package:lumen/frontend/app.dart';

/// Ponto de entrada: monta os serviços (backend) e injeta os providers.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorageService(prefs);
  final api = OpenLibraryService();

  runApp(
    MultiProvider(
      providers: [
        Provider<OpenLibraryService>.value(value: api),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
        ChangeNotifierProvider(create: (_) => LibraryProvider(storage, api)),
        ChangeNotifierProvider(create: (_) => CatalogProvider(api)..reload()),
        ChangeNotifierProvider(create: (_) => SearchProvider(api)),
      ],
      child: const LumenApp(),
    ),
  );
}
