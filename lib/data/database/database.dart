import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ============================================================================
// Enums (IntEnum for Drift)
// ============================================================================

// タスクタイプ
enum TaskType {
  strength(0),
  intelligence(1),
  luck(2),
  charm(3);

  const TaskType(this.value);
  final int value;
}

// レアリティ
enum Rarity {
  n(0),
  r(1),
  sr(2),
  ssr(3);

  const Rarity(this.value);
  final int value;
}

// タスク難易度
enum TaskDifficulty {
  low(0),
  normal(1),
  high(2);

  const TaskDifficulty(this.value);
  final int value;
}

// ============================================================================
// Tables
// ============================================================================

// 1. プレイヤーテーブル
class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get experience => integer().withDefault(const Constant(0))();
  IntColumn get str => integer().withDefault(const Constant(0))();
  IntColumn get intellect => integer().withDefault(const Constant(0))(); // intは予約語のためintellect
  IntColumn get luck => integer().withDefault(const Constant(0))();
  IntColumn get cha => integer().withDefault(const Constant(0))();
  IntColumn get willGems => integer().withDefault(const Constant(500))();
  TextColumn get currentDebuff => text().nullable()();
  DateTimeColumn get debuffExpiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 2. ガチャアイテムテーブル
class GachaItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get imagePath => text()();
  TextColumn get title => text()();
  IntColumn get rarity => intEnum<Rarity>().withDefault(Constant(Rarity.n.value))();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  IntColumn get strBonus => integer().withDefault(const Constant(0))();
  IntColumn get intBonus => integer().withDefault(const Constant(0))();
  IntColumn get luckBonus => integer().withDefault(const Constant(0))();
  IntColumn get chaBonus => integer().withDefault(const Constant(0))();
  IntColumn get bondLevel => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
}

// 3. 習慣テーブル
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get taskType => intEnum<TaskType>()();
  IntColumn get difficulty => intEnum<TaskDifficulty>().withDefault(Constant(TaskDifficulty.normal.value))();
  IntColumn get rewardGems => integer().withDefault(const Constant(100))();
  IntColumn get rewardXp => integer().withDefault(const Constant(10))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 4. 称号テーブル（Phase 2用）
class Titles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get passiveSkill => text().nullable()();
  TextColumn get unlockConditionType => text()();
  TextColumn get unlockConditionValue => text()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 5. パーティデッキテーブル（Phase 2用）
class PartyDecks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 6. パーティメンバーテーブル（Phase 2用）
class PartyMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().references(PartyDecks, #id, onDelete: KeyAction.cascade)();
  IntColumn get gachaItemId => integer().references(GachaItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get slotPosition => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  Set<Column> get uniqueKey => {deckId, slotPosition};
}

// 7. ユーザー設定テーブル（Phase 3用）
class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get isPro => boolean().withDefault(const Constant(false))();
  IntColumn get maxHabits => integer().withDefault(const Constant(3))();
  IntColumn get maxGachaItems => integer().withDefault(const Constant(50))();
  IntColumn get maxDecks => integer().withDefault(const Constant(1))();
  TextColumn get themeColor => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// Database
// ============================================================================

@DriftDatabase(
  tables: [
    Players,
    GachaItems,
    Habits,
    Titles,
    PartyDecks,
    PartyMembers,
    UserSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // デフォルトのPlayer(id:1)を作成
        await into(players).insert(PlayersCompanion.insert(
          id: const Value(1),
          level: const Value(1),
          experience: const Value(0),
          str: const Value(0),
          intellect: const Value(0),
          luck: const Value(0),
          cha: const Value(0),
          willGems: const Value(500),
        ));
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 将来のマイグレーション処理をここに追加
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'oshi_quest.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

