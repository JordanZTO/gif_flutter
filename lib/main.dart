import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/screens/random_gif_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _updateTheme(bool darkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', darkMode);
    setState(() => _isDarkMode = darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscador de GIFs Aleatórios',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: RandomGifPage(onThemeChanged: _updateTheme),
    );
  }
}
