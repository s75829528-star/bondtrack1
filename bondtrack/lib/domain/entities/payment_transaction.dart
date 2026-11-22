import 'package:bondtrack/domain/entities/bond.dart';

class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.bondId,
    required this.amountPaise,
    required this.paidDate,
    required this.type,
    required this.createdAt,
    this.scheduleId,
    this.reference,
    this.notes,
  });

  final int id;
  final int bondId;
  final int? scheduleId;
  final int amountPaise;
  final DateTime paidDate;
  final PaymentType type;

  /// Bank transaction reference, UTR, cheque number or broker reference.
  final String? reference;
  final String? notes;
  final DateTime createdAt;

  double get amount => amountPaise / 100;

  PaymentTransaction copyWith({
    int? id,
    int? bondId,
    int? scheduleId,
    int? amountPaise,
    DateTime? paidDate,
    PaymentType? type,
    String? reference,
    String? notes,
    DateTime? createdAt,
    bool clearScheduleId = false,
    bool clearReference = false,
    bool clearNotes = false,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      bondId: bondId ?? this.bondId,
      scheduleId: clearScheduleId ? null : (scheduleId ?? this.scheduleId),
      amountPaise: amountPaise ?? this.amountPaise,
      paidDate: paidDate ?? this.paidDate,
      type: type ?? this.type,
      reference: clearReference ? null : (reference ?? this.reference),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PaymentWithBond {
  const PaymentWithBond({required this.payment, required this.bond});

  final PaymentTransaction payment;
  final Bond bond;
}
