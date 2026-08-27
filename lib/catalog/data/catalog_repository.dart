import '../../core/network/api_client.dart';
import '../models/perfume.dart';
import '../models/collection_insights.dart';
import '../models/recommendation.dart';
import '../models/profile_stats.dart';

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
  Future<List<PerfumeRecommendation>> recommendations({int limit = 5}) async {
    final response = await client.getJson('/collection/recommendations?limit=$limit') as List<dynamic>;
    return response.map((e) => PerfumeRecommendation.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<ProfileStats> profileStats() async => ProfileStats.fromJson(await client.get('/profile/stats'));
  Future<List<Perfume>> wishlist() async {
    final response = await client.getJson('/wishlist') as List<dynamic>;
    return response.map((e) => Perfume.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<Perfume> addToWishlist(String externalId) async => Perfume.fromJson(await client.post('/wishlist/${Uri.encodeComponent(externalId)}', {}));
  Future<void> removeFromWishlist(String externalId) => client.delete('/wishlist/${Uri.encodeComponent(externalId)}');
  Future<Perfume> addToCollection(String externalId) async => Perfume.fromJson(await client.post('/collection/${Uri.encodeComponent(externalId)}', {}));
  Future<void> removeFromCollection(String externalId) => client.delete('/collection/${Uri.encodeComponent(externalId)}');
}
