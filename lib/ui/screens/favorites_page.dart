import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  final List<String>? initialFavorites;
  const FavoritesPage({super.key, this.initialFavorites});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<String> _favorites;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _favorites = widget.initialFavorites ?? [];
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('gifFavorites') ?? [];
    setState(() {
      _favorites = saved;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final url = _favorites[index];

    setState(() => _favorites.removeAt(index));
    await prefs.setStringList('gifFavorites', _favorites);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removido dos favoritos: $url')),
    );
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gifFavorites');
    setState(() => _favorites.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todos os favoritos foram removidos')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Limpar todos',
              onPressed: _clearAll,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Salvar e voltar',
            onPressed: () {
              Navigator.pop(context, {'favorites': _favorites});
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum GIF favorito ainda.\nAdicione alguns na tela principal!',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final url = _favorites[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          url,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                        title: Text('GIF ${index + 1}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeFavorite(index),
                        ),
                        onTap: () {
                          Navigator.pop(context, {
                            'selected': url,
                            'favorites': _favorites,
                          });
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
