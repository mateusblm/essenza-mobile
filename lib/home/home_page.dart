import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../catalog/data/catalog_repository.dart';
import '../catalog/models/perfume.dart';
import '../catalog/models/collection_insights.dart';
import '../catalog/presentation/catalog_labels.dart';
import '../core/theme/app_theme.dart';
import '../diary/data/diary_repository.dart';
import '../diary/presentation/diary_page.dart';
import '../auth/models/user.dart';

class HomePage extends StatefulWidget {
  final CatalogRepository repository;
  final DiaryRepository diaryRepository;
  final User? user;
  final Future<void> Function() onLogout;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const HomePage({
    super.key,
    required this.repository,
    required this.diaryRepository,
    this.user,
    required this.onLogout,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_tab) {
        0 => _DashboardView(
          repository: widget.repository,
          user: widget.user,
          onExplore: () => setState(() => _tab = 1),
          onProfile: () => setState(() => _tab = 4),
        ),
        1 => SearchView(
          repository: widget.repository,
          diaryRepository: widget.diaryRepository,
        ),
        2 => CollectionView(
          repository: widget.repository,
          diaryRepository: widget.diaryRepository,
        ),
        3 => const _WishlistView(),
        _ => _ProfileView(
          repository: widget.repository,
          user: widget.user,
          onLogout: widget.onLogout,
          themeMode: widget.themeMode,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_mosaic_outlined),
            selectedIcon: Icon(Icons.auto_awesome_mosaic),
            label: 'Coleção',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends StatefulWidget {
  final CatalogRepository repository;
  final User? user;
  final VoidCallback onExplore;
  final VoidCallback onProfile;
  const _DashboardView({required this.repository, this.user, required this.onExplore, required this.onProfile});
  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  late Future<CollectionInsights> _future;
  @override
  void initState() {
    super.initState();
    _future = widget.repository.collectionInsights();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: FutureBuilder<CollectionInsights>(
      future: _future,
      builder: (context, snapshot) {
        final insights = snapshot.data;
        final profile =
            insights?.olfactiveProfile ?? const <CollectionInsightScore>[];
        return RefreshIndicator(
          onRefresh: () async {
            final next = widget.repository.collectionInsights();
            setState(() => _future = next);
            await next;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Boa noite${widget.user?.name == null ? '' : ', ${widget.user!.name.split(' ').first}'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sua coleção',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${insights?.perfumeCount ?? 0} perfumes · uma assinatura só sua',
              ),
              const SizedBox(height: 24),
              _DnaCard(
                profile: profile,
                loading: snapshot.connectionState == ConnectionState.waiting,
                onIdentityTap: widget.onProfile,
              ),
              const SizedBox(height: 16),
              _CoverageCard(
                insights: insights,
                onExplore: widget.onExplore,
              ),
              const SizedBox(height: 26),
              _SectionHeader(
                title: 'Escolhidos para você',
                action: 'Ver todos',
                onTap: widget.onExplore,
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 220,
                child: insights == null || insights.recommendations.isEmpty
                    ? const _EmptyState(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Ainda sem recomendações',
                        message: 'Adicione perfumes para receber sugestões personalizadas.',
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: insights.recommendations.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, index) => _RecommendationPreview(
                          name: insights.recommendations[index],
                          tag: 'Recomendado para você',
                          icon: Icons.water_drop_outlined,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _DnaCard extends StatelessWidget {
  final List<CollectionInsightScore> profile;
  final bool loading;
  final VoidCallback onIdentityTap;
  const _DnaCard({required this.profile, required this.loading, required this.onIdentityTap});
  @override
  Widget build(BuildContext context) {
    final fallback = const [
      ('Amadeirado', 24.0),
      ('Aromático', 21.0),
      ('Doce', 17.0),
      ('Especiado', 13.0),
      ('Âmbar', 11.0),
    ];
    final available = profile.where((item) => item.percentage > 0).toList();
    final values = available.isEmpty
        ? fallback
        : available.take(5).map((e) => (e.label, e.percentage)).toList();
    final topLabels = values.take(3).map((item) => item.$1).join(' · ');
    final highest = values.fold<double>(
      1,
      (value, item) => math.max(value, item.$2),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seu DNA Olfativo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text(
              topLabels.isEmpty ? 'Seu perfil está sendo analisado' : topLabels,
              style: TextStyle(
                fontFamily: 'serif',
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 20),
            if (loading)
              const LinearProgressIndicator()
            else
              ...values.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (.25 + ((item.$2 / highest) * .75))
                              .clamp(.25, 1),
                          child: Container(
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _accordColor(item.$1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _accordTextColor(item.$1),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      SizedBox(
                        width: 34,
                        child: Text(
                          '${item.$2.round()}%',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              values.isEmpty
                  ? 'Adicione perfumes para descobrir seu DNA olfativo.'
                  : 'Sua coleção possui maior presença em ${values.first.$1.toLowerCase()}.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onIdentityTap,
              child: const Text('Ver sua identidade'),
            ),
          ],
        ),
      ),
    );
  }

  Color _accordColor(String accord) {
    final name = accord.toLowerCase();
    if (name.contains('amadeir') || name.contains('woody')) {
      return const Color(0xFF9B6B43);
    }
    if (name.contains('arom')) return const Color(0xFF72927B);
    if (name.contains('cítric') || name.contains('citrus')) {
      return const Color(0xFFE3C35C);
    }
    if (name.contains('doce') || name.contains('sweet')) {
      return const Color(0xFFD88A91);
    }
    if (name.contains('espec') || name.contains('spicy')) {
      return const Color(0xFFB85E46);
    }
    if (name.contains('âmbar') || name.contains('amber')) {
      return const Color(0xFFC68A3D);
    }
    if (name.contains('floral')) return const Color(0xFFC996A5);
    if (name.contains('fresco') || name.contains('fresh')) {
      return const Color(0xFF82B7AE);
    }
    return EssenzaColors.backgroundMuted;
  }

  Color _accordTextColor(String accord) {
    final color = _accordColor(accord);
    return color.computeLuminance() > .58 ? EssenzaColors.ink : Colors.white;
  }
}

class _CoverageCard extends StatelessWidget {
  final CollectionInsights? insights;
  final VoidCallback onExplore;
  const _CoverageCard({required this.insights, required this.onExplore});

  int get _coverageScore {
    final climates = insights?.climates ?? const <CollectionInsightScore>[];
    if (climates.isEmpty) return 0;
    return (climates.map((e) => e.percentage).reduce((a, b) => a + b) /
            climates.length)
        .round()
        .clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cobertura da coleção',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    const Text('Coleção bastante versátil'),
                  ],
                ),
              ),
              Text(
                _coverageScore.toString(),
                style: TextStyle(
                  fontFamily: 'serif',
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 36,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text('/100'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...?insights?.climates.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(e.label, style: const TextStyle(fontSize: 13)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (e.percentage / 100).clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 28),
          Text(
            'PRINCIPAL OPORTUNIDADE',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (insights?.recommendations.isNotEmpty ?? false)
                ? insights!.recommendations.first
                : 'Adicione mais perfumes para gerar recomendações.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onExplore,
            child: const Text('Ver recomendações'),
          ),
        ],
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title, action;
  final VoidCallback onTap;
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      TextButton(onPressed: onTap, child: Text(action)),
    ],
  );
}

class _RecommendationPreview extends StatelessWidget {
  final String name, tag;
  final IconData icon;
  const _RecommendationPreview({
    required this.name,
    required this.tag,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: 160,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(child: Icon(icon, color: EssenzaColors.gold, size: 46)),
        ),
        Text(
          name,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          tag,
          style: const TextStyle(
            color: EssenzaColors.success,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
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
        if (mounted && _query.text.trim() == query) {
          setState(() => _suggestions = result);
        }
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descobrir', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 6),
            const Text('Perfumes escolhidos para o seu gosto e sua coleção.'),
            const SizedBox(height: 20),
            TextField(
              controller: _query,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Buscar perfume, marca ou nota',
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
                          leading: const Icon(
                            Icons.history,
                            color: EssenzaColors.deepOcean,
                          ),
                          title: Text(perfume.name),
                          subtitle: Text(
                            perfume.brand ?? 'Marca não informada',
                          ),
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
                  message:
                      'Busque uma fragrância para conhecer suas notas e registrar sua experiência.',
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
      ),
    );
  }

}

class CollectionView extends StatefulWidget {
  final CatalogRepository repository;
  final DiaryRepository diaryRepository;

  const CollectionView({
    super.key,
    required this.repository,
    required this.diaryRepository,
  });

  @override
  State<CollectionView> createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView> {
  late Future<_CollectionData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CollectionData> _load() async {
    final results = await Future.wait([
      widget.repository.collection(),
      widget.repository.collectionInsights(),
    ]);
    return _CollectionData(
      results[0] as List<Perfume>,
      results[1] as CollectionInsights,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CollectionData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton(
              onPressed: () => setState(() => _future = _load()),
              child: const Text('Tentar novamente'),
            ),
          );
        }
        final data = snapshot.data;
        final items = data?.perfumes ?? <Perfume>[];
        if (items.isEmpty) {
          return const _EmptyState(
            icon: Icons.favorite_outline,
            title: 'Sua coleção está vazia',
            message: 'Salve perfumes para criar sua seleção pessoal.',
          );
        }
        return RefreshIndicator(
          onRefresh: () {
            final future = _load();
            setState(() => _future = future);
            return future.then((_) {});
          },
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            children: [
              _CollectionProfile(insights: data!.insights),
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
                            const SnackBar(
                              content: Text('Experiencia registrada.'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Remover da colecao',
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () async {
                          await widget.repository.removeFromCollection(
                            perfume.externalId,
                          );
                          if (mounted) setState(() => _future = _load());
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

class _CollectionData {
  final List<Perfume> perfumes;
  final CollectionInsights insights;

  const _CollectionData(this.perfumes, this.insights);
}

class _CollectionProfile extends StatelessWidget {
  final CollectionInsights insights;

  const _CollectionProfile({required this.insights});

  @override
  Widget build(BuildContext context) {
    final familyValues = insights.olfactiveProfile
        .map((item) => item.percentage / 100)
        .toList();
    final topFamilies = [...insights.olfactiveProfile]
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

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
                Text(
                  'Seu perfil olfativo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
                      values: familyValues,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: topFamilies.take(3).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${item.label}  ${item.percentage.round()}%',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Climas que combinam com sua coleção',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...insights.climates.map(
              (item) =>
                  _ProfileBar(label: item.label, value: item.percentage / 100),
            ),
            const SizedBox(height: 8),
            if (insights.occasions.isNotEmpty) ...[
              Text(
                'Momentos prováveis',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: insights.occasions
                    .map((item) => Chip(label: Text(item)))
                    .toList(),
              ),
            ],
            if (insights.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...insights.recommendations.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $item'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              minHeight: 9,
            ),
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(' ${(value * 100).round()}%', textAlign: TextAlign.end),
        ),
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
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.withValues(alpha: 0.22);
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.28);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;
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
      valuePoints.add(
        center +
            Offset(math.cos(angle), math.sin(angle)) *
                radius *
                values[i].clamp(0.08, 1),
      );
    }
    final valuePath = Path()..addPolygon(valuePoints, true);
    canvas.drawPath(valuePath, fill);
    canvas.drawPath(valuePath, outline);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class PerfumeTile extends StatelessWidget {
  final Perfume perfume;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PerfumeTile({
    super.key,
    required this.perfume,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _PerfumeImage(url: perfume.imageUrl, size: 56),
        title: Text(
          perfume.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
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
        setState(
          () => _inCollection = collection.any(
            (item) => item.externalId == widget.perfume.externalId,
          ),
        );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Adicionado à coleção.')));
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
                  child: Center(
                    child: _PerfumeImage(url: perfume.imageUrl, size: 220),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                perfume.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(perfume.brand ?? 'Marca não informada'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (perfume.rating != null)
                    _InfoChip(
                      icon: Icons.star_outline,
                      text: '${perfume.rating}',
                    ),
                  if (perfume.releaseYear != null)
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      text: '${perfume.releaseYear}',
                    ),
                  if (perfume.gender != null)
                    _InfoChip(
                      icon: Icons.person_outline,
                      text: perfumeLabel(perfume.gender),
                    ),
                  if (perfume.oilType != null)
                    _InfoChip(
                      icon: Icons.water_drop_outlined,
                      text: perfumeLabel(perfume.oilType),
                    ),
                  if (perfume.longevity != null)
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      text: 'Duração: ${perfumeLabel(perfume.longevity)}',
                    ),
                  if (perfume.sillage != null)
                    _InfoChip(
                      icon: Icons.air,
                      text: 'Projeção: ${perfumeLabel(perfume.sillage)}',
                    ),
                ],
              ),
              if (perfume.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: Text(
                    'Notas olfativas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              if (perfume.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(perfume.notes.map(perfumeLabel).join('  •  ')),
                ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _saving || _inCollection
                    ? null
                    : () => _add(perfume),
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

class _WishlistView extends StatelessWidget {
  const _WishlistView();
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: [
        Text(
          'Quero experimentar',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        const Text('Perfumes que podem ser sua próxima assinatura.'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MELHOR PRÓXIMA COMPRA',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 11,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Versace Pour Homme',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'É o perfume da sua wishlist que mais aumenta a versatilidade da sua coleção.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: .7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...const [
          ('Acqua di Giò', 'Giorgio Armani', 94, 72),
          ('Dylan Blue', 'Versace', 86, 81),
          ('Bleu de Chanel', 'Chanel', 91, 67),
        ].map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.water_drop_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.$2,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            p.$1,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniMetric(
                                  label: 'Compatibilidade',
                                  value: '${p.$3}%',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MiniMetric(
                                  label: 'Valor coleção',
                                  value: '${p.$4}%',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.favorite,
                      color: Theme.of(context).colorScheme.primary,
                      size: 21,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _MiniMetric extends StatelessWidget {
  final String label, value;
  const _MiniMetric({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _ProfileView extends StatefulWidget {
  final CatalogRepository repository;
  final User? user;
  final Future<void> Function() onLogout;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const _ProfileView({
    required this.repository,
    this.user,
    required this.onLogout,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  late Future<CollectionInsights> _insights;

  @override
  void initState() {
    super.initState();
    _insights = widget.repository.collectionInsights();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Perfil',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            _ThemeToggle(
              dark: widget.themeMode == ThemeMode.dark,
              onPressed: () => widget.onThemeModeChanged(
                widget.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.person_outline,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user?.name ?? 'Seu perfil',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(widget.user?.email ?? 'Sua coleção pessoal'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfileStat('17', 'perfumes'),
              _ProfileStat('8', 'favoritos'),
              _ProfileStat('13', 'wishlist'),
            ],
          ),
        ),
        const SizedBox(height: 22),
        FutureBuilder<CollectionInsights>(
          future: _insights,
          builder: (context, snapshot) => _ProfileIdentityCard(
            insights: snapshot.data,
            loading: snapshot.connectionState == ConnectionState.waiting,
          ),
        ),
        const SizedBox(height: 18),
        ...const [
          (Icons.tune, 'Preferências olfativas'),
          (Icons.history_outlined, 'Diário de perfumes'),
          (Icons.bar_chart_outlined, 'Estatísticas'),
          (Icons.person_outline, 'Minha conta'),
          (Icons.settings_outlined, 'Configurações'),
          (Icons.shield_outlined, 'Privacidade'),
          (Icons.info_outline, 'Sobre o Essenza'),
        ].map(
          (item) => ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 3,
            ),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                item.$1,
                color: Theme.of(context).colorScheme.primary,
                size: 21,
              ),
            ),
            title: Text(
              item.$2,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Sair da conta'),
        ),
      ],
    ),
  );
}

class _ThemeToggle extends StatelessWidget {
  final bool dark;
  final VoidCallback onPressed;

  const _ThemeToggle({required this.dark, required this.onPressed});

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          dark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
      ),
    ),
  );
}

class _ProfileIdentityCard extends StatelessWidget {
  final CollectionInsights? insights;
  final bool loading;

  const _ProfileIdentityCard({required this.insights, required this.loading});

  @override
  Widget build(BuildContext context) {
    final profile = insights?.olfactiveProfile ?? const <CollectionInsightScore>[];
    final dominant = profile.isEmpty ? null : profile.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sua identidade olfativa',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            if (loading)
              const LinearProgressIndicator()
            else if (dominant == null)
              Text(
                'Adicione perfumes para descobrir sua identidade.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              Text(
                _identityTitle(dominant.label),
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 21,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _identityDescription(dominant.label),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              if (insights!.climates.isNotEmpty)
                _IdentityDetail(
                  label: 'Combina com',
                  value: insights!.climates.take(2).map((item) => item.label).join(' · '),
                ),
              if (insights!.occasions.isNotEmpty)
                _IdentityDetail(
                  label: 'Para',
                  value: insights!.occasions.take(3).join(' · '),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _identityTitle(String label) {
    final value = label.toLowerCase();
    if (value.contains('amadeir')) return 'Elegante e amadeirada';
    if (value.contains('floral')) return 'Delicada e floral';
    if (value.contains('fresco')) return 'Leve e refrescante';
    if (value.contains('doce')) return 'Envolvente e doce';
    if (value.contains('oriental')) return 'Marcante e oriental';
    return 'Com presença ${label.toLowerCase()}';
  }

  String _identityDescription(String label) {
    final value = label.toLowerCase();
    if (value.contains('amadeir')) return 'Você prefere fragrâncias sofisticadas e marcantes.';
    if (value.contains('floral')) return 'Você prefere fragrâncias delicadas e expressivas.';
    if (value.contains('fresco')) return 'Você prefere fragrâncias leves e versáteis.';
    if (value.contains('doce')) return 'Você prefere fragrâncias quentes e envolventes.';
    if (value.contains('oriental')) return 'Você prefere fragrâncias intensas e memoráveis.';
    return 'Sua coleção revela um estilo ${label.toLowerCase()}.';
  }
}

class _IdentityDetail extends StatelessWidget {
  final String label;
  final String value;

  const _IdentityDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  const _ProfileStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 25,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.hasBoundedHeight && constraints.maxHeight < 150;
      final theme = Theme.of(context).textTheme;
      final content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 28 : 48, color: EssenzaColors.ocean),
          SizedBox(height: compact ? 4 : 16),
          Text(
            title,
            maxLines: compact ? 1 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
            textAlign: TextAlign.center,
            style: compact ? theme.titleMedium : theme.titleLarge,
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            message,
            maxLines: compact ? 2 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
            textAlign: TextAlign.center,
            style: compact ? theme.bodySmall : null,
          ),
        ],
      );
      return Center(
        child: compact
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: constraints.maxWidth - 32,
                  child: content,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(32),
                child: content,
              ),
      );
    },
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
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.local_florist,
              size: 40,
              color: EssenzaColors.ocean,
            ),
          ),
  );
}
