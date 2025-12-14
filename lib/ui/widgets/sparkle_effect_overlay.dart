import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/master_data/effect_master_data.dart';
import '../../logic/settings_controller.dart';

class SparkleEffectOverlay extends ConsumerStatefulWidget {
  final EffectType effectType;

  const SparkleEffectOverlay({super.key, required this.effectType});

  @override
  ConsumerState<SparkleEffectOverlay> createState() => _SparkleEffectOverlayState();
}

class _SparkleEffectOverlayState extends ConsumerState<SparkleEffectOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();
  double _time = 0;

  EffectDef? _currentDef;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();

    _loadDefAndParticles();
  }

  void _loadDefAndParticles() {
    _currentDef = effectMasterData[widget.effectType];
    _particles.clear();

    if (_currentDef != null) {
      if (_currentDef!.drawType != EffectDrawType.lightning) {
        for (int i = 0; i < _currentDef!.particleCount; i++) {
          _particles.add(_createParticle(randomY: true));
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant SparkleEffectOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effectType != widget.effectType) {
      setState(() {
        _time = 0;
        _loadDefAndParticles();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Path _generateThunderPath() {
    final path = Path();
    double x = _random.nextDouble() * 0.8 + 0.1;
    double y = -0.1;
    path.moveTo(x, y);

    int segments = _random.nextInt(4) + 5;
    for (int i = 0; i < segments; i++) {
      x += (_random.nextDouble() - 0.5) * 0.3;
      y += (1.2 / segments);
      path.lineTo(x, y);
    }
    return path;
  }

  _Particle _createParticle({bool randomY = false}) {
    final def = _currentDef!;
    final w = 1.0;
    final h = 1.0;

    double x = _random.nextDouble() * w;
    double y = 0.0;

    switch (def.spawnType) {
      case SpawnType.top:
        y = randomY ? _random.nextDouble() * h : -0.1;
        break;
      case SpawnType.bottom:
        y = randomY ? _random.nextDouble() * h : 1.1;
        break;
      case SpawnType.random:
        y = _random.nextDouble() * h;
        break;
    }

    double size = def.minSize + _random.nextDouble() * (def.maxSize - def.minSize);
    double speedX = def.minSpeedX + _random.nextDouble() * (def.maxSpeedX - def.minSpeedX);
    double speedY = def.minSpeedY + _random.nextDouble() * (def.maxSpeedY - def.minSpeedY);

    if (def.drawType == EffectDrawType.snow) {
      speedY = (size * 0.0008) + 0.001;
    }

    Color color = def.colors.isNotEmpty
        ? def.colors[_random.nextInt(def.colors.length)]
        : Colors.white;

    if (def.drawType == EffectDrawType.snow || def.drawType == EffectDrawType.ember) {
      color = color.withOpacity(_random.nextDouble() * 0.5 + 0.5);
    }

    // ✅ 修正: 雨の場合は回転させない (角度を0に固定)
    double rotation = 0;
    double rotationSpeed = 0;

    if (def.drawType != EffectDrawType.rain) {
      rotation = _random.nextDouble() * 2 * pi;
      rotationSpeed = (_random.nextDouble() - 0.5) * 0.05;
    }

    Path? thunderPath;
    if (def.drawType == EffectDrawType.lightning) {
      x = 0;
      y = 0;
      thunderPath = _generateThunderPath();
    }

    return _Particle(
      x: x,
      y: y,
      speedX: speedX,
      speedY: speedY,
      size: size,
      color: color,
      rotation: rotation,
      rotationSpeed: rotationSpeed,
      life: 1.0,
      maxLife: 1.0,
      wobbleOffset: _random.nextDouble() * 2 * pi,
      thunderPath: thunderPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final showEffect = settingsAsync.valueOrNull?.showEffect ?? true;

    if (!showEffect || _currentDef == null) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            _time += 0.016;
            final def = _currentDef!;

            if (def.drawType == EffectDrawType.lightning && _particles.length < def.particleCount) {
              if (_random.nextDouble() < 0.02) {
                _particles.add(_createParticle());
              }
            }

            for (var p in _particles) {
              p.x += p.speedX;
              p.y += p.speedY;
              p.rotation += p.rotationSpeed;
              p.life -= def.decayRate;

              if (def.drawType == EffectDrawType.ember) {
                p.life -= _random.nextDouble() * 0.01;
              }

              if (def.wobbleStrength > 0) {
                p.x +=
                    sin(_time * (def.drawType == EffectDrawType.ember ? 3 : 2) + p.wobbleOffset) *
                    def.wobbleStrength;
                if (def.drawType == EffectDrawType.petal) {
                  p.y += cos(_time + p.wobbleOffset) * (def.wobbleStrength * 0.5);
                }
              }

              bool reset = false;
              if (def.drawType == EffectDrawType.lightning) {
                reset = p.life <= 0;
              } else {
                reset = p.life <= 0 || p.y > 1.1 || p.y < -0.2 || p.x < -0.2 || p.x > 1.2;
              }

              if (reset) {
                p.reset(_createParticle());
              }
            }

            if (def.drawType == EffectDrawType.lightning) {
              _particles.removeWhere((p) => p.life <= 0);
            }

            return RepaintBoundary(
              child: CustomPaint(
                painter: _ParticlePainter(_particles, def),
                child: const SizedBox.expand(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  double x, y;
  double speedX, speedY;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;
  double life;
  double maxLife;
  double wobbleOffset;
  Path? thunderPath;

  _Particle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.life,
    required this.maxLife,
    required this.wobbleOffset,
    this.thunderPath,
  });

  void reset(_Particle p) {
    x = p.x;
    y = p.y;
    speedX = p.speedX;
    speedY = p.speedY;
    size = p.size;
    color = p.color;
    rotation = p.rotation;
    rotationSpeed = p.rotationSpeed;
    life = p.maxLife;
    maxLife = p.maxLife;
    wobbleOffset = p.wobbleOffset;
    thunderPath = p.thunderPath;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final EffectDef def;

  _ParticlePainter(this.particles, this.def);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.blendMode = def.blendMode;

    for (var p in particles) {
      if (def.drawType != EffectDrawType.lightning) {
        final dx = p.x * size.width;
        final dy = p.y * size.height;
        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(p.rotation);
      } else {
        canvas.save();
      }

      double opacity = (p.life / p.maxLife).clamp(0.0, 1.0);

      if (def.drawType == EffectDrawType.ember) {
        opacity = p.life < 0.2 ? p.life * 5.0 : 1.0;
      }
      if (def.drawType == EffectDrawType.lightning) {
        opacity = p.life > 0.1 ? 1.0 : p.life * 10;
      }

      paint.color = p.color.withOpacity(opacity * p.color.opacity);

      switch (def.drawType) {
        case EffectDrawType.petal:
          canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            paint,
          );
          break;

        case EffectDrawType.snow:
          final glowPaint = Paint()
            ..color = p.color.withOpacity(opacity * 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
            ..blendMode = BlendMode.plus;
          canvas.drawCircle(Offset.zero, p.size, glowPaint);
          paint.color = Colors.white.withOpacity(opacity);
          canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
          break;

        case EffectDrawType.bubble:
          final fillPaint = Paint()
            ..color = Colors.lightBlueAccent.withOpacity(opacity * 0.15)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset.zero, p.size, fillPaint);
          final strokePaint = Paint()
            ..color = Colors.lightBlueAccent.withOpacity(opacity * 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          canvas.drawCircle(Offset.zero, p.size, strokePaint);
          final highlightPaint = Paint()
            ..color = Colors.white.withOpacity(opacity * 0.5)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(-p.size * 0.35, -p.size * 0.35), p.size * 0.25, highlightPaint);
          break;

        case EffectDrawType.ember:
          canvas.drawCircle(Offset.zero, p.size, paint);
          break;

        case EffectDrawType.lightning:
          if (p.thunderPath != null && p.life > 0) {
            paint.style = PaintingStyle.stroke;
            paint.strokeWidth = p.size;
            paint.strokeCap = StrokeCap.round;
            paint.strokeJoin = StrokeJoin.round;
            paint.maskFilter = null;
            final matrix = Matrix4.identity();
            matrix.scale(size.width, size.height);
            final transformedPath = p.thunderPath!.transform(matrix.storage);
            canvas.drawPath(transformedPath, paint);
          }
          break;

        // ✅ 修正: 雨の描画 (回転なしで描画)
        case EffectDrawType.rain:
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 2.0; // 少し太く
          paint.strokeCap = StrokeCap.round;

          // 速度ベクトルの逆方向に線を引く (残像)
          // 20.0 は長さの係数
          final tailX = -p.speedX * 500.0;
          final tailY = -p.speedY * 500.0;

          canvas.drawLine(Offset.zero, Offset(tailX, tailY), paint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
