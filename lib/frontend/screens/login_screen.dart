import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:lumen/backend/providers/auth_provider.dart';
import 'package:lumen/frontend/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isLogin = true;
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _setMode(bool login) {
    if (_busy || login == _isLogin) return;
    setState(() {
      _isLogin = login;
      _error = null;
      _confirm.clear();
    });
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final error = _isLogin
        ? await auth.login(_email.text, _password.text)
        : await auth.register(_email.text, _password.text);

    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;

    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        children: [
          // Gradiente sutil ambiente de fundo (glow âmbar no topo)
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.accent.withAlpha(45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo / Ícone
                        Center(
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.accent.withAlpha(80),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.accent.withAlpha(40),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_stories_rounded,
                              size: 42,
                              color: colors.accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Lúmen',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sua biblioteca digital na palma da mão.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: colors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Switch Entrar / Cadastrar
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _setMode(true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _isLogin
                                          ? colors.accent
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Entrar',
                                      style: GoogleFonts.inter(
                                        color: _isLogin
                                            ? colors.accentText
                                            : colors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _setMode(false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_isLogin
                                          ? colors.accent
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Cadastrar',
                                      style: GoogleFonts.inter(
                                        color: !_isLogin
                                            ? colors.accentText
                                            : colors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Campo Email
                        TextFormField(
                          controller: _email,
                          enabled: !_busy,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: colors.textPrimary),
                          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: colors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: colors.border),
                            ),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Informe seu e-mail.';
                            if (!_emailRegex.hasMatch(text)) {
                              return 'Informe um e-mail válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Campo Senha
                        TextFormField(
                          controller: _password,
                          focusNode: _passwordFocus,
                          enabled: !_busy,
                          obscureText: _obscure,
                          style: TextStyle(color: colors.textPrimary),
                          textInputAction:
                              _isLogin ? TextInputAction.done : TextInputAction.next,
                          onFieldSubmitted: (_) {
                            if (_isLogin) {
                              _submit();
                            } else {
                              _confirmFocus.requestFocus();
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            helperText:
                                _isLogin ? null : 'Use pelo menos 6 caracteres.',
                            helperStyle: TextStyle(color: colors.textMuted),
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: colors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: colors.border),
                            ),
                            suffixIcon: IconButton(
                              tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                          validator: (value) {
                            final text = value ?? '';
                            if (text.isEmpty) return 'Informe sua senha.';
                            if (!_isLogin && text.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres.';
                            }
                            return null;
                          },
                        ),

                        // Confirmar Senha (apenas cadastro)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.topCenter,
                          child: _isLogin
                              ? const SizedBox(width: double.infinity)
                              : Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: TextFormField(
                                    controller: _confirm,
                                    focusNode: _confirmFocus,
                                    enabled: !_busy,
                                    obscureText: _obscure,
                                    style: TextStyle(color: colors.textPrimary),
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration: InputDecoration(
                                      labelText: 'Confirmar senha',
                                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                                      filled: true,
                                      fillColor: colors.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: colors.border),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Confirme sua senha.';
                                      }
                                      if (value != _password.text) {
                                        return 'As senhas não coincidem.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B1820),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCF6679)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFCF6679),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Color(0xFFCF6679),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Botão de Submit
                        FilledButton.icon(
                          onPressed: _busy ? null : _submit,
                          icon: _busy
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.accentText,
                                  ),
                                )
                              : Icon(
                                  _isLogin ? Icons.login : Icons.person_add_alt_1,
                                ),
                          label: Text(_isLogin ? 'Entrar' : 'Criar conta'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.accent,
                            foregroundColor: colors.accentText,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: _busy ? null : () => _setMode(!_isLogin),
                          child: Text(
                            _isLogin
                                ? 'Não tem conta? Cadastre-se'
                                : 'Já tem conta? Entre',
                            style: TextStyle(color: colors.accent),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A conta fica salva apenas neste dispositivo.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
