import 'package:drift/drift.dart';
import 'package:bondtrack/data/database/app_database.dart';
import 'package:bondtrack/data/mappers.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';
import 'package:bondtrack/domain/repositories/payment_repository.dart';
import 'package:bondtrack/domain/services/interest_engine.dart';

class DriftPaymentRepository implements PaymentRepository {
  DriftPaymentRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<PaymentTransaction>> watchAll() {
    final query = _db.select(_db.paymentTransactions)
      ..orderBy([
        (t) => OrderingTerm(expression: t.paidDate, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Stream<List<PaymentTransaction>> watchForBond(int bondId) {
    final query = _db.select(_db.paymentTransactions)
      ..where((t) => t.bondId.equals(bondId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.paidDate, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Future<List<PaymentTransaction>> getAll() async {
    final rows = await _db.select(_db.paymentTransactions).get();
    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<PaymentTransaction?> getById(int paymentId) async {
    final row = await (_db.select(
      _db.paymentTransactions,
    )..where((t) => t.id.equals(paymentId))).getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<List<PaymentTransaction>> getForSchedule(int scheduleId) async {
    final rows =
        await (_db.select(_db.paymentTransactions)
              ..where((t) => t.scheduleId.equals(scheduleId))
              ..orderBy([(t) => OrderingTerm(expression: t.paidDate)]))
            .get();
    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<int> recordPayment({
    required Bond bond,
    required int amountPaise,
    required DateTime paidDate,
    required PaymentType type,
    InterestSchedule? schedule,
    String? reference,
    String? notes,
  }) {
    if (amountPaise <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }
    return _db.transaction(() async {
      final now = DateTime.now();
      if (schedule != null) {
        final current = await (_db.select(
          _db.interestSchedules,
        )..where((t) => t.id.equals(schedule.id))).getSingleOrNull();
        if (current == null) {
          throw StateError('This interest schedule no longer exists.');
        }
        if (current.status == ScheduleStatus.paid &&
            current.receivedPaise >= current.expectedInterestPaise) {
          throw StateError(
            'This interest payment has already been received in full. '
            'Edit the existing payment instead.',
          );
        }
      }

      final paymentId = await _db
          .into(_db.paymentTransactions)
          .insert(
            PaymentTransactionsCompanion.insert(
              bondId: bond.id,
              scheduleId: Value(schedule?.id),
              amountPaise: amountPaise,
              paidDate: paidDate,
              type: type,
              reference: Value(_nullable(reference)),
              notes: Value(_nullable(notes)),
              createdAt: now,
            ),
          );

      if (schedule != null) {
        await _reconcileSchedule(schedule.id);
      }

      if (type == PaymentType.maturity) {
        await (_db.update(_db.bonds)..where((t) => t.id.equals(bond.id))).write(
          BondsCompanion(
            status: const Value(BondStatus.matured),
            updatedAt: Value(now),
          ),
        );
      }
      return paymentId;
    });
  }

  @override
  Future<void> updatePayment({
    required int paymentId,
    required int amountPaise,
    required DateTime paidDate,
    String? reference,
    String? notes,
  }) {
    if (amountPaise <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.paymentTransactions,
      )..where((t) => t.id.equals(paymentId))).getSingleOrNull();
      if (existing == null) {
        throw StateError('This payment no longer exists.');
      }
      await (_db.update(
        _db.paymentTransactions,
      )..where((t) => t.id.equals(paymentId))).write(
        PaymentTransactionsCompanion(
          amountPaise: Value(amountPaise),
          paidDate: Value(paidDate),
          reference: Value(_nullable(reference)),
          notes: Value(_nullable(notes)),
        ),
      );
      if (existing.scheduleId != null) {
        await _reconcileSchedule(existing.scheduleId!);
      }
    });
  }

  @override
  Future<void> deletePayment(int paymentId) {
    return _db.transaction(() async {
      final payment = await (_db.select(
        _db.paymentTransactions,
      )..where((t) => t.id.equals(paymentId))).getSingleOrNull();
      if (payment == null) return;

      await (_db.delete(
        _db.paymentTransactions,
      )..where((t) => t.id.equals(paymentId))).go();

      if (payment.scheduleId != null) {
        await _reconcileSchedule(payment.scheduleId!);
      }

      if (payment.type == PaymentType.maturity) {
        final remaining = await (_db.select(_db.paymentTransactions)..where(
              (t) =>
                  t.bondId.equals(payment.bondId) &
                  t.type.equalsValue(PaymentType.maturity),
            ))
            .get();
        if (remaining.isEmpty) {
          await (_db.update(
            _db.bonds,
          )..where((t) => t.id.equals(payment.bondId))).write(
            BondsCompanion(
              status: const Value(BondStatus.active),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    });
  }

  /// Recomputes the received total and status of one schedule from all of its
  /// linked payment transactions. Never marks a schedule paid without an
  /// actual receipt.
  Future<void> _reconcileSchedule(int scheduleId) async {
    final schedule = await (_db.select(
      _db.interestSchedules,
    )..where((t) => t.id.equals(scheduleId))).getSingleOrNull();
    if (schedule == null) return;
    final payments =
        await (_db.select(_db.paymentTransactions)
              ..where((t) => t.scheduleId.equals(scheduleId))
              ..orderBy([
                (t) => OrderingTerm(expression: t.paidDate, mode: OrderingMode.desc),
                (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
              ]))
            .get();
    final received = payments.fold<int>(
      0,
      (sum, payment) => sum + payment.amountPaise,
    );
    final status = InterestEngine.scheduleStatus(
      expectedPaise: schedule.expectedInterestPaise,
      receivedPaise: received,
    );
    await (_db.update(
      _db.interestSchedules,
    )..where((t) => t.id.equals(scheduleId))).write(
      InterestSchedulesCompanion(
        status: Value(status),
        receivedPaise: Value(received),
        paidDate: Value(payments.isEmpty ? null : payments.first.paidDate),
        paymentId: Value(payments.isEmpty ? null : payments.first.id),
      ),
    );
  }

  String? _nullable(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
