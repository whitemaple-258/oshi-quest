import 'package:drift/drift.dart';
import '../database/database.dart';

/// タスク（習慣）の管理とRPG報酬計算を行うリポジトリクラス
class HabitRepository {
  final AppDatabase _db;

  HabitRepository(this._db);

  // --- 既存の基本メソッド ---

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

  // --- ✅ ここから: サボり判定ロジック ---

  Future<List<String>> checkDailyReset() async {
    final messages = <String>[];

    await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();
      final now = DateTime.now();
      final lastLogin = player.lastLoginAt;

      final isSameDay =
          now.year == lastLogin.year && now.month == lastLogin.month && now.day == lastLogin.day;

      if (!isSameDay) {
        // 未完了タスクチェック（禊以外）
        final habits = await (_db.select(_db.habits)).get();
        final hasIncomplete = habits.any((h) => !h.isCompleted && h.name != '【禊】女神の許しを請う');

        if (hasIncomplete) {
          // デバフ付与
          await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
            const PlayersCompanion(currentDebuff: Value('sloth')),
          );

          // 禊クエスト発生
          final hasMisogi = habits.any((h) => h.name == '【禊】女神の許しを請う');
          if (!hasMisogi) {
            await addHabit('【禊】女神の許しを請う', TaskType.luck, TaskDifficulty.low);
          }
          messages.add('怠惰の呪いにかかりました...報酬が半減します。');
        }

        // 全タスクリセット（禊以外）
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

  // --- ✅ ここから: 完了処理 (VIT対応 + デバフ対応) ---

  Future<Map<String, int>> completeHabit(Habit habit) async {
    return await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

      // 1. デバフ解除 (禊クエストの場合)
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

      // 2. 装備ボーナス (VIT含む)
      int bonusStr = 0, bonusInt = 0, bonusVit = 0;
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
          bonusVit += item.vitBonus; // VIT対応
        }
      }

      final totalStr = player.str + bonusStr;
      final totalInt = player.intellect + bonusInt;

      // 3. 報酬計算 (デバフ半減)
      final baseGems = habit.rewardGems;
      final baseXp = habit.rewardXp;

      double gemMultiplier = 1.0;
      if (habit.difficulty == TaskDifficulty.high && totalStr > 0) {
        gemMultiplier = 1.0 + (totalStr * 0.01);
      }
      double xpMultiplier = 1.0;
      if (totalInt > 0) {
        xpMultiplier = 1.0 + (totalInt * 0.01);
      }

      if (player.currentDebuff == 'sloth') {
        gemMultiplier *= 0.5; // 半減
      }

      final calculatedGems = (baseGems * gemMultiplier).round();
      final calculatedXp = (baseXp * xpMultiplier).round();

      // 4. ステータス上昇 (VIT対応)
      int newStr = player.str,
          newIntellect = player.intellect,
          newLuck = player.luck,
          newCha = player.cha,
          newVit = player.vit;
      int strUp = 0, intUp = 0, luckUp = 0, chaUp = 0, vitUp = 0;

      switch (habit.taskType) {
        case TaskType.strength:
          newStr++;
          strUp = 1;
          break;
        case TaskType.intelligence:
          newIntellect++;
          intUp = 1;
          break;
        case TaskType.luck:
          newLuck++;
          luckUp = 1;
          break;
        case TaskType.charm:
          newCha++;
          chaUp = 1;
          break;
        case TaskType.vitality:
          newVit++;
          vitUp = 1;
          break; // VIT対応
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
          vit: Value(newVit), // VIT対応
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
        'clearedDebuff': 0,
      };
    });
  }
}
