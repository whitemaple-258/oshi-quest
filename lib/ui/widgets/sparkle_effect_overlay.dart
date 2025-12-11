import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';

class SparkleEffectOverlay extends StatefulWidget {
  final EffectType effectType;

  const SparkleEffectOverlay({super.key, required this.effectType});

  @override
  State<SparkleEffectOverlay> createState() => _SparkleEffectOverlayState();
}

class _SparkleEffectOverlayState extends State<SparkleEffectOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();

    _prewarmParticles();
  }

  void _prewarmParticles() {
    final count = _getParticleCount();
    for (int i = 0; i < count; i++) {
      if (widget.effectType != EffectType.thunder) {
        _particles.add(_createParticle(randomY: true));
      }
    }
  }

  @override
  void didUpdateWidget(covariant SparkleEffectOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effectType != widget.effectType) {
      setState(() {
        _particles.clear();
        _time = 0;
        _prewarmParticles();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getParticleCount() {
    switch (widget.effectType) {
      case EffectType.fire:
        return 150; // 火の粉は多めに
      case EffectType.water:
        return 30;
      case EffectType.thunder:
        return 2;
      case EffectType.light:
        return 60;
      case EffectType.dark:
        return 100;
      default:
        return 0;
    }
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
    final w = 1.0;
    final h = 1.0;

    double x = _random.nextDouble() * w;
    double y = randomY ? _random.nextDouble() * h : -0.1;

    double size = 0;
    double speedX = 0;
    double speedY = 0;
    double rotation = _random.nextDouble() * 2 * pi;
    double rotationSpeed = 0;
    Color color = Colors.white;
    Path? thunderPath;
    double length = 0;

    switch (widget.effectType) {
      case EffectType.light:
        y = randomY ? _random.nextDouble() * h : -0.1;
        size = _random.nextDouble() * 8 + 5;
        speedY = _random.nextDouble() * 0.002 + 0.001;
        speedX = 0.002 + (_random.nextDouble() - 0.5) * 0.001;
        rotationSpeed = (_random.nextDouble() - 0.5) * 0.05;
        color = [
          Colors.pinkAccent.withOpacity(0.8),
          Colors.pink.shade200.withOpacity(0.8),
          Colors.white.withOpacity(0.9),
        ][_random.nextInt(3)];
        break;

      case EffectType.dark:
        y = randomY ? _random.nextDouble() * h : -0.1;
        size = _random.nextDouble() * 5 + 2;
        speedY = (size * 0.0008) + 0.001;
        speedX = (_random.nextDouble() - 0.5) * 0.001;
        rotationSpeed = (_random.nextDouble() - 0.5) * 0.02;
        color = Colors.white.withOpacity(_random.nextDouble() * 0.5 + 0.5);
        break;

      case EffectType.water:
        y = randomY ? _random.nextDouble() * h : 1.1;
        size = _random.nextDouble() * 20 + 10;
        speedY = -(_random.nextDouble() * 0.001 + 0.0005);
        speedX = 0;
        color = Colors.transparent;
        break;

      case EffectType.fire:
        // 🔥 炎 (修正: さらに小さく)
        y = randomY ? _random.nextDouble() * h : 1.1;
        // ✅ 修正: 1~3px (極小)
        size = _random.nextDouble() * 2 + 1;
        speedY = -(_random.nextDouble() * 0.003 + 0.001);
        speedX = (_random.nextDouble() - 0.5) * 0.002;
        color = [
          Colors.deepOrange,
          Colors.orangeAccent,
          Colors.amber,
          Colors.white,
        ][_random.nextInt(4)];
        break;

      case EffectType.thunder:
        x = 0;
        y = 0;
        size = _random.nextDouble() * 2 + 2;
        color = Colors.white;
        thunderPath = _generateThunderPath();
        break;

      default:
        break;
    }

    return _Particle(
      x: x,
      y: y,
      speedX: speedX,
      speedY: speedY,
      size: size,
      length: length,
      color: color,
      rotation: rotation,
      rotationSpeed: rotationSpeed,
      type: widget.effectType,
      life: 1.0,
      maxLife: 1.0,
      wobbleOffset: _random.nextDouble() * 2 * pi,
      thunderPath: thunderPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.effectType == EffectType.none) return const SizedBox.shrink();

    return ClipRect(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            _time += 0.016;

            if (widget.effectType == EffectType.thunder &&
                _particles.length < _getParticleCount()) {
              if (_random.nextDouble() < 0.02) {
                _particles.add(_createParticle());
              }
            }

            for (var p in _particles) {
              p.x += p.speedX;
              p.y += p.speedY;
              p.rotation += p.rotationSpeed;

              if (widget.effectType == EffectType.thunder) {
                p.life -= 0.06;
              } else if (widget.effectType == EffectType.fire) {
                // ✅ 修正: 寿命減少をさらに緩やかに (1秒程度延長)
                p.life -= 0.0035;
              }

              if (widget.effectType == EffectType.light) {
                p.x += sin(_time * 2 + p.wobbleOffset) * 0.001;
                p.y += cos(_time * 1 + p.wobbleOffset) * 0.0005;
              } else if (widget.effectType == EffectType.dark) {
                p.x += sin(_time * 1.5 + p.wobbleOffset) * 0.0005;
              } else if (widget.effectType == EffectType.water) {
                p.x += sin(_time * 1 + p.wobbleOffset) * 0.0003;
              } else if (widget.effectType == EffectType.fire) {
                p.x += sin(_time * 3 + p.wobbleOffset) * 0.0005;
              }

              bool reset = false;
              if (widget.effectType == EffectType.thunder) {
                reset = p.life <= 0;
              } else {
                reset = p.life <= 0 || p.y > 1.1 || p.y < -0.2 || p.x < -0.2 || p.x > 1.2;
              }

              if (reset) {
                p.reset(_createParticle());
              }
            }

            if (widget.effectType == EffectType.thunder) {
              _particles.removeWhere((p) => p.life <= 0);
            }

            return RepaintBoundary(
              child: CustomPaint(
                painter: _ParticlePainter(_particles, widget.effectType),
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
  double length;
  Color color;
  double rotation;
  double rotationSpeed;
  double life;
  double maxLife;
  double wobbleOffset;
  EffectType type;
  Path? thunderPath;

  _Particle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.size,
    this.length = 0,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.life,
    required this.maxLife,
    required this.wobbleOffset,
    required this.type,
    this.thunderPath,
  });

  void reset(_Particle p) {
    x = p.x;
    y = p.y;
    speedX = p.speedX;
    speedY = p.speedY;
    size = p.size;
    length = p.length;
    color = p.color;
    rotation = p.rotation;
    rotationSpeed = p.rotationSpeed;
    life = p.maxLife;
    maxLife = p.maxLife;
    wobbleOffset = p.wobbleOffset;
    type = p.type;
    thunderPath = p.thunderPath;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final EffectType type;

  _ParticlePainter(this.particles, this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (type == EffectType.thunder || type == EffectType.water) {
      paint.blendMode = BlendMode.srcOver;
    } else {
      paint.blendMode = BlendMode.plus;
    }

    for (var p in particles) {
      if (type != EffectType.thunder) {
        final dx = p.x * size.width;
        final dy = p.y * size.height;
        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(p.rotation);
      } else {
        canvas.save();
      }

      double opacity = (p.life / p.maxLife).clamp(0.0, 1.0);

      if (type == EffectType.fire) {
        // ✅ 修正: 寿命ギリギリまで表示し、最後にフェードアウト
        opacity = p.life < 0.2 ? p.life * 5.0 : 1.0;
      }
      if (type == EffectType.thunder) opacity = p.life > 0.1 ? 1.0 : p.life * 10;

      paint.color = p.color.withOpacity(opacity * p.color.opacity);

      if (type == EffectType.light) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      } else if (type == EffectType.dark) {
        final glowPaint = Paint()
          ..color = p.color.withOpacity(opacity * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
          ..blendMode = BlendMode.plus;
        canvas.drawCircle(Offset.zero, p.size, glowPaint);
        paint.color = Colors.white.withOpacity(opacity);
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
      } else if (type == EffectType.water) {
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
      } else if (type == EffectType.fire) {
        // 火の粉（小さな円）
        canvas.drawCircle(Offset.zero, p.size, paint);
      } else if (type == EffectType.thunder) {
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
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
