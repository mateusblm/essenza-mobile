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
  int? _deletingId;

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
          return const _DiaryEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _DiaryInsights(entries: entries),
              const SizedBox(height: 16),
              Text('Suas experiências', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...entries.map((entry) {
                final rating = entry.rating == null ? '' : ' - ${'★' * entry.rating!}';
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(entry.perfumeName),
                    subtitle: Text(
                      '${entry.brand ?? 'Marca não informada'} - ${_date(entry.usedAt)}$rating',
                    ),
                    trailing: IconButton(
                      icon: _deletingId == entry.id
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.delete_outline),
                      onPressed: _deletingId == entry.id ? null : () => _deleteEntry(entry, entries),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteEntry(DiaryEntry entry, List<DiaryEntry> entries) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: Text('O registro de ${entry.perfumeName} será removido do seu diário.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deletingId = entry.id);
    try {
      await widget.repository.delete(entry.id);
      if (mounted) {
        setState(() => _future = Future.value(entries.where((item) => item.id != entry.id).toList()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro excluído.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível excluir o registro.')));
      }
    } finally {
      if (mounted) setState(() => _deletingId = null);
    }
  }

  String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _DiaryInsights extends StatelessWidget {
  final List<DiaryEntry> entries;

  const _DiaryInsights({required this.entries});

  @override
  Widget build(BuildContext context) {
    final rated = entries.where((entry) => entry.rating != null).toList();
    final average = rated.isEmpty
        ? null
        : rated.map((entry) => entry.rating!).reduce((a, b) => a + b) / rated.length;
    final favoriteOccasion = _mostCommon(entries.map((entry) => entry.occasion));
    final mostUsed = _mostCommon(entries.map((entry) => entry.perfumeName));

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seu perfil em construção', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text('Quanto mais você registra, melhores ficam suas descobertas.'),
            const SizedBox(height: 16),
            Row(
              children: [
                _InsightValue(label: 'Usos', value: '${entries.length}'),
                _InsightValue(label: 'Média', value: average == null ? '-' : average.toStringAsFixed(1)),
                _InsightValue(label: 'Mais usado', value: mostUsed ?? '-'),
              ],
            ),
            if (favoriteOccasion != null) ...[
              const SizedBox(height: 12),
              Text('Ocasião mais registrada: ${_capitalize(favoriteOccasion)}'),
            ],
          ],
        ),
      ),
    );
  }

  String? _mostCommon(Iterable<String?> values) {
    final counts = <String, int>{};
    for (final value in values) {
      if (value != null && value.isNotEmpty) counts[value] = (counts[value] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _capitalize(String value) => value[0].toUpperCase() + value.substring(1);
}

class _InsightValue extends Expanded {
  _InsightValue({required String label, required String value})
      : super(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label),
            ],
          ),
        );
}

class _DiaryEmptyState extends StatelessWidget {
  const _DiaryEmptyState();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 52),
              SizedBox(height: 16),
              Text('Seu diário vai aprender com você', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Registre como cada perfume se comporta na sua pele para criar seu perfil olfativo.', textAlign: TextAlign.center),
              SizedBox(height: 16),
              Text('Abra um perfume da sua coleção e toque em Registrar uso.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
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
