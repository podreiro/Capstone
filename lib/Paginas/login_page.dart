import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumen/providers/auth_provider.dart';

/// Tela 1 — Cadastro/Login. Ao autenticar, o AuthProvider muda e o
/// MaterialApp troca para a HomePage automaticamente.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool isLogin = true;
  bool obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    if (isLogin) {
      await auth.login(_email.text, _password.text);
    } else {
      await auth.register(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.auto_stories_rounded, size: 68, color: color),
                    const SizedBox(height: 14),
                    Text(
                      'Lúmen',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seus livros, no seu ritmo e com mais conforto.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 38),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Entrar')),
                        ButtonSegment(value: false, label: Text('Cadastrar')),
                      ],
                      selected: {isLogin},
                      onSelectionChanged: auth.loading
                          ? null
                          : (value) {
                              setState(() => isLogin = value.first);
                              auth.clearError();
                            },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        final valid =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
                        return valid ? null : 'Informe um e-mail válido.';
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: obscure,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        auth.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: auth.loading ? null : _submit,
                      icon: auth.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isLogin ? Icons.login : Icons.person_add_alt_1,
                            ),
                      label: Text(isLogin ? 'Entrar' : 'Criar conta'),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Primeiro acesso? Escolha "Cadastrar". '
                      'Os dados ficam salvos apenas neste dispositivo.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
