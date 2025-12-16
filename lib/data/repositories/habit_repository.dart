import 'dart:math';
import 'package:drift/drift.dart';
import '../database/database.dart';

/// タスク（習慣）の管理とRPG報酬計算を行うリポジトリクラス
/// Spec Version: 2.0.0 (Parameter & Intimacy Logic)
class HabitRepository {
  final AppDatabase _db;

  // レベルアップ時のステータス合計上昇量
  static const int kStatPointsPerLevel = 10;
  // ステータスの最大値キャップ
  static const int kMaxStat = 1000;

  HabitRepository(this._db);

  // --- 基本的なCRUD操作 ---

  Future<int> addHabit(String title, TaskType type, TaskDifficulty difficulty) async {
    final (gems, xp) = _getBaseRewards(difficulty);
    final companion = HabitsCompanion.insert(
      name: title,
      taskType: type,
      difficulty: Value(difficulty),
      rewardGems: Value(gems),
      rewardXp: Value(xp),
      isCompleted: const Value(false),
    );
    return await _db.into(_db.habits).insert(companion);
  }

  Future<void> updateHabit(
    Habit habit,
    String title,
    TaskType type,
    TaskDifficulty difficulty,
  ) async {
    final (gems, xp) = _getBaseRewards(difficulty);
    await (_db.update(_db.habits)..where((h) => h.id.equals(habit.id))).write(
      HabitsCompanion(
        name: Value(title),
        taskType: Value(type),
        difficulty: Value(difficulty),
        rewardGems: Value(gems),
        rewardXp: Value(xp),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  (int gems, int xp) _getBaseRewards(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.low:
        return (80, 8);
      case TaskDifficulty.normal:
        return (100, 10);
      case TaskDifficulty.high:
        return (150, 15);
    }
  }

  Stream<List<Habit>> watchAllHabits() {
    return (_db.select(_db.habits)..orderBy([
          (habit) => OrderingTerm.desc(habit.isCompleted),
          (habit) => OrderingTerm.desc(habit.createdAt),
        ]))
        .watch();
  }

  Future<List<Habit>> getAllHabits() async {
    return await (_db.select(_db.habits)..orderBy([
          (habit) => OrderingTerm.desc(habit.isCompleted),
          (habit) => OrderingTerm.desc(habit.createdAt),
        ]))
        .get();
  }

  Future<void> deleteHabit(int id) async {
    await (_db.delete(_db.habits)..where((habit) => habit.id.equals(id))).go();
  }

  // --- 🗓️ 日付変更・サボり判定ロジック (VIT v2.0仕様) ---

  Future<List<String>> checkDailyReset() async {
    final messages = <String>[];

    await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();
      final now = DateTime.now();
      final lastLogin = player.lastLoginAt;

      // 日付が変わっているかチェック
      final isSameDay =
          now.year == lastLogin.year && now.month == lastLogin.month && now.day == lastLogin.day;

      if (!isSameDay) {
        // 未完了タスクチェック
        final habits = await (_db.select(_db.habits)).get();
        final hasIncomplete = habits.any((h) => !h.isCompleted && h.name != '【禊】女神の許しを請う');

        if (hasIncomplete) {
          // ✅ VIT効果 v2.0: 猶予時間 (Grace Period)
          // VITに応じて、最後にログインしてから「ペナルティが発生するまでの時間」を延長する
          int graceHours = 0;
          if (player.vit >= 100) {
            graceHours = 48; // VIT 100以上: 48時間猶予
          } else if (player.vit >= 50) {
            graceHours = 24; // VIT 50以上: 24時間猶予
          }

          // 最終ログインからの経過時間
          final difference = now.difference(lastLogin);
          final passedHours = difference.inHours;

          if (passedHours <= graceHours + 24) {
            // ※「+24」は「本来のリセットタイミング(翌日)」に猶予時間を足したロジック
            // シンプルに「日付変更線を超えたが、猶予期間内である」とみなす
            messages.add('高いVITのおかげで、疲れを知りません！（連続記録保護中）');
          } else {
            // 猶予期間オーバー -> デバフ付与
            await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
              const PlayersCompanion(currentDebuff: Value('sloth')),
            );

            final hasMisogi = habits.any((h) => h.name == '【禊】女神の許しを請う');
            if (!hasMisogi) {
              await addHabit('【禊】女神の許しを請う', TaskType.luck, TaskDifficulty.low);
            }
            messages.add('怠惰の呪いにかかりました...報酬が半減します。');
          }
        }

        // タスクリセット
        await (_db.update(_db.habits)..where((h) => h.name.equals('【禊】女神の許しを請う').not())).write(
          const HabitsCompanion(isCompleted: Value(false), completedAt: Value(null)),
        );

        // 最終ログイン更新
        await (_db.update(
          _db.players,
        )..where((p) => p.id.equals(1))).write(PlayersCompanion(lastLoginAt: Value(now)));
      }
    });
    return messages;
  }

  // --- ✅ タスク完了処理 (動的成長システム実装版) ---

  Future<Map<String, int>> completeHabit(Habit habit) async {
    return await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

      // 1. デバフ解除判定 (変更なし)
      if (player.currentDebuff == 'sloth' && habit.name == '【禊】女神の許しを請う') {
        await (_db.update(_db.players)..where((p) => p.id.equals(1)))
            .write(const PlayersCompanion(currentDebuff: Value(null)));
        await deleteHabit(habit.id);
        return { 'gems': 0, 'xp': 0, 'levelUp': 0, 'clearedDebuff': 1 };
      }

      // 2. 装備ボーナス & パートナー特定 (変更なし)
      int bonusStr = 0, bonusInt = 0, bonusVit = 0, bonusLuck = 0, bonusCha = 0;
      int mainPartnerId = -1;

      final activeDeck = await (_db.select(_db.partyDecks)..where((t) => t.isActive.equals(true))).getSingleOrNull();
      if (activeDeck != null) {
        final query = _db.select(_db.partyMembers).join([
          innerJoin(_db.gachaItems, _db.gachaItems.id.equalsExp(_db.partyMembers.gachaItemId)),
        ]);
        query.where(_db.partyMembers.deckId.equals(activeDeck.id));
        final results = await query.get();

        for (final row in results) {
          final item = row.readTable(_db.gachaItems);
          final member = row.readTable(_db.partyMembers);
          bonusStr += item.strBonus;
          bonusInt += item.intBonus;
          bonusVit += item.vitBonus;
          bonusLuck += item.luckBonus;
          bonusCha += item.chaBonus;
          if (member.slotPosition == 0) mainPartnerId = item.id;
        }
      }

      // 合計ステータス計算 (報酬計算用)
      final totalStr = min(player.str + bonusStr, kMaxStat);
      final totalInt = min(player.intellect + bonusInt, kMaxStat);
      final totalLuck = min(player.luck + bonusLuck, kMaxStat);
      final totalCha = min(player.cha + bonusCha, kMaxStat);

      // 3. 報酬計算 (v2.0 Logic)
      final baseGems = habit.rewardGems;
      final baseXp = habit.rewardXp;

      double gemMultiplier = 1.0 + (totalStr * 0.002);
      double xpMultiplier = 1.0 + (totalInt * 0.002);

      // クリティカル判定
      bool isGreatSuccess = false;
      if (Random().nextDouble() * 100 < (1.0 + totalLuck * 0.05)) {
        isGreatSuccess = true;
        gemMultiplier *= (3 + Random().nextInt(3)); 
        xpMultiplier *= (3 + Random().nextInt(3));
      }

      if (player.currentDebuff == 'sloth') {
        gemMultiplier *= 0.5;
        xpMultiplier *= 0.5;
      }

      final calculatedGems = (baseGems * gemMultiplier).round();
      final calculatedXp = (baseXp * xpMultiplier).round();

      // 親密度加算 (変更なし)
      if (mainPartnerId != -1) {
        final double intimacyMultiplier = 1.0 + (totalCha * 0.01);
        final int intimacyGain = (10 * intimacyMultiplier).floor();
        final currentItem = await (_db.select(_db.gachaItems)..where((t) => t.id.equals(mainPartnerId))).getSingle();
        await (_db.update(_db.gachaItems)..where((t) => t.id.equals(mainPartnerId))).write(
          GachaItemsCompanion(bondLevel: Value(currentItem.bondLevel + intimacyGain)),
        );
      }

      // ======================================================================
      // 4. 動的成長システム (Growth Logic)
      // ======================================================================
      
      // A. 今回獲得した経験値を、タスク属性に応じて蓄積
      int currentTempStr = player.tempStrExp;
      int currentTempInt = player.tempIntExp;
      int currentTempLuk = player.tempLukExp;
      int currentTempCha = player.tempChaExp;
      int currentTempVit = player.tempVitExp;

      // タスクタイプに応じて加算
      switch (habit.taskType) {
        case TaskType.strength: currentTempStr += calculatedXp; break;
        case TaskType.intelligence: currentTempInt += calculatedXp; break;
        case TaskType.luck: currentTempLuk += calculatedXp; break;
        case TaskType.charm: currentTempCha += calculatedXp; break;
        case TaskType.vitality: currentTempVit += calculatedXp; break;
      }

      // B. レベルアップ判定
      int newExperience = player.experience + calculatedXp;
      // 必要経験値計算 (簡易式: Lv * 100)
      int nextLevelThreshold = player.level * 100; 
      
      int newLevel = player.level;
      
      // 上昇値の初期化
      int addStr = 0, addInt = 0, addLuk = 0, addCha = 0, addVit = 0;
      bool isLevelUp = false;

      // レベルアップ処理
      if (newExperience >= nextLevelThreshold) {
        isLevelUp = true;
        newLevel += 1;
        newExperience -= nextLevelThreshold; // 経験値を持ち越し (リセット型の場合は0にする)

        // --- ステータス分配計算 ---
        final totalTempExp = currentTempStr + currentTempInt + currentTempLuk + currentTempCha + currentTempVit;
        
        if (totalTempExp > 0) {
          // 比率計算
          double ratioStr = currentTempStr / totalTempExp;
          double ratioInt = currentTempInt / totalTempExp;
          double ratioLuk = currentTempLuk / totalTempExp;
          double ratioCha = currentTempCha / totalTempExp;
          double ratioVit = currentTempVit / totalTempExp;

          // 固定値(10pt)を分配 (端数切り捨て)
          addStr = (kStatPointsPerLevel * ratioStr).floor();
          addInt = (kStatPointsPerLevel * ratioInt).floor();
          addLuk = (kStatPointsPerLevel * ratioLuk).floor();
          addCha = (kStatPointsPerLevel * ratioCha).floor();
          addVit = (kStatPointsPerLevel * ratioVit).floor();

          // 端数調整 (合計が10になるように、一番稼いだステータスに残りを足す)
          final sumAssigned = addStr + addInt + addLuk + addCha + addVit;
          final remainder = kStatPointsPerLevel - sumAssigned;

          if (remainder > 0) {
            // 最大のTempExpを持つステータスを探す
            final statsMap = {
              'str': currentTempStr,
              'int': currentTempInt,
              'luk': currentTempLuk,
              'cha': currentTempCha,
              'vit': currentTempVit,
            };
            // 値でソートして最大のキーを取得
            final maxStatKey = statsMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;

            switch (maxStatKey) {
              case 'str': addStr += remainder; break;
              case 'int': addInt += remainder; break;
              case 'luk': addLuk += remainder; break;
              case 'cha': addCha += remainder; break;
              case 'vit': addVit += remainder; break;
            }
          }
        } else {
          // 例外: TempExpが0の場合 (ありえないが念のため)、ランダムかSTRに振る
          addStr = kStatPointsPerLevel; 
        }

        // 蓄積値をリセット
        currentTempStr = 0;
        currentTempInt = 0;
        currentTempLuk = 0;
        currentTempCha = 0;
        currentTempVit = 0;
      }

      // C. 最終的なステータス値 (上限1000キャップ適用)
      final newStrStat = min(player.str + addStr, kMaxStat);
      final newIntStat = min(player.intellect + addInt, kMaxStat);
      final newLukStat = min(player.luck + addLuk, kMaxStat);
      final newChaStat = min(player.cha + addCha, kMaxStat);
      final newVitStat = min(player.vit + addVit, kMaxStat);

      // DB更新処理
      await (_db.update(_db.habits)..where((h) => h.id.equals(habit.id)))
          .write(HabitsCompanion(isCompleted: const Value(true), completedAt: Value(DateTime.now())));

      await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
        PlayersCompanion(
          willGems: Value(player.willGems + calculatedGems),
          experience: Value(newExperience),
          level: Value(newLevel),
          // ステータス更新
          str: Value(newStrStat),
          intellect: Value(newIntStat),
          luck: Value(newLukStat),
          cha: Value(newChaStat),
          vit: Value(newVitStat),
          // 蓄積Exp更新 (リセット or 加算後)
          tempStrExp: Value(currentTempStr),
          tempIntExp: Value(currentTempInt),
          tempLukExp: Value(currentTempLuk),
          tempChaExp: Value(currentTempCha),
          tempVitExp: Value(currentTempVit),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // 結果返却
      return {
        'gems': calculatedGems,
        'xp': calculatedXp,
        'strUp': addStr,
        'intUp': addInt,
        'luckUp': addLuk,
        'chaUp': addCha,
        'vitUp': addVit,
        'levelUp': isLevelUp ? 1 : 0,
        'isCritical': isGreatSuccess ? 1 : 0,
      };
    });
  }
}
