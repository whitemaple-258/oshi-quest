import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ============================================================================
// Enums
// ============================================================================

enum TaskType {
  strength(0),
  intelligence(1),
  luck(2),
  charm(3),
  vitality(4);

  const TaskType(this.value);
  final int value;
}

enum Rarity {
  n(0),
  r(1),
  sr(2),
  ssr(3);

  const Rarity(this.value);
  final int value;
}

enum TaskDifficulty {
  low(0),
  normal(1),
  high(2);

  const TaskDifficulty(this.value);
  final int value;
}

// ✅ 追加: ボスの種類
enum BossType {
  weekly(0),
  monthly(1),
  yearly(2);

  const BossType(this.value);
  final int value;
}

// ============================================================================
// Tables
// ============================================================================

class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get experience => integer().withDefault(const Constant(0))();
  IntColumn get str => integer().withDefault(const Constant(0))();
  IntColumn get intellect => integer().withDefault(const Constant(0))();
  IntColumn get luck => integer().withDefault(const Constant(0))();
  IntColumn get cha => integer().withDefault(const Constant(0))();
  IntColumn get vit => integer().withDefault(const Constant(0))();
  IntColumn get willGems => integer().withDefault(const Constant(500))();

  TextColumn get currentDebuff => text().nullable()();
  DateTimeColumn get debuffExpiresAt => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

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
  IntColumn get vitBonus => integer().withDefault(const Constant(0))();
  IntColumn get bondLevel => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
}

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get taskType => intEnum<TaskType>()();
  IntColumn get difficulty =>
      intEnum<TaskDifficulty>().withDefault(Constant(TaskDifficulty.normal.value))();
  IntColumn get rewardGems => integer().withDefault(const Constant(100))();
  IntColumn get rewardXp => integer().withDefault(const Constant(10))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

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

class PartyDecks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class PartyMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().references(PartyDecks, #id, onDelete: KeyAction.cascade)();
  IntColumn get gachaItemId => integer().references(GachaItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get slotPosition => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  Set<Column> get uniqueKey => {deckId, slotPosition};
}

@DataClassName('UserSettingsData')
class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get isPro => boolean().withDefault(const Constant(false))();
  IntColumn get maxHabits => integer().withDefault(const Constant(3))();
  IntColumn get maxGachaItems => integer().withDefault(const Constant(5))();
  IntColumn get maxDecks => integer().withDefault(const Constant(1))();
  TextColumn get themeColor => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ✅ 追加: ボス戦の戦歴テーブル
class BossResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bossType => intEnum<BossType>()(); // 0: Weekly, 1: Monthly, 2: Yearly
  TextColumn get periodKey => text()(); // 期間ID (例: "2025-W40", "2025-10")
  BoolColumn get isWin => boolean()(); // 勝敗
  IntColumn get playerPower => integer()(); // 挑んだ時の戦力
  IntColumn get bossPower => integer()(); // ボスの強さ
  DateTimeColumn get battledAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    'UNIQUE(boss_type, period_key)', // 同じ期間のボスには1回しか勝敗がつかない（再戦ロジック次第で調整可）
  ];
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
    BossResults, // ✅ 追加
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // ✅ バージョンを 4 に更新
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // 初期プレイヤー作成
        await into(players).insert(
          PlayersCompanion.insert(
            id: const Value(1),
            level: const Value(1),
            willGems: const Value(500),
            experience: const Value(0),
            str: const Value(0),
            intellect: const Value(0),
            luck: const Value(0),
            cha: const Value(0),
            vit: const Value(0),
            lastLoginAt: Value(DateTime.now()),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(players, players.vit);
          await m.addColumn(gachaItems, gachaItems.vitBonus);
        }
        if (from < 3) {
          await m.addColumn(players, players.lastLoginAt);
          await m.addColumn(players, players.currentDebuff);
          await m.addColumn(players, players.debuffExpiresAt);
          await m.createTable(userSettings);
        }
        // ✅ v4: ボス戦テーブル追加
        if (from < 4) {
          await m.createTable(bossResults);
        }
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
