import 'package:drift/drift.dart';
import '../database/database.dart';

/// タスク（習慣）の管理とRPG報酬計算を行うリポジトリクラス
class HabitRepository {
  final AppDatabase _db;

  HabitRepository(this._db);

  // --- 基本的なCRUD操作 ---

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

  /// タスクの更新（編集）
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

  /// 全タスクをStreamで監視
  Stream<List<Habit>> watchAllHabits() {
    return (_db.select(_db.habits)..orderBy([
          (habit) => OrderingTerm.desc(habit.isCompleted),
          (habit) => OrderingTerm.desc(habit.createdAt),
        ]))
        .watch();
  }

  /// 全タスクを取得
  Future<List<Habit>> getAllHabits() async {
    return await (_db.select(_db.habits)..orderBy([
          (habit) => OrderingTerm.desc(habit.isCompleted),
          (habit) => OrderingTerm.desc(habit.createdAt),
        ]))
        .get();
  }

  /// タスクを削除
  Future<void> deleteHabit(int id) async {
    await (_db.delete(_db.habits)..where((habit) => habit.id.equals(id))).go();
  }

  // --- 🗓️ 日付変更・サボり判定ロジック ---

  /// 日付変更時のリセット処理とサボり判定
  Future<List<String>> checkDailyReset() async {
    final messages = <String>[];

    await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();
      final now = DateTime.now();
      final lastLogin = player.lastLoginAt;

      // 日付が変わっているか判定
      final isSameDay =
          now.year == lastLogin.year && now.month == lastLogin.month && now.day == lastLogin.day;

      if (!isSameDay) {
        // 1. サボり判定: 昨日のタスクで未完了のものがあるか？
        final habits = await (_db.select(_db.habits)).get();
        // 禊クエスト自体は判定対象外
        final hasIncomplete = habits.any((h) => !h.isCompleted && h.name != '【禊】女神の許しを請う');

        if (hasIncomplete) {
          // デバフ付与
          await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
            const PlayersCompanion(currentDebuff: Value('sloth')),
          );

          // 禊クエストの発生
          final hasMisogi = habits.any((h) => h.name == '【禊】女神の許しを請う');
          if (!hasMisogi) {
            await addHabit('【禊】女神の許しを請う', TaskType.luck, TaskDifficulty.low);
          }
          messages.add('怠惰の呪いにかかりました...報酬が半減します。');
        }

        // 2. デイリーリセット: 全タスクを未完了に戻す (禊クエスト以外)
        await (_db.update(_db.habits)..where((h) => h.name.equals('【禊】女神の許しを請う').not())).write(
          const HabitsCompanion(isCompleted: Value(false), completedAt: Value(null)),
        );

        // 3. 最終ログイン日時の更新
        await (_db.update(
          _db.players,
        )..where((p) => p.id.equals(1))).write(PlayersCompanion(lastLoginAt: Value(now)));
      }
    });

    return messages;
  }

  // --- ✅ タスク完了処理 (VIT, Debuff, Series対応) ---

  Future<Map<String, int>> completeHabit(Habit habit) async {
    return await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

      // 1. デバフ解除判定 (禊クエスト完了時)
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

      // 2. 装備ボーナス取得 (VIT対応)
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
          bonusVit += item.vitBonus; // ✅ VIT
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

      // デバフ中は半減
      if (player.currentDebuff == 'sloth') {
        gemMultiplier *= 0.5;
      }

      final calculatedGems = (baseGems * gemMultiplier).round();
      final calculatedXp = (baseXp * xpMultiplier).round();

      // 4. ステータス成長 (VIT対応)
      int newStr = player.str;
      int newIntellect = player.intellect;
      int newLuck = player.luck;
      int newCha = player.cha;
      int newVit = player.vit; // ✅ VIT

      int strUp = 0;
      int intUp = 0;
      int luckUp = 0;
      int chaUp = 0;
      int vitUp = 0; // ✅ VIT

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
        case TaskType.vitality:
          newVit += 1;
          vitUp = 1;
          break; // ✅ VIT
      }

      // 5. レベルアップ判定
      int newExperience = player.experience + calculatedXp;
      // 簡易計算: 100XPごとにレベルアップ
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
          vit: Value(newVit), // ✅ VIT
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
        'vitUp': vitUp, // ✅ VIT
        'levelUp': (newLevel > player.level) ? 1 : 0,
        'clearedDebuff': 0,
      };
    });
  }
}
