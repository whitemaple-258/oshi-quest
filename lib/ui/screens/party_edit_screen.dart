import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/party_controller.dart';
import 'character_detail_screen.dart';
import 'bulk_sell_screen.dart';

class PartyEditScreen extends ConsumerStatefulWidget {
  const PartyEditScreen({super.key});

  @override
  ConsumerState<PartyEditScreen> createState() => _PartyEditScreenState();
}

class _PartyEditScreenState extends ConsumerState<PartyEditScreen> {
  // フィルター状態
  final Set<Rarity> _selectedRarities = Rarity.values.toSet();
  final Set<EffectType> _selectedEffects = EffectType.values.toSet(); // ✅ 追加: エフェクトフィルター
  
  bool _showFavoritesOnly = false;
  bool _showWithSkillOnly = false; // ✅ 追加: スキル持ちのみ
  bool _showWithSeriesOnly = false; // ✅ 追加: シリーズ持ちのみ

  int? _selectedSlotIndex;

  // フィルターダイアログ
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('表示フィルター'),
              scrollable: true, // コンテンツが増えたのでスクロール可能に
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 基本スイッチ ---
                  SwitchListTile(
                    title: const Text('お気に入りのみ'),
                    secondary: const Icon(Icons.favorite, color: Colors.pinkAccent),
                    value: _showFavoritesOnly,
                    onChanged: (val) {
                      setState(() => _showFavoritesOnly = val);
                      this.setState(() {}); 
                    },
                  ),
                  SwitchListTile(
                    title: const Text('スキル所持のみ'),
                    secondary: const Icon(Icons.flash_on, color: Colors.amber),
                    value: _showWithSkillOnly,
                    onChanged: (val) {
                      setState(() => _showWithSkillOnly = val);
                      this.setState(() {}); 
                    },
                  ),
                  SwitchListTile(
                    title: const Text('シリーズ所持のみ'),
                    secondary: const Icon(Icons.collections_bookmark, color: Colors.deepPurpleAccent),
                    value: _showWithSeriesOnly,
                    onChanged: (val) {
                      setState(() => _showWithSeriesOnly = val);
                      this.setState(() {}); 
                    },
                  ),
                  
                  const Divider(),
                  const Text('レアリティ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
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

                  const Divider(),
                  // ✅ 追加: エフェクトフィルター
                  const Text('エフェクト', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: EffectType.values.map((effect) {
                      final isSelected = _selectedEffects.contains(effect);
                      return FilterChip(
                        label: Text(_getEffectLabel(effect)),
                        selected: isSelected,
                        selectedColor: Colors.cyan.withOpacity(0.3),
                        checkmarkColor: Colors.cyanAccent,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedEffects.add(effect);
                            } else {
                              _selectedEffects.remove(effect);
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
                    setState(() {
                      // リセット処理
                      _selectedRarities.addAll(Rarity.values);
                      _selectedEffects.addAll(EffectType.values);
                      _showFavoritesOnly = false;
                      _showWithSkillOnly = false;
                      _showWithSeriesOnly = false;
                    });
                    this.setState(() {});
                  },
                  child: const Text('リセット'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('閉じる'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // エフェクト名の日本語表記
  String _getEffectLabel(EffectType type) {
    switch (type) {
      case EffectType.none: return 'なし';
      case EffectType.cherry: return '桜';
      case EffectType.ember: return '火';
      case EffectType.bubble: return '泡';
      case EffectType.rain: return '雨';
      case EffectType.lightning: return '雷';
      case EffectType.snow: return '雪';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePartyAsync = ref.watch(activePartyProvider);
    final myItemsAsync = ref.watch(myItemsProvider);
    final partyController = ref.read(partyControllerProvider.notifier);

    final activeParty = activePartyAsync.value ?? {};
    final allItems = myItemsAsync.value ?? [];

    // ✅ フィルタリングロジックの更新
    final displayItems = allItems.where((item) {
      // 1. お気に入り
      if (_showFavoritesOnly && !item.isFavorite) return false;
      
      // 2. レアリティ
      if (!_selectedRarities.contains(item.rarity)) return false;
      
      // 3. エフェクト (選択されていないエフェクトは非表示)
      if (!_selectedEffects.contains(item.effectType)) return false;

      // 4. スキル有無
      if (_showWithSkillOnly && item.skillType == SkillType.none) return false;

      // 5. シリーズ有無
      if (_showWithSeriesOnly && item.seriesId == SeriesType.none) return false;

      return true;
    }).toList();

    // フィルターアイコンの色制御（フィルター適用中なら色を変える）
    final bool isFilterActive = 
        _selectedRarities.length < Rarity.values.length ||
        _selectedEffects.length < EffectType.values.length ||
        _showFavoritesOnly ||
        _showWithSkillOnly ||
        _showWithSeriesOnly;

    return Scaffold(
      appBar: AppBar(
        title: const Text('パーティ編成'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: isFilterActive ? Colors.amber : null,
            ),
            tooltip: '絞り込み',
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sell') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BulkSellScreen()),
                );
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
          // --- 1. パーティスロット ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                _buildTotalBonus(activeParty),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            const Text('MAIN PARTNER', style: TextStyle(fontSize: 10, color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Expanded(child: _buildSlot(0, activeParty[0], isMain: true)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            const Text('SUPPORTERS', style: TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(child: _buildSlot(1, activeParty[1])),
                                        const SizedBox(width: 8),
                                        Expanded(child: _buildSlot(2, activeParty[2])),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(child: _buildSlot(3, activeParty[3])),
                                        const SizedBox(width: 8),
                                        Expanded(child: _buildSlot(4, activeParty[4])),
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
              style: TextStyle(fontSize: 12, color: _selectedSlotIndex != null ? Colors.cyanAccent : Colors.grey),
            ),
          ),

          // --- 2. 所持キャラリスト ---
          Expanded(
            child: displayItems.isEmpty
                ? const Center(child: Text('条件に合うキャラクターがいません'))
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
                      // 装備中かどうか判定
                      final isEquipped = activeParty.values.any((e) => e.id == item.id);
                      
                      return GestureDetector(
                        // タップ: 装備/解除
                        onTap: () {
                          if (_selectedSlotIndex != null) {
                            HapticFeedback.selectionClick();
                            partyController.equipItem(_selectedSlotIndex!, item.id);
                          } else {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('先に上のスロットをタップして選択してください'), duration: Duration(milliseconds: 1000)));
                          }
                        },
                        // 長押し: 詳細画面へ遷移
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CharacterDetailScreen(
                                items: displayItems,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: _buildListItem(item, isEquipped),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildSlot(int slotId, GachaItem? item, {bool isMain = false}) {
    final isSelected = _selectedSlotIndex == slotId;
    final partyController = ref.read(partyControllerProvider.notifier);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (_selectedSlotIndex == slotId) {
            if (item != null) partyController.unequipItem(slotId);
            else _selectedSlotIndex = null;
          } else {
            _selectedSlotIndex = slotId;
          }
        });
      },
      onLongPress: item == null ? null : () {
        HapticFeedback.mediumImpact();
        Navigator.push(context, MaterialPageRoute(builder: (_) => CharacterDetailScreen.single(item: item)));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.black38,
          border: Border.all(
            color: isSelected 
                ? Colors.cyanAccent 
                : (item != null ? Colors.white : (isMain ? Colors.pinkAccent : Colors.blueAccent)),
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 10)] : null,
        ),
        child: item == null
            ? Icon(Icons.add, color: isSelected ? Colors.cyanAccent : Colors.white24)
            : ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(item.imagePath),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_,__,___) => const Icon(Icons.error),
                ),
              ),
      ),
    );
  }

  Widget _buildListItem(GachaItem item, bool isEquipped) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: item.isFavorite ? Colors.pinkAccent : _getRarityColor(item.rarity), 
              width: item.isFavorite ? 3 : 2
            ),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(File(item.imagePath), fit: BoxFit.cover, errorBuilder: (_,__,___) => const Center(child: Icon(Icons.broken_image, size: 16))),
          ),
        ),
        if (isEquipped)
          Container(
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
            child: const Center(child: Icon(Icons.check, color: Colors.greenAccent, size: 32)),
          ),
        Positioned(
          top: 0, left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: _getRarityColor(item.rarity), borderRadius: const BorderRadius.only(bottomRight: Radius.circular(6))),
            child: Text(item.rarity.name.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
        if (item.isFavorite)
          const Positioned(
            bottom: 2, right: 2,
            child: Icon(Icons.favorite, color: Colors.pinkAccent, size: 14),
          ),
        // ✅ スキル/シリーズ持ちのインジケーター（オプション）
        if (item.skillType != SkillType.none)
           Positioned(
            top: 2, right: 2,
            child: Icon(Icons.flash_on, color: Colors.amber.withOpacity(0.8), size: 12),
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
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        Text('+$val', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getRarityColor(Rarity r) {
    switch (r) {
      case Rarity.n: return Colors.grey;
      case Rarity.r: return Colors.blueAccent;
      case Rarity.sr: return Colors.purpleAccent;
      case Rarity.ssr: return const Color(0xFFFFD700);
    }
  }
}