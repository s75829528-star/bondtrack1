import 'package:flutter_test/flutter_test.dart';
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/domain/entities/app_settings.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/services/bond_identity.dart';
import 'package:bondtrack/domain/services/interest_engine.dart';
import 'package:bondtrack/domain/services/notification_planner.dart';
import 'package:bondtrack/domain/services/schedule_generator.dart';
import 'package:bondtrack/domain/services/spreadsheet_import_service.dart';

void main() {
  group('Money', () {
    test('parses Indian grouped amounts and lakh abbreviations', () {
      expect(Money.parseAmountToPaise('₹1,20,000.50'), 12000050);
      expect(Money.parseAmountToPaise('2.5L'), 25000000);
      expect(Money.parseAmountToPaise('1 crore'), 1000000000);
      expect(Money.parseAmountToPaise('not an amount'), isNull);
    });

    test('formats INR with Indian grouping', () {
      expect(Money.formatPaise(123456789), '₹12,34,568');
      expect(Money.formatPaise(123456789, compact: true), '₹12.3 L');
    });
  });

  group('ScheduleGenerator', () {
    test('creates monthly schedule and clamps month-end dates', () {
      final schedules = ScheduleGenerator.generate(
        purchaseDate: DateTime(2024, 1, 1),
        firstInterestDate: DateTime(2024, 1, 31),
        maturityDate: DateTime(2024, 4, 30),
        frequency: InterestFrequency.monthly,
        principalPaise: 10000000,
        annualRate: 12,
      );

      expect(schedules.map((schedule) => schedule.dueDate), [
        DateTime(2024, 1, 31),
        DateTime(2024, 2, 29),
        DateTime(2024, 3, 31),
        DateTime(2024, 4, 30),
      ]);
      expect(
        schedules.map((schedule) => schedule.expectedInterestPaise),
        everyElement(100000),
      );
    });

    test('creates quarterly coupons only through maturity', () {
      final schedules = ScheduleGenerator.generate(
        purchaseDate: DateTime(2025, 1, 1),
        firstInterestDate: DateTime(2025, 2, 15),
        maturityDate: DateTime(2025, 10, 1),
        frequency: InterestFrequency.quarterly,
        principalPaise: 10000000,
        annualRate: 8,
      );
      expect(schedules.map((schedule) => schedule.dueDate), [
        DateTime(2025, 2, 15),
        DateTime(2025, 5, 15),
        DateTime(2025, 8, 15),
      ]);
      expect(schedules.first.expectedInterestPaise, 200000);
    });
  });

  group('InterestEngine', () {
    test('uses integer paise and equal coupon periods', () {
      expect(
        InterestEngine.interestForPeriod(
          principalPaise: 10000000,
          annualRate: 12,
          periodStart: DateTime(2024, 1, 1),
          periodEnd: DateTime(2024, 2, 1),
          dayCount: DayCountConvention.equalPeriods,
          periodMonths: 1,
        ),
        100000,
      );
    });

    test('actual/actual accounts for leap-year days', () {
      final amount = InterestEngine.interestForPeriod(
        principalPaise: 10000000,
        annualRate: 10,
        periodStart: DateTime(2024, 1, 1),
        periodEnd: DateTime(2025, 1, 1),
        dayCount: DayCountConvention.actualActual,
        periodMonths: 12,
      );
      expect(amount, 1000000);
    });

    test('month-end anchoring restores the 31st after February', () {
      final dates = ScheduleGenerator.generate(
        purchaseDate: DateTime(2024, 1, 1),
        firstInterestDate: DateTime(2024, 1, 31),
        maturityDate: DateTime(2024, 3, 31),
        frequency: InterestFrequency.monthly,
        principalPaise: 10000000,
        annualRate: 12,
      ).map((period) => period.dueDate).toList();
      expect(dates, [
        DateTime(2024, 1, 31),
        DateTime(2024, 2, 29),
        DateTime(2024, 3, 31),
      ]);
    });

    test('compound balance grows faster than simple interest', () {
      final compound = InterestEngine.compoundBalance(
        principalPaise: 10000000,
        annualRate: 12,
        start: DateTime(2024, 1, 1),
        end: DateTime(2026, 1, 1),
        compounding: CompoundingFrequency.annual,
      );
      expect(compound, 12544000);
    });

    test('payment state distinguishes partial receipts and overdue', () {
      expect(
        InterestEngine.scheduleStatus(
          expectedPaise: 10000,
          receivedPaise: 2500,
        ),
        ScheduleStatus.partiallyPaid,
      );
      expect(
        InterestEngine.paymentStatus(
          dueDate: DateTime(2026, 1, 1),
          expectedPaise: 10000,
          receivedPaise: 0,
          now: DateTime(2026, 1, 2),
        ),
        PaymentStatus.overdue,
      );
    });
  });

  group('NotificationPlanner', () {
    test('uses stable ids and schedules configured lead reminders', () {
      final bond = Bond(
        id: 1,
        name: 'Test bond',
        issuer: 'Issuer',
        principalPaise: 10000000,
        annualRate: 8,
        purchaseDate: DateTime(2025, 1, 1),
        frequency: InterestFrequency.monthly,
        firstInterestDate: DateTime(2026, 1, 20),
        maturityDate: DateTime(2027, 1, 1),
        expectedMaturityAmountPaise: 11000000,
        status: BondStatus.active,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      final schedule = InterestSchedule(
        id: 7,
        bondId: 1,
        dueDate: DateTime(2026, 1, 20),
        periodStart: DateTime(2025, 12, 20),
        periodEnd: DateTime(2026, 1, 20),
        expectedInterestPaise: 66667,
        status: ScheduleStatus.pending,
      );
      final reminders = NotificationPlanner.plan(
        bonds: [bond],
        schedules: [schedule],
        settings: AppSettings.defaults,
        now: DateTime(2026, 1, 10),
      );
      final lead = reminders.firstWhere(
        (reminder) => reminder.kind == ReminderKind.interest,
      );
      expect(lead.scheduledAt, DateTime(2026, 1, 13, 9));
      expect(lead.notificationId, NotificationPlanner.stableId(lead.dedupeKey));

      final globallyConfigured = NotificationPlanner.plan(
        bonds: [bond],
        schedules: [schedule],
        settings: AppSettings.defaults.copyWith(interestReminderOffsets: '1'),
        now: DateTime(2026, 1, 10),
      ).where((reminder) => reminder.kind == ReminderKind.interest);
      expect(globallyConfigured, hasLength(1));
      expect(globallyConfigured.single.scheduledAt, DateTime(2026, 1, 19, 9));

      final perBondOverride = NotificationPlanner.plan(
        bonds: [bond.copyWith(interestReminderOffsets: '3')],
        schedules: [schedule],
        settings: AppSettings.defaults.copyWith(interestReminderOffsets: '1'),
        now: DateTime(2026, 1, 10),
      ).where((reminder) => reminder.kind == ReminderKind.interest);
      expect(perBondOverride, hasLength(1));
      expect(perBondOverride.single.scheduledAt, DateTime(2026, 1, 17, 9));

      final quiet = NotificationPlanner.plan(
        bonds: [bond],
        schedules: [schedule],
        settings: AppSettings.defaults.copyWith(
          interestReminderOffsets: '1',
          quietHoursEnabled: true,
          quietStartHour: 8,
          quietEndHour: 10,
        ),
        now: DateTime(2026, 1, 10),
      ).where((reminder) => reminder.kind == ReminderKind.interest);
      expect(quiet.single.scheduledAt, DateTime(2026, 1, 19, 10));
    });
  });

  group('SpreadsheetImportService', () {
    test('suggests mapping independent of column order', () {
      final headers = [
        'Maturity Date',
        'Issuer',
        'Bond Name',
        'Rate (%)',
        'Purchase Date',
        'Principal',
      ];
      final mapping = SpreadsheetImportService.suggestMapping(headers);
      expect(mapping[0], ImportField.maturityDate);
      expect(mapping[1], ImportField.issuer);
      expect(mapping[2], ImportField.name);
      expect(mapping[3], ImportField.rate);
      expect(mapping[4], ImportField.purchaseDate);
      expect(mapping[5], ImportField.principal);
    });

    test('previews valid, duplicate and invalid rows without losing rows', () {
      final headers = [
        'Bond Name',
        'Issuer',
        'Principal',
        'Rate',
        'Purchase Date',
        'Maturity Date',
        'Frequency',
      ];
      final table = SpreadsheetTable(
        sheetName: 'Portfolio',
        headers: headers,
        rows: [
          [
            'Alpha NCD',
            'Issuer A',
            '100000',
            '8.5%',
            '01/04/2024',
            '01/04/2027',
            'Monthly',
          ],
          [
            'Alpha NCD',
            'Issuer A',
            '100000',
            '8.5%',
            '01/04/2024',
            '01/04/2027',
            'Monthly',
          ],
          ['Broken', '', 'abc', 'bad', '32/01/2024', '', 'Monthly'],
        ],
      );
      final mapping = SpreadsheetImportService.suggestMapping(headers);
      final preview = SpreadsheetImportService.preview(
        table: table,
        mapping: mapping,
        existingDuplicateKeys: {
          bondDuplicateKey(
            name: 'Alpha NCD',
            issuer: 'Issuer A',
            purchaseDate: DateTime(2024, 4, 1),
          ),
        },
      );

      expect(preview.rows, hasLength(3));
      expect(preview.duplicateCount, 2);
      expect(preview.invalidCount, 1);
      expect(preview.selectedCount, 0);
      expect(preview.rows.last.error, isNotNull);
    });

    test(
      'offers selected existing-bond updates, but not duplicate file rows',
      () {
        final bond = Bond(
          id: 42,
          name: 'Alpha NCD',
          issuer: 'Issuer A',
          principalPaise: 10000000,
          annualRate: 8,
          purchaseDate: DateTime(2024, 4, 1),
          frequency: InterestFrequency.monthly,
          firstInterestDate: DateTime(2024, 5, 1),
          maturityDate: DateTime(2027, 4, 1),
          expectedMaturityAmountPaise: 12000000,
          status: BondStatus.active,
          createdAt: DateTime(2024, 4, 1),
          updatedAt: DateTime(2024, 4, 1),
        );
        const headers = [
          'Bond Name',
          'Issuer',
          'Principal',
          'Rate',
          'Purchase Date',
          'Maturity Date',
          'Frequency',
        ];
        final table = SpreadsheetTable(
          sheetName: 'Portfolio',
          headers: headers,
          rows: [
            [
              'Alpha NCD',
              'Issuer A',
              '120000',
              '9%',
              '01/04/2024',
              '01/04/2028',
              'Monthly',
            ],
            [
              'Alpha NCD',
              'Issuer A',
              '120000',
              '9%',
              '01/04/2024',
              '01/04/2028',
              'Monthly',
            ],
          ],
        );
        final preview = SpreadsheetImportService.preview(
          table: table,
          mapping: SpreadsheetImportService.suggestMapping(headers),
          existingDuplicateKeys: {
            bondDuplicateKey(
              name: bond.name,
              issuer: bond.issuer,
              purchaseDate: bond.purchaseDate,
            ),
          },
          existingBonds: [bond],
        );
        expect(preview.updateCount, 0);
        expect(preview.rows.first.existingBond?.id, 42);
        expect(preview.rows.last.duplicateWithinFile, isTrue);
        final selected = preview.copyWith(
          rows: [
            preview.rows.first.copyWith(updateSelected: true),
            preview.rows.last,
          ],
        );
        expect(selected.updateCount, 1);
        expect(selected.selectedCount, 1);
      },
    );
  });
}
