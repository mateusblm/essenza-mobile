import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../data/auth_repository.dart';

class LoginPage extends StatefulWidget {
  final AuthRepository repository;
  final VoidCallback onAuthenticated;
  const LoginPage({super.key, required this.repository, required this.onAuthenticated});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false, _loading = false;
  String? _error;

  @override void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      if (_register) {
        await widget.repository.register(name: _name.text.trim(), email: _email.text.trim(), password: _password.text);
      } else {
        await widget.repository.login(email: _email.text.trim(), password: _password.text);
      }
      if (mounted) widget.onAuthenticated();
    } on ApiException catch (e) { if (mounted) setState(() => _error = e.message); }
      catch (_) { if (mounted) setState(() => _error = 'Não foi possível conectar ao Essenza.'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: EssenzaColors.ocean.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.local_florist, size: 48, color: EssenzaColors.deepOcean),
        ), const SizedBox(height: 16),
        Text('Essenza', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
        Text(_register ? 'Crie sua conta' : 'Entre na sua conta', textAlign: TextAlign.center), const SizedBox(height: 32),
        if (_register) TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()), validator: (v) => v == null || v.trim().isEmpty ? 'Informe seu nome' : null),
        if (_register) const SizedBox(height: 12),
        TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()), validator: (v) => v == null || !v.contains('@') ? 'Informe um e-mail válido' : null),
        const SizedBox(height: 12), TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()), validator: (v) => v == null || v.length < 8 ? 'Use ao menos 8 caracteres' : null),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 20), FilledButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_register ? 'Criar conta' : 'Entrar')),
        TextButton(onPressed: _loading ? null : () => setState(() { _register = !_register; _error = null; }), child: Text(_register ? 'Já tenho uma conta' : 'Criar uma conta')),
      ]),
    ))))),
  );
}
