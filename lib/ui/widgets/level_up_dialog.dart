import 'package:flutter/material.dart';
import '../../data/database/database.dart'; // Playerクラスのために必要

class LevelUpDialog extends StatefulWidget {
  final Player player;            // 最新のプレイヤーデータ
  final Map<String, int> result;  // 上昇値データ (strUp, vitUp...)
  final VoidCallback onClosed;

  const LevelUpDialog({
    super.key,
    required this.player,
    required this.result,
    required this.onClosed,
  });

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();

    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 今回の上昇値を取り出し
    final int strUp = widget.result['strUp'] ?? 0;
    final int vitUp = widget.result['vitUp'] ?? 0;
    final int intUp = widget.result['intUp'] ?? 0;
    final int luckUp = widget.result['luckUp'] ?? 0;
    final int chaUp = widget.result['chaUp'] ?? 0;

    // 前のレベルを計算
    final int oldLevel = widget.player.level - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 4),
            boxShadow: [
              BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.keyboard_double_arrow_up, size: 60, color: Colors.amber),
              const SizedBox(height: 8),
              
              // --- タイトル ---
              const Text(
                'LEVEL UP!',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [Shadow(color: Colors.orange, blurRadius: 10)],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // --- レベル変化 (Lv.9 -> Lv.10) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lv.$oldLevel',
                    style: const TextStyle(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                  ),
                  Text(
                    'Lv.${widget.player.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40, // 少し大きく強調
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.amber, blurRadius: 8)],
                    ),
                  ),
                ],
              ),

              const Divider(color: Colors.white24, height: 24),

              // --- ステータス変化一覧 ---
              // Flexibleで囲むことで、画面が小さい端末でもはみ出しにくくします
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildStatRow("STR", widget.player.str, strUp, Colors.redAccent),
                      _buildStatRow("VIT", widget.player.vit, vitUp, Colors.orangeAccent),
                      _buildStatRow("INT", widget.player.intellect, intUp, Colors.blueAccent),
                      _buildStatRow("LUCK", widget.player.luck, luckUp, Colors.purpleAccent),
                      _buildStatRow("CHA", widget.player.cha, chaUp, Colors.pinkAccent),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- OKボタン ---
              ElevatedButton(
                onPressed: () {
                  widget.onClosed();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  elevation: 5,
                ),
                child: const Text('OK!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ステータス行を作成するヘルパーメソッド
  Widget _buildStatRow(String label, int currentVal, int upVal, Color color) {
    final int oldVal = currentVal - upVal;
    final bool hasIncreased = upVal > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // ラベル (STRなど)
          Container(
            width: 45,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),

          // 数値変化 (100 -> 105)
          Expanded(
            child: Row(
              children: [
                Text("$oldVal", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_right, color: Colors.white30, size: 16),
                const SizedBox(width: 8),
                Text(
                  "$currentVal", 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 16, 
                    fontWeight: hasIncreased ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // 上昇値 (+5)
          if (hasIncreased)
            Text(
              "+$upVal",
              style: const TextStyle(
                color: Colors.amberAccent, 
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                shadows: [Shadow(color: Colors.orange, blurRadius: 2)],
              ),
            )
          else
            const Text("-", style: TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }
}