import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../catalog/data/catalog_repository.dart';
import '../catalog/models/perfume.dart';
import '../catalog/presentation/catalog_labels.dart';
import '../core/theme/app_theme.dart';
import '../diary/data/diary_repository.dart';
import '../diary/presentation/diary_page.dart';

class HomePage extends StatefulWidget {
  final CatalogRepository repository;
  final DiaryRepository diaryRepository;
  final Future<void> Function() onLogout;

  const HomePage({
    super.key,
    required this.repository,
    required this.diaryRepository,
    required this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Essenza'),
        actions: [
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: switch (_tab) {
        0 => SearchView(
            repository: widget.repository,
            diaryRepository: widget.diaryRepository,
          ),
        1 => CollectionView(repository: widget.repository, diaryRepository: widget.diaryRepository),
        _ => DiaryPage(repository: widget.diaryRepository),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Coleção',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Diário',
          ),
        ],
      ),
    );
  }
}

class SearchView extends StatefulWidget {
  final CatalogRepository repository;
  final DiaryRepository diaryRepository;

  const SearchView({
    super.key,
    required this.repository,
    required this.diaryRepository,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _query = TextEditingController();
  SearchResult? _result;
  SearchResult? _suggestions;
  Timer? _suggestionTimer;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _suggestionTimer?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _suggestionTimer?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() => _suggestions = null);
      return;
    }
    _suggestionTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final result = await widget.repository.suggestions(query);
        if (mounted && _query.text.trim() == query) setState(() => _suggestions = result);
      } catch (_) {
        if (mounted) setState(() => _suggestions = null);
      }
    });
  }

  Future<void> _search() async {
    if (_query.text.trim().length < 2) {
      setState(() => _error = 'Digite ao menos 2 caracteres.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _result = await widget.repository.search(_query.text.trim());
    } catch (_) {
      _error = 'Não foi possível buscar perfumes agora.';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Encontre sua próxima assinatura',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          const Text('Explore fragrâncias e descubra novas sensações.'),
          const SizedBox(height: 20),
          TextField(
            controller: _query,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: 'Buscar perfume ou marca',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: _search,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          if (_suggestions != null && _suggestions!.items.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(top: 6),
              child: Column(
                children: _suggestions!.items
                    .map(
                      (perfume) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.history, color: EssenzaColors.deepOcean),
                        title: Text(perfume.name),
                        subtitle: Text(perfume.brand ?? 'Marca não informada'),
                        onTap: () {
                          _query.text = perfume.name;
                          setState(() => _suggestions = null);
                          _search();
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_result == null)
            const Expanded(
              child: _EmptyState(
                icon: Icons.spa_outlined,
                title: 'Sua jornada começa aqui',
                message: 'Busque uma fragrância para conhecer suas notas e registrar sua experiência.',
              ),
            )
          else if (_result!.items.isEmpty)
            const Expanded(
              child: _EmptyState(
                icon: Icons.search_off,
                title: 'Nenhum perfume encontrado',
                message: 'Tente buscar por outro nome ou marca.',
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                itemCount: _result!.items.length,
                itemBuilder: (_, index) {
                  final perfume = _result!.items[index];
                  return PerfumeTile(
                    perfume: perfume,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PerfumeDetailsPage(
                          repository: widget.repository,
                          diaryRepository: widget.diaryRepository,
                          perfume: perfume,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class CollectionView extends StatefulWidget {
  final CatalogRepository repository;
  final DiaryRepository diaryRepository;

  const CollectionView({super.key, required this.repository, required this.diaryRepository});

  @override
  State<CollectionView> createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView> {
  late Future<List<Perfume>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.collection();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Perfume>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton(
              onPressed: () => setState(() => _future = widget.repository.collection()),
              child: const Text('Tentar novamente'),
            ),
          );
        }
        final items = snapshot.data ?? <Perfume>[];
        if (items.isEmpty) {
          return const _EmptyState(
            icon: Icons.favorite_outline,
            title: 'Sua coleção está vazia',
            message: 'Salve perfumes para criar sua seleção pessoal.',
          );
        }
        return RefreshIndicator(
          onRefresh: () {
            final future = widget.repository.collection();
            setState(() => _future = future);
            return future.then((_) {});
          },
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            children: [
              _CollectionProfile(perfumes: items),
              const SizedBox(height: 12),
              ...items.map(
                (perfume) => PerfumeTile(
                    perfume: perfume,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PerfumeDetailsPage(
                          repository: widget.repository,
                          diaryRepository: widget.diaryRepository,
                          perfume: perfume,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Registrar uso',
                          icon: const Icon(Icons.history),
                          onPressed: () async {
                            final saved = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DiaryFormPage(
                                  repository: widget.diaryRepository,
                                  perfume: perfume,
                                ),
                              ),
                            );
                            if (saved != true || !context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Experiencia registrada.')),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Remover da colecao',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () async {
                            await widget.repository.removeFromCollection(perfume.externalId);
                            if (mounted) setState(() => _future = widget.repository.collection());
                          },
                        ),
                      ],
                    ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CollectionProfile extends StatelessWidget {
  final List<Perfume> perfumes;

  const _CollectionProfile({required this.perfumes});

  @override
  Widget build(BuildContext context) {
    final families = <String, double>{
      'Fresco': _score(['citrus', 'fresh', 'aquatic', 'green', 'aromatic']),
      'Floral': _score(['floral', 'rose', 'jasmine', 'iris', 'white flowers']),
      'Amadeirado': _score(['woody', 'wood', 'sandalwood', 'cedar', 'oud']),
      'Doce': _score(['sweet', 'vanilla', 'caramel', 'honey', 'chocolate']),
      'Oriental': _score(['amber', 'warm spicy', 'spicy', 'balsamic', 'resin']),
      'Frutado': _score(['fruity', 'apple', 'citrus', 'peach', 'pear']),
    };
    final sortedFamilies = families.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final climate = <String, double>{
      'Calor': _seasonScore(['summer', 'verão', 'summer heat']),
      'Ameno': _seasonScore(['spring', 'primavera', 'autumn', 'outono']),
      'Frio': _seasonScore(['winter', 'inverno']),
    };
    final occasionRanking = _rankingValues((perfume) => perfume.occasionRanking);
    final occasions = <String>[
      if ((occasionRanking['day'] ?? occasionRanking['dia'] ?? 0) >= 0.25) 'Dia',
      if ((occasionRanking['night'] ?? occasionRanking['noite'] ?? 0) >= 0.25) 'Noite',
      if ((occasionRanking['date'] ?? occasionRanking['encontro'] ?? 0) >= 0.25) 'Encontros',
      if ((occasionRanking['work'] ?? occasionRanking['trabalho'] ?? occasionRanking['office'] ?? 0) >= 0.25) 'Trabalho',
      if (occasionRanking.isEmpty && families['Fresco']! >= families['Doce']!) 'Dia',
      if (occasionRanking.isEmpty && (families['Doce']! >= 0.25 || families['Oriental']! >= 0.25)) 'Noite',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: EssenzaColors.deepOcean),
                const SizedBox(width: 8),
                Text('Seu perfil olfativo', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Uma leitura visual dos perfumes que você escolheu.'),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CustomPaint(
                    painter: _RadarPainter(
                      values: families.values.toList(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedFamilies.take(3).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('${item.key}  ${(item.value * 100).round()}%', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Climas que combinam com sua coleção', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ...climate.entries.map((item) => _ProfileBar(label: item.key, value: item.value)),
            const SizedBox(height: 8),
            if (occasions.isNotEmpty) ...[
              Text('Momentos prováveis', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: occasions.map((item) => Chip(label: Text(item))).toList()),
            ],
          ],
        ),
      ),
    );
  }

  double _score(List<String> terms) {
    if (perfumes.isEmpty) return 0;
    final weighted = _weightedAccordScore(terms);
    if (weighted != null) return weighted;
    var totalElements = 0;
    var matchingElements = 0;
    for (final perfume in perfumes) {
      final values = {...perfume.notes, ...perfume.mainAccords}
          .map((value) => value.trim().toLowerCase())
          .where((value) => value.isNotEmpty)
          .toList();
      totalElements += values.length;
      matchingElements += values.where((value) => terms.any(value.contains)).length;
    }
    return totalElements == 0 ? 0 : matchingElements / totalElements;
  }

  double? _weightedAccordScore(List<String> terms) {
    final withWeights = perfumes.where((perfume) => perfume.mainAccordsPercentage.isNotEmpty).toList();
    if (withWeights.isEmpty) return null;
    var total = 0.0;
    var matching = 0.0;
    for (final perfume in withWeights) {
      final values = perfume.mainAccordsPercentage;
      final scale = values.values.any((value) => value > 1) ? 100 : 1;
      total += values.values.fold(0.0, (sum, value) => sum + value / scale);
      matching += values.entries
          .where((entry) => terms.any(entry.key.toLowerCase().contains))
          .fold(0.0, (sum, entry) => sum + entry.value / scale);
    }
    return total == 0 ? 0 : matching / total;
  }

  double _seasonScore(List<String> terms) {
    final values = _rankingValues((perfume) => perfume.seasonRanking);
    if (values.isEmpty) return _score(terms);
    return values.entries
        .where((entry) => terms.any((term) => entry.key.contains(term)))
        .fold(0.0, (sum, entry) => sum + entry.value);
  }

  Map<String, double> _rankingValues(List<PerfumeRanking> Function(Perfume) selector) {
    final totals = <String, double>{};
    var perfumeCount = 0;
    for (final perfume in perfumes) {
      final rankings = selector(perfume);
      if (rankings.isEmpty) continue;
      perfumeCount++;
      final scale = rankings.any((item) => item.score > 1) ? 100 : 1;
      for (final ranking in rankings) {
        final key = ranking.name.toLowerCase();
        totals[key] = (totals[key] ?? 0) + ranking.score / scale;
      }
    }
    if (perfumeCount == 0) return {};
    return totals.map((key, value) => MapEntry(key, value / perfumeCount));
  }
}

class _ProfileBar extends StatelessWidget {
  final String label;
  final double value;

  const _ProfileBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(width: 52, child: Text(label)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 9),
              ),
            ),
            SizedBox(width: 42, child: Text(' ${(value * 100).round()}%', textAlign: TextAlign.end)),
          ],
        ),
      );
}

class _RadarPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _RadarPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 8;
    final grid = Paint()..style = PaintingStyle.stroke..color = color.withValues(alpha: 0.22);
    final fill = Paint()..style = PaintingStyle.fill..color = color.withValues(alpha: 0.28);
    final outline = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = color;
    final points = <Offset>[];
    final count = values.length;
    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / count);
      points.add(center + Offset(math.cos(angle), math.sin(angle)) * radius);
    }
    final gridPath = Path()..addPolygon(points, true);
    canvas.drawPath(gridPath, grid);
    for (var i = 0; i < count; i++) {
      canvas.drawLine(center, points[i], grid);
    }
    final valuePoints = <Offset>[];
    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / count);
      valuePoints.add(center + Offset(math.cos(angle), math.sin(angle)) * radius * values[i].clamp(0.08, 1));
    }
    final valuePath = Path()..addPolygon(valuePoints, true);
    canvas.drawPath(valuePath, fill);
    canvas.drawPath(valuePath, outline);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => oldDelegate.values != values || oldDelegate.color != color;
}

class PerfumeTile extends StatelessWidget {
  final Perfume perfume;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PerfumeTile({super.key, required this.perfume, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _PerfumeImage(url: perfume.imageUrl, size: 56),
        title: Text(perfume.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(perfume.brand ?? 'Marca não informada'),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}

class PerfumeDetailsPage extends StatefulWidget {
  final CatalogRepository repository;
  final DiaryRepository diaryRepository;
  final Perfume perfume;

  const PerfumeDetailsPage({
    super.key,
    required this.repository,
    required this.diaryRepository,
    required this.perfume,
  });

  @override
  State<PerfumeDetailsPage> createState() => _PerfumeDetailsPageState();
}

class _PerfumeDetailsPageState extends State<PerfumeDetailsPage> {
  late Future<Perfume> _future;
  bool _saving = false;
  bool _inCollection = false;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.details(widget.perfume.externalId);
    _loadCollectionState();
  }

  Future<void> _loadCollectionState() async {
    try {
      final collection = await widget.repository.collection();
      if (mounted) {
        setState(() => _inCollection = collection.any(
              (item) => item.externalId == widget.perfume.externalId,
            ));
      }
    } catch (_) {
      // A falha ao carregar a coleção não impede a consulta dos detalhes.
    }
  }

  Future<void> _add(Perfume perfume) async {
    setState(() => _saving = true);
    try {
      await widget.repository.addToCollection(perfume.externalId);
      if (mounted) {
        setState(() => _inCollection = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicionado à coleção.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível adicionar.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.perfume.name)),
      body: FutureBuilder<Perfume>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final perfume = snapshot.data ?? widget.perfume;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: _PerfumeImage(url: perfume.imageUrl, size: 220)),
                ),
              ),
              const SizedBox(height: 20),
              Text(perfume.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(perfume.brand ?? 'Marca não informada'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (perfume.rating != null) _InfoChip(icon: Icons.star_outline, text: '${perfume.rating}'),
                  if (perfume.releaseYear != null) _InfoChip(icon: Icons.calendar_today_outlined, text: '${perfume.releaseYear}'),
                  if (perfume.gender != null) _InfoChip(icon: Icons.person_outline, text: perfumeLabel(perfume.gender)),
                  if (perfume.oilType != null) _InfoChip(icon: Icons.water_drop_outlined, text: perfumeLabel(perfume.oilType)),
                  if (perfume.longevity != null) _InfoChip(icon: Icons.timer_outlined, text: 'Duração: ${perfumeLabel(perfume.longevity)}'),
                  if (perfume.sillage != null) _InfoChip(icon: Icons.air, text: 'Projeção: ${perfumeLabel(perfume.sillage)}'),
                ],
              ),
              if (perfume.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: Text('Notas olfativas', style: Theme.of(context).textTheme.titleLarge),
                ),
              if (perfume.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(perfume.notes.map(perfumeLabel).join('  •  ')),
                ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _saving || _inCollection ? null : () => _add(perfume),
                icon: Icon(_inCollection ? Icons.check : Icons.favorite),
                label: Text(
                  _saving
                      ? 'Salvando...'
                      : _inCollection
                          ? 'Na coleção'
                          : 'Adicionar à coleção',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiaryFormPage(
                      repository: widget.diaryRepository,
                      perfume: perfume,
                    ),
                  ),
                ),
                icon: const Icon(Icons.history),
                label: const Text('Registrar uso'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Chip(
        avatar: const Icon(Icons.circle, size: 10, color: EssenzaColors.deepOcean),
        label: Text(text),
      );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: EssenzaColors.ocean),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _PerfumeImage extends StatelessWidget {
  final String? url;
  final double size;

  const _PerfumeImage({required this.url, required this.size});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: url == null || url!.isEmpty
            ? const Icon(Icons.local_florist, size: 40, color: EssenzaColors.ocean)
            : Image.network(
                url!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.local_florist, size: 40, color: EssenzaColors.ocean),
              ),
      );
}
