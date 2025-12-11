import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/database.dart';
import '../master_data/gacha_logic_master.dart';
import '../master_data/frame_master_data.dart';

class GachaItemRepository {
  final AppDatabase _db;
  final ImagePicker _imagePicker = ImagePicker();
  final Random _random = Random();

  GachaItemRepository(this._db);

  // --- ヘルパー: 画像トリミング ---
  Future<String?> _cropImage(String sourcePath) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
      compressQuality: 100, // 最高画質
      compressFormat: ImageCompressFormat.png, // 透過維持
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '画像を編集',
          toolbarColor: Colors.pinkAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: '画像を編集', aspectRatioLockEnabled: true, resetAspectRatioEnabled: false),
      ],
    );
    return croppedFile?.path;
  }

  // --- 1. マスターデータからフレームを一括登録 ---
  Future<void> seedFramesFromMasterData() async {
    for (final def in defaultFrames) {
      final exists =
          await (_db.select(_db.gachaItems)
                ..where((t) => t.title.equals(def.title))
                ..where((t) => t.type.equals(GachaItemType.frame.index))
                ..where((t) => t.isSource.equals(true)))
              .getSingleOrNull();

      if (exists != null) continue;

      try {
        final ByteData data = await rootBundle.load(def.assetPath);
        final Uint8List bytes = data.buffer.asUint8List();

        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory(p.join(appDir.path, 'oshi_images'));
        if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

        final filename = p.basename(def.assetPath);
        final newPath = p.join(imagesDir.path, 'seeded_$filename');
        final file = File(newPath);
        await file.writeAsBytes(bytes);

        await _db
            .into(_db.gachaItems)
            .insert(
              GachaItemsCompanion.insert(
                imagePath: newPath,
                title: def.title,
                type: const Value(GachaItemType.frame),
                rarity: Value(def.rarity),
                isUnlocked: const Value(false),
                isSource: const Value(true),
                sourceId: const Value(null),
                strBonus: Value(def.strBonus),
                intBonus: Value(def.intBonus),
                vitBonus: Value(def.vitBonus),
                luckBonus: Value(def.luckBonus),
                chaBonus: Value(def.chaBonus),
                bondLevel: const Value(0),
              ),
            );
      } catch (e) {
        print('❌ フレーム登録失敗 (${def.title}): $e');
      }
    }
  }

  // --- 2. 画像登録 (元ネタ作成) ---
  Future<int?> pickAndSaveItem(
    String title, {
    GachaItemType type = GachaItemType.character,
    Rarity rarity = Rarity.n,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // 画質優先
      );
      if (pickedFile == null) return null;

      final croppedPath = await _cropImage(pickedFile.path);
      if (croppedPath == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'oshi_images'));
      if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = p.extension(pickedFile.path);
      final newFileName = '${timestamp}_cropped$extension';
      final newPath = p.join(imagesDir.path, newFileName);

      await File(croppedPath).copy(newPath);

      final companion = GachaItemsCompanion.insert(
        imagePath: newPath,
        title: title,
        type: Value(type),
        rarity: Value(rarity),
        isUnlocked: const Value(false),
        isSource: const Value(true), // 元ネタ
        sourceId: const Value(null),
        strBonus: const Value(0),
        intBonus: const Value(0),
        vitBonus: const Value(0),
        luckBonus: const Value(0),
        chaBonus: const Value(0),
        bondLevel: const Value(0),
      );

      return await _db.into(_db.gachaItems).insert(companion);
    } catch (e) {
      print('❌ 画像保存エラー: $e');
      return null;
    }
  }

  // --- 3. ガチャ実行 (個体生成・完全版) ---
  Future<GachaItem> pullGacha(int gemCost) async {
    return await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();
      if (player.willGems < gemCost) throw Exception('ジェムが足りません');

      // 1. 元ネタ(isSource=true)を取得
      final candidates = await (_db.select(
        _db.gachaItems,
      )..where((t) => t.isSource.equals(true))).get();

      if (candidates.isEmpty) throw Exception('ガチャから出る推しがいません！\nまずは画像を登録してください。');

      // ✅ LUCKによるレアリティ補正計算
      // LUCK 1000で SSR/SR の重みが 2倍 になる
      final luckFactor = 1.0 + (player.luck / 1000.0);

      // 抽選ロジック (重み付け抽選)
      GachaItem? sourceItem;
      double rarityTotalWeight = 0;
      final weights = <GachaItem, double>{};

      for (var item in candidates) {
        double weight = 100.0; // Nの基本重み
        if (item.rarity == Rarity.r) weight = 30.0;
        if (item.rarity == Rarity.sr) weight = 10.0 * luckFactor; // LUCK補正
        if (item.rarity == Rarity.ssr) weight = 3.0 * luckFactor; // LUCK補正

        weights[item] = weight;
        rarityTotalWeight += weight;
      }

      double randomPoint = _random.nextDouble() * rarityTotalWeight;
      for (var item in candidates) {
        if (randomPoint < weights[item]!) {
          sourceItem = item;
          break;
        }
        randomPoint -= weights[item]!;
      }

      // フォールバック（計算誤差対策）
      sourceItem ??= candidates.last;

      final now = DateTime.now();

      // ジェム消費
      await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
        PlayersCompanion(willGems: Value(player.willGems - gemCost), updatedAt: Value(now)),
      );

      // 2. パラメータ自動生成 (ハクスラ要素)
      // レアリティごとの設定を取得
      final setting = raritySettings[sourceItem.rarity] ?? raritySettings[Rarity.n]!;

      // ステータス生成
      final template = statTemplates[_random.nextInt(statTemplates.length)];
      // 合計値を設定範囲内でランダム決定
      final totalPoints =
          setting.minTotalStatus +
          _random.nextInt(setting.maxTotalStatus - setting.minTotalStatus + 1);

      final totalWeight =
          template.strWeight +
          template.intWeight +
          template.vitWeight +
          template.luckWeight +
          template.chaWeight;

      int str = (totalPoints * (template.strWeight / totalWeight)).round();
      int intellect = (totalPoints * (template.intWeight / totalWeight)).round();
      int vit = (totalPoints * (template.vitWeight / totalWeight)).round();
      int luck = (totalPoints * (template.luckWeight / totalWeight)).round();
      int cha = totalPoints - (str + intellect + vit + luck);
      if (cha < 0) cha = 0;

      // スキル抽選
      SkillType skillType = SkillType.none;
      int skillVal = 0;
      int cooldown = 0;
      int duration = 0;

      // レアリティごとの確率でスキルが付くか判定
      if (_random.nextDouble() < setting.skillProb) {
        // 確率に基づいてスキルを選択
        double totalSkillProb = 0;
        for (var def in skillDefinitions) totalSkillProb += def.probability;

        double skillRandom = _random.nextDouble() * totalSkillProb;
        for (final def in skillDefinitions) {
          if (skillRandom < def.probability) {
            skillType = def.type;
            // 効果値にレアリティ倍率を適用
            skillVal =
                ((def.minVal + _random.nextInt(def.maxVal - def.minVal + 1)) *
                        setting.skillPowerMult)
                    .round();
            duration =
                60 *
                (def.minDurationMinutes +
                    _random.nextInt(def.maxDurationMinutes - def.minDurationMinutes + 1));
            cooldown = duration * 2;
            break;
          }
          skillRandom -= def.probability;
        }
      }

      // シリーズ抽選
      SeriesType series = SeriesType.none;
      if (_random.nextDouble() < setting.seriesProb) {
        double totalSeriesProb = 0;
        for (var def in seriesDefinitions) totalSeriesProb += def.probability;

        double seriesRandom = _random.nextDouble() * totalSeriesProb;
        for (final def in seriesDefinitions) {
          if (seriesRandom < def.probability) {
            series = def.type;
            break;
          }
          seriesRandom -= def.probability;
        }
      }

      // 3. 新しい個体として登録 (isSource=false)
      final newItemCompanion = GachaItemsCompanion.insert(
        imagePath: sourceItem.imagePath,
        title: sourceItem.title,
        type: Value(sourceItem.type),
        rarity: Value(sourceItem.rarity),
        isUnlocked: const Value(true),
        isSource: const Value(false),
        sourceId: Value(sourceItem.id),

        strBonus: Value(str),
        intBonus: Value(intellect),
        vitBonus: Value(vit),
        luckBonus: Value(luck),
        chaBonus: Value(cha),
        bondLevel: const Value(1), // 初期レベル1

        skillType: Value(skillType),
        skillValue: Value(skillVal),
        skillDuration: Value(duration),
        skillCooldown: Value(cooldown),
        seriesId: Value(series),

        createdAt: Value(now),
      );

      final newId = await _db.into(_db.gachaItems).insert(newItemCompanion);
      return await (_db.select(_db.gachaItems)..where((t) => t.id.equals(newId))).getSingle();
    });
  }

  // --- 4. 売却 ---
  Future<void> sellItem(int itemId, int price) async {
    return await _db.transaction(() async {
      final isEquippedChar = await (_db.select(
        _db.partyMembers,
      )..where((t) => t.gachaItemId.equals(itemId))).get().then((l) => l.isNotEmpty);
      final isEquippedFrame = await (_db.select(
        _db.partyDecks,
      )..where((t) => t.equippedFrameId.equals(itemId))).get().then((l) => l.isNotEmpty);
      if (isEquippedChar || isEquippedFrame) throw Exception('このアイテムは装備中のため売却できません。');

      final item = await (_db.select(
        _db.gachaItems,
      )..where((t) => t.id.equals(itemId))).getSingleOrNull();
      if (item == null) throw Exception('アイテムが見つかりません');
      if (item.isSource) throw Exception('元データは売却できません');

      await (_db.delete(_db.gachaItems)..where((t) => t.id.equals(itemId))).go();
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();
      await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
        PlayersCompanion(willGems: Value(player.willGems + price)),
      );
    });
  }

  // --- 5. 削除 (元ネタ削除) ---
  Future<void> deleteItem(int id) async {
    final item = await (_db.select(
      _db.gachaItems,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (item != null) {
      if (item.isSource) {
        final file = File(item.imagePath);
        if (await file.exists()) await file.delete();
      }
      await (_db.delete(_db.partyMembers)..where((t) => t.gachaItemId.equals(id))).go();
      await (_db.update(_db.partyDecks)..where((t) => t.equippedFrameId.equals(id))).write(
        const PartyDecksCompanion(equippedFrameId: Value(null)),
      );
      await (_db.delete(_db.gachaItems)..where((t) => t.id.equals(id))).go();
    }
  }

  Future<void> updateItem(int id, String newTitle, {bool reCropImage = false}) async {
    final item = await (_db.select(_db.gachaItems)..where((t) => t.id.equals(id))).getSingle();
    if (reCropImage) {
      final croppedPath = await _cropImage(item.imagePath);
      if (croppedPath != null) {
        final File oldFile = File(item.imagePath);
        if (await oldFile.exists()) await File(croppedPath).copy(item.imagePath);
      }
    }
    await (_db.update(
      _db.gachaItems,
    )..where((t) => t.id.equals(id))).write(GachaItemsCompanion(title: Value(newTitle)));
  }

  // --- 読み込み ---
  Stream<List<GachaItem>> watchMyItems() {
    return (_db.select(_db.gachaItems)
          ..where((t) => t.isSource.equals(false))
          ..orderBy([(item) => OrderingTerm.desc(item.createdAt)]))
        .watch();
  }

  Stream<List<GachaItem>> watchLineupItems() {
    return (_db.select(_db.gachaItems)
          ..where((t) => t.isSource.equals(true))
          ..orderBy([(item) => OrderingTerm.desc(item.createdAt)]))
        .watch();
  }

  // 互換性維持
  Stream<List<GachaItem>> watchAllItems() => watchMyItems();
  Future<List<GachaItem>> getAllItems() async => await (_db.select(_db.gachaItems)).get();
  Future<void> unlockItem(int id) async {}
}
