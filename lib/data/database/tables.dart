import 'package:drift/drift.dart';

// ============================================================================
// 1. プレイヤーテーブル (Players)
// ============================================================================
// ユーザー自身の成長を管理するRPGステータス
class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // 基本ステータス (The 4 Parameters)
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get experience => integer().withDefault(const Constant(0))();
  IntColumn get str => integer().withDefault(const Constant(0))(); // 筋力
  IntColumn get intStat => integer().named('int').withDefault(const Constant(0))(); // 知力 (intは予約語のためintStat)
  IntColumn get luck => integer().withDefault(const Constant(0))(); // 運
  IntColumn get cha => integer().withDefault(const Constant(0))(); // 魅力
  
  // 経済圏
  IntColumn get willGems => integer().withDefault(const Constant(500))(); // 初期ジェム
  
  // 状態異常 (Debuffs)
  TextColumn get currentDebuff => text().nullable()(); // 'curse_of_sloth' など
  DateTimeColumn get debuffExpiresAt => dateTime().nullable()();
  
  // タイムスタンプ
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// 2. ガチャアイテムテーブル (GachaItems)
// ============================================================================
// 推し画像とその装備としての能力を管理
class GachaItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // 基本情報
  TextColumn get imagePath => text()(); // ローカルパス（プライバシー重視）
  TextColumn get title => text()(); // 推しのタイトル
  TextColumn get rarity => text().withDefault(const Constant('N'))(); // 'N', 'R', 'SR', 'SSR'
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  
  // アビリティ（ステータス補正）
  IntColumn get strBonus => integer().withDefault(const Constant(0))();
  IntColumn get intBonus => integer().withDefault(const Constant(0))();
  IntColumn get luckBonus => integer().withDefault(const Constant(0))();
  IntColumn get chaBonus => integer().withDefault(const Constant(0))();
  
  // 親密度（将来のボイス解放などに使用）
  IntColumn get bondLevel => integer().withDefault(const Constant(0))();
  
  // タイムスタンプ
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
}

// ============================================================================
// 3. 習慣テーブル (Habits)
// ============================================================================
// タスク/習慣の管理（Phase 1 MVPで必要）
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // 基本情報
  TextColumn get name => text()(); // タスク名
  TextColumn get taskType => text()(); // 'STR', 'INT', 'LUCK', 'CHA'
  TextColumn get difficulty => text().withDefault(const Constant('normal'))(); // 'low', 'normal', 'high'
  
  // 報酬
  IntColumn get rewardGems => integer().withDefault(const Constant(100))();
  IntColumn get rewardXp => integer().withDefault(const Constant(10))();
  
  // 状態管理
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()(); // 期限（サボり判定に使用）
  
  // タイムスタンプ
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// 4. 称号テーブル (Titles)
// ============================================================================
// 称号システム（Phase 2で実装）
class Titles extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // 基本情報
  TextColumn get name => text()(); // 称号名（例：『早起きの達人』）
  TextColumn get description => text().nullable()();
  
  // パッシブスキル（JSON形式で保存、将来拡張可能に）
  TextColumn get passiveSkill => text().nullable()(); // 例: 'morning_task_reward_bonus:5'
  
  // 獲得条件
  TextColumn get unlockConditionType => text()(); // 'login_days', 'task_count', 'qualification'
  TextColumn get unlockConditionValue => text()(); // 条件の値（例: '30'日、'100'回）
  
  // 状態
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  
  // タイムスタンプ
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// 5. パーティデッキテーブル (PartyDecks)
// ============================================================================
// パーティ編成のデッキ管理（Phase 2で実装）
class PartyDecks extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // 基本情報
  TextColumn get name => text()(); // デッキ名（例: '日常クエスト用'）
  BoolColumn get isActive => boolean().withDefault(const Constant(false))(); // アクティブなデッキ
  
  // タイムスタンプ
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// 6. パーティメンバーテーブル (PartyMembers)
// ============================================================================
// デッキに編成された推しの管理
class PartyMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // リレーション
  IntColumn get deckId => integer().references(PartyDecks, #id, onDelete: KeyAction.cascade)();
  IntColumn get gachaItemId => integer().references(GachaItems, #id, onDelete: KeyAction.cascade)();
  
  // スロット位置（0=Main Slot, 1-4=Sub Slots）
  IntColumn get slotPosition => integer()(); // 0-4
  
  // タイムスタンプ
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // ユニーク制約: 同じデッキ内で同じスロット位置に複数の推しは配置不可
  Set<Column> get uniqueKey => {deckId, slotPosition};
}

// ============================================================================
// 7. ユーザー設定テーブル (UserSettings)
// ============================================================================
// Pro版設定、UIテーマなど（Phase 3で実装）
class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Pro版設定
  BoolColumn get isPro => boolean().withDefault(const Constant(false))();
  
  // 制限値（Free版の制限）
  IntColumn get maxHabits => integer().withDefault(const Constant(3))(); // Free: 3, Pro: 無制限
  IntColumn get maxGachaItems => integer().withDefault(const Constant(50))(); // Free: 50, Pro: 無制限
  IntColumn get maxDecks => integer().withDefault(const Constant(1))(); // Free: 1, Pro: 5
  
  // UI設定
  TextColumn get themeColor => text().nullable()(); // カラーピッカーで選択した色（Hex形式）
  
  // タイムスタンプ
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  // シングルトン制約: 設定は1レコードのみ（アプリケーションロジックで制御）
}

