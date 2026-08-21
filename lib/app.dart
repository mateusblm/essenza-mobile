import 'package:flutter/material.dart';
import 'auth/data/auth_repository.dart';
import 'auth/presentation/login_page.dart';
import 'catalog/data/catalog_repository.dart';
import 'diary/data/diary_repository.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_store.dart';
import 'core/theme/app_theme.dart';
import 'home/home_page.dart';

class EssenzaApp extends StatefulWidget {
  const EssenzaApp({super.key});
  @override
  State<EssenzaApp> createState() => _EssenzaAppState();
}

class _EssenzaAppState extends State<EssenzaApp> {
  late final TokenStore _store;
  late final AuthRepository _auth;
  late final CatalogRepository _catalog;
  late final DiaryRepository _diary;
  bool _loading = true;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _store = SharedPreferencesTokenStore();
    final api = ApiClient(tokenStore: _store);
    _auth = AuthRepository(api, _store);
    _catalog = CatalogRepository(api);
    _diary = DiaryRepository(api);
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await _store.read();
    if (mounted) {
      setState(() {
        _authenticated = token != null;
        _loading = false;
      });
    }
  }

  void _onAuthenticated() => setState(() => _authenticated = true);
  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) setState(() => _authenticated = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Essenza',
      debugShowCheckedModeBanner: false,
      theme: EssenzaTheme.light(),
      home: _loading
          ? const _SplashView()
          : _authenticated
          ? HomePage(
              repository: _catalog,
              diaryRepository: _diary,
              onLogout: _logout,
            )
          : LoginPage(repository: _auth, onAuthenticated: _onAuthenticated),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/essenza_trails.png',
              width: 96,
              height: 154,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'ESSENZA',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 32,
                letterSpacing: 6,
                color: EssenzaColors.burgundyDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sua coleção. Seu aroma.',
              style: TextStyle(color: EssenzaColors.muted, letterSpacing: .4),
            ),
          ],
        ),
      ),
    ),
  );
}
