import 'package:flutter/material.dart';

import '../catalog/data/catalog_repository.dart';
import '../catalog/models/perfume.dart';
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
        1 => CollectionView(repository: widget.repository),
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
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
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

  const CollectionView({super.key, required this.repository});

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
          onRefresh: () async => setState(() => _future = widget.repository.collection()),
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            children: items
                .map(
                  (perfume) => PerfumeTile(
                    perfume: perfume,
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () async {
                        await widget.repository.removeFromCollection(perfume.externalId);
                        if (mounted) setState(() => _future = widget.repository.collection());
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
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
                  if (perfume.gender != null) _InfoChip(icon: Icons.person_outline, text: perfume.gender!),
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
                  child: Text(perfume.notes.join('  •  ')),
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
