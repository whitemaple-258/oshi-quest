import 'package:drift/drift.dart';
import '../database/database.dart';

/// 称号（実績）のマスターデータ
///
/// 新しい称号を追加する手順:
/// 1. このリストに `TitlesCompanion.insert` を追加する。
/// 2. `unlockConditionType` には以下のいずれかを指定:
///    - 'level': プレイヤーレベル
///    - 'gems': 所持ジェム
///    - 'str', 'int', 'luck', 'cha': 各ステータス
/// 3. `unlockConditionValue` に目標数値を文字列で指定。
///
/// 注意: すでにアプリをリリース・配布している場合、このリストを変更しても
/// 既存ユーザーのDBには自動反映されません（別途マイグレーション処理が必要）。
/// 開発中（DBリセット可）であれば問題ありません。

final List<TitlesCompanion> defaultTitles = [
  // --- レベル系 ---
  TitlesCompanion.insert(
    name: '見習い勇者',
    description: const Value('冒険の始まり。'),
    unlockConditionType: 'level',
    unlockConditionValue: '1',
    isUnlocked: const Value(true), // 最初から所持
    unlockedAt: Value(DateTime.now()),
  ),
  TitlesCompanion.insert(
    name: '一人前の勇者',
    description: const Value('レベル10に到達した証。'),
    unlockConditionType: 'level',
    unlockConditionValue: '10',
  ),
  TitlesCompanion.insert(
    name: 'ベテラン勇者',
    description: const Value('レベル30に到達した証。'),
    unlockConditionType: 'level',
    unlockConditionValue: '30',
  ),

  // --- ジェム（資産）系 ---
  TitlesCompanion.insert(
    name: '大富豪',
    description: const Value('所持ジェムが1000を超えた。'),
    unlockConditionType: 'gems',
    unlockConditionValue: '1000',
  ),
  TitlesCompanion.insert(
    name: '石油王',
    description: const Value('所持ジェムが10000を超えた。'),
    unlockConditionType: 'gems',
    unlockConditionValue: '10000',
  ),

  // --- ステータス系 ---
  TitlesCompanion.insert(
    name: '脳筋',
    description: const Value('STRが20を超えた。'),
    unlockConditionType: 'str',
    unlockConditionValue: '20',
  ),
  TitlesCompanion.insert(
    name: 'ガリ勉',
    description: const Value('INTが20を超えた。'),
    unlockConditionType: 'int',
    unlockConditionValue: '20',
  ),
  TitlesCompanion.insert(
    name: 'ラッキーマン',
    description: const Value('LUCKが20を超えた。'),
    unlockConditionType: 'luck',
    unlockConditionValue: '20',
  ),
  TitlesCompanion.insert(
    name: '愛されキャラ',
    description: const Value('CHAが20を超えた。'),
    unlockConditionType: 'cha',
    unlockConditionValue: '20',
  ),

  // 今後ここに追加していく
];
