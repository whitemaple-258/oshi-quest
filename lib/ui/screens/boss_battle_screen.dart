import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart'; // BossResultsなど
import '../../data/providers.dart';
import '../../data/repositories/boss_repository.dart'; // BossStatus, BattleResult
import '../../logic/boss_controller.dart';
import '../../logic/audio_controller.dart';

class BossBattleScreen extends ConsumerWidget {
  const BossBattleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bossStatusAsync = ref.watch(bossControllerProvider);
    final playerAsync = ref.watch(playerProvider);
    final activePartyAsync = ref.watch(activePartyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ボスバトル')),
      body: bossStatusAsync.when(
        data: (statusMap) {
          // 現在のプレイヤー総戦力を計算
          int playerTotalPower = 0;
          if (playerAsync.hasValue && activePartyAsync.hasValue) {
            final p = playerAsync.value!;
            final party = activePartyAsync.value!;
            int bonus = 0;
            for (var item in party.values) {
              bonus +=
                  item.strBonus + item.intBonus + item.luckBonus + item.chaBonus + item.vitBonus;
            }
            playerTotalPower = p.str + p.intellect + p.luck + p.cha + p.vit + bonus;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 現在の戦力表示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigoAccent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flash_on, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '現在の総戦力: $playerTotalPower',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ボスカード
              // ✅ 修正: const を外しました
              _buildBossCard(
                context,
                ref,
                statusMap[BossType.weekly]!,
                'WEEKLY BOSS',
                Colors.blue,
                playerTotalPower,
              ),
              const SizedBox(height: 16),
              _buildBossCard(
                context,
                ref,
                statusMap[BossType.monthly]!,
                'MONTHLY BOSS',
                Colors.purple,
                playerTotalPower,
              ),
              const SizedBox(height: 16),
              _buildBossCard(
                context,
                ref,
                statusMap[BossType.yearly]!,
                'YEARLY BOSS',
                Colors.red,
                playerTotalPower,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('エラー: $e')),
      ),
    );
  }

  Widget _buildBossCard(
    BuildContext context,
    WidgetRef ref,
    BossStatus boss,
    String title,
    Color color,
    int playerPower,
  ) {
    final isWinLikely = playerPower >= boss.bossPower;

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.whatshot, color: color, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    // ✅ 修正: const を削除 (boss.bossPowerは変数)
                    Text('推奨戦力: ${boss.bossPower}', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const Spacer(),
                if (boss.isDefeated)
                  const Chip(
                    label: Text('撃破済み', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.grey,
                  )
                else if (!boss.isAvailable)
                  const Chip(
                    label: Text('出現待ち', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.black54,
                  )
                else
                  FilledButton.icon(
                    onPressed: () => _startBattle(context, ref, boss),
                    style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                    icon: const Icon(RpgAwesome.crossed_swords),
                    label: const Text('BATTLE'),
                  ),
              ],
            ),
            if (boss.isAvailable && !boss.isDefeated) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('報酬: ${boss.rewardGems} Gems', style: const TextStyle(color: Colors.amber)),
                  Text(
                    isWinLikely ? '勝機あり！' : '危険！',
                    style: TextStyle(
                      color: isWinLikely ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startBattle(BuildContext context, WidgetRef ref, BossStatus boss) async {
    await HapticFeedback.heavyImpact();

    final result = await ref.read(bossControllerProvider.notifier).challengeBoss(boss);

    if (context.mounted && result != null) {
      if (result.isWin) {
        ref.read(audioControllerProvider.notifier).playLevelUpSE();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(
              'VICTORY!',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                Text('ボスを撃破しました！\n報酬: ${boss.rewardGems} Gems 獲得'),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('DEFEAT...', style: TextStyle(color: Colors.grey)),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sentiment_very_dissatisfied, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('力が及びませんでした...\nタスクをこなしてステータスを上げましょう！'),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('出直す'))],
          ),
        );
      }
    }
  }
}
