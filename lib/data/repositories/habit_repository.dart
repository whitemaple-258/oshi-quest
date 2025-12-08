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
  ///
  /// 変更点: 装備中の推しのステータスボーナスを加算して計算します。
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
      // int bonusLuck = 0; // 今回の計算式では未使用だが取得可能
      // int bonusCha = 0;

      // アクティブなデッキを取得
      final activeDeck = await (_db.select(
        _db.partyDecks,
      )..where((t) => t.isActive.equals(true))).getSingleOrNull();

      if (activeDeck != null) {
        // デッキに紐づくアイテム情報を結合して取得
        final query = _db.select(_db.partyMembers).join([
          innerJoin(_db.gachaItems, _db.gachaItems.id.equalsExp(_db.partyMembers.gachaItemId)),
        ]);
        query.where(_db.partyMembers.deckId.equals(activeDeck.id));

        final results = await query.get();

        // 全装備のボーナスを合算
        for (final row in results) {
          final item = row.readTable(_db.gachaItems);
          bonusStr += item.strBonus;
          bonusInt += item.intBonus;
          // bonusLuck += item.luckBonus;
          // bonusCha += item.chaBonus;
        }
      }

      // 合計ステータス（プレイヤー基礎値 + 装備補正）
      final totalStr = player.str + bonusStr;
      final totalInt = player.intellect + bonusInt;

      // 3. 報酬計算（合計ステータスを使用）
      final baseGems = habit.rewardGems;
      final baseXp = habit.rewardXp;

      // STRボーナス: 難易度Highなら、合計STRに応じて報酬倍率UP
      double gemMultiplier = 1.0;
      if (habit.difficulty == TaskDifficulty.high && totalStr > 0) {
        gemMultiplier = 1.0 + (totalStr * 0.01);
      }

      // INTボーナス: 合計INTに応じて獲得XP倍率UP
      double xpMultiplier = 1.0;
      if (totalInt > 0) {
        xpMultiplier = 1.0 + (totalInt * 0.01);
      }

      final calculatedGems = (baseGems * gemMultiplier).round();
      final calculatedXp = (baseXp * xpMultiplier).round();

      // 4. ステータス成長（プレイヤー自身の基礎値を上げる）
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
      int newLevel = player.level;

      final levelUp = newExperience ~/ 100;
      if (levelUp > player.level) {
        newLevel = levelUp;
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

      // 結果を返す
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
