import 'package:drift/drift.dart';
import 'package:bondtrack/data/database/app_database.dart';
import 'package:bondtrack/domain/entities/app_notification.dart';
import 'package:bondtrack/domain/entities/app_settings.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';

extension BondRowMapper on BondRow {
  Bond toDomain() => Bond(
    id: id,
    name: name,
    issuer: issuer,
    principalPaise: principalPaise,
    annualRate: annualRate,
    purchaseDate: purchaseDate,
    frequency: frequency,
    firstInterestDate: firstInterestDate,
    maturityDate: maturityDate,
    expectedMaturityAmountPaise: expectedMaturityAmountPaise,
    paymentAccount: paymentAccount,
    notes: notes,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
    archivedAt: archivedAt,
    interestMethod: interestMethod,
    compoundingFrequency: compoundingFrequency,
    dayCountConvention: dayCountConvention,
    creditDay: creditDay,
    manualInterestPerPeriodPaise: manualInterestPerPeriodPaise,
    remindersEnabled: remindersEnabled,
    interestReminderOffsets: interestReminderOffsets,
    maturityReminderOffsets: maturityReminderOffsets,
  );
}

extension ScheduleRowMapper on ScheduleRow {
  InterestSchedule toDomain() => InterestSchedule(
    id: id,
    bondId: bondId,
    dueDate: dueDate,
    periodStart: periodStart,
    periodEnd: periodEnd,
    expectedInterestPaise: expectedInterestPaise,
    status: status,
    receivedPaise: receivedPaise,
    paidDate: paidDate,
    paymentId: paymentId,
  );
}

extension PaymentRowMapper on PaymentRow {
  PaymentTransaction toDomain() => PaymentTransaction(
    id: id,
    bondId: bondId,
    scheduleId: scheduleId,
    amountPaise: amountPaise,
    paidDate: paidDate,
    type: type,
    reference: reference,
    notes: notes,
    createdAt: createdAt,
  );
}

extension NotificationRowMapper on NotificationRow {
  AppNotification toDomain() => AppNotification(
    id: id,
    bondId: bondId,
    type: type,
    title: title,
    body: body,
    scheduledAt: scheduledAt,
    readAt: readAt,
    dedupeKey: dedupeKey,
    createdAt: createdAt,
  );
}

extension AppSettingsMapMapper on Map<String, String> {
  AppSettings toSettings() {
    final defaults = AppSettings.defaults;
    final reminderDays =
        int.tryParse(this['reminder_days'] ?? '') ?? defaults.reminderDays;
    return AppSettings(
      currencyCode: this['currency'] ?? defaults.currencyCode,
      themeMode: AppThemeMode.fromText(this['theme_mode']),
      remindersEnabled:
          _bool(this['reminders_enabled']) ?? defaults.remindersEnabled,
      interestReminders:
          _bool(this['interest_reminders']) ?? defaults.interestReminders,
      maturityReminders:
          _bool(this['maturity_reminders']) ?? defaults.maturityReminders,
      systemNotifications:
          _bool(this['system_notifications']) ?? defaults.systemNotifications,
      reminderDays: reminderDays.clamp(0, 60),
      defaultFrequency: this['default_frequency'] ?? defaults.defaultFrequency,
      onboardingComplete:
          _bool(this['onboarding_complete']) ?? defaults.onboardingComplete,
      lastBackupAt: DateTime.tryParse(this['last_backup_at'] ?? ''),
      interestReminderOffsets:
          this['interest_reminder_offsets'] ??
          defaults.interestReminderOffsets,
      maturityReminderOffsets:
          this['maturity_reminder_offsets'] ??
          defaults.maturityReminderOffsets,
      overdueRemindersEnabled:
          _bool(this['overdue_reminders_enabled']) ??
          defaults.overdueRemindersEnabled,
      quietHoursEnabled:
          _bool(this['quiet_hours_enabled']) ?? defaults.quietHoursEnabled,
      quietStartHour:
          (int.tryParse(this['quiet_start_hour'] ?? '') ??
                  defaults.quietStartHour)
              .clamp(0, 23),
      quietEndHour:
          (int.tryParse(this['quiet_end_hour'] ?? '') ?? defaults.quietEndHour)
              .clamp(0, 23),
      appLockEnabled:
          _bool(this['app_lock_enabled']) ?? defaults.appLockEnabled,
    );
  }

  bool? _bool(String? value) {
    if (value == null) return null;
    return value == 'true' || value == '1';
  }
}

Map<String, String> settingsToMap(AppSettings settings) => {
  'currency': settings.currencyCode,
  'theme_mode': settings.themeMode.name,
  'reminders_enabled': settings.remindersEnabled.toString(),
  'interest_reminders': settings.interestReminders.toString(),
  'maturity_reminders': settings.maturityReminders.toString(),
  'system_notifications': settings.systemNotifications.toString(),
  'reminder_days': settings.reminderDays.toString(),
  'default_frequency': settings.defaultFrequency,
  'onboarding_complete': settings.onboardingComplete.toString(),
  'interest_reminder_offsets': settings.interestReminderOffsets,
  'maturity_reminder_offsets': settings.maturityReminderOffsets,
  'overdue_reminders_enabled': settings.overdueRemindersEnabled.toString(),
  'quiet_hours_enabled': settings.quietHoursEnabled.toString(),
  'quiet_start_hour': settings.quietStartHour.toString(),
  'quiet_end_hour': settings.quietEndHour.toString(),
  'app_lock_enabled': settings.appLockEnabled.toString(),
  if (settings.lastBackupAt != null)
    'last_backup_at': settings.lastBackupAt!.toIso8601String(),
};

BondsCompanion bondDraftToCompanion(
  BondDraft draft, {
  required DateTime now,
  required DateTime createdAt,
}) {
  return BondsCompanion(
    name: Value(draft.name.trim()),
    issuer: Value(draft.issuer.trim()),
    principalPaise: Value(draft.principalPaise),
    annualRate: Value(draft.annualRate),
    purchaseDate: Value(draft.purchaseDate),
    frequency: Value(draft.frequency),
    firstInterestDate: Value(draft.firstInterestDate),
    maturityDate: Value(draft.maturityDate),
    expectedMaturityAmountPaise: Value(draft.expectedMaturityAmountPaise),
    paymentAccount: Value(
      (draft.paymentAccount ?? '').trim().isEmpty
          ? null
          : draft.paymentAccount!.trim(),
    ),
    notes: Value(
      (draft.notes ?? '').trim().isEmpty ? null : draft.notes!.trim(),
    ),
    status: Value(draft.status),
    interestMethod: Value(draft.interestMethod),
    compoundingFrequency: Value(draft.compoundingFrequency),
    dayCountConvention: Value(draft.dayCountConvention),
    creditDay: Value(draft.creditDay),
    manualInterestPerPeriodPaise: Value(draft.manualInterestPerPeriodPaise),
    remindersEnabled: Value(draft.remindersEnabled),
    interestReminderOffsets: Value(draft.interestReminderOffsets),
    maturityReminderOffsets: Value(draft.maturityReminderOffsets),
    createdAt: Value(createdAt),
    updatedAt: Value(now),
  );
}

InterestSchedulesCompanion generatedScheduleToCompanion(
  int bondId,
  GeneratedSchedule schedule,
) {
  return InterestSchedulesCompanion.insert(
    bondId: bondId,
    dueDate: schedule.dueDate,
    periodStart: schedule.periodStart,
    periodEnd: schedule.periodEnd,
    expectedInterestPaise: schedule.expectedInterestPaise,
  );
}
