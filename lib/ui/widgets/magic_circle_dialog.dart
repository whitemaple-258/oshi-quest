import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../data/database/database.dart';
import '../../logic/audio_controller.dart';

// ConsumerStatefulWidget に変更して Riverpod を使えるようにする
class GachaAnimationDialog extends ConsumerStatefulWidget {
  final GachaItem item;
  final VoidCallback onAnimationComplete;

  const GachaAnimationDialog({super.key, required this.item, required this.onAnimationComplete});

  @override
  ConsumerState<GachaAnimationDialog> createState() => _GachaAnimationDialogState();
}

class _GachaAnimationDialogState extends ConsumerState<GachaAnimationDialog>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _scaleController;

  // ドラムロールの長さに合わせて調整 (例: 4秒)
  final Duration _drumDuration = const Duration(seconds: 4);

  bool _showResult = false;

  @override
  void initState() {
    super.initState();

    // 魔法陣のアニメーション
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();

    // 出現アニメーション
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 開始シーケンスを実行
    _startSequence();
  }

  void _startSequence() async {
    // 1. ドラムロール再生開始
    // (AudioController経由で再生。エラー時はログ出力のみで進行)
    ref.read(audioControllerProvider.notifier).playGachaDrum();

    // 2. 演出時間分だけ待機
    await Future.delayed(_drumDuration);

    if (mounted) {
      // 3. 結果表示へ切り替え
      // ドラムロールを停止して結果音を再生
      ref.read(audioControllerProvider.notifier).playGachaResult();

      //結果表示の瞬間に振動
      if (widget.item.rarity == Rarity.ssr) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }

      setState(() {
        _showResult = true;
      });
      _rotationController.stop();
      _scaleController.forward();

      // 完了コールバック
      widget.onAnimationComplete();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // SSR判定（DriftのEnumを使用）
  bool get _isSSR {
    return widget.item.rarity == Rarity.ssr;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * 0.8, maxWidth: 400),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- 魔法陣 (演出中) ---
            if (!_showResult)
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isSSR ? Colors.amber : Colors.cyanAccent,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isSSR ? Colors.amber : Colors.cyanAccent).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_awesome, color: Colors.white, size: 100),
                      ),
                    ),
                  );
                },
              ),

            // --- 結果カード (表示後) ---
            if (_showResult)
              ScaleTransition(
                scale: CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isSSR ? "LEGENDARY!" : "UNSEALED!",
                        style: TextStyle(
                          color: _isSSR ? Colors.amber : Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(blurRadius: 20, color: _isSSR ? Colors.orange : Colors.pink),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 画像カード
                      Container(
                        width: 280,
                        height: 380,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _isSSR ? Colors.amber : Colors.grey, width: 8),
                          boxShadow: [
                            BoxShadow(
                              color: _isSSR
                                  ? Colors.amber.withOpacity(0.6)
                                  : Colors.blue.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          // ✅ 修正: Image.file を使用
                          child: Image.file(
                            File(widget.item.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bond Level表示
                      if (widget.item.bondLevel > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.pinkAccent),
                          ),
                          child: Text(
                            'Bond Level +1 (Lv.${widget.item.bondLevel})',
                            style: const TextStyle(
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        child: const Text("閉じる"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
