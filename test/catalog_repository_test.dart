import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:essenza_mobile/catalog/data/catalog_repository.dart';
import 'package:essenza_mobile/core/network/api_client.dart';
import 'package:essenza_mobile/core/storage/token_store.dart';

class CatalogMockHttpClient extends Mock implements http.Client {}
class CatalogMemoryStore implements TokenStore {
  @override Future<String?> read() async => 'jwt';
  @override Future<void> write(String value) async {}
  @override Future<void> clear() async {}
}

void main() {
  setUpAll(() => registerFallbackValue(Uri()));

  test('search maps perfume results', () async {
    final client = CatalogMockHttpClient();
    when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response(jsonEncode({'items': [{'externalId': 'p1', 'name': 'Sauvage', 'brand': {'name': 'Dior'}}], 'total': 1}), 200));
    final result = await CatalogRepository(ApiClient(httpClient: client, tokenStore: CatalogMemoryStore(), baseUrl: 'http://test')).search('sauvage');
    expect(result.total, 1);
    expect(result.items.single.brand, 'Dior');
  });

  test('collection uses add and delete endpoints', () async {
    final client = CatalogMockHttpClient();
    when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer((_) async => http.Response(jsonEncode({'externalId': 'p1', 'name': 'Sauvage', 'brand': 'Dior'}), 200));
    when(() => client.delete(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response('', 204));
    final repository = CatalogRepository(ApiClient(httpClient: client, tokenStore: CatalogMemoryStore(), baseUrl: 'http://test'));
    expect((await repository.addToCollection('p1')).name, 'Sauvage');
    await repository.removeFromCollection('p1');
    verify(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).called(1);
    verify(() => client.delete(any(), headers: any(named: 'headers'))).called(1);
  });
}
