import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/database.dart';
import '../data/providers.dart';

part 'habit_controller.g.dart';

@riverpod
class HabitController extends _$HabitController {
  @override
  FutureOr<void> build() {
    // 初期化処理は不要
  }

  /// タスクの追加
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

  /// タスクの完了（報酬データを返す）
  Future<Map<String, int>?> completeHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(habitRepositoryProvider);
      // Repositoryから報酬計算結果を受け取る
      final rewards = await repository.completeHabit(habit);
      state = const AsyncValue.data(null);
      return rewards;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// タスクの削除
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
