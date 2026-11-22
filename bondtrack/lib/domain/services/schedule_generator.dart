import 'package:bondtrack/core/utils/date_utils.dart' as dates;
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/services/interest_engine.dart';

/// Generates the interest schedule for a bond from its first credit date to
/// maturity. Month-end anchors are preserved (e.g. 31 Jan -> 28 Feb -> 31 Mar)
/// and a final stub period is included when maturity falls between coupons.
class ScheduleGenerator {
  const ScheduleGenerator._();

  static List<GeneratedSchedule> generate({
    required DateTime purchaseDate,
    required DateTime firstInterestDate,
    required DateTime maturityDate,
    required InterestFrequency frequency,
    required int principalPaise,
    required double annualRate,
    InterestMethod method = InterestMethod.simple,
    CompoundingFrequency compounding = CompoundingFrequency.annual,
    DayCountConvention dayCount = DayCountConvention.equalPeriods,
    int? creditDay,
    int? manualInterestPerPeriodPaise,
  }) {
    final periods = InterestEngine.generatePeriods(
      purchaseDate: purchaseDate,
      firstInterestDate: firstInterestDate,
      maturityDate: maturityDate,
      frequency: frequency,
      principalPaise: principalPaise,
      annualRate: annualRate,
      method: method,
      compounding: compounding,
      dayCount: dayCount,
      creditDay: creditDay,
      manualInterestPerPeriodPaise: manualInterestPerPeriodPaise,
    );
    return [
      for (final period in periods)
        GeneratedSchedule(
          dueDate: period.dueDate,
          periodStart: period.periodStart,
          periodEnd: period.periodEnd,
          expectedInterestPaise: period.expectedInterestPaise,
        ),
    ];
  }

  /// Suggests the next credit date for a given day of month.
  static DateTime suggestedFirstCreditDate({
    required DateTime purchaseDate,
    required int creditDay,
  }) {
    return dates.nextDateForDay(purchaseDate, creditDay);
  }
}
