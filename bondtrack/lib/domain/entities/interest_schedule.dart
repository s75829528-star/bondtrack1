import 'package:bondtrack/core/utils/date_utils.dart' as dates;
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/services/interest_engine.dart';

/// One scheduled interest credit for a bond.
class InterestSchedule {
  const InterestSchedule({
    required this.id,
    required this.bondId,
    required this.dueDate,
    required this.periodStart,
    required this.periodEnd,
    required this.expectedInterestPaise,
    required this.status,
    this.receivedPaise = 0,
    this.paidDate,
    this.paymentId,
  });

  final int id;
  final int bondId;
  final DateTime dueDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int expectedInterestPaise;
  final ScheduleStatus status;

  /// Total amount actually received against this schedule. Supports partial
  /// receipts across multiple payment transactions.
  final int receivedPaise;
  final DateTime? paidDate;
  final int? paymentId;

  bool get isPaid => status == ScheduleStatus.paid;

  bool get isPartiallyPaid => status == ScheduleStatus.partiallyPaid;

  bool get isReceived => receivedPaise > 0;

  int get remainingPaise {
    final remaining = expectedInterestPaise - receivedPaise;
    return remaining < 0 ? 0 : remaining;
  }

  int get shortfallPaise {
    final shortfall = expectedInterestPaise - receivedPaise;
    return shortfall > 0 ? shortfall : 0;
  }

  int get excessPaise {
    final excess = receivedPaise - expectedInterestPaise;
    return excess > 0 ? excess : 0;
  }

  bool get isOverdue =>
      status != ScheduleStatus.paid &&
      status != ScheduleStatus.skipped &&
      dates.dateOnly(dueDate).isBefore(dates.today());

  bool get isUpcoming =>
      status == ScheduleStatus.pending &&
      !dates.dateOnly(dueDate).isBefore(dates.today());

  int get daysUntilDue => dates.daysBetween(dates.today(), dueDate);

  PaymentStatus paymentStatus({DateTime? now}) => InterestEngine.paymentStatus(
    dueDate: dueDate,
    expectedPaise: expectedInterestPaise,
    receivedPaise: receivedPaise,
    now: now,
  );
}

class ScheduleWithBond {
  const ScheduleWithBond({required this.schedule, required this.bond});

  final InterestSchedule schedule;
  final Bond bond;
}

/// A generated schedule entry, before it is persisted.
class GeneratedSchedule {
  const GeneratedSchedule({
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
