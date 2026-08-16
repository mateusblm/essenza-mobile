import '../../catalog/models/perfume.dart';
import '../../core/network/api_client.dart';
import '../models/diary_entry.dart';

class DiaryRepository {
  final ApiClient client;
  DiaryRepository(this.client);
  Future<List<DiaryEntry>> list() async => (await client.getJson('/diary') as List<dynamic>).map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>)).toList();
  Future<DiaryEntry> create({required Perfume perfume, int? rating, String? longevity, String? sillage, String? occasion, String? weather, String? notes}) async {
    final json = await client.post('/diary', {'perfumeExternalId': perfume.externalId, 'usedAt': DateTime.now().toUtc().toIso8601String(), 'rating': rating, 'longevity': longevity, 'sillage': sillage, 'occasion': occasion, 'weather': weather, 'notes': notes});
    return DiaryEntry.fromJson(json);
  }
  Future<void> delete(int id) => client.delete('/diary/$id');
}
