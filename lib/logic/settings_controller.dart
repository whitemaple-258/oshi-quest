import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/database.dart';
import '../data/providers.dart';

part 'settings_controller.g.dart';

@Riverpod(keepAlive: true)
MaterialColor currentThemeColor(CurrentThemeColorRef ref) {
  final settingsAsync = ref.watch(settingsControllerProvider);
  MaterialColor color = Colors.pink;

  if (settingsAsync.hasValue && settingsAsync.value != null) {
    final colorName = settingsAsync.value!.themeColor;
    switch (colorName) {
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
  return color;
}
class SettingsController extends _$SettingsController {
  @override
  FutureOr<UserSettingsData?> build() {
    return _fetchSettings();
  }

  Future<UserSettingsData?> _fetchSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    return await repository.getSettings();
  }

  Future<void> changeTheme(String colorName) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.updateThemeColor(colorName);
      state = AsyncValue.data(await repository.getSettings());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

// リセットデータ
  Future<void> resetGameData() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.resetAllData();
      state = AsyncValue.data(await repository.getSettings());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

// エフェクト表示切り替え
Future<void> toggleShowEffect(bool show) async {
  try {
      final repository = ref.read(settingsRepositoryProvider);
      
      // DB更新
      await repository.toggleShowEffect(show);
      
      // ✅ 重要: 更新後の最新データをDBから再取得して state にセット
      // これにより UI (SwitchListTile) が新しい値 (show) で再描画される
      final newSettings = await repository.getSettings();
      state = AsyncValue.data(newSettings);

    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
