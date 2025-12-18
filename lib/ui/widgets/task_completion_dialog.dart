import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import 'animated_growth_chart.dart'; // さっき作ったファイル

class TaskCompletionDialog extends StatefulWidget {
  final Habit habit;
  final Player player;
  final Map<String, int> result;

  const TaskCompletionDialog({
    super.key,
    required this.habit,
    required this.player,
    required this.result,
  });

  @override
  State<TaskCompletionDialog> createState() => _TaskCompletionDialogState();
}

class _TaskCompletionDialogState extends State<TaskCompletionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200), // 1.2秒で演出
      vsync: this,
    );

    // 弾むようなアニメーション (ElasticOut) で急激に伸びて落ち着く
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, 
    );

    // 表示から少し遅れて開始
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTypeColor(TaskType type) {
    switch (type) {
      case TaskType.strength: return Colors.redAccent;
      case TaskType.intelligence: return Colors.blueAccent;
      case TaskType.luck: return Colors.purpleAccent;
      case TaskType.charm: return Colors.pinkAccent;
      case TaskType.vitality: return Colors.orangeAccent;
    }
  }

  String _getTypeLabel(TaskType type) {
     switch (type) {
      case TaskType.strength: return 'STR (筋力)';
      case TaskType.intelligence: return 'INT (知力)';
      case TaskType.luck: return 'LUK (幸運)';
      case TaskType.charm: return 'CHA (魅力)';
      case TaskType.vitality: return 'VIT (体力)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(widget.habit.taskType);
    final typeLabel = _getTypeLabel(widget.habit.taskType);
    
    final gems = widget.result['gems'] ?? 0;
    final xp = widget.result['xp'] ?? 0; // ここでのXPは蓄積経験値と同じ量
    final intimacy = widget.result['intimacyGained'] ?? 0;

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            const Text(
              "QUEST CLEAR!",
              style: TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
                shadows: [Shadow(color: Colors.orange, blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.habit.name,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ✅ 成長予報チャート (アニメーション付き)
            SizedBox(
              height: 200,
              width: 200,
              child: AnimatedGrowthChart(
                player: widget.player,
                habit: widget.habit,
                gainedXp: xp, // 獲得XP = 蓄積される値
                animation: _animation,
              ),
            ),
            
            // 成長メッセージ
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "$typeLabel が成長中...",
                style: TextStyle(
                  color: typeColor, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 14,
                  shadows: [Shadow(color: typeColor, blurRadius: 10)], // 文字も光らせる
                ),
              ),
            ),

            // 報酬エリア
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRewardItem(Icons.diamond, Colors.cyanAccent, "+$gems"),
                  _buildRewardItem(Icons.bolt, Colors.amberAccent, "+$xp XP"),
                  if (intimacy > 0)
                    _buildRewardItem(Icons.favorite, Colors.pinkAccent, "+$intimacy"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 閉じるボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("閉じる", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}