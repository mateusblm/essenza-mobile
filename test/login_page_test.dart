import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:essenza_mobile/auth/data/auth_repository.dart';
import 'package:essenza_mobile/auth/presentation/login_page.dart';
import 'package:essenza_mobile/auth/models/auth_session.dart';
import 'package:essenza_mobile/auth/models/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() => registerFallbackValue(''));

  testWidgets('login validates fields before calling the API', (tester) async {
    final repository = MockAuthRepository();
    await tester.pumpWidget(MaterialApp(home: LoginPage(repository: repository, onAuthenticated: () {})));

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe um e-mail válido'), findsOneWidget);
    verifyNever(() => repository.login(email: any(named: 'email'), password: any(named: 'password')));
  });

  testWidgets('successful login notifies the app', (tester) async {
    final repository = MockAuthRepository();
    when(() => repository.login(email: 'mateus@test.dev', password: 'senha-segura'))
        .thenAnswer((_) async => const AuthSession(token: 'jwt', user: User(name: 'Mateus', email: 'mateus@test.dev')));
    var authenticated = false;
    await tester.pumpWidget(MaterialApp(home: LoginPage(repository: repository, onAuthenticated: () => authenticated = true)));
    await tester.enterText(find.byType(TextFormField).at(0), 'mateus@test.dev');
    await tester.enterText(find.byType(TextFormField).at(1), 'senha-segura');
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(authenticated, isTrue);
  });
}
