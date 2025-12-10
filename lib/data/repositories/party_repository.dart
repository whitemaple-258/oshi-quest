import 'package:drift/drift.dart';
import '../database/database.dart';

/// パーティ編成（装備）を管理するリポジトリ
class PartyRepository {
  final AppDatabase _db;

  PartyRepository(this._db);

  /// 指定したスロットに推しを装備する
  /// [slot] 0: Main, 1-4: Sub
  Future<void> equipToSlot(int slot, int gachaItemId) async {
    await _db.transaction(() async {
      // 1. アクティブなデッキを取得（なければ作成）
      var deck = await (_db.select(
        _db.partyDecks,
      )..where((t) => t.isActive.equals(true))).getSingleOrNull();

      if (deck == null) {
        final deckId = await _db
            .into(_db.partyDecks)
            .insert(
              PartyDecksCompanion.insert(
                name: 'Main Deck',
                isActive: const Value(true),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
        deck = await (_db.select(_db.partyDecks)..where((t) => t.id.equals(deckId))).getSingle();
      }

      // 2. そのスロットの既存装備を解除
      await (_db.delete(_db.partyMembers)
            ..where((t) => t.deckId.equals(deck!.id))
            ..where((t) => t.slotPosition.equals(slot)))
          .go();

      // 3. 他のスロットに同じキャラがいたら解除（重複装備不可の場合）
      await (_db.delete(_db.partyMembers)
            ..where((t) => t.deckId.equals(deck!.id))
            ..where((t) => t.gachaItemId.equals(gachaItemId)))
          .go();

      // 4. 新しい推しを装備
      await _db
          .into(_db.partyMembers)
          .insert(
            PartyMembersCompanion.insert(
              deckId: deck.id,
              gachaItemId: gachaItemId,
              slotPosition: slot,
              createdAt: Value(DateTime.now()),
            ),
          );
    });
  }

  /// 指定したスロットの装備を解除する
  Future<void> unequipSlot(int slot) async {
    final deck = await (_db.select(
      _db.partyDecks,
    )..where((t) => t.isActive.equals(true))).getSingleOrNull();

    if (deck != null) {
      await (_db.delete(_db.partyMembers)
            ..where((t) => t.deckId.equals(deck.id))
            ..where((t) => t.slotPosition.equals(slot)))
          .go();
    }
  }

  /// 現在のパーティメンバー全員を監視する
  /// key: slotPosition, value: GachaItem
  Stream<Map<int, GachaItem>> watchActiveParty() {
    final query = _db.select(_db.partyMembers).join([
      innerJoin(_db.partyDecks, _db.partyDecks.id.equalsExp(_db.partyMembers.deckId)),
      innerJoin(_db.gachaItems, _db.gachaItems.id.equalsExp(_db.partyMembers.gachaItemId)),
    ]);

    query.where(_db.partyDecks.isActive.equals(true));

    return query.watch().map((rows) {
      final Map<int, GachaItem> partyMap = {};
      for (final row in rows) {
        final member = row.readTable(_db.partyMembers);
        final item = row.readTable(_db.gachaItems);
        partyMap[member.slotPosition] = item;
      }
      return partyMap;
    });
  }

  /// （旧メソッド互換用）メインパートナー監視
  Stream<GachaItem?> watchMainPartner() {
    return watchActiveParty().map((map) => map[0]);
  }
}
