import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../widgets/sparkle_effect_overlay.dart';
import 'gacha_result_screen.dart';
import '../../data/extensions/gacha_item_extension.dart';

class GachaSequenceScreen extends StatefulWidget {
  final List<GachaItem> items;

  const GachaSequenceScreen({super.key, required this.items});

  @override
  State<GachaSequenceScreen> createState() => _GachaSequenceScreenState();
}

class _GachaSequenceScreenState extends State<GachaSequenceScreen> {
  int _currentIndex = 0;
  bool _isFinished = false;

  void _next() {
    if (_currentIndex < widget.items.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _finish();
    }
  }

  void _finish() {
    if (_isFinished) return;
    _isFinished = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GachaResultScreen(results: widget.items)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.items[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _next,
            behavior: HitTestBehavior.opaque,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildSingleResultView(currentItem),
            ),
          ),
          // カウンター
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.items.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // スキップボタン
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _finish,
              icon: const Icon(Icons.fast_forward, size: 18),
              label: const Text('SKIP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          // 案内
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Tap to Next',
                style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleResultView(GachaItem item) {
    final isSSR = item.rarity == Rarity.ssr;
    final isSR = item.rarity == Rarity.sr;

    // 枠線の色
    Color borderColor;
    if (isSSR) {
      borderColor = const Color(0xFFFFD700); // Gold
    } else if (isSR) {
      borderColor = Colors.purpleAccent;     // Purple
    } else if (item.rarity == Rarity.r) {
      borderColor = Colors.blueAccent;
    } else {
      borderColor = Colors.grey;
    }

    return Container(
      key: ValueKey(item.id),
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // タイトル演出
              if (isSSR)
                const Text('✨ SSR ✨', style: TextStyle(color: Color(0xFFFFD700), fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4, shadows: [Shadow(color: Colors.orange, blurRadius: 10)]))
              else if (isSR)
                const Text('✨ SR ✨', style: TextStyle(color: Colors.purpleAccent, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2, shadows: [Shadow(color: Colors.purple, blurRadius: 10)])),
              
              const SizedBox(height: 20),

              // キャラカード
              Container(
                width: 300,
                height: 533,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(image: item.displayImageProvider, fit: BoxFit.cover),
                      if (item.effectType != EffectType.none)
                        SparkleEffectOverlay(effectType: item.effectType),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // レアリティバッジ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.rarity.name.toUpperCase(),
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}