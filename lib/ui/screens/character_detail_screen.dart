import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift; // drift.Value のためのインポート
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/gacha_controller.dart';
import '../widgets/sparkle_effect_overlay.dart';
import 'bulk_sell_screen.dart';
import 'image_pool_screen.dart'; // 整形・転生用
import '../../data/extensions/gacha_item_extension.dart';

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
  
  // --- 整形・転生フロー (前回のロジックを保持) ---
  Future<void> _startModification(GachaItem item, ModificationType type) async {
    final controller = ref.read(gachaControllerProvider.notifier);
    final playerGems = ref.read(playerProvider).value?.willGems ?? 0;

    final cost = controller.getModificationCost(item.rarity, type);
    final typeName = type == ModificationType.reskin ? '整形' : '転生';
    final desc = type == ModificationType.reskin 
        ? '画像を差し替えます。\nステータスは維持されます。' 
        : '新しい姿に生まれ変わります。\n画像を変更し、ステータスを再抽選します。\n(スキル、エフェクト等は維持)';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$typeNameしますか？'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('必要ジェム: '),
                const Icon(Icons.diamond, color: Colors.cyanAccent, size: 16),
                Text(' $cost', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            if (playerGems < cost)
               const Text('ジェムが不足しています。', style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: playerGems < cost ? null : () => Navigator.pop(ctx, true),
            child: Text('実行する', style: TextStyle(color: playerGems < cost ? Colors.grey : null)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final newImagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const ImagePoolScreen(isSelectionMode: true),
        fullscreenDialog: true,
      ),
    );

    if (newImagePath == null) return;

    try {
      if (type == ModificationType.reskin) {
        await controller.reskinCharacter(item, newImagePath);
      } else {
        await controller.reincarnateCharacter(item, newImagePath);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$typeName完了！'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- お気に入り切り替え (前回のロジックを保持) ---
  Future<void> _toggleFavorite(GachaItem item) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.gachaItems)..where((t) => t.id.equals(item.id))).write(
      GachaItemsCompanion(isFavorite: drift.Value(!item.isFavorite)),
    );
  }

  // --- 4つのアクションボタンの共通化されたビルドメソッド ---
  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    String? subLabel, // 売却価格用
  }) {
    final effectiveColor = onTap == null ? Colors.white54 : color;
    final itemColor = onTap == null ? Colors.black54 : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: effectiveColor,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: itemColor, fontSize: 10),
            ),
            if (subLabel != null)
              Text(
                subLabel,
                style: TextStyle(color: effectiveColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myItemsAsync = ref.watch(myItemsProvider);

    // ... (buildの大部分は省略) ...
    // ... (AppBar, body, when, _getCurrentItem はそのまま) ...
    
    return Scaffold(
      backgroundColor: Colors.black, 
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
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

  Widget _buildStatusRow(String label, int value, Color color) {
    final maxValue = 50.0; // 仮の最大値
    final progressValue = value / maxValue;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 50, // ラベル幅を確保
            child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.white12,
                color: color,
                minHeight: 8, // 高さを確保
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('+$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContent(GachaItem item) {
    final imageHeight = MediaQuery.of(context).size.height * 0.6;
    final partyAsync = ref.watch(activePartyProvider);
    final isEquipped = partyAsync.value?.values.any((e) => e.id == item.id) ?? false;
    final sellPrice = BulkSellScreen.getSellPrice(item.rarity);
    final reskinCost = ref.read(gachaControllerProvider.notifier).getModificationCost(item.rarity, ModificationType.reskin);
    final reincarnateCost = ref.read(gachaControllerProvider.notifier).getModificationCost(item.rarity, ModificationType.reincarnation);


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- 1. キャラクターカードエリア (画像 + エフェクト) ---
          SizedBox(
            height: imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: item.displayImageProvider,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
                ),
                if (item.effectType != EffectType.none)
                  SparkleEffectOverlay(effectType: item.effectType),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 125,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- 2. 情報エリア ---
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

                // ステータス補正 (修正前のコードに存在しないが、前回のやり取りで実装されたロジックを流用)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'ステータス補正', 
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildStatusRow('STR', item.strBonus, Colors.redAccent),
                _buildStatusRow('INT', item.intBonus, Colors.blueAccent),
                _buildStatusRow('VIT', item.vitBonus, Colors.green),
                _buildStatusRow('LUK', item.luckBonus, Colors.purpleAccent),
                _buildStatusRow('CHA', item.chaBonus, Colors.pinkAccent),

                const SizedBox(height: 32),
                
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

                // ✅ 修正: アクションボタンエリア
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 1. 整形
                      _buildActionItem(
                        icon: Icons.face,
                        label: '整形',
                        color: Colors.cyanAccent,
                        subLabel: '(${reskinCost} 💎)',
                        onTap: () => _startModification(item, ModificationType.reskin),
                      ),
                      
                      Container(width: 1, height: 40, color: Colors.white24),
                      
                      // 2. 転生
                      _buildActionItem(
                        icon: Icons.autorenew,
                        label: '転生',
                        color: Colors.orangeAccent,
                        subLabel: '(${reincarnateCost} 💎)',
                        onTap: () => _startModification(item, ModificationType.reincarnation),
                      ),
                      
                      Container(width: 1, height: 40, color: Colors.white24),

                      // 3. お気に入り
                      _buildActionItem(
                        icon: item.isFavorite ? Icons.favorite : Icons.favorite_border,
                        label: 'お気に入り',
                        color: item.isFavorite ? Colors.pinkAccent : Colors.white,
                        onTap: () => _toggleFavorite(item),
                      ),

                      Container(width: 1, height: 40, color: Colors.white24),

                      // 4. 売却
                      _buildActionItem(
                        icon: Icons.monetization_on,
                        label: '売却',
                        color: isEquipped ? Colors.white54 : Colors.amberAccent,
                        subLabel: '(${sellPrice} 💎)',
                        onTap: isEquipped 
                          ? null 
                          : () => BulkSellScreen.showSingleSellDialog(context, ref, item),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // --- Components & Helpers (変更なし) ---

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