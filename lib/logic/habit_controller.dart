import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/database.dart';
import '../data/providers.dart';

part 'habit_controller.g.dart';

@riverpod
class HabitController extends _$HabitController {
  @override
  FutureOr<void> build() {
    // 初期化不要
  }

  Future<void> addHabit({
    required String title,
    required TaskType type,
    required TaskDifficulty difficulty,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(habitRepositoryProvider);
      await repository.addHabit(title, type, difficulty);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 👇 追加: 更新アクション
  Future<void> updateHabit({
    required Habit habit,
    required String title,
    required TaskType type,
    required TaskDifficulty difficulty,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(habitRepositoryProvider);
      await repository.updateHabit(habit, title, type, difficulty);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Map<String, int>?> completeHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(habitRepositoryProvider);
      final rewards = await repository.completeHabit(habit);
      state = const AsyncValue.data(null);
      return rewards;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<void> deleteHabit(int id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(habitRepositoryProvider);
      await repository.deleteHabit(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
