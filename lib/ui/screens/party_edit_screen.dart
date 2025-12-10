import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 振動用
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/party_controller.dart';

class PartyEditScreen extends ConsumerStatefulWidget {
  const PartyEditScreen({super.key});

  @override
  ConsumerState<PartyEditScreen> createState() => _PartyEditScreenState();
}

class _PartyEditScreenState extends ConsumerState<PartyEditScreen> {
  // 現在選択中のスロットID（デフォルトはメイン:0）
  int _selectedSlotId = 0;

  @override
  Widget build(BuildContext context) {
    final activePartyAsync = ref.watch(activePartyProvider);
    final allItemsAsync = ref.watch(gachaItemsProvider);

    final partyState = ref.watch(partyControllerProvider);

    // エラーハンドリング
    ref.listen(partyControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: ${next.error}'), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('パーティ編成')),
      body: Column(
        children: [
          // --- 上部: ステータス & スロットエリア ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black26,
            child: activePartyAsync.when(
              data: (partyMap) => Column(
                children: [
                  // 合計ステータス
                  _buildTotalBonus(partyMap),
                  const SizedBox(height: 16),

                  // ✅ レイアウト変更: 左メイン、右サブ2列
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左側: メインスロット (縦長)
                      Expanded(
                        flex: 4, // 左側を広めに
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
                            // メインスロットの高さを指定（例: 250px）
                            SizedBox(height: 250, child: _buildMainSlot(0, partyMap[0])),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12), // 左右の間隔
                      // 右側: サブスロット (2列x2行)
                      Expanded(
                        flex: 4, // 右側も広めに確保
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
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2, // 2列
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.7, // 正方形に近い比率
                              children: [
                                _buildSmallSlot(1, partyMap[1]), // Slot 1
                                _buildSmallSlot(2, partyMap[2]), // Slot 2
                                _buildSmallSlot(3, partyMap[3]), // Slot 3
                                _buildSmallSlot(4, partyMap[4]), // Slot 4
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () =>
                  const SizedBox(height: 250, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox(height: 250, child: Center(child: Text('エラー'))),
            ),
          ),

          const Divider(height: 1),

          // --- 下部: キャラクター一覧 ---
          Expanded(
            child: allItemsAsync.when(
              data: (items) {
                final unlockedItems = items.where((i) => i.isUnlocked).toList();

                if (unlockedItems.isEmpty) {
                  return const Center(child: Text('所持している推しがいません'));
                }

                final partyMap = activePartyAsync.value ?? {};

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: unlockedItems.length,
                  itemBuilder: (context, index) {
                    final item = unlockedItems[index];

                    int? equippedAt;
                    partyMap.forEach((slot, equippedItem) {
                      if (equippedItem.id == item.id) {
                        equippedAt = slot;
                      }
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
                          'STR:${item.strBonus} INT:${item.intBonus} LUCK:${item.luckBonus} CHA:${item.chaBonus}',
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
                        // 処理中はタップ無効化
                        enabled: !partyState.isLoading,
                        onTap: partyState.isLoading
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                ref
                                    .read(partyControllerProvider.notifier)
                                    .equipItem(_selectedSlotId, item.id);
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

  // --- Widgets ---

  Widget _buildTotalBonus(Map<int, GachaItem> partyMap) {
    int str = 0, intellect = 0, luck = 0, cha = 0;
    for (var item in partyMap.values) {
      str += item.strBonus;
      intellect += item.intBonus;
      luck += item.luckBonus;
      cha += item.chaBonus;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatValue('STR', str, Colors.redAccent),
        _buildStatValue('INT', intellect, Colors.blueAccent),
        _buildStatValue('LUCK', luck, Colors.amber),
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
      child: Container(
        // 高さは GridView の aspect ratio で決まるので指定しない
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
      child: Container(
        // 高さは親の SizedBox で指定
        width: double.infinity,
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
