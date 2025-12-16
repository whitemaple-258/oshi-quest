import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/database/database.dart';
import '../data/providers.dart';
import '../ui/screens/bulk_sell_screen.dart'; // 売却価格計算に使用

// ---------------------------------------------------------
// 定数・例外・Enum定義
// ---------------------------------------------------------

/// 画像登録上限数
const int kMaxUserImages = 20;

/// ガチャ抽選時の「全身タイツ君」の仮想チケット枚数
const int kTightsManTickets = 5;

/// 転生・整形のタイプ
enum ModificationType {
  reskin,        // 整形 (画像のみ変更)
  reincarnation, // 転生 (画像変更 + ステータス再抽選)
}

/// 画像登録上限エラー
class ImageLimitExceededException implements Exception {
  final String message;
  ImageLimitExceededException([this.message = '登録できる画像は$kMaxUserImages枚までです。']);
  @override
  String toString() => message;
}

// ---------------------------------------------------------
// Controller Provider
// ---------------------------------------------------------

final gachaControllerProvider = StateNotifierProvider<GachaController, AsyncValue<List<GachaItem>>>(
  (ref) => GachaController(ref),
);

// ---------------------------------------------------------
// GachaController 本体
// ---------------------------------------------------------

class GachaController extends StateNotifier<AsyncValue<List<GachaItem>>> {
  final Ref _ref;
  final Random _random = Random();

  GachaController(this._ref) : super(const AsyncValue.data([]));

  // ========================================================================
  // 1. 画像プール管理 (登録・上限チェック)
  // ========================================================================

  /// 画像プールに新しい画像を追加する
  Future<void> addImageToPool(String path, String name) async {
    final db = _ref.read(databaseProvider);

    // 1. 現在の枚数をチェック
    final currentImages = await db.select(db.characterImages).get();
    
    // 2. 上限チェック
    if (currentImages.length >= kMaxUserImages) {
      throw ImageLimitExceededException();
    }

    // 3. 登録処理
    await db.into(db.characterImages).insert(
      CharacterImagesCompanion.insert(
        imagePath: path,
        name: drift.Value(name),
      ),
    );
  }

  // ========================================================================
  // 2. ガチャ実行ロジック (タイツ君対応)
  // ========================================================================

  Future<List<GachaItem>> drawGacha(int times) async {
    state = const AsyncValue.loading();
    final db = _ref.read(databaseProvider);

    try {
      // 1. ユーザー画像プールを取得
      final userImages = await db.select(db.characterImages).get();

      // プール総数 = ユーザー画像数 + タイツ君チケット数
      // (ユーザー画像が0枚でもタイツ君が出るようにする)
      final int totalPoolSize = userImages.length + kTightsManTickets;

      final List<GachaItemsCompanion> newItems = [];

      for (int i = 0; i < times; i++) {
        // A. レアリティ抽選
        final rarity = _rollRarity();

        // B. スキン(中身)の抽選
        final int ticketIndex = _random.nextInt(totalPoolSize);

        String? selectedImagePath;
        String selectedName;
        GachaItemType selectedType;
        TightsColor selectedColor;

        if (ticketIndex < userImages.length) {
          // --- ユーザー画像当選 ---
          final image = userImages[ticketIndex];
          selectedImagePath = image.imagePath;
          selectedName = image.name;
          selectedType = GachaItemType.userImage;
          selectedColor = TightsColor.none;
        } else {
          // --- 全身タイツ君当選 ---
          selectedImagePath = null; // 画像パスなし(アセット使用)
          selectedName = "全身タイツ君";
          selectedType = GachaItemType.tightsMan;
          
          // レアリティに応じた色決定
          switch (rarity) {
            case Rarity.n:   selectedColor = TightsColor.gray; break;
            case Rarity.r:   selectedColor = TightsColor.blue; break;
            case Rarity.sr:  selectedColor = TightsColor.purple; break;
            case Rarity.ssr: selectedColor = TightsColor.gold; break;
          }
        }

        // C. ステータス・属性生成
        final newItem = _generateRandomAttributes(
          imagePath: selectedImagePath,
          name: selectedName,
          rarity: rarity,
          type: selectedType,
          tightsColor: selectedColor,
        );
        newItems.add(newItem);
      }

      // 3. DB保存 & ジェム消費
      final List<GachaItem> results = [];
      await db.transaction(() async {
        final cost = times * 100;
        final player = await (db.select(db.players)..limit(1)).getSingle();
        
        if (player.willGems < cost) {
          throw Exception('ジェムが足りません');
        }
        
        // ジェム消費
        await (db.update(db.players)..where((p) => p.id.equals(player.id))).write(
          PlayersCompanion(willGems: drift.Value(player.willGems - cost)),
        );

        // アイテム保存
        for (var companion in newItems) {
          final id = await db.into(db.gachaItems).insert(companion);
          final item = await (db.select(db.gachaItems)..where((tbl) => tbl.id.equals(id))).getSingle();
          results.add(item);
        }
      });

      state = AsyncValue.data(results);
      return results;

    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // ========================================================================
  // 3. 整形・転生ロジック
  // ========================================================================

  /// 必要ジェムコスト計算
  int getModificationCost(Rarity rarity, ModificationType type) {
    int baseCost;
    switch (rarity) {
      case Rarity.n: baseCost = 100; break;
      case Rarity.r: baseCost = 300; break;
      case Rarity.sr: baseCost = 1000; break;
      case Rarity.ssr: baseCost = 3000; break;
    }
    // 転生は整形の2倍
    return type == ModificationType.reincarnation ? baseCost * 2 : baseCost;
  }

  /// 整形 (画像のみ変更)
  /// タイツ君からユーザー画像へ変更されるため、Typeも更新する
  Future<void> reskinCharacter(GachaItem item, String newImagePath) async {
    final db = _ref.read(databaseProvider);
    final cost = getModificationCost(item.rarity, ModificationType.reskin);

    await db.transaction(() async {
      // ジェム確認・消費
      final player = await (db.select(db.players)..limit(1)).getSingle();
      if (player.willGems < cost) throw Exception('ジェムが足りません');
      
      await (db.update(db.players)..where((p) => p.id.equals(player.id))).write(
        PlayersCompanion(willGems: drift.Value(player.willGems - cost)),
      );

      // データ更新
      await (db.update(db.gachaItems)..where((t) => t.id.equals(item.id))).write(
        GachaItemsCompanion(
          imagePath: drift.Value(newImagePath),
          type: const drift.Value(GachaItemType.userImage), // ユーザー画像型へ変更
          tightsColor: const drift.Value(TightsColor.none), // 色情報リセット
        ),
      );
    });
  }

  /// 転生 (画像変更 + ステータス再抽選)
  /// スキル・エフェクトは維持し、ステータスのみ再生成
  Future<void> reincarnateCharacter(GachaItem item, String newImagePath) async {
    final db = _ref.read(databaseProvider);
    final cost = getModificationCost(item.rarity, ModificationType.reincarnation);

    // 新しいステータスを生成
    final newStats = _generateStats(item.rarity);

    await db.transaction(() async {
      // ジェム確認・消費
      final player = await (db.select(db.players)..limit(1)).getSingle();
      if (player.willGems < cost) throw Exception('ジェムが足りません');

      await (db.update(db.players)..where((p) => p.id.equals(player.id))).write(
        PlayersCompanion(willGems: drift.Value(player.willGems - cost)),
      );

      // データ更新
      await (db.update(db.gachaItems)..where((t) => t.id.equals(item.id))).write(
        GachaItemsCompanion(
          imagePath: drift.Value(newImagePath),
          type: const drift.Value(GachaItemType.userImage), // ユーザー画像型へ変更
          tightsColor: const drift.Value(TightsColor.none),
          strBonus: drift.Value(newStats['str']!),
          intBonus: drift.Value(newStats['int']!),
          luckBonus: drift.Value(newStats['luck']!),
          chaBonus: drift.Value(newStats['cha']!),
          vitBonus: drift.Value(newStats['vit']!),
        ),
      );
    });
  }

  // ========================================================================
  // 4. インベントリ管理 (売却・お気に入り)
  // ========================================================================

  /// 単体売却
  Future<bool> sellItem(GachaItem item) async {
    final db = _ref.read(databaseProvider);
    final isEquipped = await _isEquipped(item.id);
    if (isEquipped) return false;

    final price = BulkSellScreen.getSellPrice(item.rarity);

    await db.transaction(() async {
      await (db.delete(db.gachaItems)..where((t) => t.id.equals(item.id))).go();
      final player = await (db.select(db.players)..limit(1)).getSingle();
      await (db.update(db.players)..where((p) => p.id.equals(player.id))).write(
        PlayersCompanion(willGems: drift.Value(player.willGems + price)),
      );
    });
    return true;
  }

  /// 一括売却
  Future<void> sellItems(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = _ref.read(databaseProvider);

    await db.transaction(() async {
      int totalGain = 0;
      for (var id in ids) {
        final item = await (db.select(db.gachaItems)..where((t) => t.id.equals(id))).getSingleOrNull();
        if (item == null) continue;
        if (await _isEquipped(id)) continue;

        totalGain += BulkSellScreen.getSellPrice(item.rarity);
        await (db.delete(db.gachaItems)..where((t) => t.id.equals(id))).go();
      }

      if (totalGain > 0) {
        final player = await (db.select(db.players)..limit(1)).getSingle();
        await (db.update(db.players)..where((p) => p.id.equals(player.id))).write(
          PlayersCompanion(willGems: drift.Value(player.willGems + totalGain)),
        );
      }
    });
  }

  /// お気に入り切り替え
  Future<void> toggleFavorite(int itemId) async {
    final db = _ref.read(databaseProvider);
    final item = await (db.select(db.gachaItems)..where((t) => t.id.equals(itemId))).getSingle();
    await (db.update(db.gachaItems)..where((t) => t.id.equals(itemId))).write(
      GachaItemsCompanion(isFavorite: drift.Value(!item.isFavorite)),
    );
  }

  // ========================================================================
  // 5. 内部ヘルパーメソッド
  // ========================================================================

  Future<bool> _isEquipped(int itemId) async {
    final db = _ref.read(databaseProvider);
    final count = await (db.select(db.partyMembers)..where((t) => t.gachaItemId.equals(itemId))).get();
    return count.isNotEmpty;
  }

  /// レアリティ抽選
  Rarity _rollRarity() {
    final rand = _random.nextDouble();
    if (rand < 0.03) return Rarity.ssr; // 3%
    if (rand < 0.15) return Rarity.sr;  // 12%
    if (rand < 0.45) return Rarity.r;   // 30%
    return Rarity.n;                    // 55%
  }

  /// ステータス値の生成
  Map<String, int> _generateStats(Rarity rarity) {
    int baseStat = 0;
    int statSpread = 0;

    switch (rarity) {
      case Rarity.n:   baseStat = 2;  statSpread = 3; break;
      case Rarity.r:   baseStat = 5;  statSpread = 5; break;
      case Rarity.sr:  baseStat = 12; statSpread = 8; break;
      case Rarity.ssr: baseStat = 25; statSpread = 15; break;
    }

    return {
      'str': baseStat + _random.nextInt(statSpread),
      'int': baseStat + _random.nextInt(statSpread),
      'luck': baseStat + _random.nextInt(statSpread),
      'cha': baseStat + _random.nextInt(statSpread),
      'vit': baseStat + _random.nextInt(statSpread),
    };
  }

  /// ガチャアイテムデータの生成
  GachaItemsCompanion _generateRandomAttributes({
    required String? imagePath,
    required String name,
    required Rarity rarity,
    required GachaItemType type,
    required TightsColor tightsColor,
  }) {
    // 1. ステータス生成
    final stats = _generateStats(rarity);

    // 2. エフェクト生成
    EffectType effect = EffectType.none;
    if (rarity == Rarity.ssr) {
      effect = _randomChoice([EffectType.lightning, EffectType.snow, EffectType.ember, EffectType.cherry]);
    } else if (rarity == Rarity.sr) {
      if (_random.nextBool()) effect = _randomChoice([EffectType.ember, EffectType.bubble, EffectType.cherry]);
    } else if (rarity == Rarity.r) {
      if (_random.nextDouble() < 0.3) effect = _randomChoice([EffectType.rain, EffectType.bubble]);
    }

    // 3. スキル生成
    SkillType skill = SkillType.none;
    int skillVal = 0;
    bool hasSkill = (rarity == Rarity.ssr) || 
                    (rarity == Rarity.sr && _random.nextDouble() < 0.7) || 
                    (rarity == Rarity.r && _random.nextDouble() < 0.2);

    if (hasSkill) {
      skill = SkillType.values[_random.nextInt(SkillType.values.length - 1) + 1];
      skillVal = (rarity.index + 1) * 5 + _random.nextInt(10);
    }

    // 4. シリーズ生成
    SeriesType series = SeriesType.none;
    if (_random.nextDouble() < 0.4) {
      series = SeriesType.values[_random.nextInt(SeriesType.values.length - 1) + 1];
    }

    return GachaItemsCompanion.insert(
      imagePath: drift.Value(imagePath), // Nullable
      title: name,
      rarity: rarity,
      type: drift.Value(type),           // ユーザー画像 or タイツ君
      tightsColor: drift.Value(tightsColor),
      
      effectType: effect,
      skillType: drift.Value(skill),
      skillValue: drift.Value(skillVal),
      seriesId: drift.Value(series),
      
      strBonus: drift.Value(stats['str']!),
      intBonus: drift.Value(stats['int']!),
      luckBonus: drift.Value(stats['luck']!),
      chaBonus: drift.Value(stats['cha']!),
      vitBonus: drift.Value(stats['vit']!),
      
      isUnlocked: const drift.Value(true),
      isFavorite: const drift.Value(false),
    );
  }

  T _randomChoice<T>(List<T> options) {
    return options[_random.nextInt(options.length)];
  }
}