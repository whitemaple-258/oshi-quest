import 'dart:io';
import 'dart:math';
import 'dart:typed_data'; // ✅ 追加
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // ✅ 追加
import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/database.dart';
import '../master_data/gacha_logic_master.dart';
import '../master_data/frame_master_data.dart'; // ✅ 追加

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

  // --- 1. マスターデータからフレームを一括登録 (Mainで呼ぶやつ) ---
  Future<void> seedFramesFromMasterData() async {
    for (final def in defaultFrames) {
      // 重複チェック
      final exists =
          await (_db.select(_db.gachaItems)
                ..where((t) => t.title.equals(def.title))
                ..where((t) => t.type.equals(GachaItemType.frame.index))
                ..where((t) => t.isSource.equals(true)))
              .getSingleOrNull();

      if (exists != null) continue;

      try {
        // アセット読み込み
        final ByteData data = await rootBundle.load(def.assetPath);
        final Uint8List bytes = data.buffer.asUint8List();

        // アプリ内保存
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory(p.join(appDir.path, 'oshi_images'));
        if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

        final filename = p.basename(def.assetPath);
        final newPath = p.join(imagesDir.path, 'seeded_$filename');
        final file = File(newPath);
        await file.writeAsBytes(bytes);

        // DB登録
        await _db
            .into(_db.gachaItems)
            .insert(
              GachaItemsCompanion.insert(
                imagePath: newPath,
                title: def.title,
                type: const Value(GachaItemType.frame),
                rarity: Value(def.rarity),
                isUnlocked: const Value(false),
                isSource: const Value(true), // 元ネタ
                sourceId: const Value(null),

                strBonus: Value(def.strBonus),
                intBonus: Value(def.intBonus),
                vitBonus: Value(def.vitBonus),
                luckBonus: Value(def.luckBonus),
                chaBonus: Value(def.chaBonus),

                bondLevel: const Value(0),
              ),
            );

        print('✅ フレーム登録: ${def.title}');
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
      final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
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

  // --- 3. ガチャ実行 (個体生成) ---
  Future<GachaItem> pullGacha(int gemCost) async {
    return await _db.transaction(() async {
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();
      if (player.willGems < gemCost) throw Exception('ジェムが足りません');

      // 元ネタから抽選
      final candidates = await (_db.select(
        _db.gachaItems,
      )..where((t) => t.isSource.equals(true))).get();

      if (candidates.isEmpty) throw Exception('ガチャから出る推しがいません！\nまずは画像を登録してください。');

      final random = Random();
      final sourceItem = candidates[random.nextInt(candidates.length)];
      final now = DateTime.now();

      await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
        PlayersCompanion(willGems: Value(player.willGems - gemCost), updatedAt: Value(now)),
      );

      // パラメータ生成 (MasterData)
      final template = statTemplates[_random.nextInt(statTemplates.length)];
      final totalPoints = 15 + _random.nextInt(11);
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

      SkillType skillType = SkillType.none;
      int skillVal = 0;
      int cooldown = 0;
      int duration = 0;
      for (final def in skillDefinitions) {
        if (_random.nextDouble() < def.probability) {
          skillType = def.type;
          skillVal = def.minVal + _random.nextInt(def.maxVal - def.minVal + 1);
          duration =
              60 *
              (def.minDurationMinutes +
                  _random.nextInt(def.maxDurationMinutes - def.minDurationMinutes + 1));
          cooldown = duration * 2;
          break;
        }
      }

      SeriesType series = SeriesType.none;
      for (final def in seriesDefinitions) {
        if (_random.nextDouble() < def.probability) {
          series = def.type;
          break;
        }
      }

      final newItemCompanion = GachaItemsCompanion.insert(
        imagePath: sourceItem.imagePath,
        title: sourceItem.title,
        type: Value(sourceItem.type),
        rarity: Value(sourceItem.rarity),
        isUnlocked: const Value(true),
        isSource: const Value(false), // 個体
        sourceId: Value(sourceItem.id),
        strBonus: Value(str),
        intBonus: Value(intellect),
        vitBonus: Value(vit),
        luckBonus: Value(luck),
        chaBonus: Value(cha),
        bondLevel: const Value(1),
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
  Future<void> updateItem(int id, String newTitle, {bool reCropImage = false}) async {
    // 省略
  }
  Future<void> deleteItem(int id) async {
    // 省略
  }
  Stream<List<GachaItem>> watchAllItems() => watchMyItems();
  Future<List<GachaItem>> getAllItems() async => await (_db.select(_db.gachaItems)).get();
  Future<void> unlockItem(int id) async {}
}
