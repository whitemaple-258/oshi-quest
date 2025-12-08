import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/providers.dart';

part 'party_controller.g.dart';

@riverpod
class PartyController extends _$PartyController {
  @override
  FutureOr<void> build() {
    // 初期化は不要
  }

  /// 指定したアイテムをメインパートナーとして装備
  Future<void> equipItem(int itemId) async {
    // ローディング状態にする
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(partyRepositoryProvider);
      // トランザクション実行
      await repository.equipToMainSlot(itemId);

      // 成功したらデータを更新（nullでOK）
      // ※ここでコンポーネントが破棄されていなければUIが更新される
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      // エラー発生時はエラー状態にする
      state = AsyncValue.error(e, stack);
    }
  }
}
