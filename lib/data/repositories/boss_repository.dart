import 'package:drift/drift.dart';
import '../database/database.dart';

class BossRepository {
  final AppDatabase _db;

  BossRepository(this._db);

  String _getWeeklyKey(DateTime date) {
    final dayOfYear = int.parse("${date.difference(DateTime(date.year, 1, 1)).inDays + 1}");
    final week = (dayOfYear / 7).ceil();
    return "${date.year}-W$week";
  }

  String _getMonthlyKey(DateTime date) => "${date.year}-M${date.month}";
  String _getYearlyKey(DateTime date) => "${date.year}";

  Future<Map<BossType, BossStatus>> checkBossStatus() async {
    final now = DateTime.now();
    final statusMap = <BossType, BossStatus>{};

    final isSunday = now.weekday == DateTime.sunday;
    final weeklyKey = _getWeeklyKey(now);
    statusMap[BossType.weekly] = await _getStatus(BossType.weekly, weeklyKey, isSunday, 1.2);

    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final isMonthEnd = now.day == lastDay;
    final monthlyKey = _getMonthlyKey(now);
    statusMap[BossType.monthly] = await _getStatus(BossType.monthly, monthlyKey, isMonthEnd, 2.5);

    final isYearEnd = now.month == 12 && now.day == 31;
    final yearlyKey = _getYearlyKey(now);
    statusMap[BossType.yearly] = await _getStatus(BossType.yearly, yearlyKey, isYearEnd, 5.0);

    return statusMap;
  }

  Future<BossStatus> _getStatus(
    BossType type,
    String key,
    bool isDay,
    double powerMultiplier,
  ) async {
    final result =
        await (_db.select(_db.bossResults)
              ..where((t) => t.bossType.equals(type.index))
              ..where((t) => t.periodKey.equals(key)))
            .getSingleOrNull();

    final isDefeated = result?.isWin ?? false;

    final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();
    final basePower = (player.level * 20 * powerMultiplier).round();
    final bossPower = basePower < 100 ? 100 : basePower;

    return BossStatus(
      type: type,
      periodKey: key,
      isAvailable: isDay && !isDefeated,
      isDefeated: isDefeated,
      bossPower: bossPower,
      rewardGems: (bossPower * 0.5).round(),
    );
  }

  Future<BattleResult> executeBattle(BossStatus boss) async {
    return await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

      int bonusTotal = 0;
      final activeDeck = await (_db.select(
        _db.partyDecks,
      )..where((t) => t.isActive.equals(true))).getSingleOrNull();

      if (activeDeck != null) {
        // 1. パーティメンバーのボーナス
        final memberQuery = _db.select(_db.partyMembers).join([
          innerJoin(_db.gachaItems, _db.gachaItems.id.equalsExp(_db.partyMembers.gachaItemId)),
        ]);
        memberQuery.where(_db.partyMembers.deckId.equals(activeDeck.id));
        final memberResults = await memberQuery.get();
        for (final row in memberResults) {
          final item = row.readTable(_db.gachaItems);
          bonusTotal +=
              item.strBonus + item.intBonus + item.luckBonus + item.chaBonus + item.vitBonus;
        }

        // 2. ✅ 追加: 装備中フレームのボーナス
        if (activeDeck.equippedFrameId != null) {
          final frame = await (_db.select(
            _db.gachaItems,
          )..where((t) => t.id.equals(activeDeck.equippedFrameId!))).getSingleOrNull();
          if (frame != null) {
            bonusTotal +=
                frame.strBonus + frame.intBonus + frame.luckBonus + frame.chaBonus + frame.vitBonus;
          }
        }
      }

      final playerTotalPower =
          player.str + player.intellect + player.luck + player.cha + player.vit + bonusTotal;

      final isWin = playerTotalPower >= boss.bossPower;

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

      if (isWin) {
        await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
          PlayersCompanion(willGems: Value(player.willGems + boss.rewardGems)),
        );
      }

      return BattleResult(isWin: isWin, playerPower: playerTotalPower, bossPower: boss.bossPower);
    });
  }
}

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
