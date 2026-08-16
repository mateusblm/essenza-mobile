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
    return _decode(response);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await httpClient.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    return _decode(response);
  }

  Future<Map<String, String>> _headers() async {
    final token = await tokenStore.read();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, decoded['detail'] as String? ?? decoded['message'] as String? ?? 'Não foi possível concluir a operação.');
    }
    return decoded;
  }
}
