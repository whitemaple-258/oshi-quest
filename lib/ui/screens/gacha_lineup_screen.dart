import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 振動用
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/gacha_controller.dart'; // ✅ 追加

class GachaLineupScreen extends ConsumerWidget {
  const GachaLineupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItemsAsync = ref.watch(gachaItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ガチャ提供割合')),
      body: allItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('ラインナップがありません'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
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
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('レアリティ: ${item.rarity.name.toUpperCase()}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.isUnlocked)
                      Text(
                        'Bond Lv.${item.bondLevel}',
                        style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      item.isUnlocked ? '所持済み' : '未所持',
                      style: TextStyle(
                        fontSize: 12,
                        color: item.isUnlocked ? Colors.grey : Colors.white,
                      ),
                    ),
                  ],
                ),
                // ✅ 追加: 長押しで編集メニュー表示
                onLongPress: () {
                  HapticFeedback.selectionClick();
                  _showEditMenu(context, ref, item);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }

  // --- 編集・削除メニュー (RegisteredItemsScreenから移植) ---

  void _showEditMenu(BuildContext context, WidgetRef ref, GachaItem item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('編集・再トリミング'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog(context, ref, item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('削除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, GachaItem item) async {
    final titleController = TextEditingController(text: item.title);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('推し編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'タイトル'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                // 画像だけ先に再トリミングして更新
                await ref
                    .read(gachaControllerProvider.notifier)
                    .updateItem(item.id, item.title, reCrop: true);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('画像を更新しました')));
                }
              },
              icon: const Icon(Icons.crop),
              label: const Text('画像を再トリミングする'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          TextButton(
            onPressed: () async {
              // タイトル更新
              await ref
                  .read(gachaControllerProvider.notifier)
                  .updateItem(item.id, titleController.text);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('完了'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, GachaItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${item.title}」を削除しますか？\n※この操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(gachaControllerProvider.notifier).deleteItem(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('削除しました')));
      }
    }
  }
}
