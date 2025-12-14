import 'package:flutter/material.dart';
import '../database/database.dart';

/// 描画ロジックのタイプ
enum EffectDrawType {
  petal, // 花びら (Light)
  snow, // 雪/瘴気 (Dark)
  bubble, // 泡 (Water)
  ember, // 火の粉 (Fire)
  lightning, // 稲妻 (Thunder)
  rain, // 雨 (Rain)
}

/// 出現位置のタイプ
enum SpawnType {
  top, // 上から降る
  bottom, // 下から湧く
  random, // 画面全体/ランダム
}

/// エフェクトのパラメータ定義クラス
class EffectDef {
  final int particleCount; // 粒子の数
  final SpawnType spawnType; // 出現位置

  // サイズ範囲
  final double minSize;
  final double maxSize;

  // 速度範囲 (1.0 = 画面サイズ)
  final double minSpeedX;
  final double maxSpeedX;
  final double minSpeedY;
  final double maxSpeedY;

  // 寿命減少量 (0.0 で自然消滅なし)
  final double decayRate;

  // 色候補リスト
  final List<Color> colors;

  // 描画タイプ
  final EffectDrawType drawType;

  // ブレンドモード (光らせるなら plus, 濃くするなら srcOver)
  final BlendMode blendMode;

  // 揺らぎ (Wobble) の強さ
  final double wobbleStrength;

  const EffectDef({
    required this.particleCount,
    required this.spawnType,
    required this.minSize,
    required this.maxSize,
    required this.minSpeedX,
    required this.maxSpeedX,
    required this.minSpeedY,
    required this.maxSpeedY,
    required this.decayRate,
    required this.colors,
    required this.drawType,
    this.blendMode = BlendMode.plus,
    this.wobbleStrength = 0.0,
  });
}

/// ✅ エフェクトのマスターデータ
/// DatabaseのEffectType(Enum)をキーにして設定を取り出す
final Map<EffectType, EffectDef> effectMasterData = {
  // 🌸 桜吹雪 (Light)
  EffectType.cherry: EffectDef(
    particleCount: 60,
    spawnType: SpawnType.top,
    minSize: 5.0,
    maxSize: 13.0,
    minSpeedX: -0.0005,
    maxSpeedX: 0.0015,
    minSpeedY: 0.001,
    maxSpeedY: 0.003,
    decayRate: 0.0,
    colors: [
      Color(0xCCFF80AB), // PinkAccent (opacity 0.8)
      Color(0xCCF48FB1), // Pink.shade200
      Color(0xE6FFFFFF), // White
    ],
    drawType: EffectDrawType.petal,
    wobbleStrength: 0.001,
  ),

  // ❄️ 雪 (snow)
  EffectType.snow: EffectDef(
    particleCount: 150, // 密度を出すために少し多めに
    spawnType: SpawnType.top,
    
    // サイズ差をつけて奥行きを出す
    minSize: 3.0, 
    maxSize: 10.0, 
    
    // 風の影響 (全体的に少しだけ左に流れるなど)
    minSpeedX: -0.0002, 
    maxSpeedX: 0.0002,
    
    // 落下速度 (ロジック側でサイズに基づいて再計算するので、ここはベース値)
    minSpeedY: 0.0005, 
    maxSpeedY: 0.0015,
    
    // 自然に落ちるように減衰はほぼなし (画面外でリセットさせる)
    decayRate: 0.0005,
    
    colors: [Colors.white], 
    drawType: EffectDrawType.snow,
    
    // ゆらゆらさせる強度
    wobbleStrength: 0.003, 
  ),

  // 🫧 泡 (Water)
  EffectType.bubble: EffectDef(
    particleCount: 30,
    spawnType: SpawnType.bottom,
    minSize: 10.0,
    maxSize: 30.0,
    minSpeedX: 0.0,
    maxSpeedX: 0.0,
    minSpeedY: -0.0015,
    maxSpeedY: -0.0005,
    decayRate: 0.0,
    colors: [Colors.transparent], // 色は描画ロジックで固定
    drawType: EffectDrawType.bubble,
    blendMode: BlendMode.srcOver, // くっきり表示
    wobbleStrength: 0.0003,
  ),

  // 🔥 火の粉 (Fire) - 小さく長く舞う設定
  EffectType.ember: EffectDef(
    particleCount: 150,
    spawnType: SpawnType.bottom,
    minSize: 1.0,
    maxSize: 3.0,
    minSpeedX: -0.001,
    maxSpeedX: 0.001,
    minSpeedY: -0.004,
    maxSpeedY: -0.001,
    decayRate: 0.0035, // ゆっくり消える
    colors: [Colors.deepOrange, Colors.orangeAccent, Colors.amber, Colors.white],
    drawType: EffectDrawType.ember,
    wobbleStrength: 0.0005,
  ),

  // ⚡ 稲妻 (lightning)
  EffectType.lightning: EffectDef(
    particleCount: 5, // ✅ 修正: バースト時に詰まらないよう少し余裕を持たせる
    spawnType: SpawnType.random,
    minSize: 3.0, maxSize: 6.0,
    minSpeedX: 0.0, maxSpeedX: 0.0,
    minSpeedY: 0.0, maxSpeedY: 0.0,
    decayRate: 0.15, 
    colors: [
      Colors.cyanAccent,
      Colors.lightBlueAccent,
      Colors.white,
    ],
    drawType: EffectDrawType.lightning,
    blendMode: BlendMode.plus, 
  ),

  // ☔ 雨 (Rain) - 新規追加
  EffectType.rain: EffectDef(
    particleCount: 200, // 豪雨
    spawnType: SpawnType.top,
    minSize: 20.0,
    maxSize: 40.0, // 線を長く
    // ✅ 向きを揃える: X速度を固定する
    minSpeedX: -0.005,
    maxSpeedX: -0.005,

    // 落下速度
    minSpeedY: 0.03,
    maxSpeedY: 0.04,

    decayRate: 0.0,

    colors: [
      Colors.white.withOpacity(0.5), // メインの雨粒
      Colors.white.withOpacity(0.3), // 少し薄い雨
      Colors.white.withOpacity(0.1), // 背景に溶け込む雨
    ],

    drawType: EffectDrawType.rain,
    blendMode: BlendMode.srcOver, // 通常合成 (白飛び防止)
  ),
};
