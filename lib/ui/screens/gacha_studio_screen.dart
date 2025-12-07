import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/gacha_item.dart';
import '../../data/database/database.dart';

class GachaStudioScreen extends StatelessWidget {
  final List<GachaItem> boxItems;
  final Function(List<GachaItem>) onItemsUpdated;

  const GachaStudioScreen({super.key, required this.boxItems, required this.onItemsUpdated});

  void _addDemoItems(BuildContext context) {
    // 本来は画像ピッカーで追加する
    final newItems = <GachaItem>[];
    final now = DateTime.now();
    for (int i = 0; i < 5; i++) {
      final isSSR = math.Random().nextBool();
      newItems.add(
        GachaItem(
          id: 0, // 一時的なID（実際のDB保存時は自動生成）
          imagePath: 'https://picsum.photos/seed/${math.Random().nextInt(1000)}/400/600',
          title: '推しの日常ショット #$i',
          rarity: isSSR ? Rarity.ssr : Rarity.n,
          isUnlocked: false,
          strBonus: 0,
          intBonus: 0,
          luckBonus: 0,
          chaBonus: 0,
          bondLevel: 0,
          createdAt: now,
          unlockedAt: null,
        ),
      );
    }
    onItemsUpdated([...boxItems, ...newItems]);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ダミー画像を追加しました')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_special, color: Colors.amber),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("My Sealed Box", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("登録済み画像: 封印中...", style: TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _addDemoItems(context),
            icon: const Icon(Icons.add_a_photo),
            label: const Text("画像追加"),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
