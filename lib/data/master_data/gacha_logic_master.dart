import 'dart:math';
import '../database/database.dart';

// ============================================================================
// レアリティ別 生成設定 (Rarity Settings) ✅ 追加
// ============================================================================
class RaritySetting {
  final int minTotalStatus; // ステータス合計の下限
  final int maxTotalStatus; // ステータス合計の上限
  final double skillProb; // スキルが付く確率 (0.0 ~ 1.0)
  final double skillPowerMult; // スキル効果値の倍率 (1.0 = 通常, 1.5 = 1.5倍)
  final double seriesProb; // シリーズが付く確率 (0.0 ~ 1.0)

  const RaritySetting({
    required this.minTotalStatus,
    required this.maxTotalStatus,
    required this.skillProb,
    required this.skillPowerMult,
    required this.seriesProb,
  });
}

// 🛠️ ここでレアリティごとの強さを調整します
final Map<Rarity, RaritySetting> raritySettings = {
  Rarity.n: const RaritySetting(
    minTotalStatus: 10,
    maxTotalStatus: 20,
    skillProb: 0.1, // 10%
    skillPowerMult: 1.0, // 等倍
    seriesProb: 0.05, // 5%
  ),
  Rarity.r: const RaritySetting(
    minTotalStatus: 20,
    maxTotalStatus: 35,
    skillProb: 0.3, // 30%
    skillPowerMult: 1.1, // 1.1倍
    seriesProb: 0.15, // 15%
  ),
  Rarity.sr: const RaritySetting(
    minTotalStatus: 40,
    maxTotalStatus: 60,
    skillProb: 0.7, // 70%
    skillPowerMult: 1.3, // 1.3倍
    seriesProb: 0.30, // 30%
  ),
  Rarity.ssr: const RaritySetting(
    minTotalStatus: 80,
    maxTotalStatus: 120,
    skillProb: 1.0, // 100% (確定)
    skillPowerMult: 1.5, // 1.5倍
    seriesProb: 0.50, // 50%
  ),
};

// ============================================================================
// ステータス配分テンプレート
// ============================================================================
class StatTemplate {
  final String name;
  final double strWeight;
  final double intWeight;
  final double vitWeight;
  final double luckWeight;
  final double chaWeight;

  const StatTemplate(
    this.name, {
    this.strWeight = 1.0,
    this.intWeight = 1.0,
    this.vitWeight = 1.0,
    this.luckWeight = 1.0,
    this.chaWeight = 1.0,
  });
}

final List<StatTemplate> statTemplates = [
  StatTemplate('バランス型', strWeight: 1, intWeight: 1, vitWeight: 1, luckWeight: 1, chaWeight: 1),
  StatTemplate('物理アタッカー', strWeight: 5, intWeight: 1, vitWeight: 2, luckWeight: 1, chaWeight: 1),
  StatTemplate('魔法使い', strWeight: 1, intWeight: 5, vitWeight: 1, luckWeight: 2, chaWeight: 1),
  StatTemplate('タンク', strWeight: 2, intWeight: 1, vitWeight: 5, luckWeight: 1, chaWeight: 1),
  StatTemplate('ギャンブラー', strWeight: 1, intWeight: 1, vitWeight: 1, luckWeight: 6, chaWeight: 1),
  StatTemplate('アイドル', strWeight: 1, intWeight: 2, vitWeight: 1, luckWeight: 2, chaWeight: 5),
];

// ============================================================================
// スキル定義
// ============================================================================
class SkillDef {
  final SkillType type;
  final int minVal;
  final int maxVal;
  final int minDurationMinutes;
  final int maxDurationMinutes;
  final double probability;

  const SkillDef({
    required this.type,
    required this.minVal,
    required this.maxVal,
    required this.minDurationMinutes,
    required this.maxDurationMinutes,
    required this.probability,
  });
}

final List<SkillDef> skillDefinitions = [
  SkillDef(
    type: SkillType.gemBoost,
    minVal: 10,
    maxVal: 50,
    minDurationMinutes: 15,
    maxDurationMinutes: 60,
    probability: 0.15,
  ),
  SkillDef(
    type: SkillType.xpBoost,
    minVal: 10,
    maxVal: 50,
    minDurationMinutes: 15,
    maxDurationMinutes: 60,
    probability: 0.15,
  ),
  SkillDef(
    type: SkillType.strBoost,
    minVal: 5,
    maxVal: 20,
    minDurationMinutes: 5,
    maxDurationMinutes: 15,
    probability: 0.1,
  ),
  SkillDef(
    type: SkillType.luckBoost,
    minVal: 5,
    maxVal: 20,
    minDurationMinutes: 5,
    maxDurationMinutes: 15,
    probability: 0.1,
  ),
];

// ============================================================================
// シリーズ定義
// ============================================================================
class SeriesDef {
  final SeriesType type;
  final double probability;

  const SeriesDef(this.type, this.probability);
}

final List<SeriesDef> seriesDefinitions = [
  SeriesDef(SeriesType.crimson, 0.05),
  SeriesDef(SeriesType.azure, 0.05),
  SeriesDef(SeriesType.golden, 0.05),
  SeriesDef(SeriesType.phantom, 0.05),
];
