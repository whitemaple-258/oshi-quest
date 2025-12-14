import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import 'repositories/gacha_item_repository.dart';
import 'repositories/habit_repository.dart';
import 'repositories/party_repository.dart';
import 'repositories/title_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/boss_repository.dart';
import 'repositories/shop_repository.dart';

// ============================================================================
// Global Providers
// ============================================================================

// Database
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// --- Gacha (推し画像) ---
final gachaItemRepositoryProvider = Provider<GachaItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GachaItemRepository(db, ref); // ✅ refを渡す
});

// ✅ 所持品リスト (編成・一覧用)
final myItemsProvider = StreamProvider<List<GachaItem>>((ref) {
  final repository = ref.watch(gachaItemRepositoryProvider);
  return repository.watchMyItems();
});

// ✅ ラインナップ (ガチャ画面・登録用)
final lineupItemsProvider = StreamProvider<List<GachaItem>>((ref) {
  final repository = ref.watch(gachaItemRepositoryProvider);
  return repository.watchLineupItems();
});

// --- Habits (習慣) ---
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HabitRepository(db);
});
final habitsProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchAllHabits();
});

// --- Player (ステータス) ---
final playerProvider = StreamProvider<Player>((ref) async* {
  final db = ref.watch(databaseProvider);
  await for (final players in (db.select(db.players)..where((p) => p.id.equals(1))).watch()) {
    if (players.isNotEmpty) yield players.first;
  }
});

// --- Party (編成) ---
final partyRepositoryProvider = Provider<PartyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PartyRepository(db);
});
final activePartyProvider = StreamProvider<Map<int, GachaItem>>((ref) {
  final repository = ref.watch(partyRepositoryProvider);
  return repository.watchActiveParty();
});
// ✅ 装備中フレーム
final equippedFrameProvider = StreamProvider<GachaItem?>((ref) {
  final repository = ref.watch(partyRepositoryProvider);
  return repository.watchEquippedFrame();
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
