import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/database.dart';
import '../data/providers.dart';

part 'debug_controller.g.dart';

@riverpod
class DebugController extends _$DebugController {
  @override
  void build() {}

  /// ジェムを増加させる
  Future<void> addGems(int amount) async {
    final db = ref.read(databaseProvider);
    final player = await (db.select(db.players)..where((p) => p.id.equals(1))).getSingle();

    await (db.update(db.players)..where((p) => p.id.equals(1))).write(
      PlayersCompanion(willGems: Value(player.willGems + amount)),
    );
  }

  /// 経験値を増加させる（レベルも再計算）
  Future<void> addExp(int amount) async {
    final db = ref.read(databaseProvider);
    final player = await (db.select(db.players)..where((p) => p.id.equals(1))).getSingle();

    final newExp = player.experience + amount;
    final newLevel = (newExp ~/ 100) + 1; // 100XPごとにレベルアップ

    await (db.update(db.players)..where((p) => p.id.equals(1))).write(
      PlayersCompanion(experience: Value(newExp), level: Value(newLevel)),
    );
  }

  /// ステータスを全回復（デバフ解除）
  Future<void> clearDebuff() async {
    final db = ref.read(databaseProvider);
    await (db.update(
      db.players,
    )..where((p) => p.id.equals(1))).write(const PlayersCompanion(currentDebuff: Value(null)));
    // 禊クエストも削除
    await (db.delete(db.habits)..where((h) => h.name.equals('【禊】女神の許しを請う'))).go();
  }

  /// 強制的に「翌日になった」ことにする（サボり判定テスト用）
  Future<void> forceDailyReset() async {
    final db = ref.read(databaseProvider);

    // 1. 最終ログイン日時を「昨日」に書き換え
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await (db.update(
      db.players,
    )..where((p) => p.id.equals(1))).write(PlayersCompanion(lastLoginAt: Value(yesterday)));

    // 2. HabitRepositoryのチェック処理を呼び出す
    final habitRepo = ref.read(habitRepositoryProvider);
    await habitRepo.checkDailyReset();
  }
}
