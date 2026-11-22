import 'package:bondtrack/core/utils/date_utils.dart' as dates;
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/domain/entities/app_settings.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';

enum ReminderKind { interest, maturity, overdueInterest, overdueMaturity }

/// A deterministic, testable notification that should be scheduled on device.
class PlannedReminder {
  const PlannedReminder({
    required this.notificationId,
    required this.kind,
    required this.bondId,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.dedupeKey,
    this.scheduleId,
  });

  final int notificationId;
  final ReminderKind kind;
  final int bondId;
  final int? scheduleId;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String dedupeKey;

  String get payload => 'bond:$bondId';

  String get channelId => switch (kind) {
    ReminderKind.interest => 'bond_interest',
    ReminderKind.overdueInterest => 'bond_overdue',
    ReminderKind.maturity => 'bond_maturity',
    ReminderKind.overdueMaturity => 'bond_maturity',
  };
}

/// Pure reminder planner. The Android service only executes this plan, which
/// makes reminder behaviour unit-testable without platform channels.
class NotificationPlanner {
  const NotificationPlanner._();

  static const List<int> _overdueOffsets = [1, 7];

  static List<PlannedReminder> plan({
    required List<Bond> bonds,
    required List<InterestSchedule> schedules,
    required AppSettings settings,
    DateTime? now,
    int horizonMonths = 18,
  }) {
    if (!settings.remindersEnabled) return const [];
    final current = now ?? DateTime.now();
    final today = dates.dateOnly(current);
    final horizon = dates.addMonthsClamped(today, horizonMonths);
    final result = <PlannedReminder>[];
    final seen = <String>{};
    final bondById = {for (final bond in bonds) bond.id: bond};

    for (final schedule in schedules) {
      final bond = bondById[schedule.bondId];
      if (bond == null ||
          bond.status != BondStatus.active ||
          !bond.remindersEnabled ||
          !settings.interestReminders) {
        continue;
      }
      if (schedule.status == ScheduleStatus.paid ||
          schedule.status == ScheduleStatus.skipped) {
        continue;
      }
      final bondOffsets = bond.interestReminderOffsets.trim();
      final offsets = bondOffsets.isEmpty || bondOffsets == '7,3,1,0'
          ? settings.interestReminderDays
          : bond.interestReminderDays;
      for (final offset in offsets) {
        final at = _atNine(
          dates.dateOnly(schedule.dueDate).subtract(Duration(days: offset)),
        );
        final adjusted = applyQuietHours(at, settings);
        if (!adjusted.isAfter(current) || adjusted.isAfter(horizon)) continue;
        final dedupe = 'interest:${bond.id}:${schedule.id}:$offset';
        if (!seen.add(dedupe)) continue;
        result.add(
          PlannedReminder(
            notificationId: stableId(dedupe),
            kind: ReminderKind.interest,
            bondId: bond.id,
            scheduleId: schedule.id,
            title: offset == 0
                ? 'Interest due today'
                : 'Interest credit in $offset ${offset == 1 ? 'day' : 'days'}',
            body:
                '${bond.name} · ${_money(schedule.remainingPaise > 0 ? schedule.remainingPaise : schedule.expectedInterestPaise, settings.currencyCode)} expected on ${_date(schedule.dueDate)}',
            scheduledAt: adjusted,
            dedupeKey: dedupe,
          ),
        );
      }

      if (settings.overdueRemindersEnabled &&
          dates.dateOnly(schedule.dueDate).isBefore(today) &&
          schedule.remainingPaise > 0) {
        for (final offset in _overdueOffsets) {
          final at = _atNine(
            dates.dateOnly(schedule.dueDate).add(Duration(days: offset)),
          );
          final adjusted = applyQuietHours(at, settings);
          if (!adjusted.isAfter(current) || adjusted.isAfter(horizon)) continue;
          final dedupe = 'interest-overdue:${bond.id}:${schedule.id}:$offset';
          if (!seen.add(dedupe)) continue;
          result.add(
            PlannedReminder(
              notificationId: stableId(dedupe),
              kind: ReminderKind.overdueInterest,
              bondId: bond.id,
              scheduleId: schedule.id,
              title: 'Interest still pending',
              body:
                  '${bond.name} · ${_money(schedule.remainingPaise, settings.currencyCode)} was expected on ${_date(schedule.dueDate)}. Confirm the credit when received.',
              scheduledAt: adjusted,
              dedupeKey: dedupe,
            ),
          );
        }
      }
    }

    for (final bond in bonds) {
      if (bond.status != BondStatus.active ||
          !bond.remindersEnabled ||
          !settings.maturityReminders) {
        continue;
      }
      final bondOffsets = bond.maturityReminderOffsets.trim();
      final offsets = bondOffsets.isEmpty || bondOffsets == '30,15,7,1,0'
          ? settings.maturityReminderDays
          : bond.maturityReminderDays;
      final maturity = dates.dateOnly(bond.maturityDate);
      for (final offset in offsets) {
        final at = _atNine(maturity.subtract(Duration(days: offset)));
        final adjusted = applyQuietHours(at, settings);
        if (!adjusted.isAfter(current) || adjusted.isAfter(horizon)) continue;
        final dedupe = 'maturity:${bond.id}:$offset';
        if (!seen.add(dedupe)) continue;
        result.add(
          PlannedReminder(
            notificationId: stableId(dedupe),
            kind: ReminderKind.maturity,
            bondId: bond.id,
            title: offset == 0
                ? 'Bond matures today'
                : 'Bond matures in $offset ${offset == 1 ? 'day' : 'days'}',
            body:
                '${bond.name} · ${_money(bond.expectedMaturityAmountPaise, settings.currencyCode)} expected on ${_date(bond.maturityDate)}',
            scheduledAt: adjusted,
            dedupeKey: dedupe,
          ),
        );
      }

      if (settings.overdueRemindersEnabled && maturity.isBefore(today)) {
        for (final offset in _overdueOffsets) {
          final at = _atNine(maturity.add(Duration(days: offset)));
          final adjusted = applyQuietHours(at, settings);
          if (!adjusted.isAfter(current) || adjusted.isAfter(horizon)) continue;
          final dedupe = 'maturity-overdue:${bond.id}:$offset';
          if (!seen.add(dedupe)) continue;
          result.add(
            PlannedReminder(
              notificationId: stableId(dedupe),
              kind: ReminderKind.overdueMaturity,
              bondId: bond.id,
              title: 'Maturity proceeds not confirmed',
              body:
                  '${bond.name} matured on ${_date(bond.maturityDate)}. Confirm the ${_money(bond.expectedMaturityAmountPaise, settings.currencyCode)} payout.',
              scheduledAt: adjusted,
              dedupeKey: dedupe,
            ),
          );
        }
      }
    }

    result.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return result;
  }

  /// Moves a reminder that falls inside quiet hours to the end of the window.
  static DateTime applyQuietHours(DateTime at, AppSettings settings) {
    if (!settings.quietHoursEnabled) return at;
    final start = settings.quietStartHour.clamp(0, 23);
    final end = settings.quietEndHour.clamp(0, 23);
    if (start == end) return at;
    final hour = at.hour;
    final inside = start < end
        ? hour >= start && hour < end
        : hour >= start || hour < end;
    if (!inside) return at;
    if (start < end) {
      return DateTime(at.year, at.month, at.day, end);
    }
    if (hour >= start) {
      return DateTime(at.year, at.month, at.day + 1, end);
    }
    return DateTime(at.year, at.month, at.day, end);
  }

  static int stableId(String value) {
    var hash = 17;
    for (final code in value.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  static DateTime _atNine(DateTime date) =>
      DateTime(date.year, date.month, date.day, 9);

  static String _date(DateTime value) =>
      '${value.day} ${_months[value.month - 1]} ${value.year}';

  static String _money(int paise, String currencyCode) =>
      Money.formatPaise(paise, currencyCode: currencyCode, showDecimals: true);

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}
