import 'package:bondtrack/core/utils/date_utils.dart' as dates;
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';
import 'package:bondtrack/domain/models/portfolio_models.dart';
import 'package:bondtrack/domain/services/interest_engine.dart';

/// Pure portfolio analytics. Widgets never perform financial calculations
/// themselves; they only render the results from this calculator.
class PortfolioCalculator {
  const PortfolioCalculator._();

  static DashboardData dashboard({
    required List<Bond> bonds,
    required List<InterestSchedule> schedules,
    required List<PaymentTransaction> payments,
    DateTime? now,
  }) {
    final today = dates.dateOnly(now ?? DateTime.now());
    final bondById = {for (final bond in bonds) bond.id: bond};
    final active = bonds
        .where((bond) => bond.status == BondStatus.active)
        .toList();

    final activeIds = active.map((bond) => bond.id).toSet();
    final activeSchedules = schedules
        .where((s) => activeIds.contains(s.bondId))
        .toList();

    final pending = activeSchedules
        .where(
          (s) =>
              s.status == ScheduleStatus.pending ||
              s.status == ScheduleStatus.partiallyPaid,
        )
        .toList();
    final upcoming =
        pending
            .where((s) => !dates.dateOnly(s.dueDate).isBefore(today))
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final overdue =
        pending
            .where((s) => dates.dateOnly(s.dueDate).isBefore(today))
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final upcomingPayments = <ScheduleWithBond>[
      for (final schedule in upcoming.take(6))
        if (bondById[schedule.bondId] != null)
          ScheduleWithBond(
            schedule: schedule,
            bond: bondById[schedule.bondId]!,
          ),
    ];
    final overdueSchedules = <ScheduleWithBond>[
      for (final schedule in overdue.take(6))
        if (bondById[schedule.bondId] != null)
          ScheduleWithBond(
            schedule: schedule,
            bond: bondById[schedule.bondId]!,
          ),
    ];

    final maturities =
        active
            .where((bond) => !dates.dateOnly(bond.maturityDate).isBefore(today))
            .toList()
          ..sort((a, b) => a.maturityDate.compareTo(b.maturityDate));

    final totalInvested = active.fold(
      0,
      (sum, bond) => sum + bond.principalPaise,
    );
    final projections = {
      for (final bond in active)
        bond.id: InterestEngine.projectionForBond(bond, now: now),
    };
    final monthlyIncome = active.fold(
      0,
      (sum, bond) =>
          sum + (projections[bond.id]?.expectedMonthlyInterestPaise ?? 0),
    );
    final annualIncome = active.fold(
      0,
      (sum, bond) =>
          sum + (projections[bond.id]?.expectedAnnualInterestPaise ?? 0),
    );
    final totalExpectedInterest = activeSchedules
        .where((s) => s.status != ScheduleStatus.skipped)
        .fold(0, (sum, schedule) => sum + schedule.expectedInterestPaise);
    final interestPayments = payments
        .where((p) => p.type == PaymentType.interest)
        .toList();
    final totalReceived = interestPayments.fold(
      0,
      (sum, p) => sum + p.amountPaise,
    );
    final pendingInterest = pending.fold(
      0,
      (sum, schedule) => sum + schedule.remainingPaise,
    );
    final overdueAmount = overdue.fold(
      0,
      (sum, schedule) => sum + schedule.remainingPaise,
    );

    final monthStart = dates.startOfMonth(today);
    final monthEnd = dates.endOfMonth(today);
    final expectedThisMonth = activeSchedules
        .where(
          (s) =>
              s.status != ScheduleStatus.skipped &&
              dates.isWithin(s.dueDate, monthStart, monthEnd),
        )
        .fold(0, (sum, schedule) => sum + schedule.expectedInterestPaise);
    final receivedThisMonth = interestPayments
        .where((p) => dates.isWithin(p.paidDate, monthStart, monthEnd))
        .fold(0, (sum, p) => sum + p.amountPaise);

    final monthlySeries = _monthlySeries(
      today: today,
      schedules: activeSchedules,
      payments: interestPayments,
      monthsBack: 5,
      monthsForward: 6,
    );
    final annualSeries = _annualSeries(
      today: today,
      schedules: activeSchedules,
      payments: interestPayments,
      yearsBack: 2,
      yearsForward: 3,
    );

    final distribution = _distribution(
      active,
      (bond) => bond.issuer,
      maxSlices: 5,
    );

    final recent = [...payments]
      ..sort((a, b) => b.paidDate.compareTo(a.paidDate));
    final recentPayments = <PaymentWithBond>[
      for (final payment in recent.take(5))
        if (bondById[payment.bondId] != null)
          PaymentWithBond(payment: payment, bond: bondById[payment.bondId]!),
    ];

    final weightedYield = _weightedYield(active);
    final maturityValue = active.fold(
      0,
      (sum, bond) => sum + bond.expectedMaturityAmountPaise,
    );
    final timeline = _upcomingTimeline(
      upcomingPayments: upcomingPayments,
      overdueSchedules: overdueSchedules,
      upcomingMaturities: maturities,
      today: today,
    );
    final healthScore = _healthScore(
      active: active,
      distribution: distribution,
      overdueCount: overdue.length,
      receivedRatio: totalExpectedInterest == 0
          ? 1
          : totalReceived / totalExpectedInterest,
    );

    return DashboardData(
      totalInvestedPaise: totalInvested,
      expectedMonthlyInterestPaise: monthlyIncome,
      expectedAnnualInterestPaise: annualIncome,
      totalInterestReceivedPaise: totalReceived,
      pendingInterestPaise: pendingInterest,
      activeBondCount: active.length,
      overdueCount: overdue.length,
      upcomingPayments: upcomingPayments,
      upcomingMaturities: maturities.take(5).toList(),
      monthlySeries: monthlySeries,
      annualSeries: annualSeries,
      distribution: distribution,
      recentPayments: recentPayments,
      weightedYield: weightedYield,
      maturityValuePaise: maturityValue,
      expectedThisMonthPaise: expectedThisMonth,
      receivedThisMonthPaise: receivedThisMonth,
      overdueAmountPaise: overdueAmount,
      overdueSchedules: overdueSchedules,
      upcomingTimeline: timeline,
      healthScore: healthScore.$1,
      healthLabel: healthScore.$2,
      totalExpectedInterestPaise: totalExpectedInterest,
      nextPayment: upcomingPayments.isEmpty ? null : upcomingPayments.first,
      nextMaturity: maturities.isEmpty ? null : maturities.first,
    );
  }

  static AnalyticsData analytics({
    required List<Bond> bonds,
    required List<InterestSchedule> schedules,
    required List<PaymentTransaction> payments,
    DateTime? now,
    AnalyticsPeriod period = AnalyticsPeriod.all,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final today = dates.dateOnly(now ?? DateTime.now());
    final active = bonds
        .where((bond) => bond.status == BondStatus.active)
        .toList();
    final activeIds = active.map((bond) => bond.id).toSet();
    final activeSchedules = schedules
        .where((s) => activeIds.contains(s.bondId))
        .toList();
    final interestPayments = payments
        .where((p) => p.type == PaymentType.interest)
        .toList();

    final range = _range(
      period: period,
      now: today,
      bonds: bonds,
      customStart: customStart,
      customEnd: customEnd,
    );

    final totalInvested = active.fold(
      0,
      (sum, bond) => sum + bond.principalPaise,
    );
    final lifetimeInterest = interestPayments.fold(
      0,
      (sum, p) => sum + p.amountPaise,
    );
    final interestThisYear = interestPayments
        .where((p) => p.paidDate.year == today.year)
        .fold(0, (sum, p) => sum + p.amountPaise);

    final next12MonthsEnd = dates.addMonthsClamped(today, 12);
    final next12 = activeSchedules
        .where(
          (s) =>
              (s.status == ScheduleStatus.pending ||
                  s.status == ScheduleStatus.partiallyPaid) &&
              !dates.dateOnly(s.dueDate).isBefore(today) &&
              !dates.dateOnly(s.dueDate).isAfter(next12MonthsEnd),
        )
        .fold(0, (sum, s) => sum + s.remainingPaise);

    final paidSchedules = activeSchedules
        .where((s) => s.status == ScheduleStatus.paid)
        .toList();
    final overdueSchedules = activeSchedules
        .where(
          (s) =>
              (s.status == ScheduleStatus.pending ||
                  s.status == ScheduleStatus.partiallyPaid) &&
              dates.dateOnly(s.dueDate).isBefore(today),
        )
        .toList();
    final onTimeDenominator = paidSchedules.length + overdueSchedules.length;
    final onTimeRate = onTimeDenominator == 0
        ? 1.0
        : paidSchedules.length / onTimeDenominator;

    final topHoldings = [...active]
      ..sort((a, b) => b.principalPaise.compareTo(a.principalPaise));

    final expectedInRange = activeSchedules
        .where(
          (s) =>
              s.status != ScheduleStatus.skipped &&
              dates.isWithin(s.dueDate, range.$1, range.$2),
        )
        .fold(0, (sum, s) => sum + s.expectedInterestPaise);
    final receivedInRange = interestPayments
        .where((p) => dates.isWithin(p.paidDate, range.$1, range.$2))
        .fold(0, (sum, p) => sum + p.amountPaise);

    final contributions = <BondContribution>[];
    for (final bond in active) {
      final expected = activeSchedules
          .where((s) => s.bondId == bond.id && s.status != ScheduleStatus.skipped)
          .fold(0, (sum, s) => sum + s.expectedInterestPaise);
      final received = interestPayments
          .where((p) => p.bondId == bond.id)
          .fold(0, (sum, p) => sum + p.amountPaise);
      contributions.add(
        BondContribution(
          bondId: bond.id,
          name: bond.name,
          issuer: bond.issuer,
          expectedPaise: expected,
          receivedPaise: received,
          annualRate: bond.annualRate,
        ),
      );
    }
    contributions.sort((a, b) => b.expectedPaise.compareTo(a.expectedPaise));

    final cashFlow = _cashFlowForecast(
      today: today,
      bonds: active,
      schedules: activeSchedules,
      months: 18,
    );
    final exposure = _maturityExposure(bonds: active, today: today);
    final upcomingExposureEnd = dates.addMonthsClamped(today, 12);
    final upcomingExposure = active
        .where(
          (bond) =>
              !dates.dateOnly(bond.maturityDate).isBefore(today) &&
              !dates.dateOnly(bond.maturityDate).isAfter(upcomingExposureEnd),
        )
        .fold(0, (sum, bond) => sum + bond.expectedMaturityAmountPaise);
    final overdueAmount = overdueSchedules.fold(
      0,
      (sum, s) => sum + s.remainingPaise,
    );

    return AnalyticsData(
      totalInvestedPaise: totalInvested,
      lifetimeInterestPaise: lifetimeInterest,
      interestThisYearPaise: interestThisYear,
      projectedAnnualIncomePaise: active.fold(
        0,
        (sum, bond) =>
            sum +
            InterestEngine.projectionForBond(bond).expectedAnnualInterestPaise,
      ),
      weightedYield: _weightedYield(active),
      averageMonthsToMaturity: _averageMonthsToMaturity(active, today),
      maturityValuePaise: active.fold(
        0,
        (sum, bond) => sum + bond.expectedMaturityAmountPaise,
      ),
      annualSeries: _annualSeries(
        today: today,
        schedules: activeSchedules,
        payments: interestPayments,
        yearsBack: 3,
        yearsForward: 3,
      ),
      issuerSlices: _distribution(active, (bond) => bond.issuer, maxSlices: 6),
      frequencySlices: _distribution(
        active,
        (bond) => bond.frequency.label,
        maxSlices: 4,
      ),
      topHoldings: topHoldings.take(6).toList(),
      paidOnTimeRate: onTimeRate,
      paymentCount: interestPayments.length,
      next12MonthsInterestPaise: next12,
      activeBondCount: active.length,
      rangeStart: range.$1,
      rangeEnd: range.$2,
      receivedInRangePaise: receivedInRange,
      expectedInRangePaise: expectedInRange,
      bondContributions: contributions,
      monthlyCashFlow: cashFlow,
      maturityExposure: exposure,
      upcomingMaturityExposurePaise: upcomingExposure,
      overdueAmountPaise: overdueAmount,
    );
  }

  static List<MaturityBucket> maturityBuckets({
    required List<Bond> bonds,
    DateTime? now,
  }) {
    final today = dates.dateOnly(now ?? DateTime.now());
    final horizon = dates.addMonthsClamped(today, 3);
    final yearEnd = DateTime(today.year, 12, 31);
    final active = bonds
        .where((bond) => bond.status != BondStatus.archived)
        .toList();

    final next90 = <Bond>[];
    final thisYear = <Bond>[];
    final later = <Bond>[];
    final matured = <Bond>[];

    for (final bond in active) {
      final maturity = dates.dateOnly(bond.maturityDate);
      if (bond.status == BondStatus.matured || maturity.isBefore(today)) {
        matured.add(bond);
      } else if (!maturity.isAfter(horizon)) {
        next90.add(bond);
      } else if (!maturity.isAfter(yearEnd)) {
        thisYear.add(bond);
      } else {
        later.add(bond);
      }
    }
    next90.sort((a, b) => a.maturityDate.compareTo(b.maturityDate));
    thisYear.sort((a, b) => a.maturityDate.compareTo(b.maturityDate));
    later.sort((a, b) => a.maturityDate.compareTo(b.maturityDate));
    matured.sort((a, b) => b.maturityDate.compareTo(a.maturityDate));

    return [
      MaturityBucket(label: 'Next 90 days', bonds: next90),
      MaturityBucket(label: 'Later this year', bonds: thisYear),
      MaturityBucket(label: 'Beyond ${today.year}', bonds: later),
      MaturityBucket(label: 'Matured', bonds: matured),
    ].where((bucket) => bucket.bonds.isNotEmpty).toList();
  }

  static (DateTime, DateTime) _range({
    required AnalyticsPeriod period,
    required DateTime now,
    required List<Bond> bonds,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    switch (period) {
      case AnalyticsPeriod.thisMonth:
        return (dates.startOfMonth(now), dates.endOfMonth(now));
      case AnalyticsPeriod.thisQuarter:
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final start = DateTime(now.year, quarterStartMonth);
        return (start, dates.endOfMonth(DateTime(now.year, quarterStartMonth + 2)));
      case AnalyticsPeriod.thisYear:
        return (DateTime(now.year), DateTime(now.year, 12, 31));
      case AnalyticsPeriod.last12Months:
        return (
          dates.startOfMonth(dates.addMonthsClamped(now, -11, anchorDay: 1)),
          dates.endOfMonth(now),
        );
      case AnalyticsPeriod.custom:
        return (
          dates.dateOnly(customStart ?? now),
          dates.dateOnly(customEnd ?? now),
        );
      case AnalyticsPeriod.all:
        final purchases = bonds.map((bond) => bond.purchaseDate).toList();
        final maturities = bonds.map((bond) => bond.maturityDate).toList();
        final start = purchases.isEmpty
            ? now
            : purchases.reduce((a, b) => a.isBefore(b) ? a : b);
        final end = maturities.isEmpty
            ? now
            : maturities.reduce((a, b) => a.isAfter(b) ? a : b);
        return (dates.dateOnly(start), dates.dateOnly(end));
    }
  }

  static List<MonthlyIncomePoint> _monthlySeries({
    required DateTime today,
    required List<InterestSchedule> schedules,
    required List<PaymentTransaction> payments,
    required int monthsBack,
    required int monthsForward,
  }) {
    final start = DateTime(today.year, today.month - monthsBack);
    final result = <MonthlyIncomePoint>[];
    for (var i = 0; i < monthsBack + monthsForward + 1; i++) {
      final month = DateTime(start.year, start.month + i);
      final next = DateTime(month.year, month.month + 1);
      final received = payments
          .where(
            (p) => !p.paidDate.isBefore(month) && p.paidDate.isBefore(next),
          )
          .fold(0, (sum, p) => sum + p.amountPaise);
      final expected = schedules
          .where(
            (s) =>
                s.status != ScheduleStatus.skipped &&
                !s.dueDate.isBefore(month) &&
                s.dueDate.isBefore(next),
          )
          .fold(0, (sum, s) => sum + s.expectedInterestPaise);
      result.add(
        MonthlyIncomePoint(
          month: month,
          receivedPaise: received,
          expectedPaise: expected,
        ),
      );
    }
    return result;
  }

  static List<AnnualIncomePoint> _annualSeries({
    required DateTime today,
    required List<InterestSchedule> schedules,
    required List<PaymentTransaction> payments,
    required int yearsBack,
    required int yearsForward,
  }) {
    final result = <AnnualIncomePoint>[];
    for (
      var year = today.year - yearsBack;
      year <= today.year + yearsForward;
      year++
    ) {
      final start = DateTime(year);
      final end = DateTime(year + 1);
      final received = payments
          .where((p) => !p.paidDate.isBefore(start) && p.paidDate.isBefore(end))
          .fold(0, (sum, p) => sum + p.amountPaise);
      final expected = schedules
          .where(
            (s) =>
                s.status != ScheduleStatus.skipped &&
                !s.dueDate.isBefore(start) &&
                s.dueDate.isBefore(end),
          )
          .fold(0, (sum, s) => sum + s.expectedInterestPaise);
      result.add(
        AnnualIncomePoint(
          year: year,
          receivedPaise: received,
          expectedPaise: expected,
        ),
      );
    }
    return result;
  }

  static List<CashFlowPoint> _cashFlowForecast({
    required DateTime today,
    required List<Bond> bonds,
    required List<InterestSchedule> schedules,
    required int months,
  }) {
    final result = <CashFlowPoint>[];
    for (var i = 0; i < months; i++) {
      final month = DateTime(today.year, today.month + i);
      final next = DateTime(month.year, month.month + 1);
      final interest = schedules
          .where(
            (s) =>
                (s.status == ScheduleStatus.pending ||
                    s.status == ScheduleStatus.partiallyPaid) &&
                !s.dueDate.isBefore(month) &&
                s.dueDate.isBefore(next),
          )
          .fold(0, (sum, s) => sum + s.remainingPaise);
      final maturity = bonds
          .where(
            (bond) =>
                !bond.maturityDate.isBefore(month) &&
                bond.maturityDate.isBefore(next),
          )
          .fold(0, (sum, bond) => sum + bond.expectedMaturityAmountPaise);
      result.add(
        CashFlowPoint(
          month: month,
          interestPaise: interest,
          maturityPaise: maturity,
        ),
      );
    }
    return result;
  }

  static List<MaturityExposure> _maturityExposure({
    required List<Bond> bonds,
    required DateTime today,
  }) {
    final totals = <String, (DateTime, int, int, int)>{};
    for (final bond in bonds) {
      final maturity = dates.dateOnly(bond.maturityDate);
      if (maturity.isBefore(today)) continue;
      final month = DateTime(maturity.year, maturity.month);
      final key = dates.monthKey(month);
      final current = totals[key];
      totals[key] = current == null
          ? (month, bond.principalPaise, bond.expectedMaturityAmountPaise, 1)
          : (
              current.$1,
              current.$2 + bond.principalPaise,
              current.$3 + bond.expectedMaturityAmountPaise,
              current.$4 + 1,
            );
    }
    final entries = totals.values.toList()
      ..sort((a, b) => a.$1.compareTo(b.$1));
    return [
      for (final entry in entries)
        MaturityExposure(
          month: entry.$1,
          principalPaise: entry.$2,
          proceedsPaise: entry.$3,
          count: entry.$4,
        ),
    ];
  }

  static List<UpcomingEvent> _upcomingTimeline({
    required List<ScheduleWithBond> upcomingPayments,
    required List<ScheduleWithBond> overdueSchedules,
    required List<Bond> upcomingMaturities,
    required DateTime today,
  }) {
    final events = <UpcomingEvent>[
      for (final item in overdueSchedules.take(3))
        UpcomingEvent(
          date: item.schedule.dueDate,
          title: '${item.bond.name} interest overdue',
          subtitle:
              '${item.schedule.remainingPaise > 0 ? 'Remaining' : 'Expected'} ${_compactMoney(item.schedule.remainingPaise)} · confirm credit',
          type: UpcomingEventType.overdue,
          bondId: item.bond.id,
          amountPaise: item.schedule.remainingPaise,
        ),
      for (final item in upcomingPayments.take(5))
        UpcomingEvent(
          date: item.schedule.dueDate,
          title: '${item.bond.name} interest',
          subtitle:
              '${_compactMoney(item.schedule.remainingPaise)} expected · ${_relativeDays(item.schedule.dueDate, today)}',
          type: UpcomingEventType.interest,
          bondId: item.bond.id,
          amountPaise: item.schedule.remainingPaise,
        ),
      for (final bond in upcomingMaturities.take(4))
        UpcomingEvent(
          date: bond.maturityDate,
          title: '${bond.name} matures',
          subtitle:
              '${_compactMoney(bond.expectedMaturityAmountPaise)} expected · ${_relativeDays(bond.maturityDate, today)}',
          type: UpcomingEventType.maturity,
          bondId: bond.id,
          amountPaise: bond.expectedMaturityAmountPaise,
        ),
    ]..sort((a, b) => a.date.compareTo(b.date));
    return events.take(8).toList();
  }

  static (int, String) _healthScore({
    required List<Bond> active,
    required List<PortfolioSlice> distribution,
    required int overdueCount,
    required double receivedRatio,
  }) {
    if (active.isEmpty) return (0, 'No active bonds');
    var score = 100.0;
    score -= (overdueCount * 12).clamp(0, 36);
    final largest = distribution.isEmpty ? 0.0 : distribution.first.share;
    if (largest > 0.4) score -= (largest - 0.4) * 60;
    if (receivedRatio < 0.5) score -= (0.5 - receivedRatio) * 20;
    final value = score.round().clamp(0, 100);
    final label = value >= 85
        ? 'Excellent'
        : value >= 70
        ? 'Healthy'
        : value >= 50
        ? 'Needs attention'
        : 'At risk';
    return (value, label);
  }

  static List<PortfolioSlice> _distribution(
    List<Bond> bonds,
    String Function(Bond) labelOf, {
    required int maxSlices,
  }) {
    final totals = <String, int>{};
    for (final bond in bonds) {
      totals.update(
        labelOf(bond),
        (value) => value + bond.principalPaise,
        ifAbsent: () => bond.principalPaise,
      );
    }
    final total = totals.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return const [];
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final slices = <PortfolioSlice>[];
    var other = 0;
    for (var i = 0; i < entries.length; i++) {
      if (i < maxSlices) {
        slices.add(
          PortfolioSlice(
            label: entries[i].key,
            valuePaise: entries[i].value,
            share: entries[i].value / total,
          ),
        );
      } else {
        other += entries[i].value;
      }
    }
    if (other > 0) {
      slices.add(
        PortfolioSlice(label: 'Other', valuePaise: other, share: other / total),
      );
    }
    return slices;
  }

  static double _weightedYield(List<Bond> bonds) {
    final total = bonds.fold(0, (sum, bond) => sum + bond.principalPaise);
    if (total == 0) return 0;
    final weighted = bonds.fold<double>(
      0,
      (sum, bond) => sum + bond.principalPaise * bond.annualRate,
    );
    return weighted / total;
  }

  static double _averageMonthsToMaturity(List<Bond> bonds, DateTime today) {
    final total = bonds.fold(0, (sum, bond) => sum + bond.principalPaise);
    if (total == 0) return 0;
    final weighted = bonds.fold<double>(
      0,
      (sum, bond) =>
          sum +
          bond.principalPaise * dates.monthsBetween(today, bond.maturityDate),
    );
    return weighted / total;
  }

  static String _compactMoney(int paise) {
    final rupees = paise / 100;
    if (rupees >= 10000000) return '₹${(rupees / 10000000).toStringAsFixed(1)} Cr';
    if (rupees >= 100000) return '₹${(rupees / 100000).toStringAsFixed(1)} L';
    if (rupees >= 1000) return '₹${(rupees / 1000).toStringAsFixed(1)} K';
    return '₹${rupees.toStringAsFixed(0)}';
  }

  static String _relativeDays(DateTime date, DateTime today) {
    final days = dates.daysBetween(today, date);
    if (days == 0) return 'today';
    if (days == 1) return 'tomorrow';
    return 'in $days days';
  }
}
