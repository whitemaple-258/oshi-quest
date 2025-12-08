import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import 'gacha_screen.dart'; // ✅ 追加
import 'habit_screen.dart';
import 'registered_items_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  // ✅ 3つの画面を管理
  final List<Widget> _screens = [
    const HomeTab(),
    const HabitScreen(),
    const GachaScreen(), // ✅ 追加
  ];

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
          // ✅ ガチャタブ追加
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Gacha',
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
  // ⚠️ ガチャ関連のロジックは全て GachaScreen へ移動したため削除

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);
    final partnerAsync = ref.watch(currentPartnerProvider);

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
          // 装備変更ボタン
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
                          '右上のリストから装備するか、\nガチャタブで推しを召喚してください',
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
      // ⚠️ FABは削除（GachaScreenへ移動）
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
