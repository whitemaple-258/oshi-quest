import 'package:drift/drift.dart';
import '../database/database.dart';
import '../master_data/battle_master_data.dart'; // BattleMasterData, SkillDefinition

// ========================================================================
// 1. バトル用データモデル (Domain Layer)
// ========================================================================

/// バトルに参加する個々のキャラクター情報
class BattleCharacter {
  final int id; // GachaItem ID
  final String name;
  final bool isMain; // MAINかSUBか
  final int maxHp;
  final int currentHp; // バトル中のHP
  final int attack;
  final int defense;
  final int speed;
  final int luck;
  final SkillDefinition skill; // マスタから引いたスキル定義
  final GachaItem originalItem; // 元データ

  BattleCharacter({
    required this.id,
    required this.name,
    required this.isMain,
    required this.maxHp,
    required this.currentHp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.luck,
    required this.skill,
    required this.originalItem,
  });

  // HP更新用のコピーメソッド
  BattleCharacter copyWith({int? currentHp}) {
    return BattleCharacter(
      id: id,
      name: name,
      isMain: isMain,
      maxHp: maxHp,
      currentHp: currentHp ?? this.currentHp,
      attack: attack,
      defense: defense,
      speed: speed,
      luck: luck,
      skill: skill,
      originalItem: originalItem,
    );
  }
}

/// パーティ全体のバトル状態
class PartyBattleState {
  final BattleCharacter mainChar;
  final List<BattleCharacter> subChars;

  PartyBattleState({required this.mainChar, required this.subChars});

  // 全員リスト（一斉攻撃などのループ処理用）
  List<BattleCharacter> get allMembers => [mainChar, ...subChars];
  
  // 総戦力（UI表示用）
  int get totalPower => allMembers.fold(0, (sum, char) => sum + char.attack + char.defense + (char.maxHp ~/ 10));
}

// ========================================================================
// 2. PartyRepository 本体
// ========================================================================

class PartyRepository {
  final AppDatabase _db;

  PartyRepository(this._db);

  // ========================================================================
  // A. 装備・編成操作 (CRUD)
  // ========================================================================

  /// 指定したスロットに推しを装備する
  /// [slot] 0: Main, 1-4: Sub
  Future<void> equipToSlot(int slot, int gachaItemId) async {
    await _db.transaction(() async {
      // アクティブなデッキを取得（なければ作成）
      var deck = await (_db.select(
        _db.partyDecks,
      )..where((t) => t.isActive.equals(true))).getSingleOrNull();

      if (deck == null) {
        final deckId = await _db
            .into(_db.partyDecks)
            .insert(
              PartyDecksCompanion.insert(
                name: 'Main Deck',
                isActive: const Value(true),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
        deck = await (_db.select(_db.partyDecks)..where((t) => t.id.equals(deckId))).getSingle();
      }

      // 1. そのスロットの既存装備を解除
      await (_db.delete(_db.partyMembers)
            ..where((t) => t.deckId.equals(deck!.id))
            ..where((t) => t.slotPosition.equals(slot)))
          .go();

      // 2. 他のスロットに同じキャラがいたら解除（重複装備不可）
      await (_db.delete(_db.partyMembers)
            ..where((t) => t.deckId.equals(deck!.id))
            ..where((t) => t.gachaItemId.equals(gachaItemId)))
          .go();

      // 3. 新しい推しを装備
      await _db
          .into(_db.partyMembers)
          .insert(
            PartyMembersCompanion.insert(
              deckId: deck.id,
              gachaItemId: gachaItemId,
              slotPosition: slot,
              createdAt: Value(DateTime.now()),
            ),
          );
    });
  }

  /// 指定したスロットの装備を解除する
  Future<void> unequipSlot(int slot) async {
    final deck = await (_db.select(
      _db.partyDecks,
    )..where((t) => t.isActive.equals(true))).getSingleOrNull();

    if (deck != null) {
      await (_db.delete(_db.partyMembers)
            ..where((t) => t.deckId.equals(deck.id))
            ..where((t) => t.slotPosition.equals(slot)))
          .go();
    }
  }

  /// 現在のパーティメンバー全員を監視する
  /// key: slotPosition, value: GachaItem
  Stream<Map<int, GachaItem>> watchActiveParty() {
    final query = _db.select(_db.partyMembers).join([
      innerJoin(_db.partyDecks, _db.partyDecks.id.equalsExp(_db.partyMembers.deckId)),
      innerJoin(_db.gachaItems, _db.gachaItems.id.equalsExp(_db.partyMembers.gachaItemId)),
    ]);

    query.where(_db.partyDecks.isActive.equals(true));

    return query.watch().map((rows) {
      final Map<int, GachaItem> partyMap = {};
      for (final row in rows) {
        final member = row.readTable(_db.partyMembers);
        final item = row.readTable(_db.gachaItems);
        partyMap[member.slotPosition] = item;
      }
      return partyMap;
    });
  }

  /// メインパートナー監視 (Slot 0)
  Stream<GachaItem?> watchMainPartner() {
    return watchActiveParty().map((map) => map[0]);
  }

  // ========================================================================
  // B. バトルステータス計算 (Battle Logic)
  // ========================================================================

  /// MAINキャラのステータス倍率計算 (努力値)
  /// 式: 1.0 + (基礎ステータス / 1000)
  double _getMainMultiplier(int playerStat) {
    return 1.0 + (playerStat / 1000.0);
  }

  /// SUBキャラの実体化率計算 (CHA依存)
  /// 式: 10% + (基礎CHA * 0.07%) -> 上限80%
  double _getSubRealizationRate(int playerCha) {
    double rate = 0.10 + (playerCha * 0.0007);
    if (rate > 0.80) return 0.80; 
    return rate;
  }

  /// バトル用のパーティ状態（個別キャラデータ）を生成する
  Future<PartyBattleState> createPartyBattleState() async {
    final player = await (_db.select(_db.players)..limit(1)).getSingle();

    final query = _db.select(_db.partyMembers).join([
      innerJoin(_db.partyDecks, _db.partyDecks.id.equalsExp(_db.partyMembers.deckId)),
      innerJoin(_db.gachaItems, _db.gachaItems.id.equalsExp(_db.partyMembers.gachaItemId)),
    ]);
    query.where(_db.partyDecks.isActive.equals(true));
    final rows = await query.get();

    BattleCharacter? mainChar;
    List<BattleCharacter> subChars = [];

    final double subRate = _getSubRealizationRate(player.cha);
    final double strMult = _getMainMultiplier(player.str);
    final double vitMult = _getMainMultiplier(player.vit);
    final double intMult = _getMainMultiplier(player.intellect);
    final double lukMult = _getMainMultiplier(player.luck);

    for (final row in rows) {
      final member = row.readTable(_db.partyMembers);
      final item = row.readTable(_db.gachaItems);
      final isMain = member.slotPosition == 0;

      int maxHp, attack, defense, speed, luck;

      if (isMain) {
        int finalStr = (item.strBonus * strMult).floor();
        int finalVit = (item.vitBonus * vitMult).floor();
        int finalInt = (item.intBonus * intMult).floor();
        int finalLuk = (item.luckBonus * lukMult).floor();

        maxHp = (finalVit * 10) + (finalStr * 3) + (player.level * 50) + 500;
        attack = (finalStr * 2) + (finalInt * 1);
        defense = (finalVit * 2) + (finalInt * 1);
        speed = finalInt + finalLuk;
        luck = finalLuk;
      } else {
        int finalStr = (item.strBonus * subRate).floor();
        int finalVit = (item.vitBonus * subRate).floor();
        int finalInt = (item.intBonus * subRate).floor();
        int finalLuk = (item.luckBonus * subRate).floor();
        
        maxHp = (finalVit * 15) + (finalStr * 2) + 100;
        attack = (finalStr * 2) + (finalInt * 1);
        defense = (finalVit * 2) + (finalInt * 1);
        speed = finalInt + finalLuk;
        luck = finalLuk;
      }

      final char = BattleCharacter(
        id: item.id,
        name: item.title,
        isMain: isMain,
        maxHp: maxHp,
        currentHp: maxHp,
        attack: attack,
        defense: defense,
        speed: speed,
        luck: luck,
        skill: BattleMasterData.getSkill(item.skillType),
        originalItem: item,
      );

      if (isMain) {
        mainChar = char;
      } else {
        subChars.add(char);
      }
    }

    // エラーハンドリング (緊急回避用ダミーデータ)
    if (mainChar == null) {
        mainChar = BattleCharacter(
            id: -1, name: '勇者', isMain: true,
            maxHp: (player.vit * 10) + 500, currentHp: (player.vit * 10) + 500,
            attack: player.str * 2, defense: player.vit * 2, speed: player.intellect, luck: player.luck,
            skill: BattleMasterData.getSkill(SkillType.none),
            originalItem: GachaItem( 
                id: -1, 
                title: 'No Item', 
                rarity: Rarity.n, 
                type: GachaItemType.userImage, 
                tightsColor: TightsColor.none, 
                effectType: EffectType.none, 
                strBonus: 0, intBonus: 0, vitBonus: 0, luckBonus: 0, chaBonus: 0, 
                parameterType: TaskType.strength, 
                skillType: SkillType.none, 
                skillValue: 0, skillDuration: 0, skillCooldown: 0, 
                seriesType: SeriesType.none, 
                seriesId: SeriesType.none, 
                isUnlocked: true, 
                isFavorite: false, 
                isSource: false, 
                intimacyLevel: 0, 
                intimacyExp: 0, 
                isEquipped: true, 
                isLocked: false, 
                createdAt: DateTime.now(), 
            ),
        );
    }

    return PartyBattleState(mainChar: mainChar, subChars: subChars);
  }
  
  /// (UI表示用互換メソッド)
  Future<FinalBattleStats> calculateFinalBattleStats() async {
      final state = await createPartyBattleState();
      
      int totalMaxHp = state.mainChar.maxHp;
      int totalAttack = state.mainChar.attack;
      int totalDefense = state.mainChar.defense;
      int totalLuck = state.mainChar.luck;
      int totalCha = state.mainChar.originalItem.chaBonus; 

      final Set<SkillType> skills = {state.mainChar.skill.id};

      for(var sub in state.subChars) {
          totalMaxHp += sub.maxHp;
          totalAttack += sub.attack;
          totalDefense += sub.defense;
          totalLuck += sub.luck;
          totalCha += sub.originalItem.chaBonus;
          if (sub.skill.id != SkillType.none) skills.add(sub.skill.id);
      }

      return FinalBattleStats(
          maxHp: totalMaxHp,
          attack: totalAttack,
          defense: totalDefense,
          luck: totalLuck,
          charm: totalCha,
          activeSkills: skills.toList(),
      );
  }
}

// 互換性のための定義
class FinalBattleStats {
  final int maxHp;
  final int attack;
  final int defense;
  final int luck;
  final int charm;
  final List<SkillType> activeSkills;

  const FinalBattleStats({
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.luck,
    required this.charm,
    required this.activeSkills,
  });
}