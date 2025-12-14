import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database.dart';
import '../data/providers.dart'; // shopRepositoryProvider がある前提
import 'audio_controller.dart'; // SE再生用

// コントローラーのプロバイダー定義
final shopControllerProvider = StateNotifierProvider<ShopController, AsyncValue<void>>((ref) {
  return ShopController(ref);
});

class ShopController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ShopController(this._ref) : super(const AsyncValue.data(null));

  /// アイテムを追加する
  Future<void> addItem(String title, int cost) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(shopRepositoryProvider);
      await repository.addRewardItem(title, cost);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// アイテムを削除する
  Future<void> deleteItem(int id) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(shopRepositoryProvider);
      await repository.deleteRewardItem(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// アイテムを購入（交換）する
  /// 戻り値: 購入成功なら true
  Future<bool> buyItem(RewardItem item) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(shopRepositoryProvider);

      // リポジトリで購入処理（ジェム消費）を実行
      final success = await repository.purchaseItem(item.cost);

      if (success) {
        // 購入成功音 (ガチャ結果音で代用)
        _ref.read(audioControllerProvider.notifier).playGachaResult();
        state = const AsyncValue.data(null);
        return true;
      } else {
        // ジェム不足などの場合
        state = const AsyncValue.error('ジェムが足りません', StackTrace.empty);
        return false;
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

// UI監視用のアイテムリストプロバイダー
final rewardItemsProvider = StreamProvider<List<RewardItem>>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.watchRewardItems();
});
