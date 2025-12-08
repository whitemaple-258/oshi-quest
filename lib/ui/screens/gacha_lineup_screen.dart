import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';

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
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}
