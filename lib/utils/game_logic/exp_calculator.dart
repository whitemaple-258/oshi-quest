import 'dart:math';

/// 経験値計算ロジック
class ExpCalculator {
  static const int kMaxLevel = 99; // 上限
  static const int baseExp = 10;
  static const double exponent = 2.0;

  // ✅ 難易度解放レベル
  static const int unlockLevelMedium = 10;
  static const int unlockLevelHigh = 20;

  /// 次のレベルに必要な経験値を計算
  static int requiredExpForNextLevel(int currentLevel) {
    if (currentLevel >= kMaxLevel) {
      return baseExp * pow(kMaxLevel, exponent).floor();
    }
    final req = baseExp * pow(currentLevel, exponent);
    return req.floor();
  }

  /// ✅ これがないとエラーになります
  static bool isMaxLevel(int level) {
    return level >= kMaxLevel;
  }
}