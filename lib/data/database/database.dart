import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// --- Enums ---
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

enum BossType {
  weekly(0),
  monthly(1),
  yearly(2);

  const BossType(this.value);
  final int value;
}

enum SkillType {
  none(0),
  gemBoost(1),
  xpBoost(2),
  strBoost(3),
  luckBoost(4);

  const SkillType(this.value);
  final int value;
}

enum SeriesType {
  none(0),
  crimson(1),
  azure(2),
  golden(3),
  phantom(4);

  const SeriesType(this.value);
  final int value;
}

// ✅ 新規追加: キャラのタイプ
enum GachaItemType {
  userImage, // 0: ユーザー登録画像
  tightsMan, // 1: 全身タイツ君
}

// ✅ 新規追加: タイツ君の色
enum TightsColor {
  gray, // N
  blue, // R
  purple,  // SR
  gold, // SSR
  none, // ユーザー画像の場合はnone
}

// エフェクトの種類
enum EffectType { none, cherry, ember, bubble, rain, lightning, snow }

// --- Tables ---
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
  IntColumn get tempStrExp => integer().withDefault(const Constant(0))();
  IntColumn get tempVitExp => integer().withDefault(const Constant(0))();
  IntColumn get tempIntExp => integer().withDefault(const Constant(0))();
  IntColumn get tempLukExp => integer().withDefault(const Constant(0))();
  IntColumn get tempChaExp => integer().withDefault(const Constant(0))();
  TextColumn get currentDebuff => text().nullable()();
  DateTimeColumn get debuffExpiresAt => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get activeSkillType => intEnum<SkillType>().nullable()();
  IntColumn get activeSkillValue => integer().nullable()();
  DateTimeColumn get skillExpiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ガチャの排出候補となる画像のパスを管理するテーブル
class CharacterImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get imagePath => text()(); // 画像のパス
  TextColumn get name => text().withDefault(const Constant('名もなき推し'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class GachaItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get type => intEnum<GachaItemType>().withDefault(const Constant(0))();
  IntColumn get tightsColor => intEnum<TightsColor>().withDefault(const Constant(0))();
  TextColumn get title => text()();
  IntColumn get rarity => intEnum<Rarity>()();
  IntColumn get effectType => intEnum<EffectType>()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  IntColumn get strBonus => integer().withDefault(const Constant(0))();
  IntColumn get intBonus => integer().withDefault(const Constant(0))();
  IntColumn get luckBonus => integer().withDefault(const Constant(0))();
  IntColumn get chaBonus => integer().withDefault(const Constant(0))();
  IntColumn get vitBonus => integer().withDefault(const Constant(0))();
  IntColumn get bondLevel => integer().withDefault(const Constant(0))();
  IntColumn get skillType => intEnum<SkillType>().withDefault(const Constant(0))();
  IntColumn get skillValue => integer().withDefault(const Constant(0))();
  IntColumn get skillDuration => integer().withDefault(const Constant(0))();
  IntColumn get skillCooldown => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSkillUsedAt => dateTime().nullable()();
  IntColumn get seriesId => intEnum<SeriesType>().withDefault(const Constant(0))();
  BoolColumn get isSource => boolean().withDefault(const Constant(false))();
  IntColumn get sourceId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get intimacyLevel => integer().withDefault(const Constant(1))();
  IntColumn get intimacyExp => integer().withDefault(const Constant(0))();
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
  IntColumn get equippedFrameId => integer().nullable().references(GachaItems, #id)();
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
  BoolColumn get showEffect => boolean().withDefault(const Constant(true))();
  BoolColumn get showMainFrame => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class BossResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bossType => intEnum<BossType>()();
  TextColumn get periodKey => text()();
  BoolColumn get isWin => boolean()();
  IntColumn get playerPower => integer()();
  IntColumn get bossPower => integer()();
  DateTimeColumn get battledAt => dateTime().withDefault(currentDateAndTime)();
  @override
  List<String> get customConstraints => ['UNIQUE(boss_type, period_key)'];
}

// ご褒美アイテムテーブル
class RewardItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()(); // ご褒美名（例: ゲーム1時間）
  IntColumn get cost => integer()(); // 必要ジェム数
  TextColumn get iconData =>
      text().withDefault(const Constant('card_giftcard'))(); // アイコン名（今回は簡易的にデフォルト使用）
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    Players,
    GachaItems,
    Habits,
    Titles,
    PartyDecks,
    PartyMembers,
    UserSettings,
    BossResults,
    RewardItems,
    CharacterImages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await into(players).insert(
          PlayersCompanion.insert(
            id: const Value(1),
            level: const Value(1),
            willGems: const Value(500),
            lastLoginAt: Value(DateTime.now()),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 9) {
          await m.createTable(rewardItems);
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
