// app/lib/app.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/chat_screen.dart';

class FikirSignApp extends StatefulWidget {
  const FikirSignApp({super.key});

  @override
  State<FikirSignApp> createState() => _FikirSignAppState();
}

class _FikirSignAppState extends State<FikirSignApp> {
  // Default to Dark Mode (Obsidian Black with Light Orange / Olive accents)
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fikir Signs — EthSL AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      // Open straight into the AI Chat translation screen!
      home: const ChatScreen(),
    );
  }
}