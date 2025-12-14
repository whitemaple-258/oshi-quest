import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../logic/audio_controller.dart';

class GachaAnimationDialog extends ConsumerStatefulWidget {
  final GachaItem item;
  final VoidCallback onAnimationComplete;

  const GachaAnimationDialog({super.key, required this.item, required this.onAnimationComplete});

  @override
  ConsumerState<GachaAnimationDialog> createState() => _GachaAnimationDialogState();
}

class _GachaAnimationDialogState extends ConsumerState<GachaAnimationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    ref.read(audioControllerProvider.notifier).playGachaDrum();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..forward().then((_) {
        // アニメーション完了時に結果音を再生
        ref.read(audioControllerProvider.notifier).playGachaResult();
        // アニメーション完了時にコールバックを実行
        widget.onAnimationComplete();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // レアリティに応じた色を取得
  Color _getBaseColor() {
    switch (widget.item.rarity) {
      case Rarity.ssr:
        return const Color(0xFFFFD700);
      case Rarity.sr:
        return  Colors.purpleAccent;// Gold
      case Rarity.r:
        return Colors.blueAccent;
      case Rarity.n:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _getBaseColor();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 2 * pi * 3; 
          final scale = 1.0 + sin(_controller.value * pi) * 0.5;
          final opacity = _controller.value > 0.8 ? (1.0 - _controller.value) * 5.0 : 1.0;

          // 虹色シェーダーは廃止し、純粋な色を使用
          Widget circleWidget = Transform.rotate(
            angle: angle,
            child: Icon(
              Icons.auto_awesome, 
              size: 200 * scale,
              color: baseColor, // そのままの色を使用
            ),
          );

          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  circleWidget,
                  const SizedBox(height: 32),
                  Text(
                    'Summoning...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: baseColor, blurRadius: 20), // 発光を強めに
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
