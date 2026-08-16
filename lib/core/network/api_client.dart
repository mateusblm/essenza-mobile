import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../storage/token_store.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override String toString() => message;
}

class ApiClient {
  final http.Client httpClient;
  final TokenStore tokenStore;
  final String baseUrl;
  ApiClient({http.Client? httpClient, required this.tokenStore, this.baseUrl = AppConfig.apiBaseUrl})
      : httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await httpClient.post(Uri.parse('$baseUrl$path'), headers: await _headers(), body: jsonEncode(body));
    return _decode(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> get(String path) async => (await getJson(path)) as Map<String, dynamic>;

  Future<dynamic> getJson(String path) async {
    final response = await httpClient.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    return _decode(response);
  }

  Future<void> delete(String path) async {
    final response = await httpClient.delete(Uri.parse('$baseUrl$path'), headers: await _headers());
    _decode(response);
  }

  Future<Map<String, String>> _headers() async {
    final token = await tokenStore.read();
    return {'Content-Type': 'application/json', 'Accept': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
  }

  dynamic _decode(http.Response response) {
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      throw ApiException(response.statusCode, body['detail'] as String? ?? body['message'] as String? ?? 'Não foi possível concluir a operação.');
    }
    return decoded;
  }
}
