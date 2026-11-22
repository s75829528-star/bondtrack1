import 'package:bondtrack/data/database/app_database.dart';
import 'package:bondtrack/data/mappers.dart';
import 'package:bondtrack/domain/entities/app_settings.dart';
import 'package:bondtrack/domain/repositories/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<AppSettings> watch() {
    return _db.select(_db.appSettingsEntries).watch().map((rows) {
      return {for (final row in rows) row.key: row.value}.toSettings();
    });
  }

  @override
  Future<AppSettings> get() async {
    final rows = await _db.select(_db.appSettingsEntries).get();
    return {for (final row in rows) row.key: row.value}.toSettings();
  }

  @override
  Future<void> save(AppSettings settings) {
    return _db.transaction(() async {
      final values = settingsToMap(settings);
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.appSettingsEntries,
          values.entries
              .map(
                (entry) => AppSettingsEntriesCompanion.insert(
                  key: entry.key,
                  value: entry.value,
                ),
              )
              .toList(),
        );
      });
    });
  }

  @override
  Future<void> setLastBackupAt(DateTime value) async {
    await _db
        .into(_db.appSettingsEntries)
        .insertOnConflictUpdate(
          AppSettingsEntriesCompanion.insert(
            key: 'last_backup_at',
            value: value.toIso8601String(),
          ),
        );
  }
}
