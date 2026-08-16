import 'package:flutter/material.dart';
import 'auth/data/auth_repository.dart';
import 'auth/presentation/login_page.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_store.dart';
import 'home/home_page.dart';

class EssenzaApp extends StatefulWidget {
  const EssenzaApp({super.key});
  @override State<EssenzaApp> createState() => _EssenzaAppState();
}

class _EssenzaAppState extends State<EssenzaApp> {
  late final TokenStore _store;
  late final AuthRepository _auth;
  bool _loading = true;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _store = SharedPreferencesTokenStore();
    _auth = AuthRepository(ApiClient(tokenStore: _store), _store);
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await _store.read();
    if (mounted) setState(() { _authenticated = token != null; _loading = false; });
  }

  void _onAuthenticated() => setState(() => _authenticated = true);
  Future<void> _logout() async { await _auth.logout(); if (mounted) setState(() => _authenticated = false); }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Essenza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B4B8A)), useMaterial3: true),
      home: _loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _authenticated
              ? HomePage(onLogout: _logout)
              : LoginPage(repository: _auth, onAuthenticated: _onAuthenticated),
    );
  }
}
