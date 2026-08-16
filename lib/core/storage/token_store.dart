import 'package:shared_preferences/shared_preferences.dart';

abstract interface class TokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class SharedPreferencesTokenStore implements TokenStore {
  static const _key = 'essenza.auth.token';
  @override Future<String?> read() async => (await SharedPreferences.getInstance()).getString(_key);
  @override Future<void> write(String token) async => (await SharedPreferences.getInstance()).setString(_key, token);
  @override Future<void> clear() async => (await SharedPreferences.getInstance()).remove(_key);
}
