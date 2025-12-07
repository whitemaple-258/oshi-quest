import 'dart:io';
import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/database.dart';

/// 推し画像の管理を行うリポジトリクラス
class GachaItemRepository {
  final AppDatabase _db;
  final ImagePicker _imagePicker = ImagePicker();

  GachaItemRepository(this._db);

  /// ギャラリーから画像を選択し、アプリ内に保存してデータベースに登録
  Future<int> pickAndSaveItem(String title) async {
    try {
      // 画像ピッカーで画像を選択
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // 品質を少し下げてファイルサイズを削減
      );

      if (pickedFile == null) {
        throw Exception('画像が選択されませんでした');
      }

      // アプリ内の 'oshi_images' フォルダにコピー
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'oshi_images'));
      
      // ディレクトリが存在しない場合は作成
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // ファイル名を生成（タイムスタンプ + 元のファイル名）
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalFileName = p.basename(pickedFile.path);
      final newFileName = '${timestamp}_$originalFileName';
      final newPath = p.join(imagesDir.path, newFileName);

      // ファイルをコピー
      final file = File(pickedFile.path);
      await file.copy(newPath);

      // データベースに保存（isUnlocked: true, rarity: N として初期登録）
      final companion = GachaItemsCompanion.insert(
        imagePath: newPath,
        title: title,
        rarity: const Value(Rarity.n),
        isUnlocked: const Value(true),
        strBonus: const Value(0),
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

  /// 全アイテムをStreamで監視
  Stream<List<GachaItem>> watchAllItems() {
    return (_db.select(_db.gachaItems)
          ..orderBy([(item) => OrderingTerm.desc(item.createdAt)]))
        .watch();
  }

  /// 全アイテムを取得
  Future<List<GachaItem>> getAllItems() async {
    return await (_db.select(_db.gachaItems)
          ..orderBy([(item) => OrderingTerm.desc(item.createdAt)]))
        .get();
  }

  /// アイテムをアンロック
  Future<void> unlockItem(int id) async {
    await (_db.update(_db.gachaItems)..where((item) => item.id.equals(id)))
        .write(GachaItemsCompanion(
      isUnlocked: const Value(true),
      unlockedAt: Value(DateTime.now()),
    ));
  }
}

