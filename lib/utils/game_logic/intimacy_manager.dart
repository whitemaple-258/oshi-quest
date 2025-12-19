import 'dart:math';
import '../../data/database/database.dart';

/// OshiQuest Intimacy Logic v2.0.0
class IntimacyManager {
  static const int maxLevel = 100;

  // ==========================================================================
  // 特典判定ロジック
  // ==========================================================================

  /// デイリーボーナスが発生するか？ (Lv10以上)
  /// 引数: 親密度Lv
  static bool checkDailyBonusUnlock(int level) {
    return level >= 10;
  }

  /// ショップキャッシュバックが発生するか？ (Lv50以上)
  /// 引数: 親密度Lv
  static bool checkCashbackUnlock(int level) {
    return level >= 50;
  }

  /// 特殊演出・高還元が発生するか？ (LvMAX)
  static bool checkMaxLevelBenefit(int level) {
    return level >= maxLevel;
  }

  // ==========================================================================
  // 具体的な効果計算
  // ==========================================================================

  /// キャッシュバックされるジェムの量を計算
  /// logic: 確率判定 -> 成功なら還元
  static int calculateCashback(int level, int spentGems) {
    // Lv50未満は機能ロック
    if (level < 50) return 0;

    final Random rand = Random();
    double chance;
    double returnRate;

    if (level >= maxLevel) {
      // LvMAX: 高確率(50%)、高還元(20%〜100%)
      chance = 0.5;
      returnRate = 0.2 + (rand.nextDouble() * 0.8); // 0.2 ~ 1.0
    } else {
      // Lv50-99: 低確率(10%)、低還元(5%〜10%)
      chance = 0.1;
      returnRate = 0.05 + (rand.nextDouble() * 0.05); // 0.05 ~ 0.1
    }

    // 抽選
    if (rand.nextDouble() < chance) {
      return (spentGems * returnRate).floor();
    }
    
    return 0; // ハズレ
  }

  /// ログイン時の挨拶テキストタイプを取得
  static IntimacyGreetingType getGreetingType(int level) {
    if (level >= maxLevel) return IntimacyGreetingType.devoted; // デレ
    if (level >= 50) return IntimacyGreetingType.friendly;      // 親友
    if (level >= 10) return IntimacyGreetingType.normal;        // 知り合い
    return IntimacyGreetingType.business;                       // 塩対応
  }
}

enum IntimacyGreetingType {
  business, // Lv1-9
  normal,   // Lv10-49
  friendly, // Lv50-99
  devoted,  // LvMAX
}