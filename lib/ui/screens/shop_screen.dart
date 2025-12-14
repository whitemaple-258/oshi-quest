import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/shop_controller.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardItemsAsync = ref.watch(rewardItemsProvider);
    final playerAsync = ref.watch(playerProvider);
    final currentGems = playerAsync.value?.willGems ?? 0;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('ご褒美ショップ'),
        backgroundColor: Colors.teal,
        actions: [
          // 所持ジェム表示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$currentGems',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: rewardItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('ご褒美が登録されていません', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddItemDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('ご褒美を登録する'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final canBuy = currentGems >= item.cost;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _confirmPurchase(context, ref, item, canBuy),
                  onLongPress: () => _confirmDelete(context, ref, item),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // アイコンエリア
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: canBuy ? Colors.orangeAccent.withOpacity(0.1) : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.card_giftcard,
                          size: 40,
                          color: canBuy ? Colors.orange : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // タイトル
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      
                      // コスト表示
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: canBuy ? Colors.teal : Colors.grey,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.diamond, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${item.cost}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('商品追加'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  // アイテム追加ダイアログ
  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいご褒美を登録'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'ご褒美の内容 (例: お菓子)'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              decoration: const InputDecoration(labelText: '必要ジェム (例: 100)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final cost = int.tryParse(costController.text) ?? 0;
              
              if (title.isNotEmpty && cost > 0) {
                ref.read(shopControllerProvider.notifier).addItem(title, cost);
                Navigator.pop(context);
              }
            },
            child: const Text('登録'),
          ),
        ],
      ),
    );
  }

  // 購入確認ダイアログ
  void _confirmPurchase(BuildContext context, WidgetRef ref, RewardItem item, bool canBuy) {
    if (!canBuy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ジェムが足りません！ タスクをこなして貯めましょう。')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ご褒美の購入'),
        content: Text('「${item.title}」を交換しますか？\n消費: ${item.cost} ジェム'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(shopControllerProvider.notifier).buyItem(item);
              if (success && context.mounted) {
                // 購入成功演出
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
                        const SizedBox(height: 16),
                        const Text('交換しました！', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('交換する', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 削除確認 (長押し)
  void _confirmDelete(BuildContext context, WidgetRef ref, RewardItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除'),
        content: Text('「${item.title}」をショップから削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(shopControllerProvider.notifier).deleteItem(item.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}