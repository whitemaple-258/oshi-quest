import 'package:drift/drift.dart';
import '../database/database.dart';

/// ユーザー設定の管理を行うリポジトリ
class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository(this._db);

  /// 設定の取得（なければ初期作成）
  Future<UserSettingsData> getSettings() async {
    final settings = await (_db.select(
      _db.userSettings,
    )..where((s) => s.id.equals(1))).getSingleOrNull();

    if (settings == null) {
      // 初期設定の作成 (デフォルトテーマはPink)
      await _db
          .into(_db.userSettings)
          .insert(
            UserSettingsCompanion.insert(
              id: const Value(1),
              themeColor: const Value('pink'),
              isPro: const Value(false),
              maxHabits: const Value(3),
              maxGachaItems: const Value(50),
              maxDecks: const Value(1),
            ),
          );
      return await (_db.select(_db.userSettings)..where((s) => s.id.equals(1))).getSingle();
    }
    return settings;
  }

  /// 設定を監視 (Stream)
  Stream<UserSettingsData> watchSettings() {
    return (_db.select(_db.userSettings)..where((s) => s.id.equals(1))).watchSingle();
  }

  /// テーマカラーの更新
  Future<void> updateThemeColor(String colorName) async {
    await (_db.update(_db.userSettings)..where((s) => s.id.equals(1))).write(
      UserSettingsCompanion(themeColor: Value(colorName), updatedAt: Value(DateTime.now())),
    );
  }

  /// データの完全リセット (デバッグ用)
  Future<void> resetAllData() async {
    await _db.transaction(() async {
      // 全テーブルのデータを削除
      await _db.delete(_db.habits).go();
      await _db.delete(_db.partyMembers).go();
      await _db.delete(_db.partyDecks).go();
      await _db.delete(_db.gachaItems).go();
      await _db.delete(_db.titles).go();

      // プレイヤーデータはリセット（削除して再作成）
      await _db.delete(_db.players).go();
      await _db
          .into(_db.players)
          .insert(
            PlayersCompanion.insert(
              id: const Value(1),
              level: const Value(1),
              willGems: const Value(500),
              // ... 他の初期値
            ),
          );

      // 設定は維持するか、リセットするか（今回は維持）
    });
  }
}
