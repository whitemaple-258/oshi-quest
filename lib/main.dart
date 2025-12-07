import 'package:flutter/material.dart';
import 'ui/screens/gacha_home_screen.dart';

void main() {
  runApp(const OshiGachaApp());
}

class OshiGachaApp extends StatelessWidget {
  const OshiGachaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OshiQuest Gacha Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        useMaterial3: true,
      ),
      home: const GachaHomeScreen(),
    );
  }
}
