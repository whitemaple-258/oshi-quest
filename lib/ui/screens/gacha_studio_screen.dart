import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/gacha_item.dart';

class GachaStudioScreen extends StatelessWidget {
  final List<GachaItem> boxItems;
  final Function(List<GachaItem>) onItemsUpdated;

  const GachaStudioScreen({
    super.key,
    required this.boxItems,
    required this.onItemsUpdated,
  });

  void _addDemoItems(BuildContext context) {
    // 本来は画像ピッカーで追加する
    final newItems = <GachaItem>[];
    for (int i = 0; i < 5; i++) {
      newItems.add(
        GachaItem(
          id: DateTime.now().toString() + i.toString(),
          imageUrl: 'https://picsum.photos/seed/${math.Random().nextInt(1000)}/400/600',
          title: '推しの日常ショット #$i',
          isSSR: math.Random().nextBool(), // ランダムでSSR化
        ),
      );
    }
    onItemsUpdated([...boxItems, ...newItems]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ダミー画像を追加しました')),
    );
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
              Text(
                "My Sealed Box",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "登録済み画像: 封印中...",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
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

