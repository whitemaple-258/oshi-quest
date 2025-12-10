import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart'; // GachaItem型のために必要
import '../../data/providers.dart';
import '../../logic/party_controller.dart';

class RegisteredItemsScreen extends ConsumerWidget {
  const RegisteredItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItemsAsync = ref.watch(gachaItemsProvider);
    // ✅ 変更: パーティ全員の状態を監視
    final activePartyAsync = ref.watch(activePartyProvider);
    final partyState = ref.watch(partyControllerProvider);

    // 完了時の通知
    ref.listen(partyControllerProvider, (previous, next) {
      if (next is AsyncData && !next.isLoading && previous is AsyncLoading) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('パーティ編成を更新しました！')));
        Navigator.of(
          context,
        ).popUntil((route) => route.isFirst || route.settings.name == '/'); // 必要なら閉じる
      } else if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: ${next.error}'), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('推し一覧（BOX）')),
      body: allItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('アイテムが登録されていません'));
          }

          return activePartyAsync.when(
            data: (partyMap) {
              return ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final item = items[index];

                  // ✅ 現在の装備状態を検索
                  int? equippedSlot;
                  partyMap.forEach((slot, equippedItem) {
                    if (equippedItem.id == item.id) {
                      equippedSlot = slot;
                    }
                  });

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: equippedSlot != null
                        ? RoundedRectangleBorder(
                            side: BorderSide(
                              color: equippedSlot == 0 ? Colors.pinkAccent : Colors.blueAccent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(item.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: equippedSlot != null ? FontWeight.bold : FontWeight.normal,
                          color: equippedSlot == 0
                              ? Colors.pinkAccent
                              : (equippedSlot != null ? Colors.blueAccent : null),
                        ),
                      ),
                      subtitle: Text(item.isUnlocked ? 'Bond Lv.${item.bondLevel}' : '未獲得（ロック中）'),
                      // ボタンエリア
                      trailing: _buildTrailingButton(
                        context,
                        ref,
                        item,
                        equippedSlot,
                        partyMap,
                        partyState.isLoading,
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('エラー: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }

  Widget _buildTrailingButton(
    BuildContext context,
    WidgetRef ref,
    GachaItem item,
    int? equippedSlot,
    Map<int, GachaItem> partyMap,
    bool isLoading,
  ) {
    if (!item.isUnlocked) {
      return const Icon(Icons.lock, color: Colors.grey);
    }

    // 装備中の場合、スロット名を表示
    if (equippedSlot != null) {
      final label = equippedSlot == 0 ? 'MAIN' : 'SUB $equippedSlot';
      final color = equippedSlot == 0 ? Colors.pinkAccent : Colors.blueAccent;

      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Chip(
            label: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
            backgroundColor: color,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          // 解除ボタン
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: isLoading
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    ref.read(partyControllerProvider.notifier).unequipItem(equippedSlot);
                  },
          ),
        ],
      );
    }

    // 未装備の場合、「装備」ボタンでスロット選択へ
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
              HapticFeedback.selectionClick();
              _showSlotSelectionSheet(context, ref, item, partyMap);
            },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey[800],
        disabledBackgroundColor: Colors.grey[900],
      ),
      child: isLoading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('装備'),
    );
  }

  // ✅ 追加: スロット選択シート
  void _showSlotSelectionSheet(
    BuildContext context,
    WidgetRef ref,
    GachaItem newItem,
    Map<int, GachaItem> currentParty,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('どこに装備しますか？', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              // メインスロット (0)
              _buildSlotOption(ctx, ref, 0, 'Main Partner', newItem, currentParty[0]),
              const Divider(),
              // サブスロット (1-4)
              ...List.generate(4, (index) {
                final slotId = index + 1;
                return _buildSlotOption(
                  ctx,
                  ref,
                  slotId,
                  'Supporter $slotId',
                  newItem,
                  currentParty[slotId],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlotOption(
    BuildContext context,
    WidgetRef ref,
    int slotId,
    String label,
    GachaItem newItem,
    GachaItem? currentItem,
  ) {
    final isMain = slotId == 0;

    return ListTile(
      leading: Icon(
        isMain ? Icons.star : Icons.person,
        color: isMain ? Colors.pinkAccent : Colors.blueAccent,
      ),
      title: Text(
        label,
        style: TextStyle(fontWeight: isMain ? FontWeight.bold : FontWeight.normal),
      ),
      subtitle: Text(
        currentItem != null ? '入替: ${currentItem.title}' : '空き',
        style: TextStyle(color: currentItem != null ? Colors.white70 : Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context); // シートを閉じる
        ref.read(partyControllerProvider.notifier).equipItem(slotId, newItem.id);
      },
    );
  }
}
