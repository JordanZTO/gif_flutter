import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _rating = 'g';
  String _language = 'pt';
  int _itemsPerPage = 3;
  bool _autoRefresh = false;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rating = prefs.getString('rating') ?? 'g';
      _language = prefs.getString('language') ?? 'pt';
      _itemsPerPage = prefs.getInt('itemsPerPage') ?? 3;
      _autoRefresh = prefs.getBool('autoRefresh') ?? false;
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rating', _rating);
    await prefs.setString('language', _language);
    await prefs.setInt('itemsPerPage', _itemsPerPage);
    await prefs.setBool('autoRefresh', _autoRefresh);
    await prefs.setBool('darkMode', _darkMode);

    Navigator.pop(context, {'darkMode': _darkMode});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Classificação de conteúdo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButtonFormField<String>(
            value: _rating,
            items: const [
              DropdownMenuItem(value: 'g', child: Text('Leve (Geral)')),
              DropdownMenuItem(value: 'pg', child: Text('Moderado')),
              DropdownMenuItem(value: 'pg-13', child: Text('Sensível')),
              DropdownMenuItem(value: 'r', child: Text('Altamente sensível')),
            ],
            onChanged: (v) => setState(() => _rating = v ?? 'g'),
          ),
          const SizedBox(height: 16),
          const Text('Idioma', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _language,
            items: const [
              DropdownMenuItem(value: 'pt', child: Text('Português')),
              DropdownMenuItem(value: 'en', child: Text('Inglês')),
              DropdownMenuItem(value: 'es', child: Text('Espanhol')),
              DropdownMenuItem(value: 'fr', child: Text('Francês')),
            ],
            onChanged: (v) => setState(() => _language = v ?? 'pt'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quantidade de GIFs exibidos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _itemsPerPage.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$_itemsPerPage',
            onChanged: (v) => setState(() => _itemsPerPage = v.toInt()),
          ),
          SwitchListTile(
            title: const Text('Atualização automática (autoplay)'),
            value: _autoRefresh,
            onChanged: (v) => setState(() => _autoRefresh = v),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Tema escuro'),
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _savePrefs,
            icon: const Icon(Icons.check),
            label: const Text('Salvar alterações'),
          ),
        ],
      ),
    );
  }
}
