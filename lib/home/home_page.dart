import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Future<void> Function() onLogout;
  const HomePage({super.key, required this.onLogout});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Essenza'), actions: [IconButton(onPressed: onLogout, icon: const Icon(Icons.logout), tooltip: 'Sair')]),
    body: const Center(child: Text('Sua jornada olfativa começa aqui.')),
  );
}
