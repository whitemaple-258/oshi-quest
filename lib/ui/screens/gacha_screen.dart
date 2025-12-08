import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../logic/gacha_controller.dart';
import '../widgets/magic_circle_dialog.dart';
import 'gacha_lineup_screen.dart';

class GachaScreen extends ConsumerStatefulWidget {
  const GachaScreen({super.key});

  @override
  ConsumerState<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends ConsumerState<GachaScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // --- 画像追加ロジック (移植) ---
  Future<void> _pickAndSaveImage() async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('推しのタイトルを入力'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '例: 推しの日常ショット',
            helperText: '※追加した画像はガチャから排出されるまでロックされます',
            border: OutlineInputBorder(),
          ),
          autofocus: false,
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
          const SnackBar(content: Text('ガチャBOXに追加しました！'), backgroundColor: Colors.green),
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

  // --- ガチャ実行ロジック (移植) ---
  void _pullGacha() async {
    try {
      final resultItem = await ref.read(gachaControllerProvider.notifier).pullGacha();

      if (resultItem != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => GachaAnimationDialog(item: resultItem, onAnimationComplete: () {}),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);
    final gachaState = ref.watch(gachaControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('召喚の間'),
        actions: [
          // ジェム表示
          playerAsync.when(
            data: (player) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.pinkAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.diamond, color: Colors.cyanAccent, size: 16),
                    const SizedBox(width: 4),
                    Text('${player.willGems}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ガチャ演出用アイコン（装飾）
              const Icon(Icons.auto_awesome, size: 80, color: Colors.pinkAccent),
              const SizedBox(height: 24),
              const Text('運命の推しを召喚せよ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 48),

              // 1. 召喚ボタン
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton.icon(
                  onPressed: gachaState.isLoading ? null : _pullGacha,
                  icon: gachaState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.stars),
                  label: Text(gachaState.isLoading ? '召喚中...' : '1回召喚 (100💎)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. ラインナップ確認ボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GachaLineupScreen()),
                    );
                  },
                  icon: const Icon(Icons.grid_view),
                  label: const Text('提供割合・ラインナップ確認'),
                ),
              ),
              const SizedBox(height: 16),

              // 3. 画像追加ボタン（種）
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: gachaState.isLoading ? null : _pickAndSaveImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('ガチャの種（画像）を追加する'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
