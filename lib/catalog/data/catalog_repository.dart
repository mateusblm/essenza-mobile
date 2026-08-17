import '../../core/network/api_client.dart';
import '../models/perfume.dart';
import '../models/collection_insights.dart';

class CatalogRepository {
  final ApiClient client;
  CatalogRepository(this.client);

  Future<SearchResult> search(String query) async => SearchResult.fromJson(await client.get('/perfumes?q=${Uri.encodeQueryComponent(query)}'));
  Future<SearchResult> suggestions(String query) async => SearchResult.fromJson(await client.get('/perfumes/suggestions?q=${Uri.encodeQueryComponent(query)}&limit=5'));
  Future<Perfume> details(String externalId) async => Perfume.fromJson(await client.get('/perfumes/${Uri.encodeComponent(externalId)}'));
  Future<List<Perfume>> collection() async {
    final response = await client.getJson('/collection') as List<dynamic>;
    return response.map((e) => Perfume.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<CollectionInsights> collectionInsights() async => CollectionInsights.fromJson(await client.get('/collection/insights'));
  Future<Perfume> addToCollection(String externalId) async => Perfume.fromJson(await client.post('/collection/${Uri.encodeComponent(externalId)}', {}));
  Future<void> removeFromCollection(String externalId) => client.delete('/collection/${Uri.encodeComponent(externalId)}');
}
