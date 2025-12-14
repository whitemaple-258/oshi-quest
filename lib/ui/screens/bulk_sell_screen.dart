import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/gacha_controller.dart';
import '../widgets/sparkle_effect_overlay.dart';

class BulkSellScreen extends ConsumerStatefulWidget {
  const BulkSellScreen({super.key});

  @override
  ConsumerState<BulkSellScreen> createState() => _BulkSellScreenState();
}

class _BulkSellScreenState extends ConsumerState<BulkSellScreen> {
  // 選択されたアイテムIDの集合
  final Set<int> _selectedIds = {};

  // 売却価格の定義 (Repositoryと合わせる)
  int _getPrice(Rarity rarity) {
    switch (rarity) {
      case Rarity.n:
        return 50;
      case Rarity.r:
        return 150;
      case Rarity.sr:
        return 500;
      case Rarity.ssr:
        return 2000;
    }
  }

  // 一括選択ロジック
  void _selectByRarity(List<GachaItem> items, Rarity rarity, Set<int> equippedIds) {
    final targets = items
        .where((item) => item.rarity == rarity && !equippedIds.contains(item.id))
        .map((e) => e.id);

    setState(() {
      // 既に全て選択済みなら解除、そうでなければ追加
      if (_selectedIds.containsAll(targets)) {
        _selectedIds.removeAll(targets);
      } else {
        _selectedIds.addAll(targets);
      }
    });
  }

  // 売却実行
  Future<void> _executeSell() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('売却確認'),
        content: Text('${_selectedIds.length}体のキャラを売却します。\nこの操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('売却する'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(gachaControllerProvider.notifier).sellItems(_selectedIds.toList());

        if (mounted) {
          setState(() {
            _selectedIds.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('売却しました')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // データ取得
    final myItemsAsync = ref.watch(myItemsProvider);
    final partyAsync = ref.watch(activePartyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('一括売却 (整理)'),
        actions: [
          // 選択解除ボタン
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.deselect),
              onPressed: () => setState(() => _selectedIds.clear()),
              tooltip: '選択解除',
            ),
        ],
      ),
      body: myItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (items) {
          // 装備中のIDリストを作成
          final equippedIds = <int>{};
          partyAsync.whenData((party) {
            party.forEach((slot, item) => equippedIds.add(item.id));
          });

          if (items.isEmpty) {
            return const Center(child: Text('売却できるキャラがいません'));
          }

          // 合計金額計算
          int totalGain = 0;
          for (var item in items) {
            if (_selectedIds.contains(item.id)) {
              totalGain += _getPrice(item.rarity);
            }
          }

          return Column(
            children: [
              // --- フィルターボタン ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Text('一括選択: '),
                    _FilterChip(
                      label: 'N',
                      color: Colors.grey,
                      onTap: () => _selectByRarity(items, Rarity.n, equippedIds),
                    ),
                    _FilterChip(
                      label: 'R',
                      color: Colors.blueAccent,
                      onTap: () => _selectByRarity(items, Rarity.r, equippedIds),
                    ),
                    _FilterChip(
                      label: 'SR',
                      color: Colors.purpleAccent,
                      onTap: () => _selectByRarity(items, Rarity.sr, equippedIds),
                    ),
                    // SSRは誤操作防止のため一括選択ボタンを置かない、等の配慮も可
                  ],
                ),
              ),
              const Divider(height: 1),

              // --- アイテムグリッド ---
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 小さめにたくさん表示
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isEquipped = equippedIds.contains(item.id);
                    final isSelected = _selectedIds.contains(item.id);

                    return GestureDetector(
                      onTap: isEquipped
                          ? null // 装備中は選択不可
                          : () {
                              setState(() {
                                if (isSelected) {
                                  _selectedIds.remove(item.id);
                                } else {
                                  _selectedIds.add(item.id);
                                }
                              });
                            },
                      child: Opacity(
                        opacity: isEquipped ? 0.4 : 1.0,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 画像
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(item.imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                              ),
                            ),

                            // 装備中バッジ
                            if (isEquipped)
                              Container(
                                color: Colors.black54,
                                child: const Center(
                                  child: Text(
                                    '装備中',
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ),

                            // 選択中オーバーレイ
                            if (isSelected)
                              Container(
                                color: Colors.black45,
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.greenAccent,
                                    size: 32,
                                  ),
                                ),
                              ),

                            // レアリティ表示 (左上)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                color: Colors.black87,
                                child: Text(
                                  item.rarity.name.toUpperCase(),
                                  style: TextStyle(
                                    color: _getRarityColor(item.rarity),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- フッター (実行エリア) ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, -2)),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('選択数: ${_selectedIds.length} 体'),
                        Row(
                          children: [
                            const Text('獲得: '),
                            const Icon(Icons.diamond, size: 16, color: Colors.cyanAccent),
                            Text(
                              ' $totalGain',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _selectedIds.isEmpty ? null : _executeSell,
                      icon: const Icon(Icons.sell),
                      label: const Text('売却する'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getRarityColor(Rarity r) {
    switch (r) {
      case Rarity.n:
        return Colors.white;
      case Rarity.r:
        return Colors.blueAccent;
      case Rarity.sr:
        return Colors.purpleAccent;
      case Rarity.ssr:
        return Colors.amber;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        label: Text(label),
        backgroundColor: color.withOpacity(0.2),
        labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
        side: BorderSide(color: color),
        onPressed: onTap,
      ),
    );
  }
}
