import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';

class AnimatedGrowthChart extends StatelessWidget {
  final Player player;
  final Habit habit;
  final int gainedXp; // 今回獲得したXP
  final Animation<double> animation; // 0.0 -> 1.0

  const AnimatedGrowthChart({
    super.key,
    required this.player,
    required this.habit,
    required this.gainedXp,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    // 1. 現在の蓄積値 (After)
    final Map<TaskType, int> currentStats = {
      TaskType.strength: player.tempStrExp,
      TaskType.intelligence: player.tempIntExp,
      TaskType.luck: player.tempLukExp,
      TaskType.charm: player.tempChaExp,
      TaskType.vitality: player.tempVitExp,
    };

    // 2. 以前の蓄積値 (Before)
    final Map<TaskType, int> prevStats = Map.from(currentStats);
    final targetType = habit.taskType;
    prevStats[targetType] = max(0, currentStats[targetType]! - gainedXp);

    // 3. スケール計算
    int maxVal = 1;
    for (var val in currentStats.values) {
      if (val > maxVal) maxVal = val;
    }
    final double scaleMax = maxVal * 1.2;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _GrowthChartPainter(
            prevStats: prevStats,
            currentStats: currentStats,
            targetType: targetType,
            animValue: animation.value,
            scaleMax: scaleMax,
          ),
        );
      },
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final Map<TaskType, int> prevStats;
  final Map<TaskType, int> currentStats;
  final TaskType targetType;
  final double animValue;
  final double scaleMax;

  _GrowthChartPainter({
    required this.prevStats,
    required this.currentStats,
    required this.targetType,
    required this.animValue,
    required this.scaleMax,
  });

  final List<TaskType> _order = [
    TaskType.strength,    // 上
    TaskType.intelligence, // 右上
    TaskType.luck,        // 右下
    TaskType.charm,       // 左下
    TaskType.vitality,    // 左上
  ];

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
      case TaskType.strength: return 'STR';
      case TaskType.intelligence: return 'INT';
      case TaskType.luck: return 'LUK';
      case TaskType.charm: return 'CHA';
      case TaskType.vitality: return 'VIT';
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    // 半径を少し小さくしてラベルスペースを確保
    final radius = min(centerX, centerY) * 0.7; 

    // --- 背景 (五角形ガイド) ---
    final bgPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final r = radius * (i / 3);
      final path = Path();
      for (int j = 0; j < 5; j++) {
        final angle = (j * 2 * pi / 5) - (pi / 2);
        final x = centerX + r * cos(angle);
        final y = centerY + r * sin(angle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, bgPaint);
    }

    // --- チャート本体 (アニメーション補間) ---
    final path = Path();
    final points = <Offset>[];
    final mainColor = _getTypeColor(targetType);

    for (int i = 0; i < 5; i++) {
      final type = _order[i];
      
      final double startVal = prevStats[type]!.toDouble();
      final double endVal = currentStats[type]!.toDouble();
      final double currentVal = startVal + (endVal - startVal) * animValue;

      final normalized = (currentVal / scaleMax).clamp(0.0, 1.0);
      final r = radius * (normalized < 0.05 ? 0.05 : normalized);
      
      // ✅ 修正箇所: 変数 j ではなく i を使用
      final angle = (i * 2 * pi / 5) - (pi / 2);

      final x = centerX + r * cos(angle);
      final y = centerY + r * sin(angle);
      
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // 発光 (Glow)
    final double glowIntensity = 5.0 + (15.0 * animValue);
    final glowPaint = Paint()
      ..color = mainColor.withOpacity(0.6 * animValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowIntensity);
    canvas.drawPath(path, glowPaint);

    // 塗りつぶし
    final fillPaint = Paint()
      ..color = mainColor.withOpacity(0.3 * animValue)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 枠線
    final borderPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    // --- 頂点とラベルの描画 ---
    for (int i = 0; i < 5; i++) {
      final type = _order[i];
      final angle = (i * 2 * pi / 5) - (pi / 2);
      
      // 1. 頂点の描画
      if (type == targetType) {
        canvas.drawCircle(points[i], 4.0 + (2.0 * animValue), Paint()..color = Colors.white);
      } else {
        canvas.drawCircle(points[i], 2.0, Paint()..color = Colors.white30);
      }

      // 2. テキストラベルの描画
      final labelRadius = radius + 20.0; // 頂点の外側に配置
      final labelX = centerX + labelRadius * cos(angle);
      final labelY = centerY + labelRadius * sin(angle);

      final isActive = type == targetType;
      
      final textSpan = TextSpan(
        text: _getTypeLabel(type),
        style: TextStyle(
          color: isActive ? mainColor : Colors.white54,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: isActive ? [Shadow(color: mainColor, blurRadius: 4)] : null,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      // テキストの中心を座標に合わせる
      textPainter.paint(
        canvas, 
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2)
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter old) {
    return old.animValue != animValue || old.currentStats != currentStats;
  }
}