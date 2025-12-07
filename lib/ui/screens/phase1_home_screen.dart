import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../widgets/gacha_card.dart';

class Phase1HomeScreen extends ConsumerStatefulWidget {
  const Phase1HomeScreen({super.key});

  @override
  ConsumerState<Phase1HomeScreen> createState() => _Phase1HomeScreenState();
}

class _Phase1HomeScreenState extends ConsumerState<Phase1HomeScreen> {
  final TextEditingController _titleController = TextEditingController();

  Future<void> _pickAndSaveImage() async {
    // タイトル入力ダイアログを表示
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('推しのタイトルを入力'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '例: 推しの日常ショット',
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
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) {
      _titleController.clear();
      return;
    }

    try {
      final repository = ref.read(gachaItemRepositoryProvider);
      await repository.pickAndSaveItem(title);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('画像を追加しました！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _titleController.clear();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gachaItemsAsync = ref.watch(gachaItemsProvider);
    final playerAsync = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OshiQuest'),
        actions: [
          // ジェム数表示
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
                  Text(
                    '${player.willGems} Gems',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: gachaItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'まずは画像を追加してBOXを作ろう',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
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
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GachaCard(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'エラーが発生しました',
                style: TextStyle(color: Colors.red[300]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndSaveImage,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('画像追加'),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}

