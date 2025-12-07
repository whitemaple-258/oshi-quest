import 'package:drift/drift.dart';
import '../database/database.dart';

/// タスク（習慣）の管理とRPG報酬計算を行うリポジトリクラス
class HabitRepository {
  final AppDatabase _db;

  HabitRepository(this._db);

  /// 新規タスクを追加
  /// 
  /// [title] タスク名
  /// [type] タスクタイプ（STR/INT/LUCK/CHA）
  /// [difficulty] 難易度（low/normal/high）
  /// 
  /// 報酬は難易度に応じて自動設定:
  /// - Low: 80 Gems, 8 XP
  /// - Normal: 100 Gems, 10 XP
  /// - High: 150 Gems, 15 XP
  Future<int> addHabit(String title, TaskType type, TaskDifficulty difficulty) async {
    // 難易度に応じた報酬を設定
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

  /// 難易度に応じた基本報酬を取得
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

  /// 全タスクをStreamで監視
  Stream<List<Habit>> watchAllHabits() {
    return (_db.select(_db.habits)
          ..orderBy([
            (habit) => OrderingTerm.desc(habit.isCompleted),
            (habit) => OrderingTerm.desc(habit.createdAt),
          ]))
        .watch();
  }

  /// 全タスクを取得
  Future<List<Habit>> getAllHabits() async {
    return await (_db.select(_db.habits)
          ..orderBy([
            (habit) => OrderingTerm.desc(habit.isCompleted),
            (habit) => OrderingTerm.desc(habit.createdAt),
          ]))
        .get();
  }

  /// タスクを削除
  Future<void> deleteHabit(int id) async {
    await (_db.delete(_db.habits)..where((habit) => habit.id.equals(id))).go();
  }

  /// タスクを完了し、RPG報酬を計算・適用
  /// 
  /// **重要**: トランザクション処理で、PlayerとHabitの更新を原子性保証
  /// 
  /// 報酬計算ロジック:
  /// 1. Base Gems = habit.rewardGems
  /// 2. STRボーナス: 難易度HighかつPlayerのSTRが高い場合、報酬倍率UP
  ///    - 係数: 1.0 + (str * 0.01) （例: STR=50なら1.5倍）
  /// 3. INTボーナス: 獲得XPに係数を乗算
  ///    - 係数: 1.0 + (intellect * 0.01) （例: INT=30なら1.3倍）
  /// 4. 成長: タスクタイプに応じて対応ステータスを+1
  Future<void> completeHabit(Habit habit) async {
    await _db.transaction(() async {
      // 1. 現在のPlayer情報を取得
      final player = await (_db.select(_db.players)
            ..where((p) => p.id.equals(1)))
          .getSingleOrNull();

      if (player == null) {
        throw Exception('プレイヤーデータが見つかりません');
      }

      // 2. 報酬計算（RPGロジック）
      final baseGems = habit.rewardGems;
      final baseXp = habit.rewardXp;

      // STRボーナス: 難易度HighかつSTRが高い場合、報酬倍率UP
      double gemMultiplier = 1.0;
      if (habit.difficulty == TaskDifficulty.high && player.str > 0) {
        // STRが高いほど報酬倍率が上がる（例: STR=50なら1.5倍）
        gemMultiplier = 1.0 + (player.str * 0.01);
      }

      // INTボーナス: INTが高いほど獲得XPが増加
      double xpMultiplier = 1.0;
      if (player.intellect > 0) {
        // INTが高いほどXP倍率が上がる（例: INT=30なら1.3倍）
        xpMultiplier = 1.0 + (player.intellect * 0.01);
      }

      final calculatedGems = (baseGems * gemMultiplier).round();
      final calculatedXp = (baseXp * xpMultiplier).round();

      // 3. ステータス成長: タスクタイプに応じて対応ステータスを+1
      int newStr = player.str;
      int newIntellect = player.intellect;
      int newLuck = player.luck;
      int newCha = player.cha;

      switch (habit.taskType) {
        case TaskType.strength:
          newStr += 1;
          break;
        case TaskType.intelligence:
          newIntellect += 1;
          break;
        case TaskType.luck:
          newLuck += 1;
          break;
        case TaskType.charm:
          newCha += 1;
          break;
      }

      // 4. 経験値とレベルアップ判定
      int newExperience = player.experience + calculatedXp;
      int newLevel = player.level;
      
      // 簡易レベルアップ判定（100 XP = 1 Level）
      final levelUp = newExperience ~/ 100;
      if (levelUp > player.level) {
        newLevel = levelUp;
      }

      // 5. Update処理（トランザクション内）
      // Habitsテーブルを更新
      await (_db.update(_db.habits)..where((h) => h.id.equals(habit.id)))
          .write(HabitsCompanion(
        isCompleted: const Value(true),
        completedAt: Value(DateTime.now()),
      ));

      // Playersテーブルを更新
      await (_db.update(_db.players)..where((p) => p.id.equals(1)))
          .write(PlayersCompanion(
        willGems: Value(player.willGems + calculatedGems),
        experience: Value(newExperience),
        level: Value(newLevel),
        str: Value(newStr),
        intellect: Value(newIntellect),
        luck: Value(newLuck),
        cha: Value(newCha),
        updatedAt: Value(DateTime.now()),
      ));
    });
  }
}

