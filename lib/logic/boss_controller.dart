import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/database.dart';
import '../data/providers.dart';
import '../data/repositories/boss_repository.dart';

part 'boss_controller.g.dart';

@riverpod
class BossController extends _$BossController {
  @override
  FutureOr<Map<BossType, BossStatus>> build() async {
    return _fetchStatus();
  }

  Future<Map<BossType, BossStatus>> _fetchStatus() async {
    final repository = ref.read(bossRepositoryProvider);
    return await repository.checkBossStatus();
  }

  /// 戦闘実行
  Future<BattleResult?> challengeBoss(BossStatus boss) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(bossRepositoryProvider);
      final result = await repository.executeBattle(boss);
      
      // 状態を更新（勝利していれば「撃破済み」になるため）
      state = AsyncValue.data(await _fetchStatus());
      
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
}