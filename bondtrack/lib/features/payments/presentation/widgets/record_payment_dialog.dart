import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';

/// Records an interest, maturity or principal payment. When [schedule] is
/// provided, the schedule is reconciled in the same database transaction.
Future<bool> showRecordPaymentDialog(
  BuildContext context, {
  required WidgetRef ref,
  required Bond bond,
  InterestSchedule? schedule,
  PaymentType initialType = PaymentType.interest,
  bool allowTypeChange = false,
  PaymentTransaction? existingPayment,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _RecordPaymentDialog(
      bond: bond,
      schedule: schedule,
      initialType: initialType,
      allowTypeChange: allowTypeChange,
      existingPayment: existingPayment,
    ),
  );
  return result ?? false;
}

class _RecordPaymentDialog extends ConsumerStatefulWidget {
  const _RecordPaymentDialog({
    required this.bond,
    required this.schedule,
    required this.initialType,
    required this.allowTypeChange,
    required this.existingPayment,
  });

  final Bond bond;
  final InterestSchedule? schedule;
  final PaymentType initialType;
  final bool allowTypeChange;
  final PaymentTransaction? existingPayment;

  @override
  ConsumerState<_RecordPaymentDialog> createState() =>
      _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<_RecordPaymentDialog> {
  late final TextEditingController _amountController;
  final _notesController = TextEditingController();
  final _referenceController = TextEditingController();
  late PaymentType _type;
  late DateTime _paidDate;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _type = widget.existingPayment?.type ?? widget.initialType;
    _paidDate = widget.existingPayment?.paidDate ?? DateTime.now();
    final amount =
        widget.schedule?.remainingPaise ??
        (widget.initialType == PaymentType.maturity
            ? widget.bond.expectedMaturityAmountPaise
            : widget.bond.interestPerPeriodPaise);
    _amountController = TextEditingController(
      text: ((widget.existingPayment?.amountPaise ?? amount) / 100)
          .toStringAsFixed(2),
    );
    _referenceController.text = widget.existingPayment?.reference ?? '';
    _notesController.text = widget.existingPayment?.notes ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _paidDate,
      firstDate: widget.bond.purchaseDate.subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Payment received on',
    );
    if (selected != null) {
      setState(() => _paidDate = selected);
    }
  }

  Future<void> _save() async {
    final amount = Money.parseAmountToPaise(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid payment amount.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repository = ref.read(paymentRepositoryProvider);
      if (widget.existingPayment case final existing?) {
        await repository.updatePayment(
          paymentId: existing.id,
          amountPaise: amount,
          paidDate: _paidDate,
          reference: _referenceController.text,
          notes: _notesController.text,
        );
      } else {
        await repository.recordPayment(
          bond: widget.bond,
          amountPaise: amount,
          paidDate: _paidDate,
          type: _type,
          schedule: widget.schedule,
          reference: _referenceController.text,
          notes: _notesController.text,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = ref.watch(moneyFormatterProvider);
    final schedule = widget.schedule;
    return AlertDialog(
      title: Text(
        widget.existingPayment != null
            ? 'Edit payment'
            : schedule == null
            ? 'Record payment'
            : 'Confirm interest credit',
      ),
      content: SizedBox(
        width: 430,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumCard(
                shadow: false,
                padding: const EdgeInsets.all(14),
                color: context.scheme.primaryContainer.withValues(alpha: 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bond.name,
                      style: context.texts.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.bond.issuer,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.mutedColor,
                      ),
                    ),
                    if (schedule != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Due ${Money.date(schedule.dueDate)} · Expected ${formatter.format(schedule.expectedInterestPaise)} · Received ${formatter.format(schedule.receivedPaise)}',
                        style: context.texts.labelSmall?.copyWith(
                          color: context.scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.allowTypeChange) ...[
                const SizedBox(height: 16),
                Text('Payment type', style: context.texts.labelMedium),
                const SizedBox(height: 8),
                SegmentedButton<PaymentType>(
                  segments: const [
                    ButtonSegment(
                      value: PaymentType.interest,
                      label: Text('Interest'),
                    ),
                    ButtonSegment(
                      value: PaymentType.maturity,
                      label: Text('Maturity'),
                    ),
                    ButtonSegment(
                      value: PaymentType.principal,
                      label: Text('Principal'),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (value) =>
                      setState(() => _type = value.first),
                  showSelectedIcon: false,
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${Money.symbolFor(formatter.currencyCode)} ',
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Received on',
                    suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                  ),
                  child: Text(Money.date(_paidDate)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Transaction reference (optional)',
                  hintText: 'UTR, cheque or broker reference',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Reference, bank credit note…',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.scheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  widget.existingPayment == null
                      ? 'Record payment'
                      : 'Save correction',
                ),
        ),
      ],
    );
  }
}
