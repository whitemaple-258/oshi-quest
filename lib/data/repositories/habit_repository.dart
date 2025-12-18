import 'dart:math';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../utils/game_logic/exp_calculator.dart';
import '../../utils/game_logic/intimacy_calculator.dart';
import '../../utils/game_logic/stats_calculator.dart';

/// タスク（習慣）の管理とRPG報酬計算を行うリポジトリクラス
/// Spec Version: 2.0.0 (Parameter & Intimacy Logic)
class HabitRepository {
  final AppDatabase _db;

  // レベルアップ時のステータス合計上昇量
  static const int kStatPointsPerLevel = 10;
  // 基礎ステータス上限 (素の能力値)
  static const int kBaseStatCap = 999;
  // 合計ステータス上限 (カード補正込み)
  static const int kTotalStatCap = 9999;

  HabitRepository(this._db);

  // --- 基本的なCRUD操作 ---

  // --- タスク追加 ---
  Future<void> addHabit(String title, TaskType type, TaskDifficulty difficulty) async {
    // 難易度に応じた報酬設定 (レベルデザイン適用)
    int rewardGems;
    int rewardXp;

    switch (difficulty) {
      case TaskDifficulty.low:
        rewardXp = 10;
        rewardGems = 5;
        break;
      case TaskDifficulty.normal:
        rewardXp = 50;
        rewardGems = 25;
        break;
      case TaskDifficulty.high:
        rewardXp = 200;
        rewardGems = 100;
        break;
    }

    await _db
        .into(_db.habits)
        .insert(
          HabitsCompanion.insert(
            name: title,
            taskType: type,
            difficulty: Value(difficulty),
            rewardGems: Value(rewardGems),
            rewardXp: Value(rewardXp),
          ),
        );
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

  // ヘルパー: 難易度に応じた即時ステータス上昇値
  int _getImmediateStatGain(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.low:
        return 1;
      case TaskDifficulty.normal:
        return 3;
      case TaskDifficulty.high:
        return 5;
    }
  }

  // ヘルパー: レベル帯に応じた付与ステータスポイント
  int _getStatPointsForLevel(int level) {
    if (level >= 50) return 30; // 後半は一気に成長
    if (level >= 20) return 20; // 中盤
    return 10; // 序盤
  }

  (int gems, int xp) _getBaseRewards(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.low:
        return (5, 10);   // 修正: 80, 8 -> 5, 10
      case TaskDifficulty.normal:
        return (25, 50);  // 修正: 100, 10 -> 25, 50
      case TaskDifficulty.high:
        return (100, 200); // 修正: 150, 15 -> 100, 200
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

  // --- 🗓️ 日付変更処理 (VIT猶予判定 & 親密度ボーナス) ---
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
        // // ====================================================================
        // 1. VIT効果: 継続保護 (Persistence)
        // ====================================================================

        // 未完了タスクチェック
        final habits = await (_db.select(_db.habits)).get();
        final hasIncomplete = habits.any((h) => !h.isCompleted && h.name != '【禊】女神の許しを請う');

        if (hasIncomplete) {
          // ✅ 修正: 固定の猶予時間ではなく「確率による保護」に変更
          // 保護確率: VIT * 0.1% (例: VIT 500 -> 50%, VIT 999 -> 99.9%)
          double protectChance = player.vit * 0.001;
          if (protectChance > 0.95) protectChance = 0.95; // 最大95%

          final isProtected = Random().nextDouble() < protectChance;

          if (isProtected) {
            // 保護成功
            messages.add('高いVITのおかげで、疲れを知りません！（連続記録保護中）');
          } else {
            // 保護失敗 -> デバフ付与
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

        // ====================================================================
        // 2. 親密度システム: デイリーボーナス (推しの差し入れ)
        // ====================================================================

        // アクティブデッキからメインパートナー(Slot 0)を取得
        final activeDeck = await (_db.select(
          _db.partyDecks,
        )..where((t) => t.isActive.equals(true))).getSingleOrNull();
        GachaItem? mainPartner;

        if (activeDeck != null) {
          final query = _db.select(_db.partyMembers).join([
            innerJoin(_db.gachaItems, _db.gachaItems.id.equalsExp(_db.partyMembers.gachaItemId)),
          ]);
          query.where(_db.partyMembers.deckId.equals(activeDeck.id));
          final results = await query.get();

          for (final row in results) {
            if (row.readTable(_db.partyMembers).slotPosition == 0) {
              mainPartner = row.readTable(_db.gachaItems);
              break;
            }
          }
        }

        // 抽選処理
        if (mainPartner != null) {
          // 発生率 = Lv * 0.5%
          final double chance = IntimacyCalculator.getDailyBonusChance(mainPartner.intimacyLevel);
          final double roll = Random().nextDouble() * 100;

          if (roll < chance) {
            // 当選！報酬を決定
            int bonusGems = 50;
            // 親密度が高いと報酬アップ
            if (mainPartner.intimacyLevel >= 100) {
              bonusGems = 300; // カンスト特大ボーナス
            } else if (mainPartner.intimacyLevel >= 50) {
              bonusGems = 100; // 高親密度ボーナス
            }

            // プレイヤーのジェムを更新
            // ※ transaction内なので、player変数は古い値を持っている可能性があります。
            //   念のためSQLで直接加算するか、最新の値を取得しなおすのが安全ですが、
            //   ここでは直前のVIT処理でジェムは変動していないため player.willGems を使用します。

            // ただし、この関数の呼び出し元で再取得されることを想定して更新
            await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
              PlayersCompanion(willGems: Value(player.willGems + bonusGems)),
            );

            messages.add("【親密度ボーナス】${mainPartner.title}がアイテムを拾ってきました！(ジェム +$bonusGems)");
          }
        }

        // ====================================================================
        // 3. クリーンアップ処理
        // ====================================================================

        // タスクリセット (禊以外を未完了に戻す)
        await (_db.update(_db.habits)..where((h) => h.name.equals('【禊】女神の許しを請う').not())).write(
          const HabitsCompanion(isCompleted: Value(false), completedAt: Value(null)),
        );

        // 最終ログイン日時を更新
        await (_db.update(
          _db.players,
        )..where((p) => p.id.equals(1))).write(PlayersCompanion(lastLoginAt: Value(now)));
      }
    });

    return messages;
  }

  // --- タスク完了処理 (倍率ロジック適用版) ---
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
          'isCritical': 0,
          'clearedDebuff': 1,
          'intimacyGained': 0,
          'intimacyLevelUp': 0,
        };
      }

      // 2. パートナー特定 & 親密度用処理
      // ※ 今回の報酬計算にはカードステータスを使わないため、合計値計算は不要
      // ※ 親密度計算のためにメインパートナーIDのみ取得する
      int mainPartnerId = -1;
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
          final member = row.readTable(_db.partyMembers);
          if (member.slotPosition == 0) mainPartnerId = item.id;
        }
      }

      // 3. 報酬計算 (パラメータ仕様の適用)
      // =============================================================
      final baseGems = habit.rewardGems;
      final baseXp = habit.rewardXp;

      // ✅ 修正: 外部クラスを使わず、定義した計算式を直接適用
      
      // STR: 稼ぎ効率 (Base * (1 + STR/200))
      double gemMultiplier = 1.0 + (player.str / 200.0);
      
      // INT: 成長効率 (Base * (1 + INT/200))
      double xpMultiplier = 1.0 + (player.intellect / 200.0);
      
      // LUK: 大成功率 (1% + LUK * 0.01%)
      // 例: LUK 1000 -> 11%
      double greatSuccessRate = 0.01 + (player.luck * 0.0001);
      
      bool isGreatSuccess = false;
      if (Random().nextDouble() < greatSuccessRate) {
          isGreatSuccess = true;
          // 大成功時は報酬 1.5倍
          double criticalBonus = 1.5; 
          gemMultiplier *= criticalBonus;
          xpMultiplier *= criticalBonus;
      }

      if (player.currentDebuff == 'sloth') {
        gemMultiplier *= 0.5;
        xpMultiplier *= 0.5;
      }

      final calculatedGems = (baseGems * gemMultiplier).round();
      final calculatedXp = (baseXp * xpMultiplier).round();

      // 4. 親密度システム (変更なし)
      // 基礎CHAではなく、計算後の合計CHAを使う設計にするか、基礎のみにするかは要検討だが
      // ここでは仕様統一のため「基礎CHA」ベースで一旦計算（必要ならStatsCalculator経由に変更可）
      int intimacyGained = 0;
      int intimacyLevelUp = 0;
      if (mainPartnerId != -1) {
        final partnerItem = await (_db.select(
          _db.gachaItems,
        )..where((t) => t.id.equals(mainPartnerId))).getSingle();
        // 親密度上昇は基礎CHA依存とする
        intimacyGained = IntimacyCalculator.calculateGain(player.cha);

        int newIntimacyExp = partnerItem.intimacyExp + intimacyGained;
        int newIntimacyLevel = partnerItem.intimacyLevel;

        while (newIntimacyLevel < IntimacyCalculator.kMaxLevel) {
          final reqExp = IntimacyCalculator.requiredExpForNextLevel(newIntimacyLevel);
          if (newIntimacyExp >= reqExp) {
            newIntimacyExp -= reqExp;
            newIntimacyLevel++;
            intimacyLevelUp++;
          } else {
            break;
          }
        }
        await (_db.update(_db.gachaItems)..where((t) => t.id.equals(mainPartnerId))).write(
          GachaItemsCompanion(
            intimacyLevel: Value(newIntimacyLevel),
            intimacyExp: Value(newIntimacyExp),
          ),
        );
      }

      // 5. 成長システム (努力値分配方式)
      // =============================================================
      int newStr = player.str;
      int newInt = player.intellect;
      int newLuk = player.luck;
      int newCha = player.cha;
      int newVit = player.vit;

      int gainedStr = 0, gainedInt = 0, gainedLuk = 0, gainedCha = 0, gainedVit = 0;

      // A. 【傾向蓄積】 XP分をステータス経験値として貯める
      int currentTempStr = player.tempStrExp;
      int currentTempInt = player.tempIntExp;
      int currentTempLuk = player.tempLukExp;
      int currentTempCha = player.tempChaExp;
      int currentTempVit = player.tempVitExp;

      // 獲得したXP量 = その属性への努力値
      switch (habit.taskType) {
        case TaskType.strength:
          currentTempStr += calculatedXp;
          break;
        case TaskType.intelligence:
          currentTempInt += calculatedXp;
          break;
        case TaskType.luck:
          currentTempLuk += calculatedXp;
          break;
        case TaskType.charm:
          currentTempCha += calculatedXp;
          break;
        case TaskType.vitality:
          currentTempVit += calculatedXp;
          break;
      }

      // B. 【レベルアップボーナス】
      int newExperience = player.experience + calculatedXp;
      int newLevel = player.level;
      bool isLevelUp = false;
      int levelsGained = 0;

      while (newLevel < ExpCalculator.kMaxLevel) {
        final int requiredExp = ExpCalculator.requiredExpForNextLevel(newLevel);
        if (newExperience >= requiredExp) {
          isLevelUp = true;
          newLevel += 1;
          newExperience -= requiredExp;
          levelsGained += 1;

          final int pointsForThisLevel = _getStatPointsForLevel(newLevel);
          final totalTempExp =
              currentTempStr + currentTempInt + currentTempLuk + currentTempCha + currentTempVit;

          int bonusStrPoint = 0,
              bonusIntPoint = 0,
              bonusLukPoint = 0,
              bonusChaPoint = 0,
              bonusVitPoint = 0;

          if (totalTempExp > 0) {
            // 比率配分
            bonusStrPoint = (pointsForThisLevel * (currentTempStr / totalTempExp)).floor();
            bonusIntPoint = (pointsForThisLevel * (currentTempInt / totalTempExp)).floor();
            bonusLukPoint = (pointsForThisLevel * (currentTempLuk / totalTempExp)).floor();
            bonusChaPoint = (pointsForThisLevel * (currentTempCha / totalTempExp)).floor();
            bonusVitPoint = (pointsForThisLevel * (currentTempVit / totalTempExp)).floor();

            // 端数処理
            final remainder =
                pointsForThisLevel -
                (bonusStrPoint + bonusIntPoint + bonusLukPoint + bonusChaPoint + bonusVitPoint);
            if (remainder > 0) {
              final statsMap = {
                'str': currentTempStr,
                'int': currentTempInt,
                'luk': currentTempLuk,
                'cha': currentTempCha,
                'vit': currentTempVit,
              };
              final maxStatKey = statsMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
              if (maxStatKey == 'str') {
                bonusStrPoint += remainder;
              } else if (maxStatKey == 'int')
                bonusIntPoint += remainder;
              else if (maxStatKey == 'luk')
                bonusLukPoint += remainder;
              else if (maxStatKey == 'cha')
                bonusChaPoint += remainder;
              else if (maxStatKey == 'vit')
                bonusVitPoint += remainder;
            }
          } else {
            // 努力値0の場合はSTRに振る等のフォールバック
            bonusStrPoint = pointsForThisLevel;
          }

          newStr = min(newStr + bonusStrPoint, kBaseStatCap);
          newInt = min(newInt + bonusIntPoint, kBaseStatCap);
          newLuk = min(newLuk + bonusLukPoint, kBaseStatCap);
          newCha = min(newCha + bonusChaPoint, kBaseStatCap);
          newVit = min(newVit + bonusVitPoint, kBaseStatCap);

          gainedStr += bonusStrPoint;
          gainedInt += bonusIntPoint;
          gainedLuk += bonusLukPoint;
          gainedCha += bonusChaPoint;
          gainedVit += bonusVitPoint;
        } else {
          break;
        }
      }

      // レベルアップしたら蓄積値をリセット
      if (levelsGained > 0) {
        currentTempStr = 0;
        currentTempInt = 0;
        currentTempLuk = 0;
        currentTempCha = 0;
        currentTempVit = 0;
      }

      // カンスト処理
      if (newLevel >= ExpCalculator.kMaxLevel) {
        newExperience = ExpCalculator.requiredExpForNextLevel(ExpCalculator.kMaxLevel);
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
          intellect: Value(newInt),
          luck: Value(newLuk),
          cha: Value(newCha),
          vit: Value(newVit),
          tempStrExp: Value(currentTempStr),
          tempIntExp: Value(currentTempInt),
          tempLukExp: Value(currentTempLuk),
          tempChaExp: Value(currentTempCha),
          tempVitExp: Value(currentTempVit),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // UI表示用に戻り値を返す
      // ※ XPは蓄積用(calculatedXp)を返すことで、チャートアニメーションは「今回稼いだ努力値」を表示できる
      return {
        'gems': calculatedGems,
        'xp': calculatedXp,
        'strUp': gainedStr,
        'intUp': gainedInt,
        'luckUp': gainedLuk,
        'chaUp': gainedCha,
        'vitUp': gainedVit,
        'levelUp': isLevelUp ? 1 : 0,
        'isCritical': isGreatSuccess ? 1 : 0,
        'clearedDebuff': 0,
        'intimacyGained': intimacyGained,
        'intimacyLevelUp': intimacyLevelUp,
      };
    });
  }
}
