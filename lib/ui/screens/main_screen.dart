import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_quest/data/database/database_helper.dart';
import '../../data/database/database.dart'; // GachaItem型のため
import '../../data/providers.dart';
import '../../logic/settings_controller.dart'; // 設定（表示ON/OFF）のため
import '../widgets/sparkle_effect_overlay.dart';
import 'gacha_screen.dart';
import 'habit_screen.dart';
import 'party_edit_screen.dart';
import 'title_list_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import '../widgets/growth_forecast_chart.dart';
import '../../utils/game_logic/exp_calculator.dart';
import 'boss_battle_screen.dart';

// currentPartnerProvider
final currentPartnerProvider = StreamProvider<GachaItem?>((ref) {
  final repository = ref.watch(partyRepositoryProvider);
  return repository.watchMainPartner();
});

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
    const PartyEditScreen(),
    const GachaScreen(),
    const ShopScreen(),
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
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt),
            label: 'Party',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Gacha',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
        ],
      ),
    );
  }
}

// --- HomeTab (パートナー & フレーム表示) ---
class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  // 成長予報の開閉状態を管理
  bool _isChartExpanded = false;

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);
    final partnerAsync = ref.watch(currentPartnerProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);
    final showEffect = settingsAsync.value?.showEffect ?? true;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'OshiQuest',
          style: TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          tooltip: '設定',
          style: IconButton.styleFrom(
            backgroundColor: Colors.black45,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: '称号',
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              foregroundColor: Colors.amber,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TitleListScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          // 2. ✅ 追加: ボスバトルボタン
          // 称号の隣に配置し、赤色で「バトル」感を演出
          IconButton(
            icon: const Icon(Icons.whatshot), // 炎アイコン
            tooltip: 'ボスバトル',
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              foregroundColor: Colors.redAccent, // アイコン色を赤に
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BossBattleScreen()),
              );
            },
          ),

          const SizedBox(width: 8),
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
          // 1. パートナー画像 (背景)
          partnerAsync.when(
            data: (partner) {
              if (partner == null) {
                return Container(
                  color: const Color(0xFF1A1A2E),
                  child: const Center(
                    child: Text(
                      'パートナーがいません\nガチャで召喚しましょう',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return Image(
                image: partner.displayImageProvider,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('エラー')),
          ),

          // 2. エフェクト
          if (showEffect)
            partnerAsync.when(
              data: (partner) => (partner != null && partner.effectType != EffectType.none)
                  ? SparkleEffectOverlay(effectType: partner.effectType)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

          // 3. ステータス表示エリア
          Positioned(
            top: 110,
            left: 12,
            child: playerAsync.when(
              data: (player) {
                // --- ここで変数を定義するので、このブロック内なら player が使えます ---
                final partner = partnerAsync.value;
                final bonusStr = partner?.strBonus ?? 0;
                final bonusInt = partner?.intBonus ?? 0;
                final bonusLuck = partner?.luckBonus ?? 0;
                final bonusCha = partner?.chaBonus ?? 0;
                final bonusVit = partner?.vitBonus ?? 0;

                // EXP計算 (ExpCalculatorを使用)
                final bool isMax = ExpCalculator.isMaxLevel(player.level);
                final int nextLevelExp = ExpCalculator.requiredExpForNextLevel(player.level);

                double progress;
                String expText;

                if (isMax) {
                  progress = 1.0;
                  expText = "MAX";
                } else {
                  final denominator = nextLevelExp > 0 ? nextLevelExp : 100;
                  progress = player.experience / denominator;
                  if (progress > 1.0) progress = 1.0;
                  expText = "${player.experience}/$nextLevelExp";
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 開閉式ステータスボックス
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isChartExpanded = !_isChartExpanded;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 160,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 名前とLv
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Lv.${player.level} ${player.name}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  _isChartExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // EXPバー
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white12,
                                color: isMax ? Colors.amberAccent : Colors.cyanAccent,
                                minHeight: 3,
                              ),
                            ),

                            // 数値 (開いている時のみ)
                            if (_isChartExpanded)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    expText,
                                    style: TextStyle(
                                      color: isMax ? Colors.amber : Colors.white54,
                                      fontSize: 9,
                                      fontWeight: isMax ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),

                            // 成長予報チャート
                            if (_isChartExpanded) ...[
                              const Divider(color: Colors.white24, height: 12),
                              const GrowthForecastChart(),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // デバフ表示
                    if (player.currentDebuff == 'sloth')
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purpleAccent),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sick, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('怠惰の呪い', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // ステータス一覧
                    _buildStatRow('STR', player.str, bonusStr, Colors.redAccent),
                    const SizedBox(height: 2),
                    _buildStatRow('VIT', player.vit, bonusVit, Colors.orangeAccent),
                    const SizedBox(height: 2),
                    _buildStatRow('INT', player.intellect, bonusInt, Colors.blueAccent),
                    const SizedBox(height: 2),
                    _buildStatRow('LUCK', player.luck, bonusLuck, Colors.purpleAccent),
                    const SizedBox(height: 2),
                    _buildStatRow('CHA', player.cha, bonusCha, Colors.pinkAccent),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  // ステータス行のヘルパー
  Widget _buildStatRow(String label, int base, int bonus, Color color) {
    final total = base + bonus;
    final hasBonus = bonus > 0;

    return IntrinsicWidth(
      // 中身に合わせて幅を調整するWidget
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 横幅を最小限にする
          children: [
            Text(
              "$label $total",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
            if (hasBonus) ...[
              const SizedBox(width: 4), // 数値とボーナスの間隔
              Text("(+$bonus)", style: const TextStyle(color: Colors.greenAccent, fontSize: 10)),
            ],
          ],
        ),
      ),
    );
  }
}
