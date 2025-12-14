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

  double _lightningCooldown = 0.0;
  int _remainingBurstShots = 0;
  double _burstShotCooldown = 0.0;

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
      } else {
        _lightningCooldown = 1.0;
        _remainingBurstShots = 0;
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

  // --- ⚡ 雷生成ロジック ---
  void _createBoltPath(Path path, Offset p1, Offset p2, double displacement, int depth) {
    if (depth <= 0) {
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      return;
    }
    double midX = (p1.dx + p2.dx) / 2;
    double midY = (p1.dy + p2.dy) / 2;
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double length = sqrt(dx * dx + dy * dy);
    if (length < 0.001) {
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      return;
    }
    double unitNx = -dy / length;
    double unitNy = dx / length;
    double offsetAmount = (_random.nextDouble() - 0.5) * displacement;
    Offset mid = Offset(midX + unitNx * offsetAmount, midY + unitNy * offsetAmount);

    _createBoltPath(path, p1, mid, displacement * 0.5, depth - 1);
    _createBoltPath(path, mid, p2, displacement * 0.5, depth - 1);

    if (_random.nextDouble() < 0.4) { 
      double angle = (_random.nextDouble() - 0.5) * 1.0;
      double branchLen = length * 0.6;
      double newDx = dx * cos(angle) - dy * sin(angle);
      double newDy = dx * sin(angle) + dy * cos(angle);
      double currentLen = sqrt(newDx * newDx + newDy * newDy);
      if (currentLen > 0) {
        Offset branchEnd = Offset(
          mid.dx + (newDx / currentLen) * branchLen,
          mid.dy + (newDy / currentLen) * branchLen
        );
        _createBoltPath(path, mid, branchEnd, displacement * 0.5, depth - 1);
      }
    }
  }

  Path _generateThunderPath() {
    final path = Path();
    final startX = 0.2 + _random.nextDouble() * 0.6;
    final startY = -0.1;
    final start = Offset(startX, startY);
    final endX = startX + (_random.nextDouble() - 0.5) * 0.6;
    final endY = 0.8 + _random.nextDouble() * 0.3;
    final end = Offset(endX, endY);
    _createBoltPath(path, start, end, 0.25, 7);
    return path;
  }
  // ----------------------------------------

  _Particle _createParticle({bool randomY = false}) {
    final def = _currentDef!;
    final w = 1.0;
    final h = 1.0;

    double x = _random.nextDouble() * w;
    double y = 0.0;
    
    if (def.drawType == EffectDrawType.ember) {
      x = _random.nextDouble() * 1.2 - 0.1;
    }

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

    // サイズ分布
    double sizeRatio;
    if (def.drawType == EffectDrawType.ember) {
      double r = _random.nextDouble();
      sizeRatio = pow(r, 4).toDouble(); 
    } else {
      sizeRatio = _random.nextDouble();
    }
    
    double size = def.minSize + sizeRatio * (def.maxSize - def.minSize);
    
    double speedX = def.minSpeedX + _random.nextDouble() * (def.maxSpeedX - def.minSpeedX);
    double speedY = def.minSpeedY + _random.nextDouble() * (def.maxSpeedY - def.minSpeedY);

    Color color = def.colors.isNotEmpty
        ? def.colors[_random.nextInt(def.colors.length)]
        : Colors.white;

    bool isTrail = false;
    double randomPhase = _random.nextDouble() * 2 * pi;

    if (def.drawType == EffectDrawType.ember) {
      isTrail = true;
      double chaos = 0.003;
      speedX += (_random.nextDouble() - 0.5) * chaos;
      speedY += (_random.nextDouble() - 0.5) * chaos * 0.5;
      double speedFactor = 0.5 + sizeRatio * 1.0; 
      speedX *= speedFactor;
      speedY *= speedFactor;
      
      if (sizeRatio > 0.8) {
        color = const Color(0xFFFFE0B2); 
      } else if (sizeRatio > 0.4) {
        color = Colors.deepOrangeAccent; 
      } else {
        color = const Color(0xFF5D4037); 
      }
    } 
    else if (def.drawType == EffectDrawType.snow) {
      final ratio = (size - def.minSize) / (def.maxSize - def.minSize);
      speedY = 0.0005 + (ratio * 0.0015);
      final opacity = 0.4 + (ratio * 0.6);
      color = color.withOpacity(opacity);
    } 
    else if (def.drawType == EffectDrawType.bubble) {
      final ratio = (size - def.minSize) / (def.maxSize - def.minSize);
      speedY = -0.0005 - (ratio * 0.0015);
    } 
    else if (def.drawType == EffectDrawType.ember) {
      color = color.withOpacity(_random.nextDouble() * 0.5 + 0.5);
    }

    double rotation = 0;
    double rotationSpeed = 0;
    
    if (def.drawType != EffectDrawType.rain && def.drawType != EffectDrawType.ember) {
      rotation = _random.nextDouble() * 2 * pi;
      final rotScale = def.drawType == EffectDrawType.snow ? 0.02 : 0.05;
      rotationSpeed = (_random.nextDouble() - 0.5) * rotScale;
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
      wobbleSpeed: 1.0 + _random.nextDouble(),
      thunderPath: thunderPath,
      isTrail: isTrail,
      sizeRatio: sizeRatio,
      randomPhase: randomPhase,
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

            // 生成ロジック
            if (def.drawType == EffectDrawType.lightning) {
              if (_remainingBurstShots > 0) {
                _burstShotCooldown -= 0.016;
                if (_burstShotCooldown <= 0) {
                  if (_particles.length < def.particleCount) _particles.add(_createParticle());
                  _remainingBurstShots--;
                  _burstShotCooldown = _random.nextDouble() * 0.15 + 0.1;
                  if (_remainingBurstShots <= 0) _lightningCooldown = _random.nextDouble() * 3.0 + 2.0;
                }
              } else {
                _lightningCooldown -= 0.016;
                if (_lightningCooldown <= 0) {
                  _remainingBurstShots = _random.nextInt(2) + 2; 
                  _burstShotCooldown = 0;
                }
              }
            } else if (_particles.length < def.particleCount) {
              if (def.drawType == EffectDrawType.bubble) {
                if (_random.nextDouble() < 0.05) _particles.add(_createParticle());
              } else {
                if (_random.nextDouble() < 0.08) _particles.add(_createParticle());
              }
            }

            // 更新ロジック
            for (var p in _particles) {
              
              if (def.drawType == EffectDrawType.ember) {
                double decay = (1.1 - p.sizeRatio) * 0.004; 
                p.life -= decay;

                // リアルな気流シミュレーション
                double turbulenceX = sin(p.y * 5 + _time * 2 + p.randomPhase) * cos(p.x * 3 + p.randomPhase);
                double turbulenceY = cos(p.y * 4 + _time * 1.5 + p.randomPhase) * sin(p.x * 6);
                
                double strength = 0.0005 * (1.5 - p.sizeRatio);

                p.speedX += turbulenceX * strength;
                p.speedY += turbulenceY * strength * 0.5;

                p.speedX *= 0.98;
                p.speedY *= 0.99;

                p.speedY -= 0.0001 * (1.0 + p.sizeRatio); 

                p.x += p.speedX;
                p.y += p.speedY;
                p.rotation = atan2(p.speedY, p.speedX) + pi / 2;

              } else {
                p.x += p.speedX;
                p.y += p.speedY;
                p.rotation += p.rotationSpeed;
                p.life -= def.decayRate;
              }

              if (def.drawType != EffectDrawType.ember && def.wobbleStrength > 0) {
                if (def.drawType == EffectDrawType.snow) {
                  p.x += sin(_time + p.wobbleOffset) * def.wobbleStrength * 0.5;
                } else if (def.drawType == EffectDrawType.bubble) {
                   final wobble =
                      sin(_time * p.wobbleSpeed + p.wobbleOffset) * 0.5 +
                      sin(_time * p.wobbleSpeed * 0.5 + p.wobbleOffset) * 0.5;
                  p.x += wobble * def.wobbleStrength;
                } else {
                  p.x += sin(_time * 2 + p.wobbleOffset) * def.wobbleStrength;
                }
              }

              if (def.drawType == EffectDrawType.bubble) {
                p.y -= 0.0001;
              }

              bool reset = false;
              if (def.drawType == EffectDrawType.lightning) {
                reset = p.life <= 0;
              } else {
                reset = p.life <= 0 || p.y > 1.2 || p.y < -0.2 || p.x < -0.2 || p.x > 1.2;
              }

              if (reset) {
                if (def.drawType != EffectDrawType.lightning) {
                  p.reset(_createParticle());
                }
              }
            }

            if (def.drawType == EffectDrawType.lightning) {
              _particles.removeWhere((p) => p.life <= 0);
            }

            return RepaintBoundary(
              child: CustomPaint(
                painter: _ParticlePainter(_particles, def, _time),
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
  double wobbleSpeed;
  Path? thunderPath;
  bool isTrail;
  double sizeRatio;
  double randomPhase;

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
    this.wobbleSpeed = 1.0,
    this.thunderPath,
    this.isTrail = false,
    this.sizeRatio = 0.5,
    this.randomPhase = 0.0,
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
    wobbleSpeed = p.wobbleSpeed;
    thunderPath = p.thunderPath;
    isTrail = p.isTrail;
    sizeRatio = p.sizeRatio;
    randomPhase = p.randomPhase;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final EffectDef def;
  final double time;

  _ParticlePainter(this.particles, this.def, this.time);

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
        final matrix = Matrix4.identity();
        matrix.scale(size.width, size.height);
        canvas.transform(matrix.storage);
      }

      double opacity = (p.life / p.maxLife).clamp(0.0, 1.0);

      // --- 色・描画計算 ---
      if (def.drawType == EffectDrawType.ember) {
        opacity *= 0.6;
        double flicker = sin(time * 10 + p.randomPhase) * 0.15 + 0.85;
        opacity *= flicker;

        Color baseColor;
        double glowStrength;

        if (p.sizeRatio > 0.8) {
          baseColor = Color.lerp(Colors.orangeAccent, Colors.white, p.life * 0.5)!;
          glowStrength = 1.0; 
        } else if (p.sizeRatio > 0.4) {
          baseColor = Color.lerp(Colors.deepOrange, Colors.brown, 1.0 - p.life)!;
          glowStrength = 0.6;
        } else {
          baseColor = Color.lerp(const Color(0xFF5D4037), const Color(0xFF210A0A), 1.0 - p.life)!;
          glowStrength = 0.0;
        }
        
        if (p.life < 0.3) opacity *= p.life * 3.0;
        paint.color = baseColor.withOpacity(opacity);
        
        double speed = sqrt(p.speedX * p.speedX + p.speedY * p.speedY);
        // 短めのトレイル (300.0)
        double trailLen = speed * 300.0 * p.size; 
        trailLen = max(trailLen, p.size * 1.5);
        double width = p.size * 0.15; 

        if (glowStrength > 0) {
          paint.maskFilter = MaskFilter.blur(BlurStyle.normal, glowStrength);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(0, trailLen / 2), width: width * 3.0, height: trailLen),
              Radius.circular(width),
            ),
            paint,
          );
        }
        
        paint.maskFilter = null;
        paint.color = baseColor.withOpacity(opacity * 0.8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(0, trailLen / 2), width: width, height: trailLen),
            Radius.circular(width),
          ),
          paint,
        );
        
        canvas.restore();
        continue; 
      } 
      // ... (他エフェクト)
      else if (def.drawType == EffectDrawType.lightning) {
        opacity = p.life > 0.8 ? (1.0 - p.life) * 5.0 : p.life * 1.5;
        opacity = opacity.clamp(0.0, 1.0);
        paint.color = p.color.withOpacity(opacity * p.color.opacity);
      } else {
        paint.color = p.color.withOpacity(opacity * p.color.opacity);
      }

      // --- 描画 (共通) ---
      switch (def.drawType) {
        
        // ★ 変更: 桜の花びらのパス描画
        case EffectDrawType.petal:
          final path = Path();
          // スリムな比率を維持
          final w = p.size * 0.8; 
          final h = p.size * 1.2;
          
          // (0,0)を中心に描画
          path.moveTo(0, h * 0.5); // 下の先端
          
          // 左側 (下から左上の山へ)
          path.cubicTo(
            -w * 0.5, h * 0.1,    // 制御点1 (下部の膨らみ)
            -w * 0.4, -h * 0.4,   // 制御点2 (上部の絞り)
            -w * 0.15, -h * 0.5   // 左上の山頂 (少し中心からずらす)
          );
          
          // 上部の切り込み (V字)
          path.lineTo(0, -h * 0.35);       // 中央の谷 (切り込みの深さ)
          path.lineTo(w * 0.15, -h * 0.5); // 右上の山頂
          
          // 右側 (右上の山から下へ)
          path.cubicTo(
            w * 0.4, -h * 0.4,    // 制御点2
            w * 0.5, h * 0.1,     // 制御点1
            0, h * 0.5            // 下の先端に戻る
          );
          
          path.close();
          canvas.drawPath(path, paint);
          break;

        case EffectDrawType.snow:
           paint.style = PaintingStyle.stroke;
           paint.strokeWidth = (p.size * 0.1).clamp(0.5, 1.5);
           paint.strokeCap = StrokeCap.round;
           final radius = p.size / 2;
           for (int i = 0; i < 3; i++) {
             canvas.save();
             canvas.rotate(pi / 3 * i);
             canvas.drawLine(Offset(0, -radius), Offset(0, radius), paint);
             final branchY = radius * 0.6;
             final branchSize = radius * 0.3;
             canvas.drawLine(Offset(0, -branchY), Offset(-branchSize, -branchY - branchSize), paint);
             canvas.drawLine(Offset(0, -branchY), Offset(branchSize, -branchY - branchSize), paint);
             canvas.drawLine(Offset(0, branchY), Offset(-branchSize, branchY + branchSize), paint);
             canvas.drawLine(Offset(0, branchY), Offset(branchSize, branchY + branchSize), paint);
             canvas.restore();
           }
          break;

        case EffectDrawType.bubble:
          paint.color = p.color.withOpacity(opacity * 0.3);
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
          canvas.drawCircle(Offset.zero, p.size * 1.5, paint);
          paint.color = Colors.white.withOpacity(opacity);
          paint.maskFilter = null;
          canvas.drawCircle(Offset.zero, p.size * 0.6, paint);
          paint.blendMode = def.blendMode;
          break;

        case EffectDrawType.ember:
          break;

        case EffectDrawType.lightning:
          if (p.thunderPath != null && p.life > 0) {
            paint.style = PaintingStyle.stroke;
            paint.strokeCap = StrokeCap.round;
            paint.strokeJoin = StrokeJoin.round;
            paint.blendMode = BlendMode.plus;
            
            canvas.restore(); 
            canvas.save();
            
            final matrix = Matrix4.identity();
            matrix.scale(size.width, size.height);
            final transformedPath = p.thunderPath!.transform(matrix.storage);

            paint.color = Colors.blueAccent.withOpacity(opacity * 0.4);
            paint.strokeWidth = 4.0;
            paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
            canvas.drawPath(transformedPath, paint);

            paint.color = Colors.white.withOpacity(opacity);
            paint.strokeWidth = 1.0;
            paint.maskFilter = null;
            canvas.drawPath(transformedPath, paint);
          }
          break;

        case EffectDrawType.rain:
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 2.0;
          paint.strokeCap = StrokeCap.round;
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