import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/auth_provider.dart';
import 'package:lumen/backend/providers/theme_provider.dart';
import 'package:lumen/frontend/screens/home_screen.dart';
import 'package:lumen/frontend/screens/login_screen.dart';
import 'package:lumen/frontend/theme/app_theme.dart';
import 'package:lumen/frontend/widgets/lumen_tudum_intro.dart';

/// Habilita arrastar com mouse, trackpad e toque em todas as listas do app.
class LumenScrollBehavior extends MaterialScrollBehavior {
  const LumenScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lúmen',
      scrollBehavior: const LumenScrollBehavior(),
      theme: AppTheme.build(theme),
      home: const AuthGate(),
    );
  }
}

/// Controla o fluxo de autenticação e a transição "Tudum Lúmen" pós-login.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastEmail;
  bool _showIntro = false;

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().email;

    // Detecta o momento exato em que o usuário faz login
    if (email != null && _lastEmail == null) {
      _lastEmail = email;
      _showIntro = true;
    } else if (email == null) {
      _lastEmail = null;
      _showIntro = false;
    }

    if (email == null) {
      return const LoginScreen(key: ValueKey('login'));
    }

    if (_showIntro) {
      return LumenTudumIntro(
        key: ValueKey('intro-$email'),
        onComplete: () {
          if (mounted) setState(() => _showIntro = false);
        },
      );
    }

    return HomeScreen(key: ValueKey(email), email: email);
  }
}
