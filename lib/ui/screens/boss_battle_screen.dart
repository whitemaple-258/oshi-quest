import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import '../../logic/boss_battle_controller.dart';
import '../../logic/audio_controller.dart';
import '../../data/database/database.dart';
import '../../data/repositories/party_repository.dart';
import '../../data/extensions/gacha_item_extension.dart';

class BossBattleScreen extends ConsumerWidget {
  const BossBattleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battleState = ref.watch(bossBattleControllerProvider);

    ref.listen(bossBattleControllerProvider, (previous, next) {
      if (next != null && next.isFinished && (previous == null || !previous.isFinished)) {
        _showResultDialog(context, ref, next.isWin, next.bossData.rewardGems);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: battleState == null 
        ? const _LobbyView() 
        : SafeArea(child: _ActiveBattleView(state: battleState)),
    );
  }

  void _showResultDialog(BuildContext context, WidgetRef ref, bool isWin, int reward) {
    if (isWin) ref.read(audioControllerProvider.notifier).playLevelUpSE();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(isWin ? 'VICTORY' : 'DEFEAT', textAlign: TextAlign.center, style: TextStyle(color: isWin ? Colors.amber : Colors.red)),
        content: Text(isWin ? 'ボスを撃破！\n$reward Gems獲得！' : '敗北しました...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.invalidate(bossBattleControllerProvider);
              if (Navigator.canPop(context)) Navigator.pop(context);
            }, 
            child: const Text('OK')
          ),
        ],
      ),
    );
  }
}

class _SkillCutInOverlay extends StatelessWidget {
  final BattleCharacter char;
  const _SkillCutInOverlay({required this.char});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        // 画面幅を活用した計算
        final screenWidth = MediaQuery.of(context).size.width;
        
        return Stack(
          children: [
            // 1. 背景の斜めスリット（黒）
            Center(
              child: Transform.translate(
                offset: Offset((1 - value) * screenWidth, 0),
                child: ClipPath(
                  clipper: _SkewClipper(),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            
            // 2. 背景のアクセントライン（金）
            Center(
              child: Transform.translate(
                offset: Offset((1 - value) * -screenWidth * 1.2, 0),
                child: ClipPath(
                  clipper: _SkewClipper(),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.withOpacity(0.8), Colors.orange.withOpacity(0.0)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. キャラクター立ち絵 (下から突き抜けるように登場)
            Positioned(
              bottom: -50,
              left: 20 + (value * 30), // 少し右にスライド
              child: Opacity(
                opacity: (value * 2).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.8 + (value * 0.2), // ズームアップ
                  child: Image(
                    image: char.originalItem.displayImageProvider,
                    height: MediaQuery.of(context).size.height * 0.9,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // 4. スキル名テキスト
            Align(
              alignment: const Alignment(0.6, 0.1), // 右寄りに配置
              child: Opacity(
                opacity: value > 0.6 ? 1.0 : 0.0,
                child: Transform.translate(
                  offset: Offset((1 - value) * 100, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'SPECIAL SKILL',
                        style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 4),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white, width: 3)),
                        ),
                        child: Text(
                          char.skill.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -1,
                            shadows: [Shadow(color: Colors.orange, blurRadius: 15)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 5. 画面全体のフラッシュ（一瞬だけ光る）
            if (value > 0.1 && value < 0.3)
              Positioned.fill(child: Container(color: Colors.white.withOpacity(0.3))),
          ],
        );
      },
    );
  }
}

// 斜め切り抜き用のクリッパー
class _SkewClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getPath(size);
  
  @override
  Path getPath(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.2); // 左上を少し下げる
    path.lineTo(size.width, 0);       // 右上
    path.lineTo(size.width, size.height * 0.8); // 右下を少し上げる
    path.lineTo(0, size.height);      // 左下
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- バトルメイン画面 (ポケモン風・対角線レイアウト) ---
class _ActiveBattleView extends StatelessWidget {
  final BattleState state;
  const _ActiveBattleView({required this.state});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // 画面サイズに応じた描画領域の計算
    final bossAreaHeight = screenSize.height * 0.3; // 画面高さの30%
    final bossAreaWidth = screenSize.width * 0.45;  // 画面幅の45%
    final mainAreaHeight = screenSize.height * 0.35; // 画面高さの35%
    final mainAreaWidth = screenSize.width * 0.5;    // 画面幅の50%

    return Stack(
      children: [
        Column(
          children: [
            // 1. バトルフィールド (上部 7割)
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.grey[900]!],
                  ),
                ),
                child: Stack(
                  children: [
                    // --- A. ボスエリア (右奥) ---
                    Positioned(
                      top: 30,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end, // 右寄せ
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ボス情報ヘッダー
                          Text(state.bossData.name, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 150,
                            child: _HpBar(current: state.bossCurrentHp, max: state.bossData.maxHp, color: Colors.red, label: '', height: 10),
                          ),
                          const SizedBox(height: 8),
                          // ボス画像エリア (将来的に画像)
                          // 領域を固定し、はみ出さないようにする
                          SizedBox(
                            height: bossAreaHeight,
                            width: bossAreaWidth,
                            child: FittedBox(
                              fit: BoxFit.contain, // 枠内に収める
                              child: Icon(_getBossIcon(state.bossType), color: Colors.redAccent.withOpacity(0.9)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- B. メインキャラエリア (左手前) ---
                    Positioned(
                      bottom: 20, // コマンドゾーンの少し上
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // メインキャラ情報ヘッダー
                          Text(state.party.mainChar.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 150,
                            child: _HpBar(
                              current: state.party.mainChar.currentHp,
                              max: state.party.mainChar.maxHp,
                              color: Colors.green, label: '', height: 10
                            ),
                          ),
                          const SizedBox(height: 8),
                          // メインキャラ画像エリア
                          Opacity(
                            opacity: state.party.mainChar.currentHp <= 0 ? 0.3 : 1.0,
                            child: SizedBox(
                              height: mainAreaHeight,
                              width: mainAreaWidth,
                              // 将来的に右向きの画像を用意するか、ここで反転させる
                              // child: Transform.scale(scaleX: -1, child: Image(...))
                              child: Image(
                                image: state.party.mainChar.originalItem.displayImageProvider,
                                fit: BoxFit.contain, // 枠内に収める
                                alignment: Alignment.bottomLeft, // 左下基準で配置
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- C. フローティングログ (左上配置に変更) ---
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 100,
                        width: screenSize.width * 0.4, // 幅を制限
                        child: ListView.builder(
                          reverse: true,
                          itemCount: state.battleLog.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Text(
                              state.battleLog[state.battleLog.length - 1 - i],
                              style: const TextStyle(color: Colors.white70, fontSize: 11, shadows: [Shadow(blurRadius: 2, color: Colors.black)]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. コマンドゾーン (下部カード) - 変更なし
            Container(
              height: 180,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.9), border: const Border(top: BorderSide(color: Colors.amber, width: 0.5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: state.party.subChars.map((char) => _SubCard(char: char, ct: state.skillCooldowns[char.id] ?? 0)).toList(),
              ),
            ),
          ],
        ),

        // 3. カットインレイヤー - 変更なし
        if (state.cutInChar != null) _SkillCutInOverlay(char: state.cutInChar!),
      ],
    );
  }

  IconData _getBossIcon(BossType type) {
    switch (type) {
      case BossType.weekly: return RpgAwesome.skull;
      case BossType.monthly: return RpgAwesome.hydra;
      case BossType.yearly: return RpgAwesome.dragon;
    }
  }
}

// --- 以下、カードUIや共通部品は前回と同じ ---
class _SubCard extends StatelessWidget {
  final BattleCharacter char;
  final int ct;
  const _SubCard({required this.char, required this.ct});

  @override
  Widget build(BuildContext context) {
    final isDead = char.currentHp <= 0;
    return Container(
      width: 85,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDead ? Colors.red : Colors.white24),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image(image: char.originalItem.displayImageProvider, fit: BoxFit.cover, alignment: const Alignment(0, -0.6)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                _HpBar(current: char.currentHp, max: char.maxHp, color: Colors.green, label: '', height: 4, showText: false),
                const SizedBox(height: 2),
                Text(ct > 0 ? 'CT: $ct' : 'READY', style: TextStyle(fontSize: 8, color: ct > 0 ? Colors.cyan : Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HpBar extends StatelessWidget {
  final int current, max;
  final Color color;
  final String label;
  final double height;
  final bool showText;
  const _HpBar({required this.current, required this.max, required this.color, required this.label, this.height = 10, this.showText = true});

  @override
  Widget build(BuildContext context) {
    double pct = max > 0 ? (current / max).clamp(0, 1) : 0;
    return Column(
      children: [
        if (showText) Text('$current / $max', style: const TextStyle(color: Colors.white, fontSize: 10, shadows: [Shadow(blurRadius: 2, color: Colors.black)])),
        ClipRRect(
          borderRadius: BorderRadius.circular(height/2),
          child: LinearProgressIndicator(value: pct, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(color), minHeight: height),
        ),
      ],
    );
  }
}

class _LobbyView extends ConsumerWidget {
  const _LobbyView();

  @override
  // WidgetRef ref を引数に追加
  Widget build(BuildContext context, WidgetRef ref) { 
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'BOSS BATTLE', 
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(RpgAwesome.skull),
            label: const Text('WEEKLY BOSS に挑戦'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, 
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
            ),
            // これで ref が正しく参照できるようになります
            onPressed: () => ref.read(bossBattleControllerProvider.notifier).startBattle(BossType.weekly),
          ),
        ],
      ),
    );
  }
}