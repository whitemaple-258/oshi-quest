import 'package:drift/drift.dart';
import '../database/database.dart';

/// パーティ編成（装備）を管理するリポジトリ
class PartyRepository {
  final AppDatabase _db;

  PartyRepository(this._db);

  /// メインスロット(0番)に推しを装備する
  /// デッキが存在しない場合は自動作成します
  Future<void> equipToMainSlot(int gachaItemId) async {
    await _db.transaction(() async {
      // 1. アクティブなデッキを取得（なければ作成）
      var deck = await (_db.select(
        _db.partyDecks,
      )..where((t) => t.isActive.equals(true))).getSingleOrNull();

      if (deck == null) {
        // デッキ初期作成
        final deckId = await _db
            .into(_db.partyDecks)
            .insert(PartyDecksCompanion.insert(name: 'Main Deck', isActive: const Value(true)));
        deck = await (_db.select(_db.partyDecks)..where((t) => t.id.equals(deckId))).getSingle();
      }

      // 2. 既存のメインスロット(slot=0)の装備を解除（削除）
      await (_db.delete(_db.partyMembers)
            ..where((t) => t.deckId.equals(deck!.id))
            ..where((t) => t.slotPosition.equals(0)))
          .go();

      // 3. 新しい推しを装備
      await _db
          .into(_db.partyMembers)
          .insert(
            PartyMembersCompanion.insert(
              deckId: deck.id,
              gachaItemId: gachaItemId,
              slotPosition: 0, // Main Slot
            ),
          );
    });
  }

  /// 現在装備中のメインパートナーを取得するStream
  Stream<GachaItem?> watchMainPartner() {
    // 結合クエリ: ActiveDeck -> PartyMember(slot0) -> GachaItem
    final query = _db.select(_db.partyDecks).join([
      innerJoin(_db.partyMembers, _db.partyMembers.deckId.equalsExp(_db.partyDecks.id)),
      innerJoin(_db.gachaItems, _db.gachaItems.id.equalsExp(_db.partyMembers.gachaItemId)),
    ]);

    query.where(_db.partyDecks.isActive.equals(true));
    query.where(_db.partyMembers.slotPosition.equals(0));

    return query.map((row) => row.readTable(_db.gachaItems)).watchSingleOrNull();
  }
}
