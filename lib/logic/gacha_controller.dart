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

  // ✅ 追加: 10連ガチャ
  Future<List<GachaItem>> pullGacha10() async {
    state = const AsyncValue.loading();
    try {
      const costPerPull = 100; // 1回あたりのコスト
      const count = 10;

      final repository = ref.read(gachaItemRepositoryProvider);

      // 10連実行
      final items = await repository.pullGachaMulti(count, costPerPull);
      state = const AsyncValue.data(null);
      return items;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // 👇 追加: 削除
  Future<void> deleteItem(int id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(gachaItemRepositoryProvider);
      await repository.deleteItem(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 👇 追加: 編集
  Future<void> updateItem(int id, String title, {bool reCrop = false}) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(gachaItemRepositoryProvider);
      await repository.updateItem(id, title, reCropImage: reCrop);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 単体売却（価格計算はここで行う：UI側で確認ダイアログに価格を出す等の都合上）
  Future<bool> sellItem(GachaItem item) async {
    state = const AsyncValue.loading();
    try {
      int price = 0;
      switch (item.rarity) {
        case Rarity.n:
          price = 50;
          break;
        case Rarity.r:
          price = 150;
          break;
        case Rarity.sr:
          price = 500;
          break;
        case Rarity.ssr:
          price = 2000;
          break;
      }

      final repository = ref.read(gachaItemRepositoryProvider);
      await repository.sellItem(item.id, price);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false; // 売却失敗
    }
  }

  // ✅ 追加: 一括売却
  Future<void> sellItems(List<int> itemIds) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(gachaItemRepositoryProvider);
      await repository.sellItems(itemIds);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
