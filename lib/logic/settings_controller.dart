import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database.dart';
import '../data/providers.dart';

/// 設定データを管理するController
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<UserSettingsData?>>((ref) {
      return SettingsController(ref);
    });

class SettingsController extends StateNotifier<AsyncValue<UserSettingsData?>> {
  final Ref _ref;

  SettingsController(this._ref) : super(const AsyncValue.loading()) {
    _fetchSettings();
  }

  /// 初期データ取得
  Future<void> _fetchSettings() async {
    try {
      final repository = _ref.read(settingsRepositoryProvider);
      final settings = await repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// テーマカラー変更
  Future<void> changeTheme(String colorName) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(settingsRepositoryProvider);
      await repository.updateThemeColor(colorName);
      // 更新後のデータを取得してstateにセット
      final newSettings = await repository.getSettings();
      state = AsyncValue.data(newSettings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// エフェクト表示切り替え
  Future<void> toggleShowEffect(bool show) async {
    // UIのスイッチ挙動をスムーズにするため、Loadingにはせず楽観的更新を行う場合もあるが、
    // ここでは安全にLoading -> Dataの流れにする
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(settingsRepositoryProvider);
      await repository.toggleShowEffect(show);
      final newSettings = await repository.getSettings();
      state = AsyncValue.data(newSettings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 全データリセット
  Future<void> resetGameData() async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(settingsRepositoryProvider);
      await repository.resetAllData();
      final newSettings = await repository.getSettings();
      state = AsyncValue.data(newSettings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// 現在のテーマカラーを提供するProvider
final currentThemeColorProvider = Provider<MaterialColor>((ref) {
  final settingsAsync = ref.watch(settingsControllerProvider);

  // デフォルト色
  MaterialColor color = Colors.pink;

  settingsAsync.whenData((settings) {
    if (settings != null) {
      switch (settings.themeColor) {
        case 'red':
          color = Colors.red;
          break;
        case 'orange':
          color = Colors.orange;
          break;
        case 'amber':
          color = Colors.amber;
          break;
        case 'green':
          color = Colors.green;
          break;
        case 'teal':
          color = Colors.teal;
          break;
        case 'blue':
          color = Colors.blue;
          break;
        case 'indigo':
          color = Colors.indigo;
          break;
        case 'purple':
          color = Colors.purple;
          break;
        case 'pink':
          color = Colors.pink;
          break;
        case 'grey':
          color = Colors.blueGrey;
          break;
      }
    }
  });

  return color;
});
