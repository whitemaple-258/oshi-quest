import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: OshiQuestApp()));
}

class OshiQuestApp extends StatelessWidget {
  const OshiQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OshiQuest',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}