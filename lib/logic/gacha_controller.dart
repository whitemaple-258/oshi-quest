import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/database.dart';
import '../data/providers.dart';

part 'gacha_controller.g.dart';

@riverpod
class GachaController extends _$GachaController {
  @override
  FutureOr<void> build() {
    // 初期化不要
  }

  /// ガチャを実行する
  /// 戻り値: 当選したアイテム（演出表示用）
  Future<GachaItem?> pullGacha() async {
    state = const AsyncValue.loading();
    try {
      const cost = 100; // 1回100ジェム
      final repository = ref.read(gachaItemRepositoryProvider);

      // リポジトリの処理を呼び出し
      final item = await repository.pullGacha(cost);

      state = const AsyncValue.data(null);
      return item; // 当選アイテムを返す
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow; // UI側でエラーメッセージを出すために再スロー
    }
  }
}
