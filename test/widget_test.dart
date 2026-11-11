import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumen/backend/providers/auth_provider.dart';
import 'package:lumen/backend/providers/theme_provider.dart';
import 'package:lumen/backend/services/local_storage_service.dart';
import 'package:lumen/frontend/app.dart';

void main() {
  test('mantém a sessão após recriar o provider e encerra no logout', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    final auth = AuthProvider(storage);

    expect(await auth.register('leitor@example.com', 'senha-segura'), isNull);

    final restoredAuth = AuthProvider(storage);
    expect(restoredAuth.email, 'leitor@example.com');

    await restoredAuth.logout();
    expect(AuthProvider(storage).isLoggedIn, isFalse);
  });

  testWidgets('abre no login e mostra confirmação de senha no cadastro',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
          ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
        ],
        child: const LumenApp(),
      ),
    );

    expect(find.text('Lúmen'), findsWidgets);
    expect(find.text('Confirmar senha'), findsNothing);

    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar senha'), findsWidgets);
  });
}
