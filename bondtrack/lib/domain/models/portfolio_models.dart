import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';

class MonthlyIncomePoint {
  const MonthlyIncomePoint({
    required this.month,
    required this.receivedPaise,
    required this.expectedPaise,
  });

  final DateTime month;
  final int receivedPaise;
  final int expectedPaise;
}

class AnnualIncomePoint {
  const AnnualIncomePoint({
    required this.year,
    required this.receivedPaise,
    required this.expectedPaise,
  });

  final int year;
  final int receivedPaise;
  final int expectedPaise;
}

class PortfolioSlice {
  const PortfolioSlice({
    required this.label,
    required this.valuePaise,
    required this.share,
  });

  final String label;
  final int valuePaise;
  final double share;
}

/// Monthly cash-flow forecast combining coupons and principal repayments.
class CashFlowPoint {
  const CashFlowPoint({
    required this.month,
    required this.interestPaise,
    required this.maturityPaise,
  });

  final DateTime month;
  final int interestPaise;
  final int maturityPaise;

  int get totalPaise => interestPaise + maturityPaise;
}

/// One bond's contribution to expected and received interest.
class BondContribution {
  const BondContribution({
    required this.bondId,
    required this.name,
    required this.issuer,
    required this.expectedPaise,
    required this.receivedPaise,
    required this.annualRate,
  });

  final int bondId;
  final String name;
  final String issuer;
  final int expectedPaise;
  final int receivedPaise;
  final double annualRate;

  int get pendingPaise {
    final pending = expectedPaise - receivedPaise;
    return pending > 0 ? pending : 0;
  }
}

/// Principal and proceeds maturing in a given month.
class MaturityExposure {
  const MaturityExposure({
    required this.month,
    required this.principalPaise,
    required this.proceedsPaise,
    required this.count,
  });

  final DateTime month;
  final int principalPaise;
  final int proceedsPaise;
  final int count;
}

enum UpcomingEventType { interest, maturity, overdue }

class UpcomingEvent {
  const UpcomingEvent({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.type,
    this.bondId,
    this.amountPaise = 0,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final UpcomingEventType type;
  final int? bondId;
  final int amountPaise;
}

enum AnalyticsPeriod {
  thisMonth,
  thisQuarter,
  thisYear,
  last12Months,
  all,
  custom;

  String get label => switch (this) {
    AnalyticsPeriod.thisMonth => 'This month',
    AnalyticsPeriod.thisQuarter => 'This quarter',
    AnalyticsPeriod.thisYear => 'This year',
    AnalyticsPeriod.last12Months => 'Last 12 months',
    AnalyticsPeriod.all => 'All time',
    AnalyticsPeriod.custom => 'Custom',
  };
}

class DashboardData {
  const DashboardData({
    required this.totalInvestedPaise,
    required this.expectedMonthlyInterestPaise,
    required this.expectedAnnualInterestPaise,
    required this.totalInterestReceivedPaise,
    required this.pendingInterestPaise,
    required this.activeBondCount,
    required this.overdueCount,
    required this.upcomingPayments,
    required this.upcomingMaturities,
    required this.monthlySeries,
    required this.annualSeries,
    required this.distribution,
    required this.recentPayments,
    required this.weightedYield,
    required this.maturityValuePaise,
    required this.expectedThisMonthPaise,
    required this.receivedThisMonthPaise,
    required this.overdueAmountPaise,
    required this.overdueSchedules,
    required this.upcomingTimeline,
    required this.healthScore,
    required this.healthLabel,
    required this.totalExpectedInterestPaise,
    this.nextPayment,
    this.nextMaturity,
  });

  final int totalInvestedPaise;
  final int expectedMonthlyInterestPaise;
  final int expectedAnnualInterestPaise;
  final int totalInterestReceivedPaise;
  final int pendingInterestPaise;
  final int activeBondCount;
  final int overdueCount;
  final List<ScheduleWithBond> upcomingPayments;
  final List<Bond> upcomingMaturities;
  final List<MonthlyIncomePoint> monthlySeries;
  final List<AnnualIncomePoint> annualSeries;
  final List<PortfolioSlice> distribution;
  final List<PaymentWithBond> recentPayments;
  final double weightedYield;
  final int maturityValuePaise;
  final int expectedThisMonthPaise;
  final int receivedThisMonthPaise;
  final int overdueAmountPaise;
  final List<ScheduleWithBond> overdueSchedules;
  final List<UpcomingEvent> upcomingTimeline;
  final int healthScore;
  final String healthLabel;
  final int totalExpectedInterestPaise;
  final ScheduleWithBond? nextPayment;
  final Bond? nextMaturity;

  bool get isEmpty => activeBondCount == 0 && totalInterestReceivedPaise == 0;
}

class AnalyticsData {
  const AnalyticsData({
    required this.totalInvestedPaise,
    required this.lifetimeInterestPaise,
    required this.interestThisYearPaise,
    required this.projectedAnnualIncomePaise,
    required this.weightedYield,
    required this.averageMonthsToMaturity,
    required this.maturityValuePaise,
    required this.annualSeries,
    required this.issuerSlices,
    required this.frequencySlices,
    required this.topHoldings,
    required this.paidOnTimeRate,
    required this.paymentCount,
    required this.next12MonthsInterestPaise,
    required this.activeBondCount,
    required this.rangeStart,
    required this.rangeEnd,
    required this.receivedInRangePaise,
    required this.expectedInRangePaise,
    required this.bondContributions,
    required this.monthlyCashFlow,
    required this.maturityExposure,
    required this.upcomingMaturityExposurePaise,
    required this.overdueAmountPaise,
  });

  final int totalInvestedPaise;
  final int lifetimeInterestPaise;
  final int interestThisYearPaise;
  final int projectedAnnualIncomePaise;
  final double weightedYield;
  final double averageMonthsToMaturity;
  final int maturityValuePaise;
  final List<AnnualIncomePoint> annualSeries;
  final List<PortfolioSlice> issuerSlices;
  final List<PortfolioSlice> frequencySlices;
  final List<Bond> topHoldings;
  final double paidOnTimeRate;
  final int paymentCount;
  final int next12MonthsInterestPaise;
  final int activeBondCount;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int receivedInRangePaise;
  final int expectedInRangePaise;
  final List<BondContribution> bondContributions;
  final List<CashFlowPoint> monthlyCashFlow;
  final List<MaturityExposure> maturityExposure;
  final int upcomingMaturityExposurePaise;
  final int overdueAmountPaise;

  bool get isEmpty => totalInvestedPaise == 0;
}

class MaturityBucket {
  const MaturityBucket({required this.label, required this.bonds});

  final String label;
  final List<Bond> bonds;

  int get totalPaise => bonds.fold(0, (sum, bond) => sum + bond.principalPaise);

  int get expectedPaise =>
      bonds.fold(0, (sum, bond) => sum + bond.expectedMaturityAmountPaise);
}
