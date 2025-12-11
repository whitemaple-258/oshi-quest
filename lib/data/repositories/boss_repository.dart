import 'package:drift/drift.dart';
import '../database/database.dart';

class BossRepository {
  final AppDatabase _db;

  BossRepository(this._db);

  // --- 期間キーの生成 ---
  String _getWeeklyKey(DateTime date) {
    // 年間第何週かを計算（簡易版）
    final dayOfYear = int.parse("${date.difference(DateTime(date.year, 1, 1)).inDays + 1}");
    final week = (dayOfYear / 7).ceil();
    return "${date.year}-W$week";
  }

  String _getMonthlyKey(DateTime date) => "${date.year}-M${date.month}";
  String _getYearlyKey(DateTime date) => "${date.year}";

  /// 現在挑戦可能なボス情報を取得
  /// 戻り値: { BossType: (isAvailable, bossPower, periodKey, isDefeated) }
  Future<Map<BossType, BossStatus>> checkBossStatus() async {
    final now = DateTime.now();
    final statusMap = <BossType, BossStatus>{};

    // 1. 週ボス (毎週日曜日)
    final isSunday = now.weekday == DateTime.sunday;
    final weeklyKey = _getWeeklyKey(now);
    statusMap[BossType.weekly] = await _getStatus(
      BossType.weekly,
      weeklyKey,
      isSunday,
      1.2,
    ); // Lv * 1.2倍

    // 2. 月ボス (毎月最終日)
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final isMonthEnd = now.day == lastDay;
    final monthlyKey = _getMonthlyKey(now);
    statusMap[BossType.monthly] = await _getStatus(
      BossType.monthly,
      monthlyKey,
      isMonthEnd,
      2.5,
    ); // Lv * 2.5倍

    // 3. 年ボス (12月31日)
    final isYearEnd = now.month == 12 && now.day == 31;
    final yearlyKey = _getYearlyKey(now);
    statusMap[BossType.yearly] = await _getStatus(
      BossType.yearly,
      yearlyKey,
      isYearEnd,
      5.0,
    ); // Lv * 5.0倍

    return statusMap;
  }

  Future<BossStatus> _getStatus(
    BossType type,
    String key,
    bool isDay,
    double powerMultiplier,
  ) async {
    // 既に戦ったか確認
    final result =
        await (_db.select(_db.bossResults)
              ..where((t) => t.bossType.equals(type.index))
              ..where((t) => t.periodKey.equals(key)))
            .getSingleOrNull();

    final isDefeated = result?.isWin ?? false;
    final hasFought = result != null;

    // ボスの強さを計算 (プレイヤーLvベース)
    final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

    // 基礎戦闘力 = (全ステータス合計の平均想定) * レベル * 倍率
    // ※ 実際はパーティ編成もあるので、もっと強くても良い
    final basePower = (player.level * 20 * powerMultiplier).round();
    // 最低保証
    final bossPower = basePower < 100 ? 100 : basePower;

    return BossStatus(
      type: type,
      periodKey: key,
      isAvailable: isDay && !isDefeated, // 当日かつ未勝利なら挑戦可
      isDefeated: isDefeated,
      bossPower: bossPower,
      rewardGems: (bossPower * 0.5).round(), // 報酬は強さの半分
    );
  }

  /// ボス戦を実行
  Future<BattleResult> executeBattle(BossStatus boss) async {
    return await _db.transaction(() async {
      // 1. プレイヤーの総戦力を計算
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

      // 装備ボーナス取得
      int bonusTotal = 0;
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
          bonusTotal +=
              item.strBonus + item.intBonus + item.luckBonus + item.chaBonus + item.vitBonus;
        }
      }

      final playerTotalPower =
          player.str + player.intellect + player.luck + player.cha + player.vit + bonusTotal;

      // 2. 勝敗判定
      final isWin = playerTotalPower >= boss.bossPower;

      // 3. 結果記録 (既にレコードがあれば更新、なければ作成)
      // 今回はシンプルに「勝つまで何度でも挑める」仕様にするため、負けレコードは上書きor無視でも良いが、
      // 履歴を残すなら insert。ここでは「その期間の最終結果」を保存する形にする (onConflictReplace的な挙動が必要だがDrift標準ではないのでdelete insert)

      await (_db.delete(_db.bossResults)
            ..where((t) => t.bossType.equals(boss.type.index))
            ..where((t) => t.periodKey.equals(boss.periodKey)))
          .go();

      await _db
          .into(_db.bossResults)
          .insert(
            BossResultsCompanion.insert(
              bossType: boss.type,
              periodKey: boss.periodKey,
              isWin: isWin,
              playerPower: playerTotalPower,
              bossPower: boss.bossPower,
              battledAt: Value(DateTime.now()),
            ),
          );

      // 4. 勝利報酬
      if (isWin) {
        await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
          PlayersCompanion(willGems: Value(player.willGems + boss.rewardGems)),
        );
      }

      return BattleResult(isWin: isWin, playerPower: playerTotalPower, bossPower: boss.bossPower);
    });
  }
}

// データクラス
class BossStatus {
  final BossType type;
  final String periodKey;
  final bool isAvailable;
  final bool isDefeated;
  final int bossPower;
  final int rewardGems;

  BossStatus({
    required this.type,
    required this.periodKey,
    required this.isAvailable,
    required this.isDefeated,
    required this.bossPower,
    required this.rewardGems,
  });
}

class BattleResult {
  final bool isWin;
  final int playerPower;
  final int bossPower;

  BattleResult({required this.isWin, required this.playerPower, required this.bossPower});
}
