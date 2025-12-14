import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/party_controller.dart';
import '../widgets/sparkle_effect_overlay.dart';
import 'bulk_sell_screen.dart';
import 'character_detail_screen.dart';

class PartyEditScreen extends ConsumerStatefulWidget {
  const PartyEditScreen({super.key});

  @override
  ConsumerState<PartyEditScreen> createState() => _PartyEditScreenState();
}

class _PartyEditScreenState extends ConsumerState<PartyEditScreen> {
  final Set<Rarity> _selectedRarities = {Rarity.n, Rarity.r, Rarity.sr, Rarity.ssr};
  int? _selectedSlotIndex; // 現在選択中のスロット

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('表示フィルター'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('表示するレアリティを選択'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: Rarity.values.map((rarity) {
                      final isSelected = _selectedRarities.contains(rarity);
                      return FilterChip(
                        label: Text(rarity.name.toUpperCase()),
                        selected: isSelected,
                        selectedColor: _getRarityColor(rarity).withOpacity(0.3),
                        checkmarkColor: _getRarityColor(rarity),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedRarities.add(rarity);
                            } else {
                              _selectedRarities.remove(rarity);
                            }
                          });
                          this.setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() => _selectedRarities.addAll(Rarity.values));
                    this.setState(() {});
                  },
                  child: const Text('全表示'),
                ),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePartyAsync = ref.watch(activePartyProvider);
    final myItemsAsync = ref.watch(myItemsProvider);
    final partyController = ref.read(partyControllerProvider.notifier);

    final activeParty = activePartyAsync.value ?? {};
    final allItems = myItemsAsync.value ?? [];

    final displayItems = allItems.where((item) {
      return _selectedRarities.contains(item.rarity);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('パーティ編成'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _selectedRarities.length < 4 ? Colors.amber : null,
            ),
            tooltip: '絞り込み',
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sell') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BulkSellScreen()));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sell',
                child: Row(
                  children: [
                    Icon(Icons.sell, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text('一括売却・整理'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // --- 1. パーティスロット (左メイン/右サブ) ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                // 合計ステータス
                _buildTotalBonus(activeParty),
                const SizedBox(height: 12),

                // スロット配置
                SizedBox(
                  height: 250, // 高さを固定
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 左: メイン (9:16)
                      Expanded(
                        flex: 5,
                        child: Column(
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
                            Expanded(
                              child: _buildSlot(
                                0,
                                activeParty[0],
                                aspectRatio: 9 / 16,
                                isMain: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 右: サブ (グリッド)
                      Expanded(
                        flex: 5,
                        child: Column(
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
                                        Expanded(
                                          child: _buildSlot(1, activeParty[1], aspectRatio: 9 / 16),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildSlot(2, activeParty[2], aspectRatio: 9 / 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildSlot(3, activeParty[3], aspectRatio: 9 / 16),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildSlot(4, activeParty[4], aspectRatio: 9 / 16),
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
                ),
              ],
            ),
          ),

          // --- 案内メッセージ ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: _selectedSlotIndex != null ? Colors.cyan.withOpacity(0.1) : Colors.transparent,
            child: Text(
              _selectedSlotIndex != null
                  ? 'キャラをタップして ${(_selectedSlotIndex! == 0) ? "MAIN" : "SUB ${_selectedSlotIndex!}"} に装備'
                  : 'スロットをタップして選択してください',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: _selectedSlotIndex != null ? Colors.cyanAccent : Colors.grey,
              ),
            ),
          ),

          // --- 2. 所持キャラリスト ---
          Expanded(
            child: displayItems.isEmpty
                ? const Center(child: Text('キャラクターがいません'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      final isEquipped = activeParty.values.any((e) => e.id == item.id);

                      return GestureDetector(
                        onTap: () {
                          if (_selectedSlotIndex != null) {
                            HapticFeedback.selectionClick();
                            // スロットが選択されていれば装備実行
                            partyController.equipItem(_selectedSlotIndex!, item.id);
                          } else {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('先に上のスロットをタップして選択してください'),
                                duration: Duration(milliseconds: 1000),
                              ),
                            );
                          }
                        },
                        child: LongPressDraggable<GachaItem>(
                          data: item,
                          feedback: Opacity(
                            opacity: 0.8,
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.file(File(item.imagePath), fit: BoxFit.cover),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildListItem(item, isEquipped),
                          ),
                          child: _buildListItem(item, isEquipped),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildSlot(int slotId, GachaItem? item, {double aspectRatio = 1.0, bool isMain = false}) {
    final isSelected = _selectedSlotIndex == slotId;
    final partyController = ref.read(partyControllerProvider.notifier);

    return DragTarget<GachaItem>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        partyController.equipItem(slotId, details.data.id);
        setState(() => _selectedSlotIndex = slotId);
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (_selectedSlotIndex == slotId) {
                // 再タップで解除
                if (item != null)
                  partyController.unequipItem(slotId);
                else
                  _selectedSlotIndex = null;
              } else {
                // 選択
                _selectedSlotIndex = slotId;
              }
            });
          },
          onLongPress: item == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CharacterDetailScreen.single(item: item)),
                  );
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.black38,
              border: Border.all(
                color: isSelected
                    ? Colors.cyanAccent
                    : (candidateData.isNotEmpty
                          ? Colors.white
                          : (isMain ? Colors.pinkAccent : Colors.blueAccent)),
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 10)]
                  : null,
            ),
            child: item == null
                ? Icon(Icons.add, color: isSelected ? Colors.cyanAccent : Colors.white24)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(item.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.error),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildListItem(GachaItem item, bool isEquipped) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _getRarityColor(item.rarity), width: 2),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              File(item.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 16)),
            ),
          ),
        ),
        if (isEquipped)
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(child: Icon(Icons.check, color: Colors.greenAccent, size: 32)),
          ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: _getRarityColor(item.rarity),
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(6)),
            ),
            child: Text(
              item.rarity.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBonus(Map<int, GachaItem> partyMap) {
    int str = 0, intl = 0, vit = 0, luck = 0, cha = 0;
    for (var item in partyMap.values) {
      str += item.strBonus;
      intl += item.intBonus;
      vit += item.vitBonus;
      luck += item.luckBonus;
      cha += item.chaBonus;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatText('STR', str, Colors.redAccent),
        _buildStatText('INT', intl, Colors.blueAccent),
        _buildStatText('VIT', vit, Colors.green),
        _buildStatText('LUK', luck, Colors.purpleAccent),
        _buildStatText('CHA', cha, Colors.pinkAccent),
      ],
    );
  }

  Widget _buildStatText(String label, int val, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
        ),
        Text('+$val', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
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
}
