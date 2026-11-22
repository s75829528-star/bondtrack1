import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:bondtrack/data/database/tables.dart';
import 'package:bondtrack/domain/entities/app_notification.dart';
import 'package:bondtrack/domain/entities/bond.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Bonds,
    InterestSchedules,
    PaymentTransactions,
    Notifications,
    AppSettingsEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'bondtrack'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      // Future schema changes are applied here step by step, preserving all
      // existing user data. Each released version adds a guarded block.
      if (from < 1) {
        await migrator.createAll();
      }
      if (from < 2) {
        // v2: configurable interest engine, partial receipts, references and
        // per-bond reminder preferences.
        await migrator.addColumn(bonds, bonds.interestMethod);
        await migrator.addColumn(bonds, bonds.compoundingFrequency);
        await migrator.addColumn(bonds, bonds.dayCountConvention);
        await migrator.addColumn(bonds, bonds.creditDay);
        await migrator.addColumn(bonds, bonds.manualInterestPerPeriodPaise);
        await migrator.addColumn(bonds, bonds.remindersEnabled);
        await migrator.addColumn(bonds, bonds.interestReminderOffsets);
        await migrator.addColumn(bonds, bonds.maturityReminderOffsets);
        await migrator.addColumn(
          interestSchedules,
          interestSchedules.receivedPaise,
        );
        await migrator.addColumn(
          paymentTransactions,
          paymentTransactions.reference,
        );
        await customStatement('''
          UPDATE interest_schedules
          SET received_paise = COALESCE(
            (SELECT SUM(amount_paise) FROM payment_transactions
             WHERE payment_transactions.schedule_id = interest_schedules.id),
            0
          )
        ''');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (!details.wasCreated) {
        // Keep referential integrity when a bond is removed.
        await customStatement('PRAGMA foreign_keys = ON');
      }
    },
  );
}
