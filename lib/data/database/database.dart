import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// --- Enums ---

enum TaskDifficulty {
  low(0),
  normal(1),
  high(2);

  const TaskDifficulty(this.value);
  final int value;
}

// HabitScreenやタスク設定に使用されるEnum
enum TaskType { strength, intelligence, vitality, luck, charm }

// ガチャアイテムのレアリティ
enum Rarity { n, r, sr, ssr }

// ガチャアイテムのスキルタイプ
// Note: Boost系は戦闘力 (str, int, vit, luck)、Gem/XpBoostは報酬倍率
enum SkillType { none, gemBoost, xpBoost, strBoost, intBoost, vitBoost, luckBoost, chaBoost }

// ガチャアイテムのシリーズ（セット効果用）
enum SeriesType { none, crimson, azure, golden, phantom }

enum BossType {
  weekly(0),
  monthly(1),
  yearly(2);

  const BossType(this.value);
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
  purple, // SR
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
  TextColumn get name => text().withDefault(const Constant('勇者'))();
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
  IntColumn get type => intEnum<GachaItemType>().withDefault(const Constant(0))();
  IntColumn get tightsColor => intEnum<TightsColor>().withDefault(const Constant(0))();
  TextColumn get title => text()();
  IntColumn get rarity => intEnum<Rarity>()();
  IntColumn get effectType => intEnum<EffectType>()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  // 基礎パラメータボーナス（固定値）
  IntColumn get strBonus => integer().withDefault(const Constant(0))();
  IntColumn get intBonus => integer().withDefault(const Constant(0))();
  IntColumn get luckBonus => integer().withDefault(const Constant(0))();
  IntColumn get chaBonus => integer().withDefault(const Constant(0))();
  IntColumn get vitBonus => integer().withDefault(const Constant(0))();
  // 特化パラメータ
  IntColumn get parameterType => intEnum<TaskType>()();
  // スキル
  IntColumn get skillType => intEnum<SkillType>().withDefault(const Constant(0))();
  IntColumn get skillValue => integer().withDefault(const Constant(0))();
  IntColumn get skillDuration => integer().withDefault(const Constant(0))();
  IntColumn get skillCooldown => integer().withDefault(const Constant(0))();
  // シリーズ
  IntColumn get seriesType =>
      intEnum<SeriesType>().withDefault(const Constant(0))(); // SeriesType.none=0
  DateTimeColumn get lastSkillUsedAt => dateTime().nullable()();
  IntColumn get seriesId => intEnum<SeriesType>().withDefault(const Constant(0))();
  BoolColumn get isSource => boolean().withDefault(const Constant(false))();
  IntColumn get sourceId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  // 親密度
  IntColumn get intimacyLevel => integer().withDefault(const Constant(1))();
  IntColumn get intimacyExp => integer().withDefault(const Constant(0))();
  // その他
  BoolColumn get isEquipped => boolean().withDefault(const Constant(false))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  TextColumn get imagePath => text().nullable()();
}

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get taskType => intEnum<TaskType>()();
  IntColumn get difficulty => intEnum<TaskDifficulty>().withDefault(const Constant(0))();
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

// ボスのステータスを管理するテーブル
// ⚠️ 追加: このアノテーションでクラス名を強制します
@DataClassName('Boss') 
class Bosses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  
  // 前回 int に変更した場合はそのままでOK、intEnumに戻してもOKですが、
  // 安全のため今回は integer() (数値) のままで行きましょう。
  IntColumn get bossType => integer()(); 
  
  IntColumn get maxHp => integer().withDefault(const Constant(1000))();
  IntColumn get attack => integer().withDefault(const Constant(100))();
  IntColumn get defense => integer().withDefault(const Constant(50))();

  TextColumn get specialAbility => text().nullable()();
  IntColumn get rewardGems => integer().withDefault(const Constant(500))();

  DateTimeColumn get resetAt => dateTime()(); 
  
  @override
  List<String> get customConstraints => ['UNIQUE(boss_type, reset_at)'];
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
    Bosses,
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
        // バージョン9未満からのアップデート（RewardItems追加）
        if (from < 9) {
          await m.createTable(rewardItems);
        }

        // ✅ 修正: バージョン10未満からのアップデート（Bosses追加）
        if (from < 10) {
          await m.createTable(bosses);
          // 既存のBossResultsテーブルにカラム変更などがあればここで行いますが、
          // 今回は新規テーブル追加のみなので createTable だけでOKです。
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
