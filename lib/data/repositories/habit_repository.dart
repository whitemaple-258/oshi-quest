import 'dart:math';
import 'package:drift/drift.dart';
import '../database/database.dart';

/// タスク（習慣）の管理とRPG報酬計算を行うリポジトリクラス
class HabitRepository {
  final AppDatabase _db;

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

  // --- 🗓️ 日付変更・サボり判定ロジック (VIT効果) ---

  Future<List<String>> checkDailyReset() async {
    final messages = <String>[];

    await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();
      final now = DateTime.now();
      final lastLogin = player.lastLoginAt;

      final isSameDay =
          now.year == lastLogin.year && now.month == lastLogin.month && now.day == lastLogin.day;

      if (!isSameDay) {
        // 未完了タスクチェック
        final habits = await (_db.select(_db.habits)).get();
        final hasIncomplete = habits.any((h) => !h.isCompleted && h.name != '【禊】女神の許しを請う');

        if (hasIncomplete) {
          // ✅ VIT効果: ペナルティ回避判定
          // VIT 10につき1%回避 (MAX 1000で100%)
          final avoidChance = min(player.vit, 1000) / 10.0; // 0.0 ~ 100.0
          final roll = Random().nextDouble() * 100;

          if (roll < avoidChance) {
            messages.add('高いVITのおかげで、怠惰の呪いを回避しました！');
          } else {
            // 回避失敗 -> デバフ付与
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

  // --- ✅ タスク完了処理 (全パラメータ効果反映) ---

  Future<Map<String, int>> completeHabit(Habit habit) async {
    return await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

      // 1. デバフ解除判定
      if (player.currentDebuff == 'sloth' && habit.name == '【禊】女神の許しを請う') {
        await (_db.update(
          _db.players,
        )..where((p) => p.id.equals(1))).write(const PlayersCompanion(currentDebuff: Value(null)));
        await deleteHabit(habit.id);
        return {
          'gems': 0,
          'xp': 0,
          'strUp': 0,
          'intUp': 0,
          'luckUp': 0,
          'chaUp': 0,
          'vitUp': 0,
          'levelUp': 0,
          'clearedDebuff': 1,
        };
      }

      // 2. 装備ボーナス取得
      int bonusStr = 0, bonusInt = 0, bonusVit = 0, bonusLuck = 0, bonusCha = 0;
      int equippedItemId = -1; // 親密度UP用

      final activeDeck = await (_db.select(
        _db.partyDecks,
      )..where((t) => t.isActive.equals(true))).getSingleOrNull();
      if (activeDeck != null) {
        final query = _db.select(_db.partyMembers).join([
          innerJoin(_db.gachaItems, _db.gachaItems.id.equalsExp(_db.partyMembers.gachaItemId)),
        ]);
        query.where(_db.partyMembers.deckId.equals(activeDeck.id));
        final results = await query.get();

        for (final row in results) {
          final item = row.readTable(_db.gachaItems);
          bonusStr += item.strBonus;
          bonusInt += item.intBonus;
          bonusVit += item.vitBonus;
          bonusLuck += item.luckBonus;
          bonusCha += item.chaBonus;

          // メインパートナー(Slot0)のIDを保持
          final member = row.readTable(_db.partyMembers);
          if (member.slotPosition == 0) equippedItemId = item.id;
        }
      }

      // 合計ステータス (上限1000キャップはここではかけず、計算に使用)
      final totalStr = min(player.str + bonusStr, 1000);
      final totalInt = min(player.intellect + bonusInt, 1000);
      final totalLuck = min(player.luck + bonusLuck, 1000);
      final totalCha = min(player.cha + bonusCha, 1000);
      // VITはサボり判定で使うのでここでは計算のみ

      // 3. 報酬計算
      final baseGems = habit.rewardGems;
      final baseXp = habit.rewardXp;

      // ✅ STR効果: 報酬量UP
      double gemMultiplier = 1.0;
      if (habit.difficulty == TaskDifficulty.high && totalStr > 0) {
        gemMultiplier = 1.0 + (totalStr * 0.002); // 係数調整: MAX 1000で+200% (3倍)
      }

      // ✅ INT効果: XP量UP (スキル効率UPの代用)
      double xpMultiplier = 1.0;
      if (totalInt > 0) {
        xpMultiplier = 1.0 + (totalInt * 0.002); // MAX 1000で+200% (3倍)
      }

      // ✅ LUCK効果: クリティカル (大成功)
      // LUCK 1000で 50% の確率で報酬1.5倍
      bool isCritical = false;
      if (Random().nextDouble() < (totalLuck / 2000.0)) {
        isCritical = true;
        gemMultiplier *= 1.5;
        xpMultiplier *= 1.5;
      }

      // デバフ中は半減
      if (player.currentDebuff == 'sloth') {
        gemMultiplier *= 0.5;
      }

      final calculatedGems = (baseGems * gemMultiplier).round();
      final calculatedXp = (baseXp * xpMultiplier).round();

      // ✅ CHA効果: 親密度UP
      // パートナーがいる場合、CHAに応じて親密度を追加上昇
      if (equippedItemId != -1) {
        // 基本1 + (CHA / 100)
        final bondIncrease = 1 + (totalCha ~/ 100);
        await (_db.update(_db.gachaItems)..where((t) => t.id.equals(equippedItemId))).write(
          GachaItemsCompanion(
            bondLevel: Value(
              bondIncrease +
                  (await (_db.select(
                    _db.gachaItems,
                  )..where((t) => t.id.equals(equippedItemId))).getSingle()).bondLevel,
            ),
          ),
        );
      }

      // 4. ステータス成長 (上限1000キャップ適用)
      int newStr = player.str,
          newIntellect = player.intellect,
          newLuck = player.luck,
          newCha = player.cha,
          newVit = player.vit;
      int strUp = 0, intUp = 0, luckUp = 0, chaUp = 0, vitUp = 0;

      switch (habit.taskType) {
        case TaskType.strength:
          if (newStr < 1000) {
            newStr++;
            strUp = 1;
          }
          break;
        case TaskType.intelligence:
          if (newIntellect < 1000) {
            newIntellect++;
            intUp = 1;
          }
          break;
        case TaskType.luck:
          if (newLuck < 1000) {
            newLuck++;
            luckUp = 1;
          }
          break;
        case TaskType.charm:
          if (newCha < 1000) {
            newCha++;
            chaUp = 1;
          }
          break;
        case TaskType.vitality:
          if (newVit < 1000) {
            newVit++;
            vitUp = 1;
          }
          break;
      }

      // 5. レベルアップ
      int newExperience = player.experience + calculatedXp;
      final calculatedLevel = (newExperience ~/ 100) + 1;
      int newLevel = player.level;
      if (calculatedLevel > player.level) {
        newLevel = calculatedLevel;
      }

      // DB更新
      await (_db.update(_db.habits)..where((h) => h.id.equals(habit.id))).write(
        HabitsCompanion(isCompleted: const Value(true), completedAt: Value(DateTime.now())),
      );

      await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
        PlayersCompanion(
          willGems: Value(player.willGems + calculatedGems),
          experience: Value(newExperience),
          level: Value(newLevel),
          str: Value(newStr),
          intellect: Value(newIntellect),
          luck: Value(newLuck),
          cha: Value(newCha),
          vit: Value(newVit),
          updatedAt: Value(DateTime.now()),
        ),
      );

      return {
        'gems': calculatedGems,
        'xp': calculatedXp,
        'strUp': strUp,
        'intUp': intUp,
        'luckUp': luckUp,
        'chaUp': chaUp,
        'vitUp': vitUp,
        'levelUp': (newLevel > player.level) ? 1 : 0,
        'isCritical': isCritical ? 1 : 0, // UI表示用
        'clearedDebuff': 0,
      };
    });
  }
}
