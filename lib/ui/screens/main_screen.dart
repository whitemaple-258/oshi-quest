import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart'; // GachaItem型のため
import '../../data/providers.dart';
import '../../logic/settings_controller.dart'; // 設定（表示ON/OFF）のため
import '../widgets/sparkle_effect_overlay.dart';
import 'gacha_screen.dart';
import 'habit_screen.dart';
import 'party_edit_screen.dart';
import 'title_list_screen.dart';
import 'settings_screen.dart';

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
            tooltip: '称号コレクション',
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
          // 1. パートナー画像 (一番下)
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
                          'Partyタブから推しを編成するか、\nGachaタブで召喚してください',
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

          // 2. エフェクト表示 (パートナーの上に重ねる)
          if (showEffect)
            partnerAsync.when(
              data: (partner) {
                if (partner == null || partner.effectType == EffectType.none) {
                  return const SizedBox.shrink();
                }
                return SparkleEffectOverlay(effectType: partner.effectType);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

          // 3. ステータス表示 (一番上)
          Positioned(
            top: 100,
            left: 16,
            child: playerAsync.when(
              data: (player) {
                final partner = partnerAsync.value;
                final bonusStr = partner?.strBonus ?? 0;
                final bonusInt = partner?.intBonus ?? 0;
                final bonusLuck = partner?.luckBonus ?? 0;
                final bonusCha = partner?.chaBonus ?? 0;
                final bonusVit = partner?.vitBonus ?? 0;

                // final nextLevelExp = player.level * 100;
                final currentLevelStartExp = (player.level - 1) * 100;
                final currentProgressExp = player.experience - currentLevelStartExp;
                final requiredExpForNext = 100;
                final progress = (currentProgressExp / requiredExpForNext).clamp(0.0, 1.0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lvバッジ & EXPバー
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lv.${player.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white24,
                                  color: Colors.amber,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'EXP: $currentProgressExp / $requiredExpForNext',
                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // デバフ表示
                    if (player.currentDebuff == 'sloth')
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.purpleAccent),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sick, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '怠惰の呪い',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),
                    _buildStatRow('STR', player.str, bonusStr, Colors.redAccent),
                    const SizedBox(height: 4),
                    _buildStatRow('VIT', player.vit, bonusVit, Colors.orange),
                    const SizedBox(height: 4),
                    _buildStatRow('INT', player.intellect, bonusInt, Colors.blueAccent),
                    const SizedBox(height: 4),
                    _buildStatRow('LUCK', player.luck, bonusLuck, Colors.purpleAccent),
                    const SizedBox(height: 4),
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

  /// エフェクト描画用Widgetを構築するメソッド（最新版）
  ///
  /// [mainPartner] 現在設定されているメインパートナーのデータ（いない場合はnull）
  /// [showEffect] 設定画面でのエフェクト表示設定（trueなら表示）
  Widget _buildEffectOverlay(GachaItem? mainPartner, bool showEffect) {
    // 1. 表示条件のチェック
    // 設定がOFF、キャラが未設定、またはエフェクトタイプが「none」の場合は何も表示しない
    if (!showEffect || mainPartner == null || mainPartner.effectType == EffectType.none) {
      return const SizedBox.shrink();
    }

    // 2. エフェクトWidgetを配置
    // EffectType Enumを渡すだけで、内部でマスターデータを参照して適切な描画が行われます。
    // Stackの上に重ねて表示されるため、キャラクター画像の前面にエフェクトが出現します。
    return SparkleEffectOverlay(
      effectType: mainPartner.effectType,
    );
  }

  Widget _buildStatRow(String label, int base, int bonus, Color color) {
    final total = base + bonus;
    final hasBonus = bonus > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label $total ',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
            if (hasBonus)
              TextSpan(
                text: '(+$bonus)',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}
