import 'package:drift/drift.dart';
import '../database/database.dart';

/// タスク（習慣）の管理とRPG報酬計算を行うリポジトリクラス
class HabitRepository {
  final AppDatabase _db;

  HabitRepository(this._db);

  /// 新規タスクを追加
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

  // 👇 追加: タスク更新メソッド
  Future<void> updateHabit(
    Habit habit,
    String title,
    TaskType type,
    TaskDifficulty difficulty,
  ) async {
    // 難易度が変わる可能性があるため、報酬も再計算
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

  /// タスクを完了し、RPG報酬を計算・適用
  Future<Map<String, int>> completeHabit(Habit habit) async {
    return await _db.transaction(() async {
      // 1. プレイヤー情報取得
      final player = await (_db.select(
        _db.players,
      )..where((p) => p.id.equals(1))).getSingleOrNull();

      if (player == null) {
        throw Exception('プレイヤーデータが見つかりません');
      }

      // 2. 装備ボーナスの取得・計算
      int bonusStr = 0;
      int bonusInt = 0;

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
        }
      }

      final totalStr = player.str + bonusStr;
      final totalInt = player.intellect + bonusInt;

      // 3. 報酬計算
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

      final calculatedGems = (baseGems * gemMultiplier).round();
      final calculatedXp = (baseXp * xpMultiplier).round();

      // 4. ステータス成長
      int newStr = player.str;
      int newIntellect = player.intellect;
      int newLuck = player.luck;
      int newCha = player.cha;

      int strUp = 0;
      int intUp = 0;
      int luckUp = 0;
      int chaUp = 0;

      switch (habit.taskType) {
        case TaskType.strength:
          newStr += 1;
          strUp = 1;
          break;
        case TaskType.intelligence:
          newIntellect += 1;
          intUp = 1;
          break;
        case TaskType.luck:
          newLuck += 1;
          luckUp = 1;
          break;
        case TaskType.charm:
          newCha += 1;
          chaUp = 1;
          break;
      }

      // 5. レベルアップ判定
      int newExperience = player.experience + calculatedXp;
      final calculatedLevel = (newExperience ~/ 100) + 1;

      int newLevel = player.level;
      if (calculatedLevel > player.level) {
        newLevel = calculatedLevel;
      }

      // 6. DB更新
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
        'levelUp': (newLevel > player.level) ? 1 : 0,
      };
    });
  }
}
