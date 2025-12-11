import 'package:drift/drift.dart';
import '../database/database.dart';

class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository(this._db);

  Future<UserSettingsData> getSettings() async {
    final settings = await (_db.select(
      _db.userSettings,
    )..where((s) => s.id.equals(1))).getSingleOrNull();

    if (settings == null) {
      await _db
          .into(_db.userSettings)
          .insert(
            UserSettingsCompanion.insert(
              id: const Value(1),
              themeColor: const Value('pink'),
              isPro: const Value(false),
              maxHabits: const Value(3),
              maxGachaItems: const Value(50),
              maxDecks: const Value(1),
            ),
          );
      return await (_db.select(_db.userSettings)..where((s) => s.id.equals(1))).getSingle();
    }
    return settings;
  }

  Future<void> updateThemeColor(String colorName) async {
    await (_db.update(_db.userSettings)..where((s) => s.id.equals(1))).write(
      UserSettingsCompanion(themeColor: Value(colorName), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> resetAllData() async {
    await _db.transaction(() async {
      await _db.delete(_db.habits).go();
      await _db.delete(_db.partyMembers).go();
      await _db.delete(_db.partyDecks).go();
      await _db.delete(_db.gachaItems).go();
      await _db.delete(_db.titles).go();
      await _db.delete(_db.players).go();

      await _db
          .into(_db.players)
          .insert(
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
    });
  }
}
