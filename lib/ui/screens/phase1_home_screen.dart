import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../logic/gacha_controller.dart'; // コントローラーをインポート
import '../widgets/gacha_card.dart';
import '../widgets/magic_circle_dialog.dart';

class Phase1HomeScreen extends ConsumerStatefulWidget {
  const Phase1HomeScreen({super.key});

  @override
  ConsumerState<Phase1HomeScreen> createState() => _Phase1HomeScreenState();
}

class _Phase1HomeScreenState extends ConsumerState<Phase1HomeScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // 画像追加処理
  Future<void> _pickAndSaveImage() async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('推し画像を追加（ガチャの種）'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'タイトルを入力',
            helperText: '※追加した画像はガチャから排出されるまでロックされます',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _titleController.clear();
            },
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              if (_titleController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(_titleController.text.trim());
              }
            },
            child: const Text('追加する'),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    try {
      final repository = ref.read(gachaItemRepositoryProvider);
      await repository.pickAndSaveItem(title);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ガチャBOXに追加しました！ジェムを貯めて召喚しましょう。'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: $e'), backgroundColor: Colors.red));
      }
    } finally {
      _titleController.clear();
    }
  }

  // ガチャ実行処理
  void _pullGacha() async {
    try {
      // コントローラー経由でガチャを実行
      final resultItem = await ref.read(gachaControllerProvider.notifier).pullGacha();

      if (resultItem != null && mounted) {
        // 演出ダイアログを表示
        showDialog(
          context: context,
          barrierDismissible: false, // 演出中は閉じられないようにする
          builder: (context) => GachaAnimationDialog(
            item: resultItem,
            onAnimationComplete: () {
              // アニメーション完了後の処理（必要なら）
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 獲得済みのアイテムのみ表示したい場合はフィルタリング推奨
    final gachaItemsAsync = ref.watch(gachaItemsProvider);
    final playerAsync = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OshiQuest'),
        actions: [
          playerAsync.when(
            data: (player) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.pinkAccent),
              ),
              child: Row(
                children: [
                  const Icon(Icons.diamond, color: Colors.cyanAccent, size: 16),
                  const SizedBox(width: 8),
                  Text('${player.willGems}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: gachaItemsAsync.when(
        data: (items) {
          // ロック解除済みのアイテムだけを表示（BOX）
          final unlockedItems = items.where((i) => i.isUnlocked).toList();

          if (unlockedItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('獲得した推しはいません', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _pickAndSaveImage,
                    icon: const Icon(Icons.add),
                    label: const Text('ガチャの種を追加する'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: unlockedItems.length,
            itemBuilder: (context, index) {
              final item = unlockedItems[index];
              return GachaCard(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('エラーが発生しました')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 画像追加ボタン（小）
          FloatingActionButton.small(
            heroTag: 'add_image',
            onPressed: _pickAndSaveImage,
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.add_photo_alternate),
          ),
          const SizedBox(height: 16),
          // ガチャボタン（大）
          FloatingActionButton.extended(
            heroTag: 'summon',
            onPressed: _pullGacha,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('1回召喚 (100💎)'),
            backgroundColor: Colors.pinkAccent,
          ),
        ],
      ),
    );
  }
}
