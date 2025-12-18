import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart' as drift;

import '../data/database/database.dart';
import '../data/repositories/boss_repository.dart';
import '../data/repositories/party_repository.dart';
import '../data/providers.dart' as app_providers;
import '../data/master_data/battle_master_data.dart';

part 'boss_battle_controller.g.dart';

// ----------------------------------------------------------------------
// 1. 戦闘状態 (State)
// ----------------------------------------------------------------------

class BattleState {
  final BossType bossType;
  final Boss bossData;
  final PartyBattleState party;
  final int bossCurrentHp;
  final List<String> battleLog;
  final bool isBattleActive;
  final bool isFinished;
  final bool isWin;
  final Map<int, int> skillCooldowns;
  final BattleCharacter? cutInChar; // ★カットイン演出中のキャラ

  const BattleState({
    required this.bossType,
    required this.bossData,
    required this.party,
    required this.bossCurrentHp,
    required this.battleLog,
    required this.isBattleActive,
    required this.isFinished,
    required this.isWin,
    required this.skillCooldowns,
    this.cutInChar,
  });

  factory BattleState.initial(BossType type, Boss boss, PartyBattleState party) {
    return BattleState(
      bossType: type,
      bossData: boss,
      party: party,
      bossCurrentHp: boss.maxHp,
      battleLog: const ['--- バトル開始 ---'],
      isBattleActive: true,
      isFinished: false,
      isWin: false,
      skillCooldowns: {},
      cutInChar: null,
    );
  }

  BattleState copyWith({
    PartyBattleState? party,
    int? bossCurrentHp,
    List<String>? battleLog,
    bool? isBattleActive,
    bool? isFinished,
    bool? isWin,
    Map<int, int>? skillCooldowns,
    BattleCharacter? Function()? cutInChar, // null代入を許容
  }) {
    return BattleState(
      bossType: bossType,
      bossData: bossData,
      party: party ?? this.party,
      bossCurrentHp: bossCurrentHp ?? this.bossCurrentHp,
      battleLog: battleLog ?? this.battleLog,
      isBattleActive: isBattleActive ?? this.isBattleActive,
      isFinished: isFinished ?? this.isFinished,
      isWin: isWin ?? this.isWin,
      skillCooldowns: skillCooldowns ?? this.skillCooldowns,
      cutInChar: cutInChar != null ? cutInChar() : this.cutInChar,
    );
  }
}

// ----------------------------------------------------------------------
// 2. Controller
// ----------------------------------------------------------------------

@riverpod
class BossBattleController extends _$BossBattleController {
  @override
  BattleState? build() => null;

  late final BossRepository _bossRepo = ref.read(app_providers.bossRepositoryProvider);
  late final PartyRepository _partyRepo = ref.read(app_providers.partyRepositoryProvider);
  late final AppDatabase _db = ref.read(app_providers.databaseProvider);
  final Random _random = Random();

  Future<void> startBattle(BossType type) async {
    final results = await Future.wait([
      _bossRepo.getActiveBoss(type),
      _partyRepo.createPartyBattleState(),
    ]);
    state = BattleState.initial(type, results[0] as Boss, results[1] as PartyBattleState);
    
    // オートバトルループ開始
    _runBattleLoop();
  }

  Future<void> _runBattleLoop() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    while (state != null && state!.isBattleActive && !state!.isFinished) {
      await _executePlayerTurn();
      if (state == null || state!.isFinished) break;
      
      await Future.delayed(const Duration(milliseconds: 1200));
      await _executeBossTurn();
      if (state == null || state!.isFinished) break;
      
      await Future.delayed(const Duration(milliseconds: 1200));
    }
  }

  Future<void> _executePlayerTurn() async {
    if (state == null) return;
    _updateLog('▼ プレイヤーターン');

    int currentBossHp = state!.bossCurrentHp;

    for (final char in state!.party.allMembers) {
      if (char.currentHp <= 0 || currentBossHp <= 0) continue;

      double skillChance = 10.0 + (char.originalItem.intBonus * 0.05);
      bool isProc = _random.nextDouble() * 100 < skillChance;
      bool onCooldown = state!.skillCooldowns[char.id] != null && state!.skillCooldowns[char.id]! > 0;

      if (char.skill.id != SkillType.none && isProc && !onCooldown) {
        // ★カットイン演出
        _updateState(state!.copyWith(cutInChar: () => char));
        await Future.delayed(const Duration(milliseconds: 1000));
        
        final res = _executeSkill(char, currentBossHp);
        currentBossHp = res.newBossHp;
        _updateLog(res.log);
        _setCooldown(char.id, 3);
        
        _updateState(state!.copyWith(cutInChar: () => null, bossCurrentHp: currentBossHp));
      } else {
        int damage = max(1, (char.attack * 1.5).round() - state!.bossData.defense);
        currentBossHp = max(0, currentBossHp - damage);
        _updateLog('${char.name}の攻撃: $damage ダメージ');
        _updateState(state!.copyWith(bossCurrentHp: currentBossHp));
      }
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (currentBossHp <= 0) await _finishBattle(isWin: true);
  }

  Future<void> _executeBossTurn() async {
    if (state == null) return;
    _updateLog('▼ ボスの反撃');
    await Future.delayed(const Duration(milliseconds: 600));

    final aliveMembers = state!.party.allMembers.where((c) => c.currentHp > 0).toList();
    if (aliveMembers.isEmpty) return;

    final target = aliveMembers[_random.nextInt(aliveMembers.length)];
    int damage = max(1, (state!.bossData.attack * 1.5).round() - target.defense);
    
    final newHp = max(0, target.currentHp - damage);
    final newParty = _updatePartyMember(state!.party, target.copyWith(currentHp: newHp));
    
    _updateLog('${target.name}は $damage のダメージを受けた！');
    _updateCooldowns();
    _updateState(state!.copyWith(party: newParty));

    if (target.isMain && newHp <= 0) {
      _updateLog('メインパートナーが倒れた...');
      await _finishBattle(isWin: false);
    }
  }

  // --- ヘルパー群 ---
  ({int damage, int newBossHp, String log}) _executeSkill(BattleCharacter char, int currentBossHp) {
    int damage = 0;
    String log = '';
    switch (char.skill.id) {
      case SkillType.strBoost:
        damage = max(1, (char.attack * 3.0).round() - state!.bossData.defense);
        log = '【${char.skill.name}】ボスの急所を突く！ $damage ダメージ！';
        break;
      case SkillType.intBoost:
        damage = (char.attack * 2.0).round();
        log = '【${char.skill.name}】魔力が爆発！防御無視で $damage ダメージ！';
        break;
      default:
        damage = max(1, (char.attack * 1.5).round() - state!.bossData.defense);
        log = '【${char.skill.name}】強力な一撃！ $damage ダメージ！';
    }
    return (damage: damage, newBossHp: max(0, currentBossHp - damage), log: log);
  }

  void _updateLog(String msg) {
    if (state == null) return;
    state = state!.copyWith(battleLog: [...state!.battleLog, msg]);
  }

  void _updateState(BattleState newState) => state = newState;

  void _setCooldown(int id, int turns) {
    final next = Map<int, int>.from(state!.skillCooldowns);
    next[id] = turns;
    state = state!.copyWith(skillCooldowns: next);
  }

  void _updateCooldowns() {
    final next = <int, int>{};
    state!.skillCooldowns.forEach((id, t) { if (t > 1) next[id] = t - 1; });
    state = state!.copyWith(skillCooldowns: next);
  }

  PartyBattleState _updatePartyMember(PartyBattleState party, BattleCharacter newChar) {
    if (newChar.isMain) return PartyBattleState(mainChar: newChar, subChars: party.subChars);
    return PartyBattleState(mainChar: party.mainChar, subChars: party.subChars.map((c) => c.id == newChar.id ? newChar : c).toList());
  }

  Future<void> _finishBattle({required bool isWin}) async {
    _updateLog(isWin ? '--- VICTORY! ---' : '--- DEFEAT ---');
    _updateState(state!.copyWith(isBattleActive: false, isFinished: true, isWin: isWin));
    if (isWin) {
      final player = await (_db.select(_db.players)..limit(1)).getSingle();
      await (_db.update(_db.players)..where((p) => p.id.equals(player.id))).write(
        PlayersCompanion(willGems: drift.Value(player.willGems + state!.bossData.rewardGems)),
      );
    }
  }
}