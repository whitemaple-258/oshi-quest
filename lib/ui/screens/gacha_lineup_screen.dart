import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/master_data/gacha_logic_master.dart';
import '../../data/extensions/gacha_item_extension.dart';
import 'full_screen_image_viewer.dart';

class GachaLineupScreen extends ConsumerWidget {
  const GachaLineupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    // ✅ 変更: ガチャアイテム(GachaItems)ではなく、画像プール(CharacterImages)を監視
    final imagesStream = db.select(db.characterImages).watch();

    return Scaffold(
      appBar: AppBar(title: const Text('提供割合・画像プール')),
      body: Column(
        children: [
          // --- 1. 確率表示エリア (変更なし) ---
          ExpansionTile(
            title: const Text(
              '排出確率・詳細',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            initiallyExpanded: false,
            children: [
              Container(
                height: 300, // 内容が増えたので高さを拡張
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 1. レアリティ ---
                      const Text(
                        '【レアリティ別 提供割合】',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                      ),
                      const SizedBox(height: 4),
                      _buildRateRow('N (Normal)', '55%'),
                      _buildRateRow('R (Rare)', '30%'),
                      _buildRateRow('SR (Super Rare)', '12%'),
                      _buildRateRow('SSR (Legendary)', '3%'),
                      
                      const SizedBox(height: 16),

                      // --- 2. 画像とタイツ君の仕様 (Updated!) ---
                      const Text(
                        '【画像排出と登録仕様】',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '・登録上限：最大 20枚\n'
                        '・タイツ君排出率の変動：\n'
                        '　登録画像数に応じて、タイツ君の出現率は100%から徐々に下がります。\n'
                        '　上限(20枚)まで登録すると、最低保証値である「10%」になります。\n'
                        '　(登録画像が多いほど、オリジナルキャラが出やすくなります)\n\n'
                        '　[推移目安]\n'
                        '　 0枚登録：タイツ君 100%\n'
                        '　10枚登録：タイツ君  55%\n'
                        '　20枚登録：タイツ君  10% (Min)',
                        style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
                      ),

                      const SizedBox(height: 16),

                      // --- 3. スキル ---
                      const Text(
                        '【スキル一覧】',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const Text(
                        'レアリティに応じて確率で付与されます。',
                        style: TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                      const SizedBox(height: 4),
                      ...skillDefinitions.map(
                        (def) => _buildRateRow(
                          _getSkillName(def.type),
                          '${(def.probability * 100).toStringAsFixed(0)}%',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- 4. シリーズ (New!) ---
                      const Text(
                        '【シリーズ効果】',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '稀に特定の「シリーズ」を持ったキャラが排出されます。\n'
                        '同じシリーズを持つキャラをパーティに複数編成すると、ステータスにボーナスが発生します。',
                        style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1),

          // --- 2. 画像プール表示エリア ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '排出対象画像 (登録済みプール)',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CharacterImage>>(
              stream: imagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('エラー: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final images = snapshot.data!;

                // ============================================================
                // 1. 表示用データの統合 (タイツ君 + ユーザー画像)
                // ============================================================

                // タイツ君の定義
                final tightsDefinitions = [
                  {'name': '全身タイツ君(N)', 'asset': 'assets/images/tights_gray.png'},
                  {'name': '全身タイツ君(R)', 'asset': 'assets/images/tights_blue.png'},
                  {'name': '全身タイツ君(SR)', 'asset': 'assets/images/tights_purple.png'},
                  {'name': '全身タイツ君(SSR)', 'asset': 'assets/images/tights_gold.png'},
                ];

                // 統合リストを作成
                final List<LineupDisplayItem> displayItems = [];

                // A. タイツ君を追加
                for (var def in tightsDefinitions) {
                  displayItems.add(
                    LineupDisplayItem(
                      imageProvider: AssetImage(def['asset']!),
                      name: def['name']!,
                      isTightsMan: true,
                    ),
                  );
                }

                // B. ユーザー画像を追加
                for (var img in images) {
                  displayItems.add(
                    LineupDisplayItem(
                      // パスがnullなら空文字にしておく(エラービルダーが処理する)
                      imageProvider: FileImage(File(img.imagePath)),
                      name: img.name,
                      isTightsMan: false,
                    ),
                  );
                }

                // ============================================================
                // 2. GridViewの構築
                // ============================================================
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  // 統合したリストの件数を使う
                  itemCount: displayItems.length,

                  itemBuilder: (context, index) {
                    final item = displayItems[index];

                    return GestureDetector(
                      // タップ時の処理：全画面プレビューへ遷移
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // 統合リスト全体と、現在のインデックスを渡す
                            builder: (_) =>
                                FullScreenImageViewer(items: displayItems, initialIndex: index),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 画像部分
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white24),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image(
                                      image: item.imageProvider,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ),
                                    // タイツ君にはロックアイコンを表示(オプション)
                                    if (item.isTightsMan)
                                      const Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Icon(Icons.lock, color: Colors.white38, size: 14),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 名前ラベル
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 10, color: Colors.white70),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getSkillName(SkillType type) {
    switch (type) {
      case SkillType.gemBoost:
        return '金運招来 (Gem UP)';
      case SkillType.xpBoost:
        return '修練の極意 (XP UP)';
      case SkillType.strBoost:
        return '剛力活性 (STR UP)';
      case SkillType.luckBoost:
        return '幸運の星 (LUK UP)';
      default:
        return 'なし';
    }
  }
}