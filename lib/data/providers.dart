import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import 'repositories/gacha_item_repository.dart';
import 'repositories/habit_repository.dart';
import 'repositories/party_repository.dart';
import 'repositories/title_repository.dart';
import 'repositories/settings_repository.dart'; // ✅ 追加

// Database
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Gacha
final gachaItemRepositoryProvider = Provider<GachaItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GachaItemRepository(db);
});
final gachaItemsProvider = StreamProvider<List<GachaItem>>((ref) {
  final repository = ref.watch(gachaItemRepositoryProvider);
  return repository.watchAllItems();
});

// Habit
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HabitRepository(db);
});
final habitsProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchAllHabits();
});

// Player
final playerProvider = StreamProvider<Player>((ref) async* {
  final db = ref.watch(databaseProvider);
  await for (final players in (db.select(db.players)..where((p) => p.id.equals(1))).watch()) {
    if (players.isNotEmpty) yield players.first;
  }
});

// Party
final partyRepositoryProvider = Provider<PartyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PartyRepository(db);
});
final currentPartnerProvider = StreamProvider<GachaItem?>((ref) {
  final repository = ref.watch(partyRepositoryProvider);
  return repository.watchMainPartner();
});
final activePartyProvider = StreamProvider<Map<int, GachaItem>>((ref) {
  final repository = ref.watch(partyRepositoryProvider);
  return repository.watchActiveParty();
});

// Title
final titleRepositoryProvider = Provider<TitleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TitleRepository(db);
});
final titlesProvider = StreamProvider<List<Title>>((ref) {
  final repository = ref.watch(titleRepositoryProvider);
  return repository.watchAllTitles();
});

// Settings ✅ 追加
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepository(db);
});
