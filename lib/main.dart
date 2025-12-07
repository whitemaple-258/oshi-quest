import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/database/database.dart';
import 'data/repositories/gacha_item_repository.dart';
import 'data/repositories/habit_repository.dart';
import 'ui/screens/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: OshiQuestApp()));
}

class OshiQuestApp extends StatelessWidget {
  const OshiQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OshiQuest',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// データベースプロバイダー
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// ガチャアイテムリポジトリプロバイダー
final gachaItemRepositoryProvider = Provider<GachaItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GachaItemRepository(db);
});

/// ガチャアイテム一覧のStreamProvider
final gachaItemsProvider = StreamProvider<List<GachaItem>>((ref) {
  final repository = ref.watch(gachaItemRepositoryProvider);
  return repository.watchAllItems();
});

/// 習慣リポジトリプロバイダー
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HabitRepository(db);
});

/// 習慣一覧のStreamProvider
final habitsProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchAllHabits();
});

/// プレイヤー情報のStreamProvider（リアルタイム更新）
final playerProvider = StreamProvider<Player>((ref) async* {
  final db = ref.watch(databaseProvider);
  await for (final players in (db.select(db.players)..where((p) => p.id.equals(1))).watch()) {
    if (players.isNotEmpty) {
      yield players.first;
    }
  }
});
