import 'package:drift/drift.dart';
import 'package:oshi_quest/data/repositories/habit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/database.dart'; // Enums, Tables
import '../data/providers.dart' as app_providers; // databaseProvider, habitRepositoryProvider
import '../data/repositories/gacha_item_repository.dart';
import '../data/master_data/gacha_logic_master.dart'; // GachaItemRepository, gachaItemRepositoryProvider

part 'debug_controller.g.dart';

@riverpod
class DebugController extends _$DebugController {
  @override
  void build() {}

  // リポジトリとDBへの参照
  late final AppDatabase _db = ref.read(app_providers.databaseProvider);
  late final GachaItemRepository _gachaRepo = ref.read(app_providers.gachaItemRepositoryProvider);
  late final HabitRepository _habitRepo = ref.read(app_providers.habitRepositoryProvider);

  // ========================================================================
  // 1. プレイヤーリソース/ステータス操作
  // ========================================================================

  /// ジェムを増加させる
  Future<void> addGems(int amount) async {
    final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

    await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
      PlayersCompanion(willGems: Value(player.willGems + amount)),
    );
  }

  /// 経験値を増加させる（レベルも再計算）
  Future<void> addExp(int amount) async {
    final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

    final newExp = player.experience + amount;
    // 経験値からレベルを計算するロジック（例: 100XPごとにレベルアップ）
    final newLevel = (newExp ~/ 100) + 1;

    await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
      PlayersCompanion(experience: Value(newExp), level: Value(newLevel)),
    );
  }

  /// プレイヤーの全基本ステータスを一括増加させる
  Future<void> addAllStats(int amount) async {
    final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

    await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
      PlayersCompanion(
        str: Value(player.str + amount),
        intellect: Value(player.intellect + amount),
        vit: Value(player.vit + amount),
        luck: Value(player.luck + amount),
        cha: Value(player.cha + amount),
      ),
    );
  }

  // ========================================================================
  // 2. 状態・リセット関連
  // ========================================================================

  /// ステータスを全回復（デバフ解除）
  Future<void> clearDebuff() async {
    await (_db.update(
      _db.players,
    )..where((p) => p.id.equals(1))).write(const PlayersCompanion(currentDebuff: Value(null)));
    // 禊クエストも削除
    await (_db.delete(_db.habits)..where((h) => h.name.equals('【禊】女神の許しを請う'))).go();
  }

  /// 強制的に「翌日になった」ことにする（サボり判定テスト用）
  Future<void> forceDailyReset() async {
    // 1. 最終ログイン日時を「昨日」に書き換え
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await (_db.update(
      _db.players,
    )..where((p) => p.id.equals(1))).write(PlayersCompanion(lastLoginAt: Value(yesterday)));

    // 2. HabitRepositoryのチェック処理を呼び出す
    await _habitRepo.checkDailyReset();
  }

  // ========================================================================
  // 3. ガチャアイテム関連
  // ========================================================================

  /// 指定したレアリティのアイテムを強制的に10枚追加する
  Future<void> addGachaItemsByRarity(Rarity rarity) async {
    // リポジトリの生成ロジックを利用してCompanionを作成し、DBに挿入する
    final List<GachaItemsCompanion> companions = [];

    for (int i = 0; i < 10; i++) {
      // NOTE: リポジトリのcreateNewItemCompanionメソッドは、ガチャコントローラーと同じロジックで
      // 必須パラメータやスキル/エフェクトを生成します。
      final companion = GachaLogicMaster.generateItemCompanion(
        imagePath: null, // デバッグ用なので画像なし（タイツ君）
        name: 'デバッグ用 ${rarity.name.toUpperCase()}カード $i',
        rarity: rarity,
        type: GachaItemType.tightsMan,
        tightsColor: TightsColor.gold, // デバッグ用は常にゴールドタイツ
      );
      companions.add(companion);
    }

    await _db.batch((batch) {
      batch.insertAll(_db.gachaItems, companions);
    });
  }

  /// 全ての装備を強制解除し、アイテムロックを解除する
  Future<void> clearEquipmentsAndLocks() async {
    // 1. 全てのPartyMembersを削除 (装備解除)
    await _db.delete(_db.partyMembers).go();

    // 2. 全てのGachaItemsのロックを解除
    await _db.update(_db.gachaItems).write(const GachaItemsCompanion(isLocked: Value(false)));
  }

  /// 特定のアイテムのエフェクトを強制的に更新する (デバッグ用)
  Future<void> updateGachaItemEffect(int itemId, EffectType newEffect) async {
    await _db.transaction(() async {
      final item = await _gachaRepo.getItemById(itemId);

      // リポジトリのupdateGachaItemメソッドを呼び出す
      await _gachaRepo.updateGachaItem(
        itemId,
        GachaItemsCompanion(
          // --- 更新フィールド ---
          effectType: Value(newEffect),

          // --- 必須フィールドの充足 (Value()ラッパーを使用) ---
          title: Value(item.title),
          rarity: Value(item.rarity),
          type: Value(item.type),
          tightsColor: Value(item.tightsColor),
          parameterType: Value(item.parameterType),
          skillType: Value(item.skillType),
          seriesType: Value(item.seriesType),
          createdAt: Value(item.createdAt),
          skillDuration: Value(item.skillDuration),
          skillCooldown: Value(item.skillCooldown),
          intimacyLevel: Value(item.intimacyLevel),
          intimacyExp: Value(item.intimacyExp),
        ),
      );
    });
  }
}
