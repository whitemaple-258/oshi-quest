import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers.dart'; // databaseProviderへのアクセス用
import '../../ui/screens/bulk_sell_screen.dart'; // 売却価格計算ロジック(共有用)

// ---------------------------------------------------------
// 定数・例外・Enum定義 (Repositoryに関連するもの)
// ---------------------------------------------------------

/// 画像登録上限数
const int kMaxUserImages = 20;

/// ガチャ抽選時の「全身タイツ君」の仮想チケット枚数
const int kTightsManTickets = 5;

/// 転生・整形のタイプ
enum ModificationType {
  reskin, // 整形 (画像のみ変更)
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
// Repository Provider
// ---------------------------------------------------------

final gachaItemRepositoryProvider = Provider<GachaItemRepository>((ref) {
  return GachaItemRepository(ref.watch(databaseProvider));
});

// ---------------------------------------------------------
// Repository Class
// ---------------------------------------------------------

class GachaItemRepository {
  final AppDatabase _db;
  final Random _random = Random();

  GachaItemRepository(this._db);

  // ========================================================================
  // 1. 画像プール管理
  // ========================================================================

  /// 画像プールに新しい画像を追加する
  /// 上限(20枚)を超えている場合は [ImageLimitExceededException] をスロー
  Future<void> addImageToPool(String path, String name) async {
    // 1. 現在の枚数をチェック
    final currentImages = await _db.select(_db.characterImages).get();

    // 2. 上限チェック
    if (currentImages.length >= kMaxUserImages) {
      throw ImageLimitExceededException();
    }

    // 3. 登録処理
    await _db
        .into(_db.characterImages)
        .insert(CharacterImagesCompanion.insert(imagePath: path, name: Value(name)));
  }

  // ========================================================================
  // 2. ガチャ実行ロジック
  // ========================================================================

  /// ガチャを指定回数引き、DBに保存して結果を返す
  /// ジェム不足の場合は Exception をスロー
  Future<List<GachaItem>> drawGacha(int times) async {
    // 1. ユーザー画像リストを取得
    final userImages = await _db.select(_db.characterImages).get();
    final List<GachaItemsCompanion> newItems = [];

    // --- 確率計算ロジック (変更点) ---
    // 現在の登録数に基づいて、タイツ君が出る確率(0.0 ~ 1.0)を決定する
    double tightsProbability;

    if (userImages.isEmpty) {
      // 画像がなければ100%タイツ君
      tightsProbability = 1.0;
    } else {
      // 最大登録数(kMaxUserImages)のときに10%になるように減少させる
      // 減少幅 = (100% - 10%) / 最大数
      final double decreasePerImage = 0.9 / kMaxUserImages;

      // 確率 = 100% - (減少幅 * 現在の枚数)
      double calculated = 1.0 - (decreasePerImage * userImages.length);

      // 下限を10%(0.1)に固定
      tightsProbability = max(0.1, calculated);
    }

    for (int i = 0; i < times; i++) {
      // A. レアリティ抽選
      final rarity = _rollRarity();

      // B. キャラクタースキン(中身)の抽選
      String? selectedImagePath;
      String selectedName;
      GachaItemType selectedType;
      TightsColor selectedColor;

      // 0.0〜1.0の乱数を生成し、タイツ確率未満ならタイツ君
      bool isTightsMan = _random.nextDouble() < tightsProbability;

      // ※万が一ユーザー画像がない場合は強制的にタイツ君にする
      if (userImages.isEmpty) isTightsMan = true;

      if (isTightsMan) {
        // --- 全身タイツ君当選 ---
        selectedImagePath = null;
        selectedName = "全身タイツ君";
        selectedType = GachaItemType.tightsMan;

        switch (rarity) {
          case Rarity.n:
            selectedColor = TightsColor.gray;
            break;
          case Rarity.r:
            selectedColor = TightsColor.blue;
            break;
          case Rarity.sr:
            selectedColor = TightsColor.purple;
            break;
          case Rarity.ssr:
            selectedColor = TightsColor.gold;
            break;
        }
      } else {
        // --- ユーザー画像当選 ---
        // ユーザー画像リストからランダムに1つ選ぶ
        final image = userImages[_random.nextInt(userImages.length)];
        selectedImagePath = image.imagePath;
        selectedName = image.name;
        selectedType = GachaItemType.userImage;
        selectedColor = TightsColor.none;
      }

      // C. アイテム生成
      final newItem = _generateRandomAttributes(
        imagePath: selectedImagePath,
        name: selectedName,
        rarity: rarity,
        type: selectedType,
        tightsColor: selectedColor,
      );
      newItems.add(newItem);
    }

    // 3. DBトランザクション (ジェム消費 & 保存)
    final List<GachaItem> results = [];

    await _db.transaction(() async {
      final cost = times * 100;
      final player = await (_db.select(_db.players)..limit(1)).getSingle();

      if (player.willGems < cost) {
        throw Exception('ジェムが足りません');
      }

      // ジェム消費
      await (_db.update(_db.players)..where((p) => p.id.equals(player.id))).write(
        PlayersCompanion(willGems: Value(player.willGems - cost)),
      );

      // アイテム保存
      for (var companion in newItems) {
        final id = await _db.into(_db.gachaItems).insert(companion);
        final item = await (_db.select(
          _db.gachaItems,
        )..where((tbl) => tbl.id.equals(id))).getSingle();
        results.add(item);
      }
    });

    return results;
  }

  // ========================================================================
  // 3. 整形・転生ロジック
  // ========================================================================

  int getModificationCost(Rarity rarity, ModificationType type) {
    int baseCost;
    switch (rarity) {
      case Rarity.n:
        baseCost = 100;
        break;
      case Rarity.r:
        baseCost = 300;
        break;
      case Rarity.sr:
        baseCost = 1000;
        break;
      case Rarity.ssr:
        baseCost = 3000;
        break;
    }
    return type == ModificationType.reincarnation ? baseCost * 2 : baseCost;
  }

  /// 整形 (画像差し替え)
  Future<void> reskinCharacter(GachaItem item, String newImagePath) async {
    final cost = getModificationCost(item.rarity, ModificationType.reskin);

    await _db.transaction(() async {
      final player = await (_db.select(_db.players)..limit(1)).getSingle();
      if (player.willGems < cost) throw Exception('ジェムが足りません');

      // 消費
      await (_db.update(_db.players)..where((p) => p.id.equals(player.id))).write(
        PlayersCompanion(willGems: Value(player.willGems - cost)),
      );

      // 更新: ユーザー画像型へ変更
      await (_db.update(_db.gachaItems)..where((t) => t.id.equals(item.id))).write(
        GachaItemsCompanion(
          imagePath: Value(newImagePath),
          type: const Value(GachaItemType.userImage),
          tightsColor: const Value(TightsColor.none),
        ),
      );
    });
  }

  /// 転生 (画像変更 + ステータス再抽選)
  Future<void> reincarnateCharacter(GachaItem item, String newImagePath) async {
    final cost = getModificationCost(item.rarity, ModificationType.reincarnation);
    final newStats = _generateStats(item.rarity); // ステータス再生成

    await _db.transaction(() async {
      final player = await (_db.select(_db.players)..limit(1)).getSingle();
      if (player.willGems < cost) throw Exception('ジェムが足りません');

      // 消費
      await (_db.update(_db.players)..where((p) => p.id.equals(player.id))).write(
        PlayersCompanion(willGems: Value(player.willGems - cost)),
      );

      // 更新: ユーザー画像型へ変更 + ステータス更新
      await (_db.update(_db.gachaItems)..where((t) => t.id.equals(item.id))).write(
        GachaItemsCompanion(
          imagePath: Value(newImagePath),
          type: const Value(GachaItemType.userImage),
          tightsColor: const Value(TightsColor.none),
          strBonus: Value(newStats['str']!),
          intBonus: Value(newStats['int']!),
          luckBonus: Value(newStats['luck']!),
          chaBonus: Value(newStats['cha']!),
          vitBonus: Value(newStats['vit']!),
        ),
      );
    });
  }

  // ========================================================================
  // 4. インベントリ操作 (売却・お気に入り)
  // ========================================================================

  /// 単体売却
  Future<bool> sellItem(GachaItem item) async {
    if (await _isEquipped(item.id)) return false;

    final price = BulkSellScreen.getSellPrice(item.rarity);

    await _db.transaction(() async {
      await (_db.delete(_db.gachaItems)..where((t) => t.id.equals(item.id))).go();
      final player = await (_db.select(_db.players)..limit(1)).getSingle();
      await (_db.update(_db.players)..where((p) => p.id.equals(player.id))).write(
        PlayersCompanion(willGems: Value(player.willGems + price)),
      );
    });
    return true;
  }

  /// 一括売却
  Future<void> sellItems(List<int> ids) async {
    if (ids.isEmpty) return;

    await _db.transaction(() async {
      int totalGain = 0;
      for (var id in ids) {
        final item = await (_db.select(
          _db.gachaItems,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (item == null) continue;
        if (await _isEquipped(id)) continue;

        totalGain += BulkSellScreen.getSellPrice(item.rarity);
        await (_db.delete(_db.gachaItems)..where((t) => t.id.equals(id))).go();
      }

      if (totalGain > 0) {
        final player = await (_db.select(_db.players)..limit(1)).getSingle();
        await (_db.update(_db.players)..where((p) => p.id.equals(player.id))).write(
          PlayersCompanion(willGems: Value(player.willGems + totalGain)),
        );
      }
    });
  }

  /// お気に入り切り替え
  Future<void> toggleFavorite(int itemId) async {
    final item = await (_db.select(_db.gachaItems)..where((t) => t.id.equals(itemId))).getSingle();
    await (_db.update(_db.gachaItems)..where((t) => t.id.equals(itemId))).write(
      GachaItemsCompanion(isFavorite: Value(!item.isFavorite)),
    );
  }

  // ========================================================================
  // 5. 内部ヘルパー (Private)
  // ========================================================================

  Future<bool> _isEquipped(int itemId) async {
    final count = await (_db.select(
      _db.partyMembers,
    )..where((t) => t.gachaItemId.equals(itemId))).get();
    return count.isNotEmpty;
  }

  Rarity _rollRarity() {
    final rand = _random.nextDouble();
    if (rand < 0.03) return Rarity.ssr;
    if (rand < 0.15) return Rarity.sr;
    if (rand < 0.45) return Rarity.r;
    return Rarity.n;
  }

  Map<String, int> _generateStats(Rarity rarity) {
    int baseStat = 0;
    int statSpread = 0;

    switch (rarity) {
      case Rarity.n:
        baseStat = 2;
        statSpread = 3;
        break;
      case Rarity.r:
        baseStat = 5;
        statSpread = 5;
        break;
      case Rarity.sr:
        baseStat = 12;
        statSpread = 8;
        break;
      case Rarity.ssr:
        baseStat = 25;
        statSpread = 15;
        break;
    }

    return {
      'str': baseStat + _random.nextInt(statSpread),
      'int': baseStat + _random.nextInt(statSpread),
      'luck': baseStat + _random.nextInt(statSpread),
      'cha': baseStat + _random.nextInt(statSpread),
      'vit': baseStat + _random.nextInt(statSpread),
    };
  }

  GachaItemsCompanion _generateRandomAttributes({
    required String? imagePath,
    required String name,
    required Rarity rarity,
    required GachaItemType type,
    required TightsColor tightsColor,
  }) {
    final stats = _generateStats(rarity);

    // エフェクト生成
    EffectType effect = EffectType.none;
    if (rarity == Rarity.ssr) {
      effect = _randomChoice([
        EffectType.lightning,
        EffectType.snow,
        EffectType.ember,
        EffectType.cherry,
      ]);
    } else if (rarity == Rarity.sr) {
      if (_random.nextBool())
        effect = _randomChoice([EffectType.ember, EffectType.bubble, EffectType.cherry]);
    } else if (rarity == Rarity.r) {
      if (_random.nextDouble() < 0.3) effect = _randomChoice([EffectType.rain, EffectType.bubble]);
    }

    // スキル生成
    SkillType skill = SkillType.none;
    int skillVal = 0;
    bool hasSkill =
        (rarity == Rarity.ssr) ||
        (rarity == Rarity.sr && _random.nextDouble() < 0.7) ||
        (rarity == Rarity.r && _random.nextDouble() < 0.2);

    if (hasSkill) {
      skill = SkillType.values[_random.nextInt(SkillType.values.length - 1) + 1];
      skillVal = (rarity.index + 1) * 5 + _random.nextInt(10);
    }

    // シリーズ生成
    SeriesType series = SeriesType.none;
    if (_random.nextDouble() < 0.4) {
      series = SeriesType.values[_random.nextInt(SeriesType.values.length - 1) + 1];
    }

    return GachaItemsCompanion.insert(
      imagePath: Value(imagePath),
      title: name,
      rarity: rarity,
      type: Value(type),
      tightsColor: Value(tightsColor),

      effectType: effect,
      skillType: Value(skill),
      skillValue: Value(skillVal),
      seriesId: Value(series),

      strBonus: Value(stats['str']!),
      intBonus: Value(stats['int']!),
      luckBonus: Value(stats['luck']!),
      chaBonus: Value(stats['cha']!),
      vitBonus: Value(stats['vit']!),

      isUnlocked: const Value(true),
      isFavorite: const Value(false),
    );
  }

  T _randomChoice<T>(List<T> options) {
    return options[_random.nextInt(options.length)];
  }
}
