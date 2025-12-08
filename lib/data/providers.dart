import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import 'repositories/gacha_item_repository.dart';
import 'repositories/habit_repository.dart';
import 'repositories/party_repository.dart';

// ============================================================================
// Global Providers (手動定義)
// ============================================================================

/// データベース本体
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// --- Gacha (推し画像) ---

final gachaItemRepositoryProvider = Provider<GachaItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GachaItemRepository(db);
});

final gachaItemsProvider = StreamProvider<List<GachaItem>>((ref) {
  final repository = ref.watch(gachaItemRepositoryProvider);
  return repository.watchAllItems();
});

// --- Habits (習慣クエスト) ---

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
  // ID=1 のプレイヤーを監視
  await for (final players in (db.select(db.players)..where((p) => p.id.equals(1))).watch()) {
    if (players.isNotEmpty) {
      yield players.first;
    }
  }
});

// --- Party (装備・編成) ---

final partyRepositoryProvider = Provider<PartyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PartyRepository(db);
});

// メインスロット(0)に装備中の推しを監視
final currentPartnerProvider = StreamProvider<GachaItem?>((ref) {
  final repository = ref.watch(partyRepositoryProvider);
  return repository.watchMainPartner();
});
