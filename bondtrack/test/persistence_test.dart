import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bondtrack/data/database/app_database.dart';
import 'package:bondtrack/data/repositories/drift_bond_repository.dart';
import 'package:bondtrack/data/repositories/drift_payment_repository.dart';
import 'package:bondtrack/data/repositories/drift_schedule_repository.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/features/settings/data/backup_restore_service.dart';

void main() {
  // Reopening the same on-disk file is the behaviour this test exercises.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  TestWidgetsFlutterBinding.ensureInitialized();

  test('partial payments reconcile and survive a database restart', () async {
    final directory = await Directory.systemTemp.createTemp('bondtrack-test-');
    final file = File('${directory.path}/portfolio.sqlite');
    var database = AppDatabase(NativeDatabase(file));
    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
    });

    final bondRepository = DriftBondRepository(database);
    final bondId = await bondRepository.create(
      BondDraft(
        name: 'Persistence test',
        issuer: 'Test issuer',
        principalPaise: 10000000,
        annualRate: 12,
        purchaseDate: DateTime(2025, 1, 1),
        frequency: InterestFrequency.monthly,
        firstInterestDate: DateTime(2025, 2, 1),
        maturityDate: DateTime(2025, 4, 1),
        expectedMaturityAmountPaise: 11000000,
      ),
    );
    final bond = (await bondRepository.getById(bondId))!;
    final scheduleRepository = DriftScheduleRepository(database);
    final schedule = (await scheduleRepository.getForBond(bondId)).first;
    final paymentRepository = DriftPaymentRepository(database);

    final paymentId = await paymentRepository.recordPayment(
      bond: bond,
      amountPaise: 40000,
      paidDate: DateTime(2025, 2, 1),
      type: PaymentType.interest,
      schedule: schedule,
      reference: 'UTR-123',
    );
    var updatedSchedule = (await scheduleRepository.getForBond(bondId)).first;
    expect(updatedSchedule.status, ScheduleStatus.partiallyPaid);
    expect(updatedSchedule.receivedPaise, 40000);
    expect(updatedSchedule.remainingPaise, 60000);

    await paymentRepository.updatePayment(
      paymentId: paymentId,
      amountPaise: 100000,
      paidDate: DateTime(2025, 2, 2),
      reference: 'UTR-CORRECTED',
    );
    updatedSchedule = (await scheduleRepository.getForBond(bondId)).first;
    expect(updatedSchedule.status, ScheduleStatus.paid);
    expect(updatedSchedule.receivedPaise, 100000);

    await database.close();
    database = AppDatabase(NativeDatabase(file));
    final reopenedSchedules = DriftScheduleRepository(database);
    final reopenedPayments = DriftPaymentRepository(database);
    updatedSchedule = (await reopenedSchedules.getForBond(bondId)).first;
    expect(updatedSchedule.status, ScheduleStatus.paid);
    expect(
      (await reopenedPayments.getById(paymentId))!.reference,
      'UTR-CORRECTED',
    );

    final backup = await BackupRestoreService(database)
        .createBackup(password: 'a-secure-test-password');
    final restoredDatabase = AppDatabase(NativeDatabase.memory());
    addTearDown(restoredDatabase.close);
    final restoreResult = await BackupRestoreService(restoredDatabase)
        .restore(backup, password: 'a-secure-test-password');
    expect(restoreResult.bondsImported, 1);
    expect(
      (await DriftScheduleRepository(restoredDatabase).getForBond(bondId))
          .first
          .receivedPaise,
      100000,
    );
    await expectLater(
      BackupRestoreService(restoredDatabase)
          .restore(backup, password: 'wrong-password'),
      throwsA(isA<FormatException>()),
    );

    await reopenedPayments.deletePayment(paymentId);
    updatedSchedule = (await reopenedSchedules.getForBond(bondId)).first;
    expect(updatedSchedule.status, ScheduleStatus.pending);
    expect(updatedSchedule.receivedPaise, 0);

    final reopenedBondRepository = DriftBondRepository(database);
    final beforeFailedSync = (await reopenedBondRepository.getAll()).length;
    await expectLater(
      reopenedBondRepository.syncImport(
        newBonds: [
          BondDraft(
            name: 'Must roll back',
            issuer: 'Test issuer',
            principalPaise: 500000,
            annualRate: 7,
            purchaseDate: DateTime(2025, 1, 1),
            frequency: InterestFrequency.monthly,
            firstInterestDate: DateTime(2025, 2, 1),
            maturityDate: DateTime(2026, 1, 1),
            expectedMaturityAmountPaise: 550000,
          ),
        ],
        updates: [
          BondDraft(
            id: 999999,
            name: 'Missing bond',
            issuer: 'Test issuer',
            principalPaise: 500000,
            annualRate: 7,
            purchaseDate: DateTime(2025, 1, 1),
            frequency: InterestFrequency.monthly,
            firstInterestDate: DateTime(2025, 2, 1),
            maturityDate: DateTime(2026, 1, 1),
            expectedMaturityAmountPaise: 550000,
          ),
        ],
      ),
      throwsA(isA<StateError>()),
    );
    expect((await reopenedBondRepository.getAll()).length, beforeFailedSync);
  });
}
