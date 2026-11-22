import 'dart:convert';
import 'dart:typed_data';

import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';
import 'package:excel/excel.dart';

class PortfolioSpreadsheetService {
  PortfolioSpreadsheetService._();

  static Uint8List exportXlsx({
    required List<Bond> bonds,
    required List<InterestSchedule> schedules,
    required List<PaymentTransaction> payments,
  }) {
    final excel = Excel.createExcel();
    final bondSheet = excel['Bonds'];
    bondSheet.appendRow([
      TextCellValue('Bond name'),
      TextCellValue('Issuer'),
      TextCellValue('Principal amount (INR)'),
      TextCellValue('Annual interest rate (%)'),
      TextCellValue('Purchase date'),
      TextCellValue('Interest frequency'),
      TextCellValue('First interest credit date'),
      TextCellValue('Maturity date'),
      TextCellValue('Expected maturity amount (INR)'),
      TextCellValue('Payment account reference'),
      TextCellValue('Notes'),
      TextCellValue('Status'),
    ]);
    for (final bond in bonds) {
      bondSheet.appendRow([
        TextCellValue(bond.name),
        TextCellValue(bond.issuer),
        DoubleCellValue(bond.principalPaise / 100),
        DoubleCellValue(bond.annualRate),
        DateCellValue.fromDateTime(bond.purchaseDate),
        TextCellValue(bond.frequency.label),
        DateCellValue.fromDateTime(bond.firstInterestDate),
        DateCellValue.fromDateTime(bond.maturityDate),
        DoubleCellValue(bond.expectedMaturityAmountPaise / 100),
        TextCellValue(bond.paymentAccount ?? ''),
        TextCellValue(bond.notes ?? ''),
        TextCellValue(bond.status.label),
      ]);
    }

    final scheduleSheet = excel['Interest schedule'];
    scheduleSheet.appendRow([
      TextCellValue('Bond name'),
      TextCellValue('Issuer'),
      TextCellValue('Due date'),
      TextCellValue('Period start'),
      TextCellValue('Period end'),
      TextCellValue('Expected interest (INR)'),
      TextCellValue('Received amount (INR)'),
      TextCellValue('Remaining amount (INR)'),
      TextCellValue('Status'),
      TextCellValue('Paid date'),
    ]);
    final bondById = {for (final bond in bonds) bond.id: bond};
    for (final schedule in schedules) {
      final bond = bondById[schedule.bondId];
      if (bond == null) continue;
      scheduleSheet.appendRow([
        TextCellValue(bond.name),
        TextCellValue(bond.issuer),
        DateCellValue.fromDateTime(schedule.dueDate),
        DateCellValue.fromDateTime(schedule.periodStart),
        DateCellValue.fromDateTime(schedule.periodEnd),
        DoubleCellValue(schedule.expectedInterestPaise / 100),
        DoubleCellValue(schedule.receivedPaise / 100),
        DoubleCellValue(schedule.remainingPaise / 100),
        TextCellValue(schedule.status.label),
        if (schedule.paidDate != null)
          DateCellValue.fromDateTime(schedule.paidDate!)
        else
          TextCellValue(''),
      ]);
    }

    final paymentSheet = excel['Payments'];
    paymentSheet.appendRow([
      TextCellValue('Bond name'),
      TextCellValue('Issuer'),
      TextCellValue('Payment date'),
      TextCellValue('Payment type'),
      TextCellValue('Amount (INR)'),
      TextCellValue('Transaction reference'),
      TextCellValue('Notes'),
    ]);
    for (final payment in payments) {
      final bond = bondById[payment.bondId];
      if (bond == null) continue;
      paymentSheet.appendRow([
        TextCellValue(bond.name),
        TextCellValue(bond.issuer),
        DateCellValue.fromDateTime(payment.paidDate),
        TextCellValue(payment.type.label),
        DoubleCellValue(payment.amountPaise / 100),
        TextCellValue(payment.reference ?? ''),
        TextCellValue(payment.notes ?? ''),
      ]);
    }

    final maturitySheet = excel['Maturity'];
    maturitySheet.appendRow([
      TextCellValue('Bond name'),
      TextCellValue('Issuer'),
      TextCellValue('Maturity date'),
      TextCellValue('Principal (INR)'),
      TextCellValue('Expected proceeds (INR)'),
      TextCellValue('Actual proceeds received (INR)'),
      TextCellValue('Expected vs actual difference (INR)'),
      TextCellValue('Status'),
    ]);
    for (final bond in bonds) {
      final actual = payments
          .where(
            (payment) =>
                payment.bondId == bond.id &&
                payment.type == PaymentType.maturity,
          )
          .fold<int>(0, (sum, payment) => sum + payment.amountPaise);
      maturitySheet.appendRow([
        TextCellValue(bond.name),
        TextCellValue(bond.issuer),
        DateCellValue.fromDateTime(bond.maturityDate),
        DoubleCellValue(bond.principalPaise / 100),
        DoubleCellValue(bond.expectedMaturityAmountPaise / 100),
        DoubleCellValue(actual / 100),
        DoubleCellValue((actual - bond.expectedMaturityAmountPaise) / 100),
        TextCellValue(bond.status.label),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) throw StateError('Could not generate the Excel file.');
    return Uint8List.fromList(bytes);
  }

  static Uint8List exportBackupJson({
    required List<Bond> bonds,
    required List<InterestSchedule> schedules,
    required List<PaymentTransaction> payments,
    required Map<String, String> settings,
  }) {
    final payload = {
      'format': 'bondtrack-backup',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'bonds': bonds
          .map(
            (bond) => {
              'id': bond.id,
              'name': bond.name,
              'issuer': bond.issuer,
              'principalPaise': bond.principalPaise,
              'annualRate': bond.annualRate,
              'purchaseDate': bond.purchaseDate.toIso8601String(),
              'frequency': bond.frequency.name,
              'firstInterestDate': bond.firstInterestDate.toIso8601String(),
              'maturityDate': bond.maturityDate.toIso8601String(),
              'expectedMaturityAmountPaise': bond.expectedMaturityAmountPaise,
              'paymentAccount': bond.paymentAccount,
              'notes': bond.notes,
              'status': bond.status.name,
              'createdAt': bond.createdAt.toIso8601String(),
              'updatedAt': bond.updatedAt.toIso8601String(),
              'archivedAt': bond.archivedAt?.toIso8601String(),
            },
          )
          .toList(),
      'schedules': schedules
          .map(
            (schedule) => {
              'bondId': schedule.bondId,
              'dueDate': schedule.dueDate.toIso8601String(),
              'periodStart': schedule.periodStart.toIso8601String(),
              'periodEnd': schedule.periodEnd.toIso8601String(),
              'expectedInterestPaise': schedule.expectedInterestPaise,
              'status': schedule.status.name,
              'paidDate': schedule.paidDate?.toIso8601String(),
            },
          )
          .toList(),
      'payments': payments
          .map(
            (payment) => {
              'bondId': payment.bondId,
              'scheduleId': payment.scheduleId,
              'amountPaise': payment.amountPaise,
              'paidDate': payment.paidDate.toIso8601String(),
              'type': payment.type.name,
              'notes': payment.notes,
              'createdAt': payment.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'settings': settings,
    };
    return Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)),
    );
  }

  static String exportFileName({String extension = 'xlsx'}) {
    final date = Money.isoDate(DateTime.now());
    return 'bondtrack-portfolio-$date.$extension';
  }
}
