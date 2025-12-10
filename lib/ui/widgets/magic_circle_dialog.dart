import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../data/database/database.dart';
import '../../logic/audio_controller.dart';

class GachaAnimationDialog extends ConsumerStatefulWidget {
  final GachaItem item;
  final VoidCallback onAnimationComplete;

  const GachaAnimationDialog({super.key, required this.item, required this.onAnimationComplete});

  @override
  ConsumerState<GachaAnimationDialog> createState() => _GachaAnimationDialogState();
}

class _GachaAnimationDialogState extends State<GachaAnimationDialog> with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _scaleController;

  final Duration _drumDuration = const Duration(seconds: 4);

  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _scaleController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
    _startSequence();
  }

  void _startSequence() async {
    // 1. ドラムロール再生開始 🥁
    ref.read(audioControllerProvider.notifier).playGachaDrum();

    // 2. 指定時間待機（演出時間）
    await Future.delayed(_drumDuration);

    if (mounted) {
      // 3. 結果表示へ切り替え 🎉
      // ドラムロールを止めて結果音を鳴らす
      ref.read(audioControllerProvider.notifier).playGachaResult();

      setState(() {
        _showResult = true;
      });
      _rotationController.stop();
      _scaleController.forward();
      widget.onAnimationComplete();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // ✅ 修正: Enumの値を正しく比較
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
            // --- 魔法陣 ---
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
                      child: const Center(child: Icon(Icons.star, color: Colors.white, size: 100)),
                    ),
                  );
                },
              ),

            // --- 結果カード ---
            if (_showResult)
              ScaleTransition(
                scale: CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "UNSEALED!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [Shadow(blurRadius: 10, color: Colors.pink)],
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
                          // ✅ 修正: Image.file を使用してローカル画像を表示
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
                      const SizedBox(height: 30),
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
