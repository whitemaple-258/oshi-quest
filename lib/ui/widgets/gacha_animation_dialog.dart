import 'dart:math' as math;
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
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _chargeAnimation;
  late Animation<double> _explodeAnimation;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // ドラムロール再生
    ref.read(audioControllerProvider.notifier).playGachaDrum();

    // ✅ 修正: アニメーション時間をドラムロールに合わせて「4秒」に設定
    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000));

    // ✅ チャージ・フェーズ (0% -> 85%): 約3.4秒間、音に合わせてじっくり溜める
    _chargeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.85, curve: Curves.easeInCubic),
    );

    // ✅ エクスプロード・フェーズ (85% -> 100%): 残り0.6秒で一気に開放し、ホワイトアウトして遷移
    _explodeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.85, 1.0, curve: Curves.easeOutExpo),
    );

    _mainController.forward().then((_) {
      // 完了時 (4秒後) に結果音を再生し、コールバックを実行
      ref.read(audioControllerProvider.notifier).playGachaResult();
      widget.onAnimationComplete();
    });

    _initParticles();
  }

  void _initParticles() {
    final count = widget.item.rarity == Rarity.ssr ? 150 : 80;
    for (int i = 0; i < count; i++) {
      _particles.add(_Particle(
        angle: _random.nextDouble() * 2 * math.pi,
        radius: _random.nextDouble() * 150,
        speed: _random.nextDouble() * 2 + 1,
        size: _random.nextDouble() * 4 + 2,
        colorOpacity: _random.nextDouble() * 0.5 + 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  Color _getBaseColor() {
    switch (widget.item.rarity) {
      case Rarity.ssr: return const Color(0xFFFFD700);
      case Rarity.sr: return Colors.purpleAccent;
      case Rarity.r: return Colors.blueAccent;
      case Rarity.n: return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _getBaseColor();
    final isSSR = widget.item.rarity == Rarity.ssr;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          // フェーズ判定
          final isCharging = _mainController.value < 0.85;
          final chargeProgress = _chargeAnimation.value;
          final explodeProgress = _explodeAnimation.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. 魔法陣とパーティクルの描画
              CustomPaint(
                painter: _MagicCirclePainter(
                  color: baseColor,
                  rotation: chargeProgress * math.pi * (isSSR ? 12 : 6), // 4秒あるので回転数を増やす
                  chargeProgress: chargeProgress,
                  explodeProgress: explodeProgress,
                  particles: _particles,
                  isSSR: isSSR,
                ),
                child: const SizedBox(width: 300, height: 300),
              ),

              // 2. 中心のコア
              if (isCharging)
                Transform.scale(
                  scale: 0.5 + chargeProgress * 2.0, // より大きく膨張させる
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: baseColor.withOpacity(0.2 + chargeProgress * 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(0.6),
                          blurRadius: 20 + chargeProgress * 40,
                          spreadRadius: 5 + chargeProgress * 15,
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. 爆発時の閃光 (ホワイトアウト)
              if (!isCharging)
                Opacity(
                  opacity: (1.0 - explodeProgress).clamp(0.0, 1.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white.withOpacity(0.9), // ほぼ真っ白にする
                  ),
                ),

              // 4. テキスト
              Positioned(
                bottom: 100,
                child: Opacity(
                  opacity: (1.0 - explodeProgress * 5).clamp(0.0, 1.0), // 爆発直前に素早く消す
                  child: Text(
                    'Summoning...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: baseColor,
                          blurRadius: 10 + chargeProgress * 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Particle {
  double angle;
  double radius;
  double speed;
  double size;
  double colorOpacity;

  _Particle({
    required this.angle,
    required this.radius,
    required this.speed,
    required this.size,
    required this.colorOpacity,
  });
}

class _MagicCirclePainter extends CustomPainter {
  final Color color;
  final double rotation;
  final double chargeProgress;
  final double explodeProgress;
  final List<_Particle> particles;
  final bool isSSR;

  _MagicCirclePainter({
    required this.color,
    required this.rotation,
    required this.chargeProgress,
    required this.explodeProgress,
    required this.particles,
    required this.isSSR,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final particlePaint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    if (explodeProgress == 0) {
      // --- Charge Phase ---
      canvas.rotate(rotation);

      paint.color = color.withOpacity(0.3 + chargeProgress * 0.7);
      canvas.drawCircle(Offset.zero, maxRadius * (0.8 + chargeProgress * 0.2), paint);
      
      paint.strokeWidth = 1.0 + chargeProgress;
      final path = Path();
      const sides = 6;
      final innerRadius = maxRadius * 0.6;
      for (int i = 0; i < sides * 2; i++) {
        final r = i.isEven ? innerRadius : innerRadius * 0.5;
        final a = i * math.pi / sides;
        final x = r * math.cos(a);
        final y = r * math.sin(a);
        if (i == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paint);

      for (var p in particles) {
        // 吸い込み速度を調整
        p.radius = p.radius * (1.0 - chargeProgress * 0.03) - p.speed * chargeProgress * 0.5;
        if (p.radius < 0) p.radius = maxRadius;

        final x = p.radius * math.cos(p.angle + rotation * 0.5);
        final y = p.radius * math.sin(p.angle + rotation * 0.5);
        particlePaint.color = color.withOpacity(p.colorOpacity * chargeProgress);
        canvas.drawCircle(Offset(x, y), p.size * chargeProgress, particlePaint);
      }
    } else {
      // --- Explode Phase ---
      // 衝撃波
      paint.color = color.withOpacity((1.0 - explodeProgress).clamp(0.0, 1.0));
      paint.strokeWidth = 20 * explodeProgress;
      canvas.drawCircle(Offset.zero, maxRadius * explodeProgress * 4, paint);

      for (var p in particles) {
        // 拡散速度
        final explodeSpeed = p.speed * (isSSR ? 20 : 12);
        p.radius += explodeSpeed * explodeProgress;

        final x = p.radius * math.cos(p.angle);
        final y = p.radius * math.sin(p.angle);
        
        particlePaint.color = color.withOpacity(p.colorOpacity * (1.0 - explodeProgress));
        canvas.drawCircle(Offset(x, y), p.size * (1.0 + explodeProgress * 3), particlePaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MagicCirclePainter oldDelegate) => true;
}