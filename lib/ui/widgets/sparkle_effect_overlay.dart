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

  double _lightningCooldown = 0.0; // 次のバーストまでの待機時間
  int _remainingBurstShots = 0; // バースト中の残り発射数
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
        // 雷の場合は初期タイマーをセット (最初は少し待つ)
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

  void _generateBranch(Path path, Offset start, double length, double angle, int depth) {
    if (depth <= 0 || length < 20.0) return;

    // 終点を計算（角度にランダムな揺らぎを加える）
    final wobble = (_random.nextDouble() - 0.5) * pi / 3; // ±60度の範囲で揺らぐ
    final endX = start.dx + length * cos(angle + wobble);
    final endY = start.dy + length * sin(angle + wobble);
    final end = Offset(endX, endY);

    path.lineTo(end.dx, end.dy);

    // 次の分岐へ
    final nextLength = length * (_random.nextDouble() * 0.4 + 0.6); // 長さを0.6~1.0倍に減衰

    // メインの枝を続ける
    _generateBranch(path, end, nextLength, angle, depth - 1);

    // 確率でサブの枝を分岐させる
    if (_random.nextDouble() < 0.6) {
      // 60%の確率で分岐
      final branchAngle =
          angle +
          (_random.nextBool() ? 1 : -1) * (_random.nextDouble() * pi / 4 + pi / 6); // 30~75度傾ける

      // 分岐用の新しいパスを開始
      final branchPath = Path()..moveTo(end.dx, end.dy);
      _generateBranch(branchPath, end, nextLength * 0.7, branchAngle, depth - 1);
      path.addPath(branchPath, Offset.zero);
    }
  }

  // ✅ 修正: 雷パス生成のエントリーポイント
  Path _generateThunderPath() {
    final path = Path();

    // 画面外上部からスタート
    final startX = _random.nextDouble() * 1.2 - 0.1; // -0.1 ~ 1.1
    final startY = -0.2;
    final start = Offset(startX, startY);

    path.moveTo(start.dx, start.dy);

    // メインの角度（ほぼ下向き）
    final mainAngle = pi / 2 + (_random.nextDouble() - 0.5) * pi / 6; // 下方向 ±30度

    // 再帰的に雷を生成（開始点、初期長さ、角度、再帰深度）
    _generateBranch(path, start, 150.0, mainAngle, 6);

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

    Color color = def.colors.isNotEmpty
        ? def.colors[_random.nextInt(def.colors.length)]
        : Colors.white;

    // ❄️ 雪: 奥行きの表現 (手前は速くくっきり、奥は遅く薄く)
    if (def.drawType == EffectDrawType.snow) {
      final sizeRatio = (size - def.minSize) / (def.maxSize - def.minSize);
      speedY = 0.0005 + (sizeRatio * 0.0015);
      final opacity = 0.4 + (sizeRatio * 0.6);
      color = color.withOpacity(opacity);
    }
    // 🫧 泡: 浮力の表現 (大きい泡ほど速く昇る)
    else if (def.drawType == EffectDrawType.bubble) {
      final sizeRatio = (size - def.minSize) / (def.maxSize - def.minSize);
      speedY = -0.0005 - (sizeRatio * 0.0015);
    }
    // 🔥 火の粉: ランダムな透明度
    else if (def.drawType == EffectDrawType.ember) {
      color = color.withOpacity(_random.nextDouble() * 0.5 + 0.5);
    }

    // 回転
    double rotation = 0;
    double rotationSpeed = 0;
    if (def.drawType != EffectDrawType.rain) {
      rotation = _random.nextDouble() * 2 * pi;
      // 雪はゆっくり回転する
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

            if (def.drawType == EffectDrawType.lightning) {
              if (_remainingBurstShots > 0) {
                // --- バースト中 (連続発生) ---
                _burstShotCooldown -= 0.016;
                if (_burstShotCooldown <= 0) {
                  // 生成上限チェック
                  if (_particles.length < def.particleCount) {
                    _particles.add(_createParticle());
                  }

                  _remainingBurstShots--;

                  // 次の1発までの短い間隔 (0.1秒〜0.25秒)
                  // 少しバラつきを持たせて自然にする
                  _burstShotCooldown = _random.nextDouble() * 0.15 + 0.1;

                  // バースト終了判定
                  if (_remainingBurstShots <= 0) {
                    // 次のバーストまでの長いクールダウン (2秒〜5秒)
                    _lightningCooldown = _random.nextDouble() * 3.0 + 2.0;
                  }
                }
              } else {
                // --- 待機中 (何も起きない) ---
                _lightningCooldown -= 0.016;
                if (_lightningCooldown <= 0) {
                  // バースト開始！
                  _remainingBurstShots = _random.nextInt(2) + 2; // 2本 または 3本
                  _burstShotCooldown = 0; // 即座に1発目を撃つ
                }
              }
            } else if (_particles.length < def.particleCount) {
              // 泡などは全画面に出てほしいので、足りなければ確率で補充
              // (lightningは上で制御しているのでここには来ない)
              // ※ここで確率を入れることで一気に出現するのを防いでいる
              if (def.drawType == EffectDrawType.bubble) {
                if (_random.nextDouble() < 0.05) _particles.add(_createParticle());
              } else {
                // 通常のエフェクト
                if (_random.nextDouble() < 0.02) _particles.add(_createParticle());
              }
            }

            // パーティクル更新ループ (位置計算など)
            for (var p in _particles) {
              p.x += p.speedX;
              p.y += p.speedY;
              p.rotation += p.rotationSpeed;
              p.life -= def.decayRate;

              if (def.drawType == EffectDrawType.ember) {
                p.life -= _random.nextDouble() * 0.01;
              }

              if (def.wobbleStrength > 0) {
                if (def.drawType == EffectDrawType.snow) {
                  p.x += sin(_time + p.wobbleOffset) * def.wobbleStrength * 0.5;
                } else if (def.drawType == EffectDrawType.bubble) {
                  final wobble =
                      sin(_time * p.wobbleSpeed + p.wobbleOffset) * 0.5 +
                      sin(_time * p.wobbleSpeed * 0.5 + p.wobbleOffset) * 0.5;
                  p.x += wobble * def.wobbleStrength;
                } else if (def.drawType == EffectDrawType.petal) {
                  p.x += sin(_time * 2 + p.wobbleOffset) * def.wobbleStrength;
                  p.y += cos(_time + p.wobbleOffset) * (def.wobbleStrength * 0.5);
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
                reset = p.life <= 0 || p.y > 1.1 || p.y < -0.2 || p.x < -0.2 || p.x > 1.2;
              }

              if (reset) {
                // 雷の場合は消滅させる (次の生成はタイマーが管理)
                if (def.drawType == EffectDrawType.lightning) {
                  // リストから削除するためにマークしたいが、
                  // 下の removeWhere で処理するのでここでは何もしないでOK
                  // (p.life <= 0 になっていれば削除される)
                } else {
                  // 他のエフェクトは再利用
                  p.reset(_createParticle());
                }
              }
            }

            // 寿命が尽きたパーティクルを削除 (雷用)
            // 他のエフェクトは reset で再利用しているので life > 0 に戻っているはずだが、
            // 安全のため lightning 限定の削除ロジックにする
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
  double wobbleSpeed;
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
    this.wobbleSpeed = 1.0,
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
    wobbleSpeed = p.wobbleSpeed;
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
        // 雷フェードアウト
        opacity = p.life > 0.8 ? (1.0 - p.life) * 5.0 : p.life * 1.2;
        opacity = opacity.clamp(0.0, 1.0);
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
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = (p.size * 0.1).clamp(0.5, 1.5);
          paint.strokeCap = StrokeCap.round;
          paint.color = Colors.white.withOpacity(opacity);

          final radius = p.size / 2;

          // 6方向への枝を描画 (雪の結晶)
          for (int i = 0; i < 3; i++) {
            canvas.save();
            canvas.rotate(pi / 3 * i); // 60度ずつ回転 (3本で6方向)

            // メインの軸線
            canvas.drawLine(Offset(0, -radius), Offset(0, radius), paint);

            // 枝分かれの装飾 (視認性を考慮してシンプルに)
            final branchY = radius * 0.6;
            final branchSize = radius * 0.3;

            // 上側の枝
            canvas.drawLine(Offset(0, -branchY), Offset(-branchSize, -branchY - branchSize), paint);
            canvas.drawLine(Offset(0, -branchY), Offset(branchSize, -branchY - branchSize), paint);

            // 下側の枝
            canvas.drawLine(Offset(0, branchY), Offset(-branchSize, branchY + branchSize), paint);
            canvas.drawLine(Offset(0, branchY), Offset(branchSize, branchY + branchSize), paint);

            canvas.restore();
          }
          break;

        case EffectDrawType.bubble:
          // 本体 (薄い)
          final fillPaint = Paint()
            ..color = Colors.lightBlueAccent.withOpacity(0.1 * opacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset.zero, p.size, fillPaint);

          // 輪郭
          final strokePaint = Paint()
            ..color = Colors.white.withOpacity(0.5 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawCircle(Offset.zero, p.size, strokePaint);

          // ハイライト
          final highlightPaint = Paint()
            ..color = Colors.white.withOpacity(0.8 * opacity)
            ..style = PaintingStyle.fill;

          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(-p.size * 0.4, -p.size * 0.4),
              width: p.size * 0.4,
              height: p.size * 0.25,
            ),
            highlightPaint,
          );
          canvas.drawCircle(Offset(p.size * 0.4, p.size * 0.4), p.size * 0.1, highlightPaint);
          break;

        case EffectDrawType.ember:
          canvas.drawCircle(Offset.zero, p.size, paint);
          break;

        case EffectDrawType.lightning:
          if (p.thunderPath != null && p.life > 0) {
            final matrix = Matrix4.identity();
            matrix.translate(p.x * size.width * 0.2, p.y * size.height * 0.2);
            matrix.scale(size.width * 1.2, size.height * 0.8);
            final transformedPath = p.thunderPath!.transform(matrix.storage);

            paint.style = PaintingStyle.stroke;
            paint.strokeCap = StrokeCap.butt;
            paint.strokeJoin = StrokeJoin.miter;
            paint.blendMode = BlendMode.plus;

            // 1. 外光
            paint.color = p.color.withOpacity(opacity * 0.6);
            paint.strokeWidth = p.size * 6.0;
            paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);
            canvas.drawPath(transformedPath, paint);

            // 2. 中間
            paint.color = p.color.withOpacity(opacity * 0.8);
            paint.strokeWidth = p.size * 3.0;
            paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
            canvas.drawPath(transformedPath, paint);

            // 3. コア
            paint.color = Colors.white.withOpacity(opacity);
            paint.strokeWidth = p.size * 1.0;
            paint.maskFilter = null;
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
