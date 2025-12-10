import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/database.dart';
import '../data/providers.dart';
import 'title_controller.dart'; // ✅ 追加

part 'habit_controller.g.dart';

@riverpod
class HabitController extends _$HabitController {
  @override
  FutureOr<void> build() {
    // 初期化不要
  }

  // ... (addHabit, deleteHabit は変更なし) ...
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

  // ... (updateHabit も変更なし) ...
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

  // 👇 修正: 完了処理に称号チェックを追加
  Future<Map<String, dynamic>?> completeHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(habitRepositoryProvider);

      // 1. クエスト完了 & 報酬計算
      final rewards = await repository.completeHabit(habit);

      // 2. 称号アンロック判定 (TitleController経由)
      // リターン型が変わるので、元のrewardsをMutableなMapに変換して拡張
      final result = Map<String, dynamic>.from(rewards);

      // 称号チェック実行
      final newTitles = await ref.read(titleControllerProvider.notifier).checkAchievements();
      result['newTitles'] = newTitles; // 獲得した称号リスト(List<String>)を追加

      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
}
