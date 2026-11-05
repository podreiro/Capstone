import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumen/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Login valida o formulário e cadastra o usuário',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LumenApp());
    await tester.pumpAndSettle();

    // Formulário vazio: mostra erros do validator.
    await tester.tap(find.text('Entrar').last);
    await tester.pump();
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);

    // Conta inexistente em "Entrar".
    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Entrar').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Conta não encontrada'), findsOneWidget);
  });
}
