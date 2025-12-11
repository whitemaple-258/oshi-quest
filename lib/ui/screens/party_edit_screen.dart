import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/party_controller.dart';
import '../../logic/gacha_controller.dart';
import 'character_detail_screen.dart';

class PartyEditScreen extends ConsumerStatefulWidget {
  const PartyEditScreen({super.key});

  @override
  ConsumerState<PartyEditScreen> createState() => _PartyEditScreenState();
}

class _PartyEditScreenState extends ConsumerState<PartyEditScreen> {
  int _selectedSlotId = 0;

  @override
  Widget build(BuildContext context) {
    final activePartyAsync = ref.watch(activePartyProvider);
    final allItemsAsync = ref.watch(myItemsProvider);
    final partyState = ref.watch(partyControllerProvider);

    ref.listen(partyControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: ${next.error}'), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('パーティ編成'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('キャラを長押しで詳細確認・換金ができます')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- 上部: ステータス & スロット ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black26,
            child: activePartyAsync.when(
              data: (partyMap) => Column(
                children: [
                  _buildTotalBonus(partyMap),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MAIN PARTNER',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(child: _buildMainSlot(0, partyMap[0])),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SUPPORTERS',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(child: _buildSmallSlot(1, partyMap[1])),
                                          const SizedBox(width: 8),
                                          Expanded(child: _buildSmallSlot(2, partyMap[2])),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(child: _buildSmallSlot(3, partyMap[3])),
                                          const SizedBox(width: 8),
                                          Expanded(child: _buildSmallSlot(4, partyMap[4])),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () =>
                  const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox(height: 200, child: Center(child: Text('エラー'))),
            ),
          ),

          const Divider(height: 1),

          // --- 下部: キャラクター一覧 ---
          Expanded(
            child: allItemsAsync.when(
              data: (items) {
                final unlockedItems = items.where((i) => i.isUnlocked).toList();
                if (unlockedItems.isEmpty) return const Center(child: Text('所持している推しがいません'));

                final partyMap = activePartyAsync.value ?? {};

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: unlockedItems.length,
                  itemBuilder: (context, index) {
                    final item = unlockedItems[index];

                    int? equippedAt;
                    partyMap.forEach((slot, equippedItem) {
                      if (equippedItem.id == item.id) equippedAt = slot;
                    });
                    final isEquippedInCurrentSlot = equippedAt == _selectedSlotId;

                    return Card(
                      color: isEquippedInCurrentSlot ? Colors.grey[800] : null,
                      child: ListTile(
                        leading: SizedBox(
                          width: 48,
                          height: 48,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(File(item.imagePath), fit: BoxFit.cover),
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: isEquippedInCurrentSlot
                                ? (_selectedSlotId == 0 ? Colors.pinkAccent : Colors.blueAccent)
                                : null,
                            fontWeight: isEquippedInCurrentSlot
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          'STR:${item.strBonus} INT:${item.intBonus} VIT:${item.vitBonus} LUK:${item.luckBonus} CHA:${item.chaBonus}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: equippedAt != null
                            ? Chip(
                                label: Text(equippedAt == 0 ? 'MAIN' : 'SUB $equippedAt'),
                                backgroundColor: equippedAt == 0
                                    ? Colors.pinkAccent
                                    : Colors.blueAccent,
                                labelStyle: const TextStyle(fontSize: 10, color: Colors.white),
                              )
                            : null,
                        enabled: !partyState.isLoading,

                        // ✅ 変更: タップ時の挙動（トグル）
                        onTap: partyState.isLoading
                            ? null
                            : () {
                                HapticFeedback.selectionClick();

                                if (isEquippedInCurrentSlot) {
                                  // 既にこのスロットに装備中なら解除
                                  ref
                                      .read(partyControllerProvider.notifier)
                                      .unequipItem(_selectedSlotId);
                                } else {
                                  // それ以外なら装備（上書き/移動）
                                  ref
                                      .read(partyControllerProvider.notifier)
                                      .equipItem(_selectedSlotId, item.id);
                                }
                              },

                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          _showCharacterMenu(context, ref, item);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('エラー: $e')),
            ),
          ),
        ],
      ),
    );
  }

  // --- メニュー表示 ---
  void _showCharacterMenu(BuildContext context, WidgetRef ref, GachaItem item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: const Text('詳細を見る'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CharacterDetailScreen(item: item)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on, color: Colors.amber),
              title: const Text('換金する (お別れ)'),
              subtitle: Text(_getSellPriceText(item.rarity)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmSell(context, ref, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getSellPriceText(Rarity rarity) {
    switch (rarity) {
      case Rarity.n:
        return '売却額: 50 Gems';
      case Rarity.r:
        return '売却額: 150 Gems';
      case Rarity.sr:
        return '売却額: 500 Gems';
      case Rarity.ssr:
        return '売却額: 2000 Gems';
    }
  }

  Future<void> _confirmSell(BuildContext context, WidgetRef ref, GachaItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('換金確認'),
        content: Text('「${item.title}」とお別れしてジェムに換えますか？\n\n※この操作は取り消せません。\n※装備中のキャラは売却できません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '換金する',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(gachaControllerProvider.notifier).sellItem(item);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('換金しました！'), backgroundColor: Colors.amber));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildTotalBonus(Map<int, GachaItem> partyMap) {
    int str = 0, intellect = 0, luck = 0, cha = 0, vit = 0;
    for (var item in partyMap.values) {
      str += item.strBonus;
      intellect += item.intBonus;
      luck += item.luckBonus;
      cha += item.chaBonus;
      vit += item.vitBonus;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatValue('STR', str, Colors.redAccent),
        _buildStatValue('INT', intellect, Colors.blueAccent),
        _buildStatValue('VIT', vit, Colors.orange),
        _buildStatValue('LUCK', luck, Colors.purpleAccent),
        _buildStatValue('CHA', cha, Colors.pinkAccent),
      ],
    );
  }

  Widget _buildStatValue(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
        ),
        Text('+$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSmallSlot(int slotId, GachaItem? item) {
    final isSelected = _selectedSlotId == slotId;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSlotId = slotId);
        HapticFeedback.selectionClick();
      },
      onLongPress: item == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CharacterDetailScreen(item: item)),
              );
            },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey[700]!,
            width: isSelected ? 3 : 1,
          ),
          image: item != null
              ? DecorationImage(image: FileImage(File(item.imagePath)), fit: BoxFit.cover)
              : null,
        ),
        child: item == null ? const Icon(Icons.add, size: 20, color: Colors.grey) : null,
      ),
    );
  }

  Widget _buildMainSlot(int slotId, GachaItem? item) {
    final isSelected = _selectedSlotId == slotId;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSlotId = slotId);
        HapticFeedback.selectionClick();
      },
      onLongPress: item == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CharacterDetailScreen(item: item)),
              );
            },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.pinkAccent : Colors.grey[700]!,
            width: isSelected ? 3 : 1,
          ),
          image: item != null
              ? DecorationImage(
                  image: FileImage(File(item.imagePath)),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                )
              : null,
        ),
        child: Stack(
          children: [
            if (item == null)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 40, color: Colors.grey),
                    SizedBox(height: 4),
                    Text('パートナーを選択', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '選択中',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (item != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                  ),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
