import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/gacha_item.dart';

class GachaAnimationDialog extends StatefulWidget {
  final GachaItem item;
  final VoidCallback onAnimationComplete;

  const GachaAnimationDialog({super.key, required this.item, required this.onAnimationComplete});

  @override
  State<GachaAnimationDialog> createState() => _GachaAnimationDialogState();
}

class _GachaAnimationDialogState extends State<GachaAnimationDialog> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  bool _showResult = false; // 結果表示フラグ

  @override
  void initState() {
    super.initState();

    // 魔法陣の回転
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();

    // 出現演出
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // アニメーションシーケンス
    _startSequence();
  }

  void _startSequence() async {
    // 1. 魔法陣が回る (2秒待機)
    await Future.delayed(const Duration(seconds: 2));

    // 2. 結果表示へ移行
    if (mounted) {
      setState(() {
        _showResult = true;
      });
      _rotationController.stop();
      _scaleController.forward(); // ぼよんと出現

      // 親ウィジェットの状態を更新（ここでジェム消費などを確定）
      widget.onAnimationComplete();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- 魔法陣 (Magic Circle) ---
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
                          color: widget.item.isSSR ? Colors.amber : Colors.cyanAccent,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.item.isSSR ? Colors.amber : Colors.cyanAccent)
                                .withOpacity(0.5),
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

            // --- 結果カード (Result Card) ---
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
                    // カード本体
                    Container(
                      width: 280,
                      height: 380,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.item.isSSR ? Colors.amber : Colors.grey,
                          width: 8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.item.isSSR
                                ? Colors.amber.withOpacity(0.6)
                                : Colors.blue.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // エラー時はプレースホルダーを表示
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 64,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '画像を読み込めませんでした',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
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


