import 'package:drift/drift.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/app_notification.dart';

/// Bonds are the aggregate root. Amounts are integer paise; rates are percent.
@DataClassName('BondRow')
@TableIndex(name: 'idx_bonds_status', columns: {#status})
@TableIndex(name: 'idx_bonds_maturity', columns: {#maturityDate})
class Bonds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 160)();
  TextColumn get issuer => text().withLength(min: 1, max: 160)();
  IntColumn get principalPaise => integer()();
  RealColumn get annualRate => real()();
  DateTimeColumn get purchaseDate => dateTime()();
  TextColumn get frequency => textEnum<InterestFrequency>()();
  DateTimeColumn get firstInterestDate => dateTime()();
  DateTimeColumn get maturityDate => dateTime()();
  IntColumn get expectedMaturityAmountPaise => integer()();
  TextColumn get paymentAccount => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status =>
      textEnum<BondStatus>().withDefault(const Constant('active'))();
  TextColumn get interestMethod =>
      textEnum<InterestMethod>().withDefault(const Constant('simple'))();
  TextColumn get compoundingFrequency =>
      textEnum<CompoundingFrequency>().withDefault(const Constant('annual'))();
  TextColumn get dayCountConvention => textEnum<DayCountConvention>()
      .withDefault(const Constant('equalPeriods'))();
  IntColumn get creditDay => integer().nullable()();
  IntColumn get manualInterestPerPeriodPaise => integer().nullable()();
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get interestReminderOffsets =>
      text().withDefault(const Constant('7,3,1,0'))();
  TextColumn get maturityReminderOffsets =>
      text().withDefault(const Constant('30,15,7,1,0'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

@DataClassName('ScheduleRow')
@TableIndex(name: 'idx_schedules_bond', columns: {#bondId})
@TableIndex(name: 'idx_schedules_due', columns: {#dueDate})
@TableIndex(name: 'idx_schedules_status', columns: {#status})
class InterestSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bondId =>
      integer().references(Bonds, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime()();
  IntColumn get expectedInterestPaise => integer()();
  IntColumn get receivedPaise => integer().withDefault(const Constant(0))();
  TextColumn get status =>
      textEnum<ScheduleStatus>().withDefault(const Constant('pending'))();
  DateTimeColumn get paidDate => dateTime().nullable()();
  IntColumn get paymentId => integer().nullable().references(
    PaymentTransactions,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

@DataClassName('PaymentRow')
@TableIndex(name: 'idx_payments_bond', columns: {#bondId})
@TableIndex(name: 'idx_payments_date', columns: {#paidDate})
class PaymentTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bondId =>
      integer().references(Bonds, #id, onDelete: KeyAction.cascade)();
  IntColumn get scheduleId => integer().nullable().references(
    InterestSchedules,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get amountPaise => integer()();
  DateTimeColumn get paidDate => dateTime()();
  TextColumn get type => textEnum<PaymentType>()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('NotificationRow')
@TableIndex(
  name: 'idx_notifications_dedupe',
  columns: {#dedupeKey},
  unique: true,
)
@TableIndex(name: 'idx_notifications_read', columns: {#readAt})
class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bondId => integer().nullable().references(
    Bonds,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get type => textEnum<AppNotificationType>()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();
  TextColumn get dedupeKey => text()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Flexible key/value settings so new preferences can be added without a
/// destructive schema migration.
@DataClassName('SettingRow')
class AppSettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
