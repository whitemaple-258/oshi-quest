// Driftが生成したGachaItemをエクスポート
// 既存のコードとの互換性のため、拡張メソッドを追加
import 'package:drift/drift.dart';
import '../database/database.dart';

export '../database/database.dart' show GachaItem, GachaItemsCompanion;

extension GachaItemExtension on GachaItem {
  // 既存コードとの互換性: imageUrl → imagePath
  String get imageUrl => imagePath;

  // 既存コードとの互換性: isSSR → rarity == Rarity.ssr
  bool get isSSR => rarity == Rarity.ssr;

  // 既存コードとの互換性: idをStringとして扱う（一時的）
  String get idString => id.toString();

  // isUnlockedを更新するためのヘルパーメソッド
  GachaItem copyWithUnlocked({required bool isUnlocked}) {
    return copyWith(
      isUnlocked: isUnlocked,
      unlockedAt: isUnlocked ? Value(DateTime.now()) : const Value.absent(),
    );
  }
}
