import 'dart:math';

/// OshiQuest Parameter Logic v2.0.0
class StatCalculator {
  // パラメータ上限 (想定)
  static const int maxStat = 1000;

  // ==========================================================================
  // STR: 筋力 (Strength)
  // ==========================================================================
  
  /// Battle: 基礎攻撃力への加算値 (直接加算)
  static int getAttackBonus(int str) => str;

  /// Life: 報酬獲得量 (Coin/Gem) の倍率
  /// 仕様: 稼ぎ効率を高める
  /// 計算式: 1.0 + (STR * 0.002) -> 1000で3倍
  static double getRewardMultiplier(int str) {
    return 1.0 + (str * 0.002);
  }

  // ==========================================================================
  // VIT: 体力 (Vitality)
  // ==========================================================================

  /// Battle: HP/DEFへの加算値 (直接加算)
  static int getDefenseBonus(int vit) => vit;

  /// Life: 連続記録保護 (猶予時間)
  /// 仕様: タスク未完了時のリセット回避時間
  static int getStreakGracePeriodHours(int vit) {
    if (vit >= 100) {
      return 48; // 100以上で48時間延長
    } else if (vit >= 50) {
      return 24; // 50以上で24時間延長
    } else {
      return 0;  // 保護なし
    }
  }

  // ==========================================================================
  // INT: 知力 (Intelligence)
  // ==========================================================================

  /// Battle: スキル発動率ボーナス (%)
  /// 計算式: INT * 0.02 -> 1000で+20%
  static double getSkillActivationRateBonus(int intel) {
    return intel * 0.02;
  }

  /// Life: プレイヤー経験値獲得量の倍率
  /// 仕様: レベル上げを加速
  /// 計算式: 1.0 + (INT * 0.002) -> 1000で3倍
  static double getExpMultiplier(int intel) {
    return 1.0 + (intel * 0.002);
  }

  // ==========================================================================
  // LUK: 運 (Luck)
  // ==========================================================================

  /// Battle: クリティカル率ボーナス (%)
  /// 計算式: LUK * 0.05 -> 1000で+50%
  static double getCriticalRateBonus(int luk) {
    return luk * 0.05;
  }

  /// Life: タスク大成功率 (%)
  /// 仕様: Base(1%) + (LUK * 0.05%)
  static double getGreatSuccessRate(int luk) {
    const double baseRate = 1.0;
    return baseRate + (luk * 0.05);
  }

  /// 大成功時の報酬倍率 (3倍〜5倍のランダム)
  static int getGreatSuccessMultiplier() {
    return 3 + Random().nextInt(3); // 3, 4, 5 のいずれか
  }

  // ==========================================================================
  // CHA: 魅力 (Charisma)
  // ==========================================================================

  /// Battle: サブメンバーのステータス反映率 (0.0 ~ 1.0)
  /// 仕様: 0.1 + CHA * 0.0005
  /// 例: CHA 0 -> 10%, CHA 1000 -> 60%
  static double getSubMemberStatsRatio(int cha) {
    return 0.1 + (cha * 0.0005);
  }

  /// Life: 親密度獲得量 (1回あたり)
  /// 仕様: Base(10) * (1 + CHA * 0.01)
  static int getIntimacyGainPerTask(int cha) {
    const int baseIntimacy = 10;
    final double multiplier = 1.0 + (cha * 0.01);
    return (baseIntimacy * multiplier).floor();
  }
}