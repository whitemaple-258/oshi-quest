import '../database/database.dart';

/// フレームの定義クラス
class FrameDef {
  final String assetPath;
  final String title;
  final Rarity rarity;
  // ステータス補正値（任意）
  final int strBonus;
  final int intBonus;
  final int vitBonus;
  final int luckBonus;
  final int chaBonus;

  const FrameDef({
    required this.assetPath,
    required this.title,
    this.rarity = Rarity.n,
    this.strBonus = 0,
    this.intBonus = 0,
    this.vitBonus = 0,
    this.luckBonus = 0,
    this.chaBonus = 0,
  });
}

/// ✅ フレームのマスタデータ一覧
/// ここに追記するだけでアプリに反映されます
final List<FrameDef> defaultFrames = [
  FrameDef(
    assetPath: 'assets/frames/frame_wood.png', // 画像ファイル名に合わせてください
    title: '木の額縁',
    rarity: Rarity.n,
    vitBonus: 1, // 少し体力が上がる
  ),
  FrameDef(
    assetPath: 'assets/frames/frame_silver.png',
    title: '白銀のフレーム',
    rarity: Rarity.r,
    strBonus: 2,
    intBonus: 2,
  ),
  FrameDef(
    assetPath: 'assets/frames/frame_gold.png',
    title: '黄金の額縁',
    rarity: Rarity.sr,
    luckBonus: 5,
    chaBonus: 3,
  ),
  // ... 今後ここに追加
];
