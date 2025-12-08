import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../logic/party_controller.dart';

class RegisteredItemsScreen extends ConsumerWidget {
  const RegisteredItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItemsAsync = ref.watch(gachaItemsProvider);
    final currentPartnerAsync = ref.watch(currentPartnerProvider);

    // ✅ 追加: コントローラーの状態を監視（これで処理中に破棄されなくなる）
    final partyState = ref.watch(partyControllerProvider);

    // ✅ 追加: 完了時の通知処理
    ref.listen(partyControllerProvider, (previous, next) {
      if (next is AsyncData && !next.isLoading && previous is AsyncLoading) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('パートナーを変更しました！')));
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
          return ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = items[index];
              final isEquipped = currentPartnerAsync.value?.id == item.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: isEquipped
                    ? RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.pinkAccent, width: 2),
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
                      fontWeight: isEquipped ? FontWeight.bold : FontWeight.normal,
                      color: isEquipped ? Colors.pinkAccent : null,
                    ),
                  ),
                  subtitle: Text(item.isUnlocked ? '獲得済み' : '未獲得（ロック中）'),
                  // ボタン生成メソッドにisLoading状態を渡す
                  trailing: _buildTrailingButton(
                    context,
                    ref,
                    item,
                    isEquipped,
                    partyState.isLoading,
                  ),
                ),
              );
            },
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
    dynamic item,
    bool isEquipped,
    bool isLoading,
  ) {
    if (!item.isUnlocked) {
      return const Icon(Icons.lock, color: Colors.grey);
    }

    if (isEquipped) {
      return const Chip(
        label: Text('パートナー中', style: TextStyle(fontSize: 10, color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
      );
    }

    // 装備ボタン
    return ElevatedButton(
      onPressed: isLoading
          ? null // ✅ 処理中はボタン無効化
          : () {
              ref.read(partyControllerProvider.notifier).equipItem(item.id);
            },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey[800],
        disabledBackgroundColor: Colors.grey[900], // 無効時の色
      ),
      child: isLoading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('装備'),
    );
  }
}
