import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:essenza_mobile/auth/data/auth_repository.dart';
import 'package:essenza_mobile/core/network/api_client.dart';
import 'package:essenza_mobile/core/storage/token_store.dart';

class MockHttpClient extends Mock implements http.Client {}

class MemoryTokenStore implements TokenStore {
  String? token;
  @override Future<String?> read() async => token;
  @override Future<void> write(String value) async => token = value;
  @override Future<void> clear() async => token = null;
}

void main() {
  setUpAll(() => registerFallbackValue(Uri()));

  test('login saves the JWT returned by the API', () async {
    final client = MockHttpClient();
    final store = MemoryTokenStore();
    when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response(jsonEncode({'token': 'jwt-123', 'user': {'id': 1, 'name': 'Mateus', 'email': 'mateus@test.dev'}}), 200));

    final session = await AuthRepository(ApiClient(httpClient: client, tokenStore: store, baseUrl: 'http://test'), store)
        .login(email: 'mateus@test.dev', password: 'senha-segura');

    expect(session.user.name, 'Mateus');
    expect(store.token, 'jwt-123');
  });

  test('authenticated requests send the bearer token', () async {
    final client = MockHttpClient();
    final store = MemoryTokenStore()..token = 'jwt-123';
    when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((invocation) async {
      expect(invocation.namedArguments[#headers], containsPair('Authorization', 'Bearer jwt-123'));
      return http.Response('{}', 200);
    });

    await ApiClient(httpClient: client, tokenStore: store, baseUrl: 'http://test').get('/collection');
    verify(() => client.get(any(), headers: any(named: 'headers'))).called(1);
  });

  test('API errors become user-facing ApiException', () async {
    final client = MockHttpClient();
    final store = MemoryTokenStore();
    when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{"detail":"E-mail ou senha inválidos."}', 401));

    await expectLater(
      AuthRepository(ApiClient(httpClient: client, tokenStore: store, baseUrl: 'http://test'), store)
          .login(email: 'x@test.dev', password: 'errada'),
      throwsA(isA<ApiException>()),
    );
  });
}
