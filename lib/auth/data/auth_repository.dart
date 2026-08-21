import '../../core/network/api_client.dart';
import 'dart:typed_data';
import '../../core/storage/token_store.dart';
import '../models/auth_session.dart';

class AuthRepository {
  final ApiClient client;
  final TokenStore tokenStore;
  AuthRepository(this.client, this.tokenStore);

  Future<AuthSession> register({required String name, required String email, required String password}) async {
    return _save(await client.post('/auth/register', {'name': name, 'email': email, 'password': password}));
  }

  Future<AuthSession> login({required String email, required String password}) async {
    return _save(await client.post('/auth/login', {'email': email, 'password': password}));
  }

  Future<void> logout() => tokenStore.clear();
  Future<Uint8List?> avatar() async {
    try {
      return await client.getBytes('/auth/me/avatar');
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }
  Future<void> uploadAvatar(Uint8List bytes, {required String filename, required String contentType}) => client.putMultipart('/auth/me/avatar', bytes, filename: filename, contentType: contentType);
  Future<AuthSession> _save(Map<String, dynamic> json) async { final session = AuthSession.fromJson(json); await tokenStore.write(session.token); return session; }
}
