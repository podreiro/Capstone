import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/auth_provider.dart';
import 'package:lumen/backend/providers/theme_provider.dart';
import 'package:lumen/frontend/screens/home_screen.dart';
import 'package:lumen/frontend/screens/login_screen.dart';
import 'package:lumen/frontend/theme/app_theme.dart';

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lúmen',
      theme: AppTheme.build(theme),
      home: const AuthGate(),
    );
  }
}

/// Mostra o login enquanto não há sessão. Como a sessão fica só em memória,
/// recarregar a página (F5) sempre volta para esta tela.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().email;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: email == null
          ? const LoginScreen(key: ValueKey('login'))
          : HomeScreen(key: ValueKey(email), email: email),
    );
  }
}
