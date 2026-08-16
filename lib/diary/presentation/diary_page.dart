import 'package:flutter/material.dart';

import '../../catalog/models/perfume.dart';
import '../data/diary_repository.dart';
import '../models/diary_entry.dart';

class DiaryPage extends StatefulWidget {
  final DiaryRepository repository;

  const DiaryPage({super.key, required this.repository});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  late Future<List<DiaryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.list();
  }

  void _reload() => setState(() => _future = widget.repository.list());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiaryEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton(
              onPressed: _reload,
              child: const Text('Tentar novamente'),
            ),
          );
        }

        final entries = snapshot.data ?? <DiaryEntry>[];
        if (entries.isEmpty) {
          return const Center(child: Text('Registre seu primeiro uso de perfume.'));
        }

        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final rating = entry.rating == null ? '' : ' • ${'★' * entry.rating!}';
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(entry.perfumeName),
                subtitle: Text(
                  '${entry.brand ?? 'Marca não informada'} • ${_date(entry.usedAt)}$rating',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await widget.repository.delete(entry.id);
                    if (mounted) _reload();
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class DiaryFormPage extends StatefulWidget {
  final DiaryRepository repository;
  final Perfume perfume;

  const DiaryFormPage({
    super.key,
    required this.repository,
    required this.perfume,
  });

  @override
  State<DiaryFormPage> createState() => _DiaryFormPageState();
}

class _DiaryFormPageState extends State<DiaryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _notes = TextEditingController();
  String? _longevity;
  String? _sillage;
  String? _occasion;
  String? _weather;
  int? _rating;
  bool _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.repository.create(
        perfume: widget.perfume,
        rating: _rating,
        longevity: _longevity,
        sillage: _sillage,
        occasion: _occasion,
        weather: _weather,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar o registro.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar uso')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(widget.perfume.name, style: Theme.of(context).textTheme.headlineSmall),
            Text(widget.perfume.brand ?? ''),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(
              initialValue: _rating,
              decoration: const InputDecoration(
                labelText: 'Sua avaliação',
                border: OutlineInputBorder(),
              ),
              items: [1, 2, 3, 4, 5]
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value estrelas'),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 12),
            _select('Duração', ['baixa', 'moderada', 'alta'], _longevity,
                (value) => setState(() => _longevity = value)),
            const SizedBox(height: 12),
            _select('Projeção', ['baixa', 'moderada', 'alta'], _sillage,
                (value) => setState(() => _sillage = value)),
            const SizedBox(height: 12),
            _select('Ocasião', ['trabalho', 'encontro', 'casual', 'festa', 'casa'], _occasion,
                (value) => setState(() => _occasion = value)),
            const SizedBox(height: 12),
            _select('Clima', ['quente', 'ameno', 'frio', 'chuvoso'], _weather,
                (value) => setState(() => _weather = value)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 4,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Salvando...' : 'Salvar registro'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _select(
    String label,
    List<String> options,
    String? selected,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: selected,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
