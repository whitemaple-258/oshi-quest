import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/providers.dart';

part 'party_controller.g.dart';

@Riverpod(keepAlive: true)
class PartyController extends _$PartyController {
  @override
  FutureOr<void> build() {
    // 初期化不要
  }

  /// 指定スロットに装備
  Future<void> equipItem(int slot, int itemId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(partyRepositoryProvider);
      await repository.equipToSlot(slot, itemId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 指定スロットの装備を解除
  Future<void> unequipItem(int slot) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(partyRepositoryProvider);
      await repository.unequipSlot(slot);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
