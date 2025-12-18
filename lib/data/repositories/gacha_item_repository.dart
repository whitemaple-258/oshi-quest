// lib/data/repositories/gacha_item_repository.dart

import 'package:drift/drift.dart';
import '../database/database.dart'; 

class GachaItemRepository {
  final AppDatabase _db;
  
  GachaItemRepository(this._db);
  
  // ========================================================================
  // 1. データ操作 (CRUD)
  // ========================================================================

  /// Companionをデータベースに挿入し、GachaItemとして返す
  /// データの生成ロジックはLogicMasterが担当するため、ここでは受け取ったデータを保存するだけ
  Future<GachaItem> insertNewGachaItem(GachaItemsCompanion companion) async {
    final id = await _db.into(_db.gachaItems).insert(companion);
    return (_db.select(_db.gachaItems)..where((tbl) => tbl.id.equals(id))).getSingle();
  }
  
  /// アイテムを更新する (汎用的な更新メソッド)
  Future<void> updateGachaItem(int itemId, GachaItemsCompanion companion) async {
    await (_db.update(_db.gachaItems)..where((t) => t.id.equals(itemId))).write(companion);
  }

  /// アイテムを削除する
  Future<void> deleteGachaItem(int itemId) async {
    await (_db.delete(_db.gachaItems)..where((t) => t.id.equals(itemId))).go();
  }

  /// IDでGachaItemを取得する
  Future<GachaItem> getItemById(int id) {
    return (_db.select(_db.gachaItems)..where((t) => t.id.equals(id))).getSingle();
  }

  // ========================================================================
  // 2. 画像プール管理
  // ========================================================================

  /// 画像プールに新しい画像を追加する
  Future<void> addImageToPool(String path, String name) async {
    await _db.into(_db.characterImages).insert(
      CharacterImagesCompanion.insert(
        imagePath: path,
        name: Value(name),
      ),
    );
  }

  /// 現在のユーザー画像プールを取得する
  Future<List<CharacterImage>> getUserImagePool() {
    return _db.select(_db.characterImages).get();
  }

  // ========================================================================
  // 3. 特殊な更新操作 (Controllerから委譲された処理)
  // ========================================================================

  /// 整形 (画像のみ変更)
  /// ロジックはController/LogicMaster側で決定された値を渡す形にするのが理想だが、
  /// ここでは利便性のため「画像パスの更新」に特化したメソッドとして残す
  Future<void> reskinItem(GachaItem item, String newImagePath) async {
    await updateGachaItem(
      item.id,
      GachaItemsCompanion(
        imagePath: Value(newImagePath),
        type: const Value(GachaItemType.userImage), // ユーザー画像型へ変更
        tightsColor: const Value(TightsColor.none), // 色情報リセット
        
        // 更新日時などのメタデータを更新する場合はここに追加
      ),
    );
  }

  /// 転生 (画像変更 + ステータス再抽選)
  /// ※ パラメータの再抽選ロジックは本来ここにあるべきではないが、
  /// Controller側でLogicMasterを使って生成したCompanionを受け取る形に修正するのがベスト。
  /// 今回はController側でこのメソッドを呼んでいるため、互換性のために残すが、
  /// 実際の中身は「Controllerから渡された値で更新する」形に変更する。
  Future<void> reincarnateItem(GachaItem item, String newImagePath) async {
    // Note: このメソッド内でのステータス再抽選ロジックは削除し、
    // ControllerがLogicMasterを使って生成した新しいパラメータをupdateGachaItemで適用することを推奨。
    // そのため、このメソッドは実質的にreskinItemと同じ役割になるか、削除してController側でupdateGachaItemを直接呼ぶべき。
    
    // しかし、既存のControllerコードがこのメソッドに依存しているため、
    // 互換性維持として「画像更新のみ」を行う形にするか、
    // またはController側でロジックを組んでupdateGachaItemを呼ぶ形に修正済み。
    
    // ここでは「画像更新 + 属性変更」を行うメソッドとして定義
    await updateGachaItem(
      item.id,
      GachaItemsCompanion(
        imagePath: Value(newImagePath),
        type: const Value(GachaItemType.userImage),
        tightsColor: const Value(TightsColor.none),
      ),
    );
  }
}