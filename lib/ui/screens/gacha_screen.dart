import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/gacha_controller.dart';
import '../widgets/gacha_animation_dialog.dart';
import 'gacha_lineup_screen.dart';
import 'gacha_sequence_screen.dart';
import 'gacha_result_screen.dart';
import 'bulk_sell_screen.dart';

class GachaScreen extends ConsumerStatefulWidget {
  const GachaScreen({super.key});

  @override
  ConsumerState<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends ConsumerState<GachaScreen> {
  final TextEditingController _titleController = TextEditingController();
  // 選択中のレアリティ（デフォルトN）
  Rarity _selectedRarity = Rarity.n;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // --- 画像追加ロジック ---
  Future<void> _pickAndSaveImage() async {
    // 初期化
    _titleController.clear();
    _selectedRarity = Rarity.n;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('ガチャにアイテムを追加'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'あなたの推し画像を登録して、\nガチャのラインナップに追加します。',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'タイトル',
                    hintText: '例: 推しの日常ショット',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: false,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('レアリティ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                // レアリティ選択
                SegmentedButton<Rarity>(
                  segments: const [
                    ButtonSegment(value: Rarity.n, label: Text('N')),
                    ButtonSegment(value: Rarity.r, label: Text('R')),
                    ButtonSegment(value: Rarity.sr, label: Text('SR')),
                    ButtonSegment(value: Rarity.ssr, label: Text('SSR')),
                  ],
                  selected: {_selectedRarity},
                  onSelectionChanged: (Set<Rarity> newSelection) {
                    setState(() {
                      _selectedRarity = newSelection.first;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    try {
      final repository = ref.read(gachaItemRepositoryProvider);

      // ✅ 修正: 名前付き引数で渡す
      await repository.pickAndSaveItem(
        _titleController.text.trim(),
        rarity: _selectedRarity,
        type: GachaItemType.character, // デフォルト
      );

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

  // --- 単発ガチャ実行ロジック ---
  void _pullGacha() async {
    try {
      final resultItem = await ref.read(gachaControllerProvider.notifier).pullGacha();

      if (resultItem != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => GachaAnimationDialog(
            item: resultItem,
            onAnimationComplete: () {
              Navigator.pop(ctx);

              // ✅ 修正: 共通の結果画面へ遷移 (リストにして渡す)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GachaResultScreen(results: [resultItem])),
              );
            },
          ),
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

  // --- 10連ガチャ実行ロジック ---
  void _pullGacha10() async {
    try {
      // 1. ガチャ実行
      final resultItems = await ref.read(gachaControllerProvider.notifier).pullGacha10();

      if (resultItems.isNotEmpty && mounted) {
        // 2. 演出用の「代表キャラ（最高レア）」を決定
        // (SSRがあればSSR演出、なければSR演出...とするため)
        GachaItem bestItem = resultItems[0];
        for (final item in resultItems) {
          // 列挙型のindex比較 (N=0, R=1, SR=2, SSR=3 前提)
          if (item.rarity.index > bestItem.rarity.index) {
            bestItem = item;
          }
        }

        // 3. 魔法陣アニメーションを表示
        // (単発と同じダイアログを使い、最高レアの色で演出する)
        showDialog(
          context: context,
          barrierDismissible: false, // アニメ中は閉じられないようにする
          builder: (ctx) => GachaAnimationDialog(
            item: bestItem, // ここに最高レアを渡すことで色が変化
            onAnimationComplete: () {
              // アニメーション完了後の処理
              Navigator.pop(ctx); // ダイアログを閉じる

              // 4. 10連シーケンス画面へ遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => GachaSequenceScreen(items: resultItems),
                ),
              );
            },
          ),
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

    // テーマカラーを取得
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final onPrimaryColor = colorScheme.onPrimary;

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
              // ガチャアイコン（テーマカラー適用）
              Icon(Icons.auto_awesome, size: 80, color: primaryColor),

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
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: onPrimaryColor),
                        )
                      : const Icon(Icons.stars),
                  label: Text(gachaState.isLoading ? '召喚中...' : '1回召喚 (100💎)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: onPrimaryColor,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- ✅ 10連ガチャボタン ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton.icon(
                  onPressed: gachaState.isLoading ? null : _pullGacha10,
                  icon: gachaState.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: onPrimaryColor),
                        )
                      : const Icon(Icons.stars),
                  label: Text(gachaState.isLoading ? '召喚中...' : '10回召喚 (1000💎)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: onPrimaryColor,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

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

              // ✅ ここに追加: 一括売却ボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BulkSellScreen()),
                    );
                  },
                  icon: const Icon(Icons.sell, color: Colors.orangeAccent),
                  label: const Text('キャラ売却・整理 (ジェム獲得)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orangeAccent,
                    side: const BorderSide(color: Colors.orangeAccent),
                  ),
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
