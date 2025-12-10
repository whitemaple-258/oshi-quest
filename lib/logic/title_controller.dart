import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/providers.dart';

part 'title_controller.g.dart';

@Riverpod(keepAlive: true)
class TitleController extends _$TitleController {
  @override
  void build() {}

  /// 称号の解除チェックを行い、解除された称号があれば返す
  Future<List<String>> checkAchievements() async {
    try {
      final repository = ref.read(titleRepositoryProvider);
      final unlockedNames = await repository.checkUnlockConditions();
      return unlockedNames;
    } catch (e) {
      print('称号チェックエラー: $e');
      return [];
    }
  }
}
