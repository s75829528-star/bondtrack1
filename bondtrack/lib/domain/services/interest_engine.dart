import 'package:bondtrack/core/utils/date_utils.dart' as dates;
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';

/// Status shown for an expected interest credit.
enum PaymentStatus {
  upcoming,
  dueToday,
  received,
  partiallyReceived,
  overdue;

  String get label => switch (this) {
    PaymentStatus.upcoming => 'Upcoming',
    PaymentStatus.dueToday => 'Due today',
    PaymentStatus.received => 'Received',
    PaymentStatus.partiallyReceived => 'Partially received',
    PaymentStatus.overdue => 'Overdue',
  };

  bool get isReceived => this == PaymentStatus.received;
  bool get isOverdue =>
      this == PaymentStatus.overdue || this == PaymentStatus.partiallyReceived;
}

/// One calculated coupon period. All amounts are integer paise.
class ComputedPeriod {
  const ComputedPeriod({
    required this.dueDate,
    required this.periodStart,
    required this.periodEnd,
    required this.expectedInterestPaise,
  });

  final DateTime dueDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int expectedInterestPaise;
}

/// Complete projection for one bond. This is the single source of truth used
/// by the dashboard, analytics, forms, reminders and maturity tracker.
class BondProjection {
  const BondProjection({
    required this.periods,
    required this.expectedMonthlyInterestPaise,
    required this.expectedQuarterlyInterestPaise,
    required this.expectedHalfYearlyInterestPaise,
    required this.expectedAnnualInterestPaise,
    required this.totalExpectedInterestPaise,
    required this.expectedMaturityProceedsPaise,
    required this.totalInterestReceivedPaise,
    required this.nextPaymentDate,
    required this.nextPaymentAmountPaise,
    required this.computedMaturityProceedsPaise,
  });

  final List<ComputedPeriod> periods;
  final int expectedMonthlyInterestPaise;
  final int expectedQuarterlyInterestPaise;
  final int expectedHalfYearlyInterestPaise;
  final int expectedAnnualInterestPaise;
  final int totalExpectedInterestPaise;
  final int expectedMaturityProceedsPaise;
  final int totalInterestReceivedPaise;
  final DateTime? nextPaymentDate;
  final int nextPaymentAmountPaise;
  final int computedMaturityProceedsPaise;

  bool get isEmpty => periods.isEmpty;
}

/// Central financial calculation engine.
///
/// Monetary inputs and outputs are integer paise. Rate arithmetic is performed
/// with [BigInt] numerators so large portfolios do not lose precision, and
/// rounding is half-up at the final step.
class InterestEngine {
  const InterestEngine._();

  static const int _maxPeriods = 1200;

  /// Half-up rounding for positive values. Negative values round away from
  /// zero, which keeps refunds and differences symmetric.
  static int roundDiv(BigInt numerator, BigInt denominator) {
    if (denominator == BigInt.zero) return 0;
    final negative = numerator.isNegative != denominator.isNegative;
    final n = numerator.abs();
    final d = denominator.abs();
    final quotient = n ~/ d;
    final remainder = n % d;
    final rounded = remainder * BigInt.two >= d
        ? quotient + BigInt.one
        : quotient;
    return (negative ? -rounded : rounded).toInt();
  }

  static BigInt _rateBps(double annualRate) =>
      BigInt.from((annualRate * 100).round());

  /// Number of days according to the 30/360 convention.
  static int days30360(DateTime start, DateTime end) {
    var d1 = start.day;
    var d2 = end.day;
    if (d1 == 31) d1 = 30;
    if (d2 == 31 && d1 == 30) d2 = 30;
    return (end.year - start.year) * 360 +
        (end.month - start.month) * 30 +
        (d2 - d1);
  }

  /// Interest for one period using the selected day-count convention.
  static int interestForPeriod({
    required int principalPaise,
    required double annualRate,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DayCountConvention dayCount,
    required int periodMonths,
  }) {
    if (principalPaise <= 0 || annualRate <= 0) return 0;
    final start = dates.dateOnly(periodStart);
    final end = dates.dateOnly(periodEnd);
    if (!end.isAfter(start)) return 0;
    final principal = BigInt.from(principalPaise);
    final rate = _rateBps(annualRate);

    switch (dayCount) {
      case DayCountConvention.equalPeriods:
        if (periodMonths <= 0) return 0;
        return roundDiv(
          principal * rate * BigInt.from(periodMonths),
          BigInt.from(10000 * 12),
        );
      case DayCountConvention.actual365:
        final days = end.difference(start).inDays;
        return roundDiv(
          principal * rate * BigInt.from(days),
          BigInt.from(10000 * 365),
        );
      case DayCountConvention.actualActual:
        // Split the period at year boundaries so a leap year receives 366
        // denominator days while ordinary years receive 365.
        var cursor = start;
        var total = BigInt.zero;
        while (cursor.isBefore(end)) {
          final nextYear = DateTime(cursor.year + 1);
          final segmentEnd = nextYear.isBefore(end) ? nextYear : end;
          final segmentDays = segmentEnd.difference(cursor).inDays;
          final yearDays = _isLeapYear(cursor.year) ? 366 : 365;
          total += BigInt.from(
            roundDiv(
              principal * rate * BigInt.from(segmentDays),
              BigInt.from(10000 * yearDays),
            ),
          );
          cursor = segmentEnd;
        }
        return total.toInt();
      case DayCountConvention.thirty360:
        final days = days30360(start, end);
        return roundDiv(
          principal * rate * BigInt.from(days),
          BigInt.from(10000 * 360),
        );
    }
  }

  static bool _isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  /// Compound interest for a single period, added to [balancePaise].
  static int compoundInterestForPeriod({
    required int balancePaise,
    required double annualRate,
    required DateTime periodStart,
    required DateTime periodEnd,
    required CompoundingFrequency compounding,
  }) {
    if (balancePaise <= 0 || annualRate <= 0) return 0;
    final start = dates.dateOnly(periodStart);
    final end = dates.dateOnly(periodEnd);
    if (!end.isAfter(start)) return 0;
    final rate = _rateBps(annualRate);
    final periods = compounding.periodsPerYear;

    // Count whole compounding periods and pro-rate any remainder daily.
    var cursor = start;
    var balance = balancePaise;
    var iterations = 0;
    while (iterations < _maxPeriods) {
      final next = dates.addMonthsClamped(
        cursor,
        compounding.months,
        anchorDay: cursor.day,
      );
      if (next.isAfter(end)) break;
      final interest = roundDiv(
        BigInt.from(balance) * rate,
        BigInt.from(10000 * periods),
      );
      balance += interest;
      cursor = next;
      iterations++;
    }
    final remainderDays = end.difference(cursor).inDays;
    if (remainderDays > 0) {
      balance += roundDiv(
        BigInt.from(balance) * rate * BigInt.from(remainderDays),
        BigInt.from(10000 * 365),
      );
    }
    return balance - balancePaise;
  }

  /// Compound balance at [end] starting from [principalPaise] at [start].
  static int compoundBalance({
    required int principalPaise,
    required double annualRate,
    required DateTime start,
    required DateTime end,
    required CompoundingFrequency compounding,
  }) {
    if (principalPaise <= 0 || annualRate <= 0) return principalPaise;
    final startDate = dates.dateOnly(start);
    final endDate = dates.dateOnly(end);
    if (!endDate.isAfter(startDate)) return principalPaise;
    return principalPaise +
        compoundInterestForPeriod(
          balancePaise: principalPaise,
          annualRate: annualRate,
          periodStart: startDate,
          periodEnd: endDate,
          compounding: compounding,
        );
  }

  /// Builds scheduled coupon dates from the first credit date through
  /// maturity. No extra stub coupon is invented when maturity falls between
  /// credit dates; issuers' redemption terms can be entered as a manual coupon.
  static List<ComputedPeriod> generatePeriods({
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
    if (principalPaise <= 0 || annualRate <= 0) return const [];
    final purchase = dates.dateOnly(purchaseDate);
    final maturity = dates.dateOnly(maturityDate);
    if (!maturity.isAfter(purchase)) return const [];

    var first = dates.dateOnly(firstInterestDate);
    if (first.isBefore(purchase)) first = purchase;
    if (first.isAfter(maturity)) return const [];

    final anchorDay = (creditDay ?? first.day).clamp(1, 31);
    if (creditDay != null && first.day != anchorDay) {
      first = dates.nextDateForDay(first, anchorDay);
      if (first.isAfter(maturity)) return const [];
    }

    final periods = <ComputedPeriod>[];
    var previous = purchase;
    var due = first;
    var index = 0;
    var balance = principalPaise;

    while (!due.isAfter(maturity) && index < _maxPeriods) {
      final int amount;
      if (manualInterestPerPeriodPaise != null &&
          manualInterestPerPeriodPaise > 0) {
        amount = manualInterestPerPeriodPaise;
        if (method == InterestMethod.compound) balance += amount;
      } else if (method == InterestMethod.compound) {
        amount = compoundInterestForPeriod(
          balancePaise: balance,
          annualRate: annualRate,
          periodStart: previous,
          periodEnd: due,
          compounding: compounding,
        );
        balance += amount;
      } else {
        amount = interestForPeriod(
          principalPaise: principalPaise,
          annualRate: annualRate,
          periodStart: previous,
          periodEnd: due,
          dayCount: dayCount,
          periodMonths: frequency.months,
        );
      }
      periods.add(
        ComputedPeriod(
          dueDate: due,
          periodStart: previous,
          periodEnd: due,
          expectedInterestPaise: amount < 0 ? 0 : amount,
        ),
      );
      previous = due;
      index++;
      due = dates.addMonthsClamped(
        first,
        frequency.months * index,
        anchorDay: anchorDay,
      );
    }

    return periods;
  }

  /// Interest expected for an arbitrary number of months. Used for the
  /// monthly/quarterly/half-yearly/annual summary cards.
  static int interestForMonths({
    required int principalPaise,
    required double annualRate,
    required int months,
    InterestMethod method = InterestMethod.simple,
    CompoundingFrequency compounding = CompoundingFrequency.annual,
    DayCountConvention dayCount = DayCountConvention.equalPeriods,
  }) {
    if (months <= 0) return 0;
    if (method == InterestMethod.compound) {
      final start = DateTime(2001, 1, 1);
      final end = dates.addMonthsClamped(start, months, anchorDay: 1);
      return compoundBalance(
            principalPaise: principalPaise,
            annualRate: annualRate,
            start: start,
            end: end,
            compounding: compounding,
          ) -
          principalPaise;
    }
    if (dayCount == DayCountConvention.equalPeriods) {
      return roundDiv(
        BigInt.from(principalPaise) *
            _rateBps(annualRate) *
            BigInt.from(months),
        BigInt.from(10000 * 12),
      );
    }
    final start = DateTime(2001, 1, 1);
    final end = dates.addMonthsClamped(start, months, anchorDay: 1);
    return interestForPeriod(
      principalPaise: principalPaise,
      annualRate: annualRate,
      periodStart: start,
      periodEnd: end,
      dayCount: dayCount,
      periodMonths: months,
    );
  }

  static int computedMaturityProceeds({
    required int principalPaise,
    required double annualRate,
    required DateTime purchaseDate,
    required DateTime maturityDate,
    required InterestMethod method,
    required CompoundingFrequency compounding,
  }) {
    if (method == InterestMethod.compound) {
      return compoundBalance(
        principalPaise: principalPaise,
        annualRate: annualRate,
        start: purchaseDate,
        end: maturityDate,
        compounding: compounding,
      );
    }
    // For simple interest the proceeds are principal plus every generated
    // coupon, so the caller's schedule is authoritative.
    return principalPaise;
  }

  /// Full projection for a stored bond and its payments.
  static BondProjection projectionForBond(
    Bond bond, {
    List<PaymentTransaction> payments = const [],
    DateTime? now,
  }) {
    final periods = generatePeriods(
      purchaseDate: bond.purchaseDate,
      firstInterestDate: bond.firstInterestDate,
      maturityDate: bond.maturityDate,
      frequency: bond.frequency,
      principalPaise: bond.principalPaise,
      annualRate: bond.annualRate,
      method: bond.interestMethod,
      compounding: bond.compoundingFrequency,
      dayCount: bond.dayCountConvention,
      creditDay: bond.creditDay,
      manualInterestPerPeriodPaise: bond.manualInterestPerPeriodPaise,
    );
    final totalExpected = periods.fold(
      0,
      (sum, period) => sum + period.expectedInterestPaise,
    );
    final computedProceeds = computedMaturityProceeds(
      principalPaise: bond.principalPaise,
      annualRate: bond.annualRate,
      purchaseDate: bond.purchaseDate,
      maturityDate: bond.maturityDate,
      method: bond.interestMethod,
      compounding: bond.compoundingFrequency,
    );
    final expectedProceeds = bond.expectedMaturityAmountPaise > 0
        ? bond.expectedMaturityAmountPaise
        : (bond.interestMethod == InterestMethod.compound
              ? computedProceeds
              : bond.principalPaise + totalExpected);
    final interestPayments = payments.where(
      (payment) =>
          payment.bondId == bond.id && payment.type == PaymentType.interest,
    );
    final totalReceived = interestPayments.fold(
      0,
      (sum, payment) => sum + payment.amountPaise,
    );

    final today = dates.dateOnly(now ?? DateTime.now());
    ComputedPeriod? next;
    for (final period in periods) {
      if (!dates.dateOnly(period.dueDate).isBefore(today)) {
        next = period;
        break;
      }
    }

    return BondProjection(
      periods: periods,
      expectedMonthlyInterestPaise: _summaryInterest(bond, 1),
      expectedQuarterlyInterestPaise: _summaryInterest(bond, 3),
      expectedHalfYearlyInterestPaise: _summaryInterest(bond, 6),
      expectedAnnualInterestPaise: _summaryInterest(bond, 12),
      totalExpectedInterestPaise: totalExpected,
      expectedMaturityProceedsPaise: expectedProceeds,
      totalInterestReceivedPaise: totalReceived,
      nextPaymentDate: next?.dueDate,
      nextPaymentAmountPaise: next?.expectedInterestPaise ?? 0,
      computedMaturityProceedsPaise:
          bond.interestMethod == InterestMethod.compound
          ? computedProceeds
          : bond.principalPaise + totalExpected,
    );
  }

  static int _summaryInterest(Bond bond, int months) {
    final manual = bond.manualInterestPerPeriodPaise;
    if (manual != null && manual > 0) {
      return roundDiv(
        BigInt.from(manual) * BigInt.from(months),
        BigInt.from(bond.frequency.months),
      );
    }
    return interestForMonths(
      principalPaise: bond.principalPaise,
      annualRate: bond.annualRate,
      months: months,
      method: bond.interestMethod,
      compounding: bond.compoundingFrequency,
      dayCount: bond.dayCountConvention,
    );
  }

  /// Payment status for a schedule with partial receipts.
  static PaymentStatus paymentStatus({
    required DateTime dueDate,
    required int expectedPaise,
    required int receivedPaise,
    DateTime? now,
  }) {
    final today = dates.dateOnly(now ?? DateTime.now());
    final due = dates.dateOnly(dueDate);
    if (expectedPaise > 0 && receivedPaise >= expectedPaise) {
      return PaymentStatus.received;
    }
    if (receivedPaise > 0) {
      return PaymentStatus.partiallyReceived;
    }
    if (due.isBefore(today)) return PaymentStatus.overdue;
    if (due.isAtSameMomentAs(today)) return PaymentStatus.dueToday;
    return PaymentStatus.upcoming;
  }

  /// Converts a receipt total into the persisted schedule status.
  static ScheduleStatus scheduleStatus({
    required int expectedPaise,
    required int receivedPaise,
  }) {
    if (receivedPaise <= 0) return ScheduleStatus.pending;
    if (expectedPaise > 0 && receivedPaise >= expectedPaise) {
      return ScheduleStatus.paid;
    }
    return ScheduleStatus.partiallyPaid;
  }

  /// Total interest expected between two dates using generated periods.
  static int expectedInterestBetween({
    required Bond bond,
    required DateTime start,
    required DateTime end,
  }) {
    final periods = generatePeriods(
      purchaseDate: bond.purchaseDate,
      firstInterestDate: bond.firstInterestDate,
      maturityDate: bond.maturityDate,
      frequency: bond.frequency,
      principalPaise: bond.principalPaise,
      annualRate: bond.annualRate,
      method: bond.interestMethod,
      compounding: bond.compoundingFrequency,
      dayCount: bond.dayCountConvention,
      creditDay: bond.creditDay,
      manualInterestPerPeriodPaise: bond.manualInterestPerPeriodPaise,
    );
    final from = dates.dateOnly(start);
    final to = dates.dateOnly(end);
    return periods
        .where((period) {
          final due = dates.dateOnly(period.dueDate);
          return !due.isBefore(from) && !due.isAfter(to);
        })
        .fold(0, (sum, period) => sum + period.expectedInterestPaise);
  }
}
