import 'dart:io';
// import 'dart:ui'; // ImageFilterは不要になったので削除
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/gacha_controller.dart';
import '../widgets/sparkle_effect_overlay.dart';
import 'bulk_sell_screen.dart';

class CharacterDetailScreen extends ConsumerStatefulWidget {
  final GachaItem? singleItem;
  final List<GachaItem>? items;
  final int initialIndex;

  const CharacterDetailScreen({super.key, this.items, this.initialIndex = 0}) : singleItem = null;

  const CharacterDetailScreen.single({super.key, required GachaItem item})
    : singleItem = item,
      items = null,
      initialIndex = 0;

  @override
  ConsumerState<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends ConsumerState<CharacterDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myItemsAsync = ref.watch(myItemsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: myItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
        data: (allItems) {
          final targetList = widget.singleItem != null
              ? [widget.singleItem!]
              : (widget.items ?? []);

          final currentItem = _getCurrentItem(allItems);

          if (currentItem == null) {
            return const Center(
              child: Text('データが見つかりません', style: TextStyle(color: Colors.white)),
            );
          }

          if (widget.singleItem != null) {
            return _buildContent(currentItem);
          } else {
            return PageView.builder(
              controller: _pageController,
              itemCount: targetList.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final itemModel = targetList[index];
                final freshItem = allItems.firstWhere(
                  (element) => element.id == itemModel.id,
                  orElse: () => itemModel,
                );
                return _buildContent(freshItem);
              },
            );
          }
        },
      ),
    );
  }

  GachaItem? _getCurrentItem(List<GachaItem> allItems) {
    int targetId;
    if (widget.singleItem != null) {
      targetId = widget.singleItem!.id;
    } else if (widget.items != null && widget.items!.isNotEmpty) {
      if (_currentIndex >= widget.items!.length) return null;
      targetId = widget.items![_currentIndex].id;
    } else {
      return null;
    }

    try {
      return allItems.firstWhere((item) => item.id == targetId);
    } catch (e) {
      return null;
    }
  }

  Widget _buildContent(GachaItem item) {
    // 高さ制限 (imageHeight) を削除し、スクロール全体で高さを決定する

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- 1. キャラクター画像エリア (横幅いっぱい、縦なりゆき) ---
          Stack(
            // fit: StackFit.expand, // 削除: 画像のサイズに合わせる
            alignment: Alignment.topCenter,
            children: [
              // メイン画像: 横幅を画面に合わせて、縦はアスペクト比を維持して伸びる
              Image.file(
                File(item.imagePath),
                fit: BoxFit.fitWidth, // ✅ 横幅いっぱい
                width: double.infinity, // 明示的に横幅を最大にする
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Container(
                  height: 300,
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),

              // エフェクト: Positioned.fill で画像エリア全体に広げる
              if (item.effectType != EffectType.none)
                Positioned.fill(child: SparkleEffectOverlay(effectType: item.effectType)),

              // 下部の境界線をなじませるグラデーション
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 120, // グラデーションの高さを少し調整
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- 2. 情報エリア (黒背景) ---
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // レアリティ & 名前
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRarityColor(item.rarity),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getRarityColor(item.rarity).withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        item.rarity.name.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 基本情報
                _buildInfoCard('基本情報', [
                  _buildRow('Bond Level', '${item.bondLevel}'),
                  _buildRow('エフェクト', _getEffectName(item.effectType)),
                ], Colors.blueGrey),
                const SizedBox(height: 12),

                // ステータス補正
                _buildInfoCard('ステータス補正', [
                  _buildRow('STR (筋力)', '+${item.strBonus}', color: Colors.redAccent),
                  _buildRow('INT (知力)', '+${item.intBonus}', color: Colors.blueAccent),
                  _buildRow('VIT (体力)', '+${item.vitBonus}', color: Colors.green),
                  _buildRow('LUK (幸運)', '+${item.luckBonus}', color: Colors.purpleAccent),
                  _buildRow('CHA (魅力)', '+${item.chaBonus}', color: Colors.pinkAccent),
                ], Colors.indigo),
                const SizedBox(height: 12),

                // スキル情報
                if (item.skillType != SkillType.none)
                  _buildInfoCard('保有スキル', [
                    _buildRow('スキル名', _getSkillName(item.skillType)),
                    _buildRow('効果', _getSkillEffect(item.skillType, item.skillValue)),
                    _buildRow('持続時間', '${item.skillDuration}秒'),
                    _buildRow('クールタイム', '${item.skillCooldown}秒'),
                  ], Colors.orange),

                if (item.skillType != SkillType.none) const SizedBox(height: 12),

                // シリーズ情報
                if (item.seriesId != SeriesType.none)
                  _buildInfoCard('シリーズ装備', [
                    _buildRow('シリーズ名', _getSeriesName(item.seriesId)),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '※同じシリーズを揃えると追加ボーナスが発生します',
                        style: TextStyle(fontSize: 11, color: Colors.white60),
                      ),
                    ),
                  ], Colors.teal),

                const SizedBox(height: 40),

                // アクションボタン
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // お気に入り
                      InkWell(
                        onTap: () {
                          ref.read(gachaControllerProvider.notifier).toggleFavorite(item.id);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Icon(
                                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: item.isFavorite ? Colors.pinkAccent : Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'お気に入り',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(width: 1, height: 40, color: Colors.white24),

                      // 売却
                      InkWell(
                        onTap: () {
                          BulkSellScreen.showSingleSellDialog(context, ref, item);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                color: Colors.amberAccent,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '売却 (${BulkSellScreen.getSellPrice(item.rarity)})',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Components & Helpers ---

  Widget _buildInfoCard(String title, List<Widget> children, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(Rarity r) {
    switch (r) {
      case Rarity.n:
        return Colors.grey;
      case Rarity.r:
        return Colors.blueAccent;
      case Rarity.sr:
        return Colors.purpleAccent;
      case Rarity.ssr:
        return const Color(0xFFFFD700);
    }
  }

  String _getEffectName(EffectType type) {
    switch (type) {
      case EffectType.none:
        return 'なし';
      case EffectType.cherry:
        return '桜吹雪';
      case EffectType.ember:
        return '火の粉';
      case EffectType.bubble:
        return '泡';
      case EffectType.rain:
        return '氷雨';
      case EffectType.lightning:
        return '稲妻';
      case EffectType.snow:
        return '豪雪';
    }
  }

  String _getSkillName(SkillType type) {
    switch (type) {
      case SkillType.none:
        return 'なし';
      case SkillType.gemBoost:
        return 'ジェム取得アップ';
      case SkillType.xpBoost:
        return '経験値アップ';
      case SkillType.strBoost:
        return 'STR強化';
      case SkillType.luckBoost:
        return 'LUCK強化';
      default:
        return type.toString().split('.').last;
    }
  }

  String _getSkillEffect(SkillType type, int value) {
    switch (type) {
      case SkillType.gemBoost:
        return 'ジェム獲得量 +$value%';
      case SkillType.xpBoost:
        return '経験値獲得量 +$value%';
      case SkillType.strBoost:
        return 'STR +$value';
      case SkillType.luckBoost:
        return 'LUCK +$value';
      default:
        return '効果値: $value';
    }
  }

  String _getSeriesName(SeriesType type) {
    switch (type) {
      case SeriesType.none:
        return 'なし';
      case SeriesType.crimson:
        return '紅蓮シリーズ';
      case SeriesType.azure:
        return '蒼天シリーズ';
      case SeriesType.golden:
        return '黄金シリーズ';
      case SeriesType.phantom:
        return '幻影シリーズ';
    }
  }
}
