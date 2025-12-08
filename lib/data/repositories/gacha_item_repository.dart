import 'dart:io';
import 'dart:math';
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
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        throw Exception('画像が選択されませんでした');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'oshi_images'));

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalFileName = p.basename(pickedFile.path);
      final newFileName = '${timestamp}_$originalFileName';
      final newPath = p.join(imagesDir.path, newFileName);

      final file = File(pickedFile.path);
      await file.copy(newPath);

      final companion = GachaItemsCompanion.insert(
        imagePath: newPath,
        title: title,
        rarity: const Value(Rarity.n),
        isUnlocked: const Value(false),
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
