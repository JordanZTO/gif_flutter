import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../repository/gif_repository.dart';
import 'settings_page.dart';
import 'favorites_page.dart';
import 'history_page.dart';

class RandomGifPage extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  const RandomGifPage({super.key, this.onThemeChanged});

  @override
  State<RandomGifPage> createState() => _RandomGifPageState();
}

class _RandomGifPageState extends State<RandomGifPage> {
  final GifRepository _repository = GifRepository();
  final TextEditingController _tagController = TextEditingController();

  List<Map<String, dynamic>> _gifList = [];
  List<String> _favorites = [];
  String _rating = 'g';
  String _language = 'pt';
  int _itemsPerPage = 3;
  bool _autoRefresh = false;
  bool _isLoading = false;
  bool _hasError = false;

  Timer? _timer;
  Timer? _debounce;
  String? _randomId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    await _initRandomId();
    await _loadPreferences();
    await _loadFavorites();
    if (_autoRefresh) _startAutoRefresh();
    _fetchRandomGifs();
  }

  Future<void> _initRandomId() async {
    final id = await _repository.getRandomId();
    setState(() => _randomId = id);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rating = prefs.getString('rating') ?? 'g';
      _language = prefs.getString('language') ?? 'pt';
      _itemsPerPage = prefs.getInt('itemsPerPage') ?? 3;
      _autoRefresh = prefs.getBool('autoRefresh') ?? false;
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('gifFavorites') ?? [];
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('gifFavorites', _favorites);
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_autoRefresh) _fetchRandomGifs();
    });
  }

  Future<void> _fetchRandomGifs() async {
    if (_randomId == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final gifs = <Map<String, dynamic>>[];

      for (int i = 0; i < _itemsPerPage; i++) {
        final data = await _repository.getRandomGif(
          tag: _tagController.text.trim(),
          rating: _rating,
          randomId: _randomId!,
          language: _language,
        );

        if (data != null) {
          gifs.add(data);
          await _addToHistory(
            data['images']?['downsized_large']?['url'] ?? '',
          );
        }
      }

      setState(() => _gifList = gifs);
    } catch (e) {
      setState(() => _hasError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToHistory(String gifUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('gifHistory') ?? [];
    history.remove(gifUrl);
    history.insert(0, gifUrl);
    if (history.length > 5) history.removeRange(5, history.length);
    await prefs.setStringList('gifHistory', history);
  }

  Future<void> _toggleFavorite(String url) async {
    setState(() {
      if (_favorites.contains(url)) {
        _favorites.remove(url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removido dos favoritos')),
        );
      } else {
        _favorites.insert(0, url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicionado aos favoritos!')),
        );
      }
    });
    await _saveFavorites();
  }

  bool _isFavorite(String url) => _favorites.contains(url);

  void _onTagChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _fetchRandomGifs();
    });
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );

    if (result is Map) {
      await _loadPreferences();
      if (result.containsKey('darkMode')) {
        widget.onThemeChanged?.call(result['darkMode']);
      }
    }
  }

  Future<void> _openHistory() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryPage()),
    );

    if (selected != null && selected is String) {
      setState(() => _gifList = [
            {'images': {'downsized_large': {'url': selected}}}
          ]);
    }
  }

Future<void> _openFavorites() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const FavoritesPage()),
  );

  if (result is Map && result.containsKey('favorites')) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('gifFavorites', List<String>.from(result['favorites']));
    setState(() {});
  }
}

  @override
  void dispose() {
    _timer?.cancel();
    _debounce?.cancel();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIFs Aleatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver histórico',
            onPressed: _openHistory,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favoritos',
            onPressed: _openFavorites,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRandomGifs,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: 'Buscar por tag',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _tagController.clear();
                      _fetchRandomGifs();
                    },
                  ),
                ),
                onChanged: _onTagChanged,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? const Center(
                          child: Text(
                            'Erro ao carregar GIFs. Verifique sua conexão.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _gifList.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum GIF carregado ainda.\nToque no botão abaixo!',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: _gifList.length,
                              itemBuilder: (context, index) {
                                final gif = _gifList[index];
                                final url = gif['images']?['downsized_large']?['url'];
                                if (url == null) {
                                  return const Card(
                                    elevation: 3,
                                    child: Icon(Icons.image_not_supported),
                                  );
                                }
                                return Card(
                                  elevation: 3,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.network(url, fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: IconButton(
                                          icon: Icon(
                                            _isFavorite(url)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () => _toggleFavorite(url),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchRandomGifs,
        icon: const Icon(Icons.casino),
        label: const Text('Novos GIFs'),
      ),
    );
  }
}
