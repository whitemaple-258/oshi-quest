import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../widgets/gacha_card.dart';
import 'habit_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const HabitScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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

/// Homeタブ（推し表示 & ステータス確認）
class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final TextEditingController _titleController = TextEditingController();

  Future<void> _pickAndSaveImage() async {
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
    final playerAsync = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OshiQuest'),
        actions: [
          // ステータス表示
          playerAsync.when(
            data: (player) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  // ジェム数
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          '${player.willGems}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ステータス簡易表示
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildStatChip('STR', player.str, Colors.red),
                        const SizedBox(width: 4),
                        _buildStatChip('INT', player.intellect, Colors.blue),
                        const SizedBox(width: 4),
                        _buildStatChip('LUCK', player.luck, Colors.amber),
                        const SizedBox(width: 4),
                        _buildStatChip('CHA', player.cha, Colors.pink),
                      ],
                    ),
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
      body: const Phase1HomeScreenContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndSaveImage,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('画像追加'),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label:$value',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Phase1HomeScreenのコンテンツ部分（AppBarなし）
class Phase1HomeScreenContent extends ConsumerWidget {
  const Phase1HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gachaItemsAsync = ref.watch(gachaItemsProvider);

    return gachaItemsAsync.when(
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
    );
  }
}

