import 'package:drift/drift.dart';
import '../database/database.dart';

class ShopRepository {
  final AppDatabase _db;

  ShopRepository(this._db);

  // --- 読み込み ---

  /// 全てのご褒美アイテムを監視 (作成日時の降順)
  Stream<List<RewardItem>> watchRewardItems() {
    return (_db.select(
      _db.rewardItems,
    )..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).watch();
  }

  /// 全てのご褒美アイテムを取得 (Future)
  Future<List<RewardItem>> getAllRewardItems() async {
    return await (_db.select(
      _db.rewardItems,
    )..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).get();
  }

  // --- 書き込み ---

  /// ご褒美アイテムの追加
  Future<int> addRewardItem(String title, int cost) async {
    return await _db
        .into(_db.rewardItems)
        .insert(
          RewardItemsCompanion.insert(
            title: title,
            cost: cost,
            // iconDataはデフォルト値が使われる
          ),
        );
  }

  /// ご褒美アイテムの削除
  Future<void> deleteRewardItem(int id) async {
    await (_db.delete(_db.rewardItems)..where((t) => t.id.equals(id))).go();
  }

  /// ジェム消費処理 (購入)
  /// 成功したら true, ジェム不足なら false を返す
  Future<bool> purchaseItem(int cost) async {
    return await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

      if (player.willGems < cost) {
        return false; // ジェム不足
      }

      // ジェムを減らす
      await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
        PlayersCompanion(willGems: Value(player.willGems - cost), updatedAt: Value(DateTime.now())),
      );

      return true; // 購入成功
    });
  }
}
