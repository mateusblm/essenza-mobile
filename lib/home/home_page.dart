import 'package:flutter/material.dart';
import '../catalog/data/catalog_repository.dart';
import '../catalog/models/perfume.dart';
import '../diary/data/diary_repository.dart';
import '../diary/presentation/diary_page.dart';

class HomePage extends StatefulWidget {
  final CatalogRepository repository;
  final DiaryRepository diaryRepository;
  final Future<void> Function() onLogout;
  const HomePage({super.key, required this.repository, required this.diaryRepository, required this.onLogout});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Essenza'), actions: [IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout), tooltip: 'Sair')]),
    body: _tab == 0 ? SearchView(repository: widget.repository, diaryRepository: widget.diaryRepository) : _tab == 1 ? CollectionView(repository: widget.repository) : DiaryPage(repository: widget.diaryRepository),
    bottomNavigationBar: NavigationBar(selectedIndex: _tab, onDestinationSelected: (value) => setState(() => _tab = value), destinations: const [NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'), NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Coleção'), NavigationDestination(icon: Icon(Icons.history), label: 'Diário')]),
  );
}

class SearchView extends StatefulWidget {
  final CatalogRepository repository;
  final DiaryRepository diaryRepository;
  const SearchView({super.key, required this.repository, required this.diaryRepository});
  @override State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _query = TextEditingController();
  SearchResult? _result;
  bool _loading = false;
  String? _error;
  @override void dispose() { _query.dispose(); super.dispose(); }

  Future<void> _search() async {
    if (_query.text.trim().length < 2) { setState(() => _error = 'Digite ao menos 2 caracteres.'); return; }
    setState(() { _loading = true; _error = null; });
    try { _result = await widget.repository.search(_query.text.trim()); }
    catch (_) { _error = 'Não foi possível buscar perfumes agora.'; }
    if (mounted) setState(() => _loading = false);
  }

  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    TextField(controller: _query, textInputAction: TextInputAction.search, onSubmitted: (_) => _search(), decoration: InputDecoration(labelText: 'Buscar perfume ou marca', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: _search, icon: const Icon(Icons.arrow_forward)), border: const OutlineInputBorder())),
    if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
    if (_loading) const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
    if (!_loading && _result != null && _result!.items.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Nenhum perfume encontrado.')),
    if (!_loading && _result != null) Expanded(child: ListView.builder(itemCount: _result!.items.length, itemBuilder: (_, index) => PerfumeTile(perfume: _result!.items[index], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PerfumeDetailsPage(repository: widget.repository, diaryRepository: widget.diaryRepository, perfume: _result!.items[index])))))),
  ]));
}

class CollectionView extends StatefulWidget {
  final CatalogRepository repository;
  const CollectionView({super.key, required this.repository});
  @override State<CollectionView> createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView> {
  late Future<List<Perfume>> _future;
  @override void initState() { super.initState(); _future = widget.repository.collection(); }
  @override Widget build(BuildContext context) => FutureBuilder<List<Perfume>>(future: _future, builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
    if (snapshot.hasError) return Center(child: FilledButton(onPressed: () => setState(() => _future = widget.repository.collection()), child: const Text('Tentar novamente')));
    final items = snapshot.data ?? [];
    if (items.isEmpty) return const Center(child: Text('Sua coleção ainda está vazia.'));
    return RefreshIndicator(onRefresh: () async => setState(() => _future = widget.repository.collection()), child: ListView(children: items.map((perfume) => PerfumeTile(perfume: perfume, trailing: IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () async { await widget.repository.removeFromCollection(perfume.externalId); if (mounted) setState(() => _future = widget.repository.collection()); }))).toList()));
  });
}

class PerfumeTile extends StatelessWidget {
  final Perfume perfume;
  final VoidCallback? onTap;
  final Widget? trailing;
  const PerfumeTile({super.key, required this.perfume, this.onTap, this.trailing});
  @override Widget build(BuildContext context) => ListTile(onTap: onTap, leading: _PerfumeImage(url: perfume.imageUrl, size: 56), title: Text(perfume.name), subtitle: Text(perfume.brand ?? 'Marca não informada'), trailing: trailing ?? const Icon(Icons.chevron_right));
}

class PerfumeDetailsPage extends StatefulWidget {
  final CatalogRepository repository;
  final DiaryRepository diaryRepository;
  final Perfume perfume;
  const PerfumeDetailsPage({super.key, required this.repository, required this.diaryRepository, required this.perfume});
  @override State<PerfumeDetailsPage> createState() => _PerfumeDetailsPageState();
}

class _PerfumeDetailsPageState extends State<PerfumeDetailsPage> {
  late Future<Perfume> _future;
  bool _saving = false;
  @override void initState() { super.initState(); _future = widget.repository.details(widget.perfume.externalId); }
  Future<void> _add(Perfume perfume) async { setState(() => _saving = true); try { await widget.repository.addToCollection(perfume.externalId); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicionado à coleção.'))); } catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível adicionar.'))); } finally { if (mounted) setState(() => _saving = false); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.perfume.name)), body: FutureBuilder<Perfume>(future: _future, builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
    final perfume = snapshot.data ?? widget.perfume;
    return ListView(padding: const EdgeInsets.all(20), children: [_PerfumeImage(url: perfume.imageUrl, size: 220), const SizedBox(height: 20), Text(perfume.name, style: Theme.of(context).textTheme.headlineSmall), Text(perfume.brand ?? 'Marca não informada'), if (perfume.rating != null) Text('Avaliação: ${perfume.rating}'), if (perfume.releaseYear != null) Text('Ano: ${perfume.releaseYear}'), if (perfume.notes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 16), child: Text('Notas: ${perfume.notes.join(', ')}')), const SizedBox(height: 24), FilledButton.icon(onPressed: _saving ? null : () => _add(perfume), icon: const Icon(Icons.favorite), label: Text(_saving ? 'Salvando...' : 'Adicionar à coleção')), const SizedBox(height: 12), OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryFormPage(repository: widget.diaryRepository, perfume: perfume)),), icon: const Icon(Icons.history), label: const Text('Registrar uso'))]);
  }));
}

class _PerfumeImage extends StatelessWidget {
  final String? url;
  final double size;
  const _PerfumeImage({required this.url, required this.size});
  @override Widget build(BuildContext context) => SizedBox(width: size, height: size, child: url == null || url!.isEmpty ? const Icon(Icons.local_florist, size: 40) : Image.network(url!, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_florist, size: 40)));
}
