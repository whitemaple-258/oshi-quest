import 'package:drift/drift.dart';
import '../database/database.dart';

/// 称号（実績）の管理を行うリポジトリ
class TitleRepository {
  final AppDatabase _db;

  TitleRepository(this._db);

  /// 称号マスターデータの初期化（アプリ起動時に呼ぶ）
  Future<void> initMasterData() async {
    final count = await (_db.select(_db.titles)).get().then((l) => l.length);
    if (count == 0) {
      // 初期データの登録
      await _db.batch((batch) {
        batch.insertAll(_db.titles, [
          TitlesCompanion.insert(
            name: '見習い勇者',
            description: const Value('冒険の始まり。'),
            unlockConditionType: 'level',
            unlockConditionValue: '1',
            isUnlocked: const Value(true), // 最初から所持
            unlockedAt: Value(DateTime.now()),
          ),
          TitlesCompanion.insert(
            name: '一人前の勇者',
            description: const Value('レベル10に到達した証。'),
            unlockConditionType: 'level',
            unlockConditionValue: '10',
          ),
          TitlesCompanion.insert(
            name: '大富豪',
            description: const Value('所持ジェムが1000を超えた。'),
            unlockConditionType: 'gems',
            unlockConditionValue: '1000',
          ),
          TitlesCompanion.insert(
            name: '脳筋',
            description: const Value('STRが20を超えた。'),
            unlockConditionType: 'str',
            unlockConditionValue: '20',
          ),
          TitlesCompanion.insert(
            name: 'ガリ勉',
            description: const Value('INTが20を超えた。'),
            unlockConditionType: 'int',
            unlockConditionValue: '20',
          ),
          TitlesCompanion.insert(
            name: 'ラッキーマン',
            description: const Value('LUCKが20を超えた。'),
            unlockConditionType: 'luck',
            unlockConditionValue: '20',
          ),
          TitlesCompanion.insert(
            name: '愛されキャラ',
            description: const Value('CHAが20を超えた。'),
            unlockConditionType: 'cha',
            unlockConditionValue: '20',
          ),
        ]);
      });
    }
  }

  /// 全称号を監視
  Stream<List<Title>> watchAllTitles() {
    return (_db.select(
      _db.titles,
    )..orderBy([(t) => OrderingTerm.desc(t.isUnlocked), (t) => OrderingTerm.asc(t.id)])).watch();
  }

  /// 称号のアンロック状態をチェック・更新する
  /// 何かアンロックされた場合は、その称号名をリストで返す
  Future<List<String>> checkUnlockConditions() async {
    final unlockedTitles = <String>[];

    await _db.transaction(() async {
      // 1. プレイヤー情報の取得
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

      // 2. 未アンロックの称号を取得
      final lockedTitles = await (_db.select(
        _db.titles,
      )..where((t) => t.isUnlocked.equals(false))).get();

      for (final title in lockedTitles) {
        bool conditionMet = false;
        final value = int.tryParse(title.unlockConditionValue) ?? 0;

        // 条件判定ロジック
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

        // 条件達成なら更新
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
