import 'package:flutter/material.dart';
// import 'dart:io'; // ✅ Fileを直接使わなくなったので不要ですが、残しておいても害はありません
import '../../data/database/database.dart';
import '../widgets/sparkle_effect_overlay.dart';
import 'character_detail_screen.dart';
import '../../data/extensions/gacha_item_extension.dart'; // ✅ これが重要です

class GachaResultScreen extends StatelessWidget {
  final List<GachaItem> results;

  const GachaResultScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final isSingleResult = results.length == 1;

    return Scaffold(
      backgroundColor: const Color(0xFF2A1A3E),
      appBar: AppBar(
        title: const Text('召喚結果'),
        backgroundColor: Colors.black54,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isSingleResult ? _buildSingleLayout(context) : _buildGridLayout(context),
            ),
            _buildBottomButtonArea(context),
          ],
        ),
      ),
    );
  }

  // --- レイアウト構築メソッド ---

  Widget _buildSingleLayout(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: _buildLargeResultCard(context, results.first),
        ),
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: results.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return _buildSmallResultCard(context, results[index], index);
        },
      ),
    );
  }

  Widget _buildBottomButtonArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.black54,
        border: Border(top: BorderSide(color: Colors.white24)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Text('閉じる'),
        ),
      ),
    );
  }

  // --- カードビルダ ---

  // 1. 単発用の大きなカード
  Widget _buildLargeResultCard(BuildContext context, GachaItem item) {
    final colors = _getRarityColors(item.rarity);
    final baseColor = colors.base;
    final gradient = colors.gradient;
    final isSSR = item.rarity == Rarity.ssr;

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: isSSR ? null : Border.all(color: baseColor, width: 4),
        boxShadow: [BoxShadow(color: baseColor.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: item.displayImageProvider, // ここで自動判別
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
            ),

            if (item.effectType != EffectType.none)
              SparkleEffectOverlay(effectType: item.effectType),

            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSSR ? null : baseColor,
                  gradient: gradient,
                  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                ),
                child: Text(
                  item.rarity.name.toUpperCase(),
                  style: TextStyle(
                    color: item.rarity == Rarity.n ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.black87,
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isSSR && gradient != null) {
      cardContent = Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: gradient),
        child: cardContent,
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CharacterDetailScreen.single(item: item)),
        );
      },
      child: cardContent,
    );
  }

  // 2. グリッド用の小さなカード
  Widget _buildSmallResultCard(BuildContext context, GachaItem item, int index) {
    final colors = _getRarityColors(item.rarity);
    final baseColor = colors.base;
    final gradient = colors.gradient;
    final isSSR = item.rarity == Rarity.ssr;

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: isSSR ? null : Border.all(color: baseColor, width: 3),
        boxShadow: [BoxShadow(color: baseColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: item.displayImageProvider, // ここで自動判別
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
            ),

            if (item.effectType != EffectType.none)
              SparkleEffectOverlay(effectType: item.effectType),

            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSSR ? null : baseColor,
                  gradient: gradient,
                  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                ),
                child: Text(
                  item.rarity.name.toUpperCase(),
                  style: TextStyle(
                    color: item.rarity == Rarity.n ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                color: Colors.black87,
                child: Text(
                  item.title,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isSSR && gradient != null) {
      cardContent = Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), gradient: gradient),
        child: cardContent,
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CharacterDetailScreen(items: results, initialIndex: index),
          ),
        );
      },
      child: cardContent,
    );
  }

  // --- ヘルパー ---

  ({Color base, LinearGradient? gradient}) _getRarityColors(Rarity rarity) {
    Color base;
    LinearGradient? gradient;

    switch (rarity) {
      case Rarity.ssr:
        base = const Color(0xFFFFD700);
        gradient = const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFC107), Color(0xFFFFF176), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case Rarity.sr:
        base = Colors.purpleAccent;
        break;
      case Rarity.r:
        base = Colors.blueAccent;
        break;
      case Rarity.n:
        base = Colors.grey;
        break;
    }
    return (base: base, gradient: gradient);
  }
}
