import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/database.dart';

/// 推し画像の管理を行うリポジトリクラス
class GachaItemRepository {
  final AppDatabase _db;
  final ImagePicker _imagePicker = ImagePicker();

  GachaItemRepository(this._db);

  /// ギャラリーから画像を選択し、トリミングして保存
  Future<int?> pickAndSaveItem(String title) async {
    try {
      // 1. 画像を選択
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // トリミングで質が落ちないよう高めに
      );

      if (pickedFile == null) {
        return null; // キャンセル時は何もしない
      }

      // 2. 画像をトリミング (待ち受け比率 9:16)
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        // ✅ 縦長（待ち受け）比率に固定
        aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '画像を編集',
            toolbarColor: Colors.pinkAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false, // 比率ロックを外して自由にする場合は false
          ),
          IOSUiSettings(
            title: '画像を編集',
            aspectRatioLockEnabled: true, // 比率を固定するなら true
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) {
        return null; // トリミングキャンセル時
      }

      // 3. アプリ内フォルダに保存
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'oshi_images'));

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // 元ファイル名が取得しにくい場合があるため拡張子を補完
      final extension = p.extension(pickedFile.path);
      final newFileName = '${timestamp}_cropped$extension';
      final newPath = p.join(imagesDir.path, newFileName);

      // トリミング後のファイルをコピー
      final file = File(croppedFile.path);
      await file.copy(newPath);

      // 4. データベースに登録
      final companion = GachaItemsCompanion.insert(
        imagePath: newPath,
        title: title,
        rarity: const Value(Rarity.n),
        isUnlocked: const Value(false),
        strBonus: const Value(0),
        vitBonus: const Value(0),
        intBonus: const Value(0),
        luckBonus: const Value(0),
        chaBonus: const Value(0),
        bondLevel: const Value(0),
      );

      return await _db.into(_db.gachaItems).insert(companion);
    } catch (e) {
      throw Exception('画像の保存に失敗しました: $e');
    }
  }

  // 共通トリミング処理
  Future<String?> _cropImage(String sourcePath) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
      compressQuality: 90,
      maxWidth: 1080,
      maxHeight: 1920,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '画像を編集',
          toolbarColor: Colors.pinkAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: '画像を編集',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    return croppedFile?.path;
  }

  // アイテムの削除
  Future<void> deleteItem(int id) async {
    // DBからアイテム情報を取得
    final item = await (_db.select(_db.gachaItems)..where((t) => t.id.equals(id))).getSingleOrNull();
    
    if (item != null) {
      // 1. ファイル削除
      final file = File(item.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // 2. 関連データ削除 (パーティ編成などからはCascadeで消える設定なら不要だが念のため)
      // パーティメンバーからの削除はDBの外部キー制約(Cascade)に任せるか、手動で行う
      // ここではDB定義に従いCascadeされると仮定、または手動削除を追加
      await (_db.delete(_db.partyMembers)..where((t) => t.gachaItemId.equals(id))).go();

      // 3. DBレコード削除
      await (_db.delete(_db.gachaItems)..where((t) => t.id.equals(id))).go();
    }
  }

  // アイテムの更新 (タイトル変更 & 画像再編集)
  Future<void> updateItem(int id, String newTitle, {bool reCropImage = false}) async {
    final item = await (_db.select(_db.gachaItems)..where((t) => t.id.equals(id))).getSingle();
    
    String? newImagePath;

    if (reCropImage) {
      // 現在の画像を再度トリミング画面で開く
      final croppedPath = await _cropImage(item.imagePath);
      if (croppedPath != null) {
        // 上書き保存（または新規ファイル作成してパス更新）
        // ここでは安全のため新規ファイルとして保存し、古い方を後で消す運用も可だが、
        // 簡易的に上書き保存する（トリミングライブラリは一時ファイルを返すのでコピーが必要）
        final File oldFile = File(item.imagePath);
        if (await oldFile.exists()) {
          await File(croppedPath).copy(item.imagePath); // 同じパスに上書き
          newImagePath = item.imagePath;
        }
      }
    }

    await (_db.update(_db.gachaItems)..where((t) => t.id.equals(id)))
        .write(GachaItemsCompanion(
      title: Value(newTitle),
      // 画像パスは上書きなら変更なし、新規パスなら更新（今回は上書きなので更新不要だが念のため）
    ));
  }

  /// 全アイテムをStreamで監視
  Stream<List<GachaItem>> watchAllItems() {
    return (_db.select(
      _db.gachaItems,
    )..orderBy([(item) => OrderingTerm.desc(item.createdAt)])).watch();
  }

  /// 全アイテムを取得
  Future<List<GachaItem>> getAllItems() async {
    return await (_db.select(
      _db.gachaItems,
    )..orderBy([(item) => OrderingTerm.desc(item.createdAt)])).get();
  }

  Future<void> unlockItem(int id) async {
    await (_db.update(_db.gachaItems)..where((item) => item.id.equals(id))).write(
      GachaItemsCompanion(isUnlocked: const Value(true), unlockedAt: Value(DateTime.now())),
    );
  }

  // 👇 重複あり・親密度加算ロジックに変更
  Future<GachaItem> pullGacha(int gemCost) async {
    return await _db.transaction(() async {
      // 1. プレイヤー情報取得
      final player = await (_db.select(_db.players)..where((p) => p.id.equals(1))).getSingle();

      if (player.willGems < gemCost) {
        throw Exception('ジェムが足りません（必要: $gemCost Gems）');
      }

      // 2. 排出候補：全てのアイテムを対象にする（重複OK）
      final candidates = await (_db.select(_db.gachaItems)).get();

      if (candidates.isEmpty) {
        throw Exception('ガチャから出る推しがいません！\nまずは画像を登録してください。');
      }

      // ランダム抽選
      final random = Random();
      final winner = candidates[random.nextInt(candidates.length)];
      final now = DateTime.now();

      // 3. 更新処理
      // ジェム消費
      await (_db.update(_db.players)..where((p) => p.id.equals(1))).write(
        PlayersCompanion(willGems: Value(player.willGems - gemCost), updatedAt: Value(now)),
      );

      // アイテム更新（アンロック & 親密度加算）
      // 既に所持している場合でも bondLevel を +1 する
      final newBondLevel = winner.bondLevel + 1;

      await (_db.update(_db.gachaItems)..where((i) => i.id.equals(winner.id))).write(
        GachaItemsCompanion(
          isUnlocked: const Value(true),
          unlockedAt: Value(now), // 更新日時として記録
          bondLevel: Value(newBondLevel), // ✅ 親密度UP
        ),
      );

      // 4. 更新後のアイテムを返す
      return winner.copyWith(isUnlocked: true, unlockedAt: Value(now), bondLevel: newBondLevel);
    });
  }
}
