import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/gacha_controller.dart';
import '../../data/extensions/gacha_item_extension.dart';

class BulkSellScreen extends ConsumerStatefulWidget {
  const BulkSellScreen({super.key});

  // 価格計算ロジック
  static int getSellPrice(Rarity rarity) {
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

  // 単発売却ダイアログ
  static Future<void> showSingleSellDialog(
    BuildContext context,
    WidgetRef ref,
    GachaItem item,
  ) async {
    if (item.isFavorite) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('お気に入り登録されているため売却できません')));
      return;
    }

    final price = getSellPrice(item.rarity);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('売却確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('「${item.title}」を売却しますか？'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('獲得ジェム: '),
                const Icon(Icons.diamond, size: 16, color: Colors.cyanAccent),
                Text(' $price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('※この操作は取り消せません', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
          ],
        ),
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

    if (result == true) {
      try {
        final success = await ref.read(gachaControllerProvider.notifier).sellItem(item);

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('売却しました (+$price 💎)')));
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('装備中のため売却できません')));
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
        }
      }
    }
  }

  @override
  ConsumerState<BulkSellScreen> createState() => _BulkSellScreenState();
}

class _BulkSellScreenState extends ConsumerState<BulkSellScreen> {
  final Set<int> _selectedIds = {};

  void _selectByRarity(List<GachaItem> items, Rarity rarity, Set<int> equippedIds) {
    final targets = items
        .where(
          (item) => item.rarity == rarity && !equippedIds.contains(item.id) && !item.isFavorite,
        )
        .map((e) => e.id);

    setState(() {
      if (_selectedIds.containsAll(targets)) {
        _selectedIds.removeAll(targets);
      } else {
        _selectedIds.addAll(targets);
      }
    });
  }

  Future<void> _executeSell() async {
    if (_selectedIds.isEmpty) return;

    final allItems = ref.read(myItemsProvider).value ?? [];
    int totalGain = 0;
    for (var id in _selectedIds) {
      final item = allItems.firstWhere((e) => e.id == id, orElse: () => allItems.first);
      totalGain += BulkSellScreen.getSellPrice(item.rarity);
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('一括売却確認'),
        content: Text('${_selectedIds.length}体のキャラを売却します。\n獲得予定: $totalGain 💎\nこの操作は取り消せません。'),
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
          setState(() => _selectedIds.clear());
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('売却しました (+$totalGain 💎)')));
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
    final myItemsAsync = ref.watch(myItemsProvider);
    final partyAsync = ref.watch(activePartyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('一括売却 (整理)'),
        actions: [
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
          final equippedIds = <int>{};
          partyAsync.whenData((party) {
            party.forEach((slot, item) => equippedIds.add(item.id));
          });

          if (items.isEmpty) return const Center(child: Text('売却できるキャラがいません'));

          int totalGain = 0;
          for (var item in items) {
            if (_selectedIds.contains(item.id)) {
              totalGain += BulkSellScreen.getSellPrice(item.rarity);
            }
          }

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Text('一括選択 (お気に入り除く): ', style: TextStyle(fontSize: 12)),
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
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
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
                          ? null
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image(
                                image: item.displayImageProvider,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                              ),
                            ),
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
                            if (item.isFavorite)
                              const Positioned(
                                bottom: 2,
                                right: 2,
                                child: Icon(Icons.favorite, color: Colors.pinkAccent, size: 16),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
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
