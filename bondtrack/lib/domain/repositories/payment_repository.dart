import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';

abstract interface class PaymentRepository {
  Stream<List<PaymentTransaction>> watchAll();

  Stream<List<PaymentTransaction>> watchForBond(int bondId);

  Future<List<PaymentTransaction>> getAll();

  Future<PaymentTransaction?> getById(int paymentId);

  Future<List<PaymentTransaction>> getForSchedule(int scheduleId);

  /// Records a payment and, when linked to a schedule, reconciles it in the
  /// same transaction. Partial receipts are supported: the schedule becomes
  /// partially paid until the expected amount is fully received.
  Future<int> recordPayment({
    required Bond bond,
    required int amountPaise,
    required DateTime paidDate,
    required PaymentType type,
    InterestSchedule? schedule,
    String? reference,
    String? notes,
  });

  /// Corrects a previously recorded payment and reconciles its schedule.
  Future<void> updatePayment({
    required int paymentId,
    required int amountPaise,
    required DateTime paidDate,
    String? reference,
    String? notes,
  });

  Future<void> deletePayment(int paymentId);
}
