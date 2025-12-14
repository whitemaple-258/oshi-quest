import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../widgets/sparkle_effect_overlay.dart'; // エフェクト用

class CharacterDetailScreen extends StatefulWidget {
  final List<GachaItem> items;
  final int initialIndex;

  // ✅ 追加: 単体表示用のコンストラクタ (これが不足していました)
  CharacterDetailScreen.single({super.key, required GachaItem item})
    : items = [item],
      initialIndex = 0;

  // 通常のコンストラクタ (リスト表示用)
  const CharacterDetailScreen({super.key, required this.items, required this.initialIndex});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 現在表示中のアイテム
    final currentItem = widget.items[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // 全体の背景色
      appBar: AppBar(
        // リスト表示のときは "1 / 10" のようにカウントを表示
        title: widget.items.length > 1
            ? Text('${_currentIndex + 1} / ${widget.items.length}')
            : Text(currentItem.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      // ✅ PageViewでスワイプ切り替え可能に
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return _buildCharacterPage(widget.items[index]);
        },
      ),
    );
  }

  Widget _buildCharacterPage(GachaItem item) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- キャラ画像 (アスペクト比固定・余白なし・全体枠線) ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: _getRarityColor(item.rarity), width: 4),
            ),
            child: AspectRatio(
              aspectRatio: 9 / 16, // ガチャのトリミング比率に合わせる
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. 画像
                  Image.file(
                    File(item.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey)),
                  ),

                  // 2. エフェクト (画像の上に重ねる)
                  SparkleEffectOverlay(effectType: item.effectType),
                ],
              ),
            ),
          ),

          // --- 詳細情報エリア ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 名前
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // --- 基本情報 ---
                _buildInfoCard('基本情報', [
                  _buildRow('レアリティ', item.rarity.name.toUpperCase()),
                  _buildRow('Bond Level', '${item.bondLevel}'),
                  _buildRow('エフェクト', _getEffectName(item.effectType)),
                ], Colors.blueGrey),
                const SizedBox(height: 12),

                // --- ステータス補正 ---
                _buildInfoCard('ステータス補正', [
                  _buildRow('STR (筋力)', '+${item.strBonus}', color: Colors.redAccent),
                  _buildRow('INT (知力)', '+${item.intBonus}', color: Colors.blueAccent),
                  _buildRow('VIT (体力)', '+${item.vitBonus}', color: Colors.green),
                  _buildRow('LUK (幸運)', '+${item.luckBonus}', color: Colors.purpleAccent),
                  _buildRow('CHA (魅力)', '+${item.chaBonus}', color: Colors.pinkAccent),
                ], Colors.indigo),
                const SizedBox(height: 12),

                // --- スキル情報 ---
                if (item.skillType != SkillType.none)
                  _buildInfoCard('保有スキル', [
                    _buildRow('スキル名', _getSkillName(item.skillType)),
                    _buildRow('効果', _getSkillEffect(item.skillType, item.skillValue)),
                    _buildRow('効果時間', '${item.skillDuration ~/ 60}分'),
                    _buildRow('クールタイム', '${item.skillCooldown ~/ 60}分'),
                  ], Colors.orange),

                if (item.skillType != SkillType.none) const SizedBox(height: 12),

                // --- シリーズ情報 ---
                if (item.seriesId != SeriesType.none)
                  _buildInfoCard('シリーズ装備', [
                    _buildRow('シリーズ名', _getSeriesName(item.seriesId)),
                    const Text(
                      '※同じシリーズを揃えると追加ボーナスが発生します',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ], Colors.teal),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildInfoCard(String title, List<Widget> children, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.white),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.n:
        return Colors.grey;
      case Rarity.r:
        return Colors.blue;
      case Rarity.sr:
        return Colors.purple;
      case Rarity.ssr:
        return Colors.amber;
    }
  }

  String _getSkillName(SkillType type) {
    switch (type) {
      case SkillType.gemBoost:
        return '金運招来';
      case SkillType.xpBoost:
        return '修練の極意';
      case SkillType.strBoost:
        return '剛力活性';
      case SkillType.luckBoost:
        return '幸運の星';
      default:
        return 'なし';
    }
  }

  String _getSkillEffect(SkillType type, int value) {
    switch (type) {
      case SkillType.gemBoost:
        return '獲得ジェム +$value%';
      case SkillType.xpBoost:
        return '獲得経験値 +$value%';
      case SkillType.strBoost:
        return 'STR +$value (一時的)';
      case SkillType.luckBoost:
        return 'LUK +$value (一時的)';
      default:
        return '';
    }
  }

  String _getSeriesName(SeriesType type) {
    switch (type) {
      case SeriesType.crimson:
        return '紅蓮シリーズ';
      case SeriesType.azure:
        return '蒼穹シリーズ';
      case SeriesType.golden:
        return '黄金シリーズ';
      case SeriesType.phantom:
        return '幻影シリーズ';
      default:
        return 'なし';
    }
  }

  String _getEffectName(EffectType type) {
    switch (type) {
      case EffectType.ember:
        return '紅蓮の炎';
      case EffectType.rain:
        return '豪雨';
      case EffectType.lightning:
        return '白雷';
      case EffectType.cherry:
        return '桜吹雪';
      case EffectType.snow:
        return '豪雪';
      case EffectType.bubble:
        return '泡沫';
      case EffectType.none:
        return 'なし';
    }
  }
}
