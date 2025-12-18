import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import 'repositories/gacha_item_repository.dart'; // パスが正しいか確認してください
// 他のリポジトリのインポートは環境に合わせて維持してください
import 'repositories/habit_repository.dart';
import 'repositories/party_repository.dart';
import 'repositories/title_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/boss_repository.dart';
import 'repositories/shop_repository.dart';

// ============================================================================
// Global Providers
// ============================================================================

// --- Database ---
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// ============================================================================
// Gacha System (ガチャ・アイテム・画像)
// ============================================================================

// ✅ リポジトリ (ロジック担当)
final gachaItemRepositoryProvider = Provider<GachaItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GachaItemRepository(db); // refは不要になったため削除
});

// ✅ 所持品リスト (IDの降順 = 新しい順)
final myItemsProvider = StreamProvider<List<GachaItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.gachaItems,
  )..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)])).watch();
});

// ✅ 登録済み画像プール (ImagePoolScreen用)
// 以前の lineupItemsProvider の代わり、または追加として使用
final characterImagesProvider = StreamProvider<List<CharacterImage>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.characterImages).watch();
});

// ============================================================================
// Player Status (プレイヤー情報)
// ============================================================================
final playerProvider = StreamProvider<Player>((ref) {
  final db = ref.watch(databaseProvider);
  // 常に最初の1件を監視する
  return db.select(db.players).watchSingle();
});

// ============================================================================
// Party System (編成)
// ============================================================================
final partyRepositoryProvider = Provider<PartyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PartyRepository(db);
});

// 現在のパーティ編成 (Map<ポジション, Item>)
final activePartyProvider = StreamProvider<Map<int, GachaItem>>((ref) {
  final db = ref.watch(databaseProvider);

  // PartyMembersとGachaItemsを結合して監視
  final query = db.select(db.partyMembers).join([
    innerJoin(db.gachaItems, db.gachaItems.id.equalsExp(db.partyMembers.gachaItemId)),
  ]);

  return query.watch().map((rows) {
    final Map<int, GachaItem> partyMap = {};
    for (final row in rows) {
      final member = row.readTable(db.partyMembers);
      final item = row.readTable(db.gachaItems);
      partyMap[member.slotPosition] = item;
    }
    return partyMap;
  });
});

// ============================================================================
// Other Features (習慣・ボス・称号・ショップ・設定)
// ============================================================================

// --- Habits (習慣) ---
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HabitRepository(db);
});
final habitsProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchAllHabits();
});

// --- Boss (ボス) ---
final bossRepositoryProvider = Provider<BossRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BossRepository(db);
});

// --- Title (称号) ---
final titleRepositoryProvider = Provider<TitleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TitleRepository(db);
});
final titlesProvider = StreamProvider<List<Title>>((ref) {
  final repository = ref.watch(titleRepositoryProvider);
  return repository.watchAllTitles();
});

// --- Shop (ご褒美ショップ) ---
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ShopRepository(db);
});

// --- Settings (設定) ---
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepository(db);
});
