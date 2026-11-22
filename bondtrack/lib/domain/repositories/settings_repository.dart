import 'package:bondtrack/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  Stream<AppSettings> watch();

  Future<AppSettings> get();

  Future<void> save(AppSettings settings);

  Future<void> setLastBackupAt(DateTime value);
}
