import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../logic/gacha_controller.dart';
import '../widgets/magic_circle_dialog.dart';
import 'habit_screen.dart';
import 'registered_items_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const HomeTab(), const HabitScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Quests',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

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

  void _pullGacha() async {
    try {
      // コントローラー経由でガチャを実行
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
        // エラーメッセージの整形
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
    final partnerAsync = ref.watch(currentPartnerProvider);

    // ✅ 追加: ガチャ状態を監視（処理中の破棄を防ぐ）
    final gachaState = ref.watch(gachaControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'OshiQuest',
          style: TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // ✅ リストボタン（登録アイテム一覧へ）
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: '推し一覧・装備変更',
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisteredItemsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // パートナー画像表示
          partnerAsync.when(
            data: (partner) {
              if (partner == null) {
                return Container(
                  color: const Color(0xFF1A1A2E),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_alt_1, size: 80, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        const Text(
                          'パートナーがいません',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '右上のリストから装備するか、\nガチャで推しを召喚してください',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Image.file(
                File(partner.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('エラーが発生しました')),
          ),

          // ステータス表示
          Positioned(
            top: 100,
            left: 16,
            child: playerAsync.when(
              data: (player) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatBadge('Lv.${player.level}', Colors.white, Colors.black54),
                  const SizedBox(height: 8),
                  _buildStatBadge('STR ${player.str}', Colors.redAccent, Colors.black54),
                  const SizedBox(height: 4),
                  _buildStatBadge('INT ${player.intellect}', Colors.blueAccent, Colors.black54),
                  const SizedBox(height: 4),
                  _buildStatBadge('LUCK ${player.luck}', Colors.amber, Colors.black54),
                  const SizedBox(height: 4),
                  _buildStatBadge('CHA ${player.cha}', Colors.pinkAccent, Colors.black54),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_image',
            onPressed: gachaState.isLoading ? null : _pickAndSaveImage,
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.add_photo_alternate),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'summon',
            // 処理中はボタンを無効化
            onPressed: gachaState.isLoading ? null : _pullGacha,
            icon: gachaState.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(gachaState.isLoading ? '召喚中...' : '召喚 (100💎)'),
            backgroundColor: Colors.pinkAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
    );
  }
}
