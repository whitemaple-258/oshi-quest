// lib/logic/gacha_logic_master.dart

import 'dart:math';
import 'package:drift/drift.dart';
import '../database/database.dart';

// ============================================================================
// 設定値 (Config)
// ============================================================================

// レアリティ設定
class RaritySetting {
  final int minTotalStatus;
  final int maxTotalStatus;
  final double skillProb;
  final double skillPowerMult;
  final double seriesProb;

  const RaritySetting({
    required this.minTotalStatus,
    required this.maxTotalStatus,
    required this.skillProb,
    required this.skillPowerMult,
    required this.seriesProb,
  });
}

// ステータステンプレート
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

// スキル定義
class SkillDef {
  final SkillType type;
  final int minVal;
  final int maxVal;
  final double probability;

  const SkillDef({
    required this.type,
    required this.minVal,
    required this.maxVal,
    required this.probability,
  });
}

// シリーズ定義
class SeriesDef {
  final SeriesType type;
  final double probability;
  const SeriesDef(this.type, this.probability);
}

// ============================================================================
// Logic Master 本体
// ============================================================================

class GachaLogicMaster {
  static final Random _random = Random();

  // --- 設定データ ---
  static final Map<Rarity, RaritySetting> _raritySettings = {
    Rarity.n: const RaritySetting(minTotalStatus: 50, maxTotalStatus: 150, skillProb: 0.1, skillPowerMult: 1.0, seriesProb: 0.05),
    Rarity.r: const RaritySetting(minTotalStatus: 150, maxTotalStatus: 350, skillProb: 0.3, skillPowerMult: 1.1, seriesProb: 0.15),
    Rarity.sr: const RaritySetting(minTotalStatus: 500, maxTotalStatus: 1000, skillProb: 0.7, skillPowerMult: 1.3, seriesProb: 0.30),
    Rarity.ssr: const RaritySetting(minTotalStatus: 1500, maxTotalStatus: 3000, skillProb: 1.0, skillPowerMult: 1.8, seriesProb: 0.70),
  };

  static final List<StatTemplate> _statTemplates = [
    const StatTemplate('バランス型'),
    const StatTemplate('物理アタッカー', strWeight: 5, intWeight: 1, vitWeight: 2),
    const StatTemplate('魔法使い', strWeight: 1, intWeight: 5, vitWeight: 1, luckWeight: 2),
    const StatTemplate('タンク', vitWeight: 5, strWeight: 2, intWeight: 1),
    const StatTemplate('ギャンブラー', luckWeight: 6, strWeight: 1, intWeight: 1),
    const StatTemplate('アイドル', chaWeight: 5, intWeight: 2, luckWeight: 2),
  ];

  static final List<SkillDef> _skillDefinitions = [
    const SkillDef(type: SkillType.gemBoost, minVal: 10, maxVal: 50, probability: 0.20),
    const SkillDef(type: SkillType.xpBoost, minVal: 10, maxVal: 50, probability: 0.20),
    const SkillDef(type: SkillType.strBoost, minVal: 5, maxVal: 20, probability: 0.15),
    const SkillDef(type: SkillType.luckBoost, minVal: 5, maxVal: 20, probability: 0.15),
    const SkillDef(type: SkillType.intBoost, minVal: 5, maxVal: 20, probability: 0.15),
    const SkillDef(type: SkillType.vitBoost, minVal: 5, maxVal: 20, probability: 0.15),
  ];

  static final List<SeriesDef> _seriesDefinitions = [
    const SeriesDef(SeriesType.crimson, 0.25),
    const SeriesDef(SeriesType.azure, 0.25),
    const SeriesDef(SeriesType.golden, 0.25),
    const SeriesDef(SeriesType.phantom, 0.25),
  ];

  // ========================================================================
  // 外部参照用のGetter
  // ========================================================================
  
  /// 排出率画面などで使用: スキル定義リスト
  static List<SkillDef> get skillDefinitions => _skillDefinitions;

  /// 排出率画面などで使用: レアリティ設定マップ
  static Map<Rarity, RaritySetting> get raritySettings => _raritySettings;

  /// 排出率画面などで使用: シリーズ定義リスト
  static List<SeriesDef> get seriesDefinitions => _seriesDefinitions;

  // ========================================================================
  // 公開メソッド (API)
  // ========================================================================

  /// レアリティを抽選する
  static Rarity rollRarity() {
    final rand = _random.nextDouble();
    if (rand < 0.03) return Rarity.ssr; // 3%
    if (rand < 0.15) return Rarity.sr;  // 12%
    if (rand < 0.45) return Rarity.r;   // 30%
    return Rarity.n;                    // 55%
  }

  /// タイツの色を決定する
  static TightsColor determineTightsColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.ssr: return TightsColor.gold;
      case Rarity.sr: return TightsColor.purple;
      case Rarity.r: return TightsColor.blue;
      case Rarity.n: return TightsColor.gray;
    }
  }

  /// ガチャアイテムデータ (Companion) を生成する
  /// 画像パスなどがnullの場合は「全身タイツ君」として生成
  static GachaItemsCompanion generateItemCompanion({
    required Rarity rarity,
    String? imagePath,
    String? name,
    required GachaItemType type,
    TightsColor? tightsColor,
  }) {
    final setting = _raritySettings[rarity]!;
    final template = _selectRandomTemplate();

    // 1. ステータス計算
    final stats = _calculateStats(setting, template);

    // 2. スキル・シリーズ・エフェクト
    final skillData = _determineSkill(setting);
    final seriesType = _determineSeries(setting);
    final effectType = _selectRandomEffect();
    final parameterType = _determineParameterType(template);

    // 3. タイトル生成
    final title = name ?? '${rarity.name.toUpperCase()}カード (${template.name})';

    // 4. Companion生成
    return GachaItemsCompanion.insert(
      type: Value(type),
      tightsColor: Value(tightsColor ?? TightsColor.none),
      title: title,
      rarity: rarity,
      effectType: effectType,
      parameterType: parameterType,
      
      // ステータス
      strBonus: Value(stats['str']!),
      intBonus: Value(stats['int']!),
      vitBonus: Value(stats['vit']!),
      luckBonus: Value(stats['luck']!),
      chaBonus: Value(stats['cha']!),

      // スキル
      skillType: Value(skillData.type),
      skillValue: Value(skillData.value),
      skillDuration: const Value(0), // 現在は未使用
      skillCooldown: const Value(0),
      
      // シリーズ
      seriesType: Value(seriesType), // 古いカラム
      seriesId: Value(seriesType), // 新しいカラム (両方入れておくのが無難)
      
      // その他
      isUnlocked: const Value(true),
      imagePath: Value(imagePath),
      createdAt: Value(DateTime.now()),
      intimacyLevel: const Value(1),
      intimacyExp: const Value(0),
      isEquipped: const Value(false),
      isLocked: const Value(false),
      isFavorite: const Value(false),
      isSource: const Value(false),
    );
  }

  // ========================================================================
  // 内部ロジック
  // ========================================================================

  static StatTemplate _selectRandomTemplate() {
    return _statTemplates[_random.nextInt(_statTemplates.length)];
  }

  static Map<String, int> _calculateStats(RaritySetting setting, StatTemplate template) {
    final totalStatus = setting.minTotalStatus + _random.nextInt(setting.maxTotalStatus - setting.minTotalStatus + 1);
    final double totalWeight = template.strWeight + template.intWeight + template.vitWeight + template.luckWeight + template.chaWeight;
    
    int str = (totalStatus * (template.strWeight / totalWeight)).round();
    int inte = (totalStatus * (template.intWeight / totalWeight)).round();
    int vit = (totalStatus * (template.vitWeight / totalWeight)).round();
    int luck = (totalStatus * (template.luckWeight / totalWeight)).round();
    int cha = (totalStatus * (template.chaWeight / totalWeight)).round();

    // 端数調整
    int currentTotal = str + inte + vit + luck + cha;
    int diff = totalStatus - currentTotal;
    if (diff != 0) {
      final list = [str, inte, vit, luck, cha];
      list[_random.nextInt(5)] += diff;
      str=list[0]; inte=list[1]; vit=list[2]; luck=list[3]; cha=list[4];
    }
    return {'str': str, 'int': inte, 'vit': vit, 'luck': luck, 'cha': cha};
  }

  static ({SkillType type, int value}) _determineSkill(RaritySetting setting) {
    if (_random.nextDouble() > setting.skillProb) {
      return (type: SkillType.none, value: 0);
    }
    
    double totalProb = _skillDefinitions.fold(0.0, (sum, def) => sum + def.probability);
    double roll = _random.nextDouble() * totalProb;
    double current = 0.0;
    SkillDef selected = _skillDefinitions.last;

    for (var def in _skillDefinitions) {
      current += def.probability;
      if (roll <= current) {
        selected = def;
        break;
      }
    }

    int baseVal = selected.minVal + _random.nextInt(selected.maxVal - selected.minVal + 1);
    int value = (baseVal * setting.skillPowerMult).round();
    return (type: selected.type, value: value);
  }

  static SeriesType _determineSeries(RaritySetting setting) {
    if (_random.nextDouble() > setting.seriesProb) return SeriesType.none;
    return _seriesDefinitions[_random.nextInt(_seriesDefinitions.length)].type;
  }

  static EffectType _selectRandomEffect() {
    final effects = EffectType.values.where((e) => e != EffectType.none).toList();
    if (effects.isEmpty) return EffectType.none;
    return effects[_random.nextInt(effects.length)];
  }

  static TaskType _determineParameterType(StatTemplate template) {
    final Map<TaskType, double> weights = {
      TaskType.strength: template.strWeight,
      TaskType.intelligence: template.intWeight,
      TaskType.vitality: template.vitWeight,
      TaskType.luck: template.luckWeight,
      TaskType.charm: template.chaWeight,
    };
    return weights.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}