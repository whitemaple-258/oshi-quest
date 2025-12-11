import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
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
  Rarity _selectedRarity = Rarity.n;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickAndSaveImage() async {
    _selectedRarity = Rarity.n;
    _titleController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('推しのタイトルを入力'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: '例: 推しの日常ショット'),
                ),
                const SizedBox(height: 16),
                const Text('レアリティを選択', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<Rarity>(
                  segments: const [
                    ButtonSegment(value: Rarity.n, label: Text('N')),
                    ButtonSegment(value: Rarity.r, label: Text('R')),
                    ButtonSegment(value: Rarity.sr, label: Text('SR')),
                    ButtonSegment(value: Rarity.ssr, label: Text('SSR')),
                  ],
                  selected: {_selectedRarity},
                  onSelectionChanged: (Set<Rarity> newSelection) {
                    setState(() => _selectedRarity = newSelection.first);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
            ],
          );
        },
      ),
    );

    if (result == true && _titleController.text.trim().isNotEmpty) {
      try {
        final repository = ref.read(gachaItemRepositoryProvider);
        await repository.pickAndSaveItem(
          _titleController.text.trim(),
          rarity: _selectedRarity, // ✅ 引数を渡す
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('登録しました！')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
    }
  }

  void _pullGacha() async {
    try {
      final resultItem = await ref.read(gachaControllerProvider.notifier).pullGacha();
      if (resultItem != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => GachaAnimationDialog(
            item: resultItem,
            onAnimationComplete: () {},
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);
    final gachaState = ref.watch(gachaControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('召喚の間'),
        actions: [
          playerAsync.when(
            data: (player) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('${player.willGems} 💎', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              Icon(Icons.auto_awesome, size: 80, color: colorScheme.primary),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton.icon(
                  onPressed: gachaState.isLoading ? null : _pullGacha,
                  icon: const Icon(Icons.stars),
                  label: Text(gachaState.isLoading ? '召喚中...' : '1回召喚 (100💎)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GachaLineupScreen())),
                icon: const Icon(Icons.grid_view),
                label: const Text('ラインナップ確認'),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: gachaState.isLoading ? null : _pickAndSaveImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('画像を登録する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}