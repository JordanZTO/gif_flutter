import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('gifHistory') ?? [];
    setState(() => _history = stored);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gifHistory');
    setState(() => _history = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de GIFs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: _history.isEmpty
          ? const Center(child: Text('Nenhum GIF no histórico ainda.'))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final gifUrl = _history[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(gifUrl, width: 60, height: 60),
                    title: Text('GIF ${index + 1}'),
                    onTap: () {
                      Navigator.pop(context, gifUrl);
                    },
                  ),
                );
              },
            ),
    );
  }
}
