import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';

class CharacterDetailScreen extends StatelessWidget {
  final GachaItem item;

  const CharacterDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- キャラ画像 ---
            Center(
              child: Container(
                height: screenSize.height*0.6,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getRarityColor(item.rarity), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: _getRarityColor(item.rarity).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(item.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 基本情報 ---
            _buildInfoCard('基本情報', [
              _buildRow('レアリティ', item.rarity.name.toUpperCase()),
              _buildRow('Bond Level', '${item.bondLevel}'),
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
          ],
        ),
      ),
    );
  }

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
}
