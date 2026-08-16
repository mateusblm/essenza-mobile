import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:essenza_mobile/catalog/models/perfume.dart';
import 'package:essenza_mobile/core/network/api_client.dart';
import 'package:essenza_mobile/core/storage/token_store.dart';
import 'package:essenza_mobile/diary/data/diary_repository.dart';

class DiaryMockHttpClient extends Mock implements http.Client {}
class DiaryMemoryStore implements TokenStore { @override Future<String?> read() async => 'jwt'; @override Future<void> write(String value) async {} @override Future<void> clear() async {} }

void main() {
  setUpAll(() => registerFallbackValue(Uri()));

  test('creates a diary entry with the selected perfume and observations', () async {
    final client = DiaryMockHttpClient();
    when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer((_) async => http.Response(jsonEncode({'id': 1, 'perfumeExternalId': 'p1', 'perfumeName': 'Sauvage', 'usedAt': '2026-08-16T10:00:00Z', 'rating': 5, 'notes': 'Ótimo'}), 200));
    final repo = DiaryRepository(ApiClient(httpClient: client, tokenStore: DiaryMemoryStore(), baseUrl: 'http://test'));
    final entry = await repo.create(perfume: const Perfume(externalId: 'p1', name: 'Sauvage'), rating: 5, notes: 'Ótimo');
    expect(entry.perfumeName, 'Sauvage');
    expect(entry.rating, 5);
  });

  test('lists diary entries from the authenticated user', () async {
    final client = DiaryMockHttpClient();
    when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response('[{"id":1,"perfumeExternalId":"p1","perfumeName":"Sauvage","usedAt":"2026-08-16T10:00:00Z"}]', 200));
    final entries = await DiaryRepository(ApiClient(httpClient: client, tokenStore: DiaryMemoryStore(), baseUrl: 'http://test')).list();
    expect(entries.single.perfumeExternalId, 'p1');
  });
}
