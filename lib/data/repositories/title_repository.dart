import 'package:drift/drift.dart';
import '../database/database.dart';
import '../master_data/title_master_data.dart';

/// 称号（実績）の管理を行うリポジトリ
class TitleRepository {
  final AppDatabase _db;

  TitleRepository(this._db);

  /// 称号マスターデータの初期化（アプリ起動時に呼ぶ）
  Future<void> initMasterData() async {
    // 既存の称号数をカウント
    final count = await (_db.select(_db.titles)).get().then((l) => l.length);

    // まだデータがない場合（初回起動時）のみ実行
    if (count == 0) {
      await _db.batch((batch) {
        // ✅ 修正: 別ファイルのリストを使うだけでOK
        batch.insertAll(_db.titles, defaultTitles);
      });
    } else {
      // (応用) アップデートで称号が増えた場合の処理をここに書くことも可能
      // 今回は簡易的にスキップ
    }
  }

  /// 全称号を監視
  Stream<List<Title>> watchAllTitles() {
    return (_db.select(
      _db.titles,
    )..orderBy([(t) => OrderingTerm.desc(t.isUnlocked), (t) => OrderingTerm.asc(t.id)])).watch();
  }

  /// 称号のアンロック状態をチェック・更新する
  Future<List<String>> checkUnlockConditions() async {
    final unlockedTitles = <String>[];

    await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

      final lockedTitles = await (_db.select(
        _db.titles,
      )..where((t) => t.isUnlocked.equals(false))).get();

      for (final title in lockedTitles) {
        bool conditionMet = false;
        final value = int.tryParse(title.unlockConditionValue) ?? 0;

        switch (title.unlockConditionType) {
          case 'level':
            conditionMet = player.level >= value;
            break;
          case 'gems':
            conditionMet = player.willGems >= value;
            break;
          case 'str':
            conditionMet = player.str >= value;
            break;
          case 'int':
            conditionMet = player.intellect >= value;
            break;
          case 'luck':
            conditionMet = player.luck >= value;
            break;
          case 'cha':
            conditionMet = player.cha >= value;
            break;
        }

        if (conditionMet) {
          await (_db.update(_db.titles)..where((t) => t.id.equals(title.id))).write(
            TitlesCompanion(isUnlocked: const Value(true), unlockedAt: Value(DateTime.now())),
          );
          unlockedTitles.add(title.name);
        }
      }
    });

    return unlockedTitles;
  }
}
