import 'package:drift/drift.dart';
import '../database/database.dart'; 

class BossRepository {
  final AppDatabase _db;

  BossRepository(this._db);

  /// 現在アクティブなボスを取得する
  Future<Boss> getActiveBoss(BossType type) async {
    // 1. 数値として検索 (type.index を使用)
    final activeBoss = await (_db.select(_db.bosses)
          ..where((b) => b.bossType.equals(type.index)) // .index で数値に変換
          ..orderBy([
            (b) => OrderingTerm(expression: b.resetAt, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();

    if (activeBoss != null) {
      return activeBoss;
    }
    
    // 2. 新規作成時も数値として保存
    final now = DateTime.now(); 
    final newBossCompanion = _createNewBossCompanion(type, now);
    final id = await _db.into(_db.bosses).insert(newBossCompanion);
    
    return (_db.select(_db.bosses)..where((b) => b.id.equals(id))).getSingle();
  }

  /// ボスのデータ (Companion) を生成する
  BossesCompanion _createNewBossCompanion(BossType type, DateTime resetAt) {
    String name;
    int hp, attack, defense;
    int reward;

    switch (type) {
      case BossType.weekly:
        name = '週刊の怨霊';
        hp = 1000;
        attack = 100;
        defense = 50;
        reward = 500;
        break;
      case BossType.monthly:
        name = '月刊の悪夢';
        hp = 5000;
        attack = 250;
        defense = 150;
        reward = 2000;
        break;
      case BossType.yearly:
        name = '年間の破壊神';
        hp = 15000;
        attack = 500;
        defense = 300;
        reward = 5000;
        break;
    }

    return BossesCompanion.insert(
      name: name,
      bossType: type.index, // ⚠️ 変更点: Enumではなく数値を渡す
      maxHp: Value(hp),
      attack: Value(attack),
      defense: Value(defense),
      rewardGems: Value(reward),
      resetAt: resetAt,
    );
  }
  
  // (saveBossResultは変更なし)
  Future<void> saveBossResult({
    required BossType bossType,
    required String periodKey, 
    required bool isWin,
    required int playerPower,
    required int bossPower,
  }) async {
    await _db.into(_db.bossResults).insert(
      BossResultsCompanion.insert(
        bossType: bossType, // こちらはintEnumのままであればそのままでOK
        periodKey: periodKey,
        isWin: isWin,
        playerPower: playerPower,
        bossPower: bossPower,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}