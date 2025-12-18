import 'dart:math';

class IntimacyCalculator {
  static const int kMaxLevel = 100; // 仕様: Lv100 (Soft Cap)
  static const int baseExp = 50;    // Lv1->2 の基準値
  static const double exponent = 1.8; // プレイヤーLvより少し緩めだが、後半沼になる設定

  /// 次のレベルに必要な親密度経験値を計算
  static int requiredExpForNextLevel(int currentLevel) {
    if (currentLevel >= kMaxLevel) {
      return baseExp * pow(kMaxLevel, exponent).floor();
    }
    final req = baseExp * pow(currentLevel, exponent);
    return req.floor();
  }

  /// 獲得親密度ポイントの計算
  /// Formula: 10 * (1 + CHA * 0.01)
  static int calculateGain(int cha) {
    // CHA 0 -> 10pt
    // CHA 100 -> 20pt
    // CHA 1000 -> 110pt
    double multiplier = 1.0 + (cha * 0.01);
    return (10 * multiplier).floor();
  }

  /// デイリーボーナス発生率 (Lv * 0.5%)
  static double getDailyBonusChance(int level) {
    return min(level * 0.5, 100.0); // 最大100%等はロジックで制御
  }

  /// キャッシュバック発生率 ((Lv - 40) * 0.5%)
  static double getCashbackChance(int level) {
    if (level < 50) return 0.0;
    // Lv50 -> 5%, Lv100 -> 30%
    return max(0.0, (level - 40) * 0.5);
  }
}