import '../database/database.dart'; // SeriesType, SkillTypeなどのEnum

// ============================================================================
// 1. 定義クラス (Definitions)
// ============================================================================

enum SkillTrigger { onAttack, onTurnStart, onDamage, passive }
enum SkillEffectType { damage, heal, buff, debuff, tank, gambler }

/// スキルの詳細定義
class SkillDefinition {
  final SkillType id;
  final String name;
  final String description;
  final SkillTrigger trigger;
  final SkillEffectType effectType;
  final double value; // 倍率や固定値

  const SkillDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.trigger,
    required this.effectType,
    required this.value,
  });
}

/// シリーズの詳細定義
class SeriesDefinition {
  final SeriesType id;
  final String name;
  final String description;
  // このシリーズが持ちうるスキルリスト（ガチャ抽選用）
  final List<SkillType> availableSkills;

  const SeriesDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.availableSkills,
  });
}

// ============================================================================
// 2. マスタデータ (Master Data)
// ============================================================================

class BattleMasterData {
  /// スキルマスタ
  static const Map<SkillType, SkillDefinition> skills = {
    SkillType.strBoost: SkillDefinition(
      id: SkillType.strBoost,
      name: '渾身の一撃',
      description: '物理ダメージが1.5倍になる',
      trigger: SkillTrigger.onAttack,
      effectType: SkillEffectType.damage,
      value: 1.5,
    ),
    SkillType.vitBoost: SkillDefinition(
      id: SkillType.vitBoost,
      name: '鉄壁の守り',
      description: '受けるダメージを軽減する',
      trigger: SkillTrigger.onDamage,
      effectType: SkillEffectType.tank,
      value: 0.5,
    ),
    SkillType.gemBoost: SkillDefinition(
      id: SkillType.gemBoost,
      name: '幸運の兆し',
      description: 'クリティカル率アップ',
      trigger: SkillTrigger.passive,
      effectType: SkillEffectType.gambler,
      value: 1.2,
    ),
    // ... 他のスキルも同様に定義
  };

  /// シリーズマスタ (既存のEnumに概念をマッピング)
  static const Map<SeriesType, SeriesDefinition> series = {
    SeriesType.crimson: SeriesDefinition(
      id: SeriesType.crimson,
      name: '勇者シリーズ',
      description: 'バランスの良いステータスを持つ伝説の勇者たち',
      availableSkills: [SkillType.strBoost, SkillType.vitBoost],
    ),
    SeriesType.golden: SeriesDefinition(
      id: SeriesType.golden,
      name: 'アイドルシリーズ',
      description: '高いCHAでパーティを支援する',
      availableSkills: [SkillType.chaBoost, SkillType.gemBoost],
    ),
    SeriesType.azure: SeriesDefinition(
      id: SeriesType.azure,
      name: 'ハッカーシリーズ',
      description: '高いINTで敵を翻弄する',
      availableSkills: [SkillType.intBoost],
    ),
    SeriesType.phantom: SeriesDefinition(
      id: SeriesType.phantom,
      name: '社畜シリーズ',
      description: '高いVITでMAINを守る盾となる',
      availableSkills: [SkillType.vitBoost],
    ),
  };

  static SkillDefinition getSkill(SkillType type) {
    return skills[type] ?? const SkillDefinition(
      id: SkillType.none, name: 'なし', description: '', 
      trigger: SkillTrigger.passive, effectType: SkillEffectType.buff, value: 0
    );
  }
}