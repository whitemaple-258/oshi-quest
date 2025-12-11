import '../database/database.dart';

// ============================================================================
// ステータス配分テンプレート (Stat Templates)
// ============================================================================
class StatTemplate {
  final String name;
  // 各ステータスの配分比率 (合計が1.0にならなくても、比率として計算されます)
  final double strWeight;
  final double intWeight;
  final double vitWeight;
  final double luckWeight;
  final double chaWeight;

  const StatTemplate(this.name, {
    this.strWeight = 1.0,
    this.intWeight = 1.0,
    this.vitWeight = 1.0,
    this.luckWeight = 1.0,
    this.chaWeight = 1.0,
  });
}

// 🛠️ ここをいじればステータスの傾向を調整できます
final List<StatTemplate> statTemplates = [
  StatTemplate('バランス型', strWeight: 1, intWeight: 1, vitWeight: 1, luckWeight: 1, chaWeight: 1),
  StatTemplate('物理アタッカー', strWeight: 5, intWeight: 1, vitWeight: 2, luckWeight: 1, chaWeight: 1),
  StatTemplate('魔法使い', strWeight: 1, intWeight: 5, vitWeight: 1, luckWeight: 2, chaWeight: 1),
  StatTemplate('タンク', strWeight: 2, intWeight: 1, vitWeight: 5, luckWeight: 1, chaWeight: 1),
  StatTemplate('ギャンブラー', strWeight: 1, intWeight: 1, vitWeight: 1, luckWeight: 6, chaWeight: 1),
  StatTemplate('アイドル', strWeight: 1, intWeight: 2, vitWeight: 1, luckWeight: 2, chaWeight: 5),
];

// ============================================================================
// スキル定義 (Skill Definitions)
// ============================================================================
class SkillDef {
  final SkillType type;
  final int minVal;
  final int maxVal;
  final int minDurationMinutes;
  final int maxDurationMinutes;
  final double probability; // 出現確率 (0.0 ~ 1.0)

  const SkillDef({
    required this.type,
    required this.minVal,
    required this.maxVal,
    required this.minDurationMinutes,
    required this.maxDurationMinutes,
    required this.probability,
  });
}

// 🛠️ ここをいじればスキルの内容や確率を調整できます
final List<SkillDef> skillDefinitions = [
  SkillDef(type: SkillType.gemBoost, minVal: 10, maxVal: 50, minDurationMinutes: 15, maxDurationMinutes: 60, probability: 0.15),
  SkillDef(type: SkillType.xpBoost, minVal: 10, maxVal: 50, minDurationMinutes: 15, maxDurationMinutes: 60, probability: 0.15),
  SkillDef(type: SkillType.strBoost, minVal: 5, maxVal: 20, minDurationMinutes: 5, maxDurationMinutes: 15, probability: 0.1),
  SkillDef(type: SkillType.luckBoost, minVal: 5, maxVal: 20, minDurationMinutes: 5, maxDurationMinutes: 15, probability: 0.1),
];

// ============================================================================
// シリーズ定義 (Series Definitions)
// ============================================================================
class SeriesDef {
  final SeriesType type;
  final double probability;

  const SeriesDef(this.type, this.probability);
}

// 🛠️ ここをいじればシリーズ装備の出現率を調整できます
final List<SeriesDef> seriesDefinitions = [
  SeriesDef(SeriesType.crimson, 0.05),
  SeriesDef(SeriesType.azure, 0.05),
  SeriesDef(SeriesType.golden, 0.05),
  SeriesDef(SeriesType.phantom, 0.05),
];