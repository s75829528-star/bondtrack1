import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/providers/ui_state_providers.dart';
import 'package:bondtrack/core/theme/app_colors.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/utils/date_utils.dart' as dates;
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/core/widgets/app_page.dart';
import 'package:bondtrack/core/widgets/common.dart';
import 'package:bondtrack/core/widgets/empty_state.dart';
import 'package:bondtrack/core/widgets/metric_card.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/core/widgets/section_header.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';
import 'package:bondtrack/features/payments/presentation/widgets/record_payment_dialog.dart';

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deletePayment(PaymentTransaction payment) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete this payment?',
      message: 'The payment will be removed from history. If it was linked to a scheduled interest credit, that credit returns to pending.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    await ref.read(paymentRepositoryProvider).deletePayment(payment.id);
    if (mounted) showAppSnackBar(context, 'Payment removed.');
  }

  Future<void> _editPayment(PaymentTransaction payment, Bond bond) async {
    final success = await showRecordPaymentDialog(
      context,
      ref: ref,
      bond: bond,
      initialType: payment.type,
      existingPayment: payment,
    );
    if (success && mounted) showAppSnackBar(context, 'Payment corrected.');
  }

  Future<void> _recordManualPayment() async {
    final bonds = ref.read(bondsProvider).valueOrNull ?? const <Bond>[];
    if (bonds.isEmpty) {
      showAppSnackBar(context, 'Add a bond before recording a payment.');
      return;
    }
    final bond = await showModalBottomSheet<Bond>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _BondPickerSheet(bonds: bonds),
    );
    if (bond == null || !mounted) return;
    final success = await showRecordPaymentDialog(
      context,
      ref: ref,
      bond: bond,
      allowTypeChange: true,
    );
    if (success && mounted) {
      showAppSnackBar(context, 'Payment recorded.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(paymentsProvider).valueOrNull ?? const [];
    final bonds = ref.watch(bondsProvider).valueOrNull ?? const [];
    final filter = ref.watch(paymentFilterProvider);
    final formatter = ref.watch(moneyFormatterProvider);
    final bondById = {for (final bond in bonds) bond.id: bond};

    final filtered = payments.where((payment) {
      if (filter.filter == PaymentFilter.interest &&
          payment.type != PaymentType.interest) {
        return false;
      }
      if (filter.filter == PaymentFilter.maturity &&
          payment.type != PaymentType.maturity) {
        return false;
      }
      final query = filter.query.trim().toLowerCase();
      if (query.isEmpty) return true;
      final bond = bondById[payment.bondId];
      return (bond?.name.toLowerCase().contains(query) ?? false) ||
          (bond?.issuer.toLowerCase().contains(query) ?? false) ||
          (payment.notes?.toLowerCase().contains(query) ?? false);
    }).toList()..sort((a, b) => b.paidDate.compareTo(a.paidDate));

    final now = DateTime.now();
    final totalReceived = payments
        .where((payment) => payment.type == PaymentType.interest)
        .fold(0, (sum, payment) => sum + payment.amountPaise);
    final thisYear = payments
        .where(
          (payment) =>
              payment.paidDate.year == now.year &&
              payment.type == PaymentType.interest,
        )
        .fold(0, (sum, payment) => sum + payment.amountPaise);
    final interestCount = payments
        .where((payment) => payment.type == PaymentType.interest)
        .length;
    final months = <String, List<PaymentTransaction>>{};
    for (final payment in filtered) {
      months
          .putIfAbsent(dates.monthKey(payment.paidDate), () => [])
          .add(payment);
    }
    final monthKeys = months.keys.toList()..sort((a, b) => b.compareTo(a));

    return AppPage(
      title: 'Payment history',
      subtitle: 'Every interest credit and principal repayment',
      fab: FloatingActionButton.extended(
        onPressed: _recordManualPayment,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveGrid(
            minItemWidth: 150,
            maxColumns: 3,
            children: [
              _PaymentStat(
                label: 'Interest received',
                value: formatter.format(totalReceived),
                icon: Icons.savings_outlined,
                color: AppColors.emerald,
              ),
              _PaymentStat(
                label: 'Received in ${now.year}',
                value: formatter.format(thisYear),
                icon: Icons.calendar_today_rounded,
                color: AppColors.teal,
              ),
              _PaymentStat(
                label: 'Interest credits',
                value: '$interestCount',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF2E5AAC),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SearchField(
            controller: _searchController,
            hintText: 'Search bond, issuer or notes',
            onChanged: ref.read(paymentFilterProvider.notifier).setQuery,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in PaymentFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(option.label),
                      selected: filter.filter == option,
                      onSelected: (_) => ref
                          .read(paymentFilterProvider.notifier)
                          .setFilter(option),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (payments.isEmpty)
            EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No payments recorded',
              message: 'Mark an interest credit as paid from the dashboard, calendar or a bond page. You can also record a manual payment.',
              primaryLabel: 'Record a payment',
              onPrimary: _recordManualPayment,
            )
          else if (filtered.isEmpty)
            EmptyState(
              compact: true,
              icon: Icons.search_off_rounded,
              title: 'No matching payments',
              message: 'Try a different search or payment type.',
              secondaryLabel: 'Clear filters',
              onSecondary: () {
                _searchController.clear();
                ref.read(paymentFilterProvider.notifier)
                  ..setQuery('')
                  ..setFilter(PaymentFilter.all);
              },
            )
          else
            for (final key in monthKeys) ...[
              _MonthGroup(
                month: dates.monthStartFromKey(key),
                payments: months[key]!,
                bonds: bondById,
                formatter: formatter,
                onDelete: _deletePayment,
                onEdit: _editPayment,
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _MonthGroup extends StatelessWidget {
  const _MonthGroup({
    required this.month,
    required this.payments,
    required this.bonds,
    required this.formatter,
    required this.onDelete,
    required this.onEdit,
  });

  final DateTime month;
  final List<PaymentTransaction> payments;
  final Map<int, Bond> bonds;
  final MoneyFormatter formatter;
  final ValueChanged<PaymentTransaction> onDelete;
  final Future<void> Function(PaymentTransaction, Bond) onEdit;

  @override
  Widget build(BuildContext context) {
    final total = payments.fold(0, (sum, payment) => sum + payment.amountPaise);
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(Money.monthYear(month), style: context.texts.titleSmall),
              const Spacer(),
              Text(
                '+${formatter.format(total)}',
                style: context.texts.labelMedium?.copyWith(
                  color: AppColors.emerald,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < payments.length; i++) ...[
            if (bonds[payments[i].bondId] != null)
              _PaymentRow(
                payment: payments[i],
                bond: bonds[payments[i].bondId]!,
                formatter: formatter,
                onDelete: () => onDelete(payments[i]),
                onEdit: () {
                  final bond = bonds[payments[i].bondId];
                  if (bond != null) onEdit(payments[i], bond);
                },
              ),
            if (i != payments.length - 1)
              Divider(height: 1, color: context.borderColor),
          ],
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.payment,
    required this.bond,
    required this.formatter,
    required this.onDelete,
    required this.onEdit,
  });

  final PaymentTransaction payment;
  final Bond bond;
  final MoneyFormatter formatter;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final maturity = payment.type == PaymentType.maturity;
    final color = maturity ? AppColors.gold : AppColors.emerald;
    return InkWell(
      onTap: () => context.push('/bonds/${bond.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: context.isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                maturity ? Icons.flag_rounded : Icons.south_west_rounded,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bond.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.titleSmall,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${payment.type.label} · ${Money.date(payment.paidDate)}'
                    '${payment.scheduleId == null ? ' · Manual' : ''}',
                    style: context.texts.bodySmall?.copyWith(
                      color: context.mutedColor,
                      fontSize: 10.5,
                    ),
                  ),
                  if (payment.notes != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      payment.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.mutedColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${formatter.format(payment.amountPaise)}',
                  style: context.texts.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: onEdit,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Edit'),
                      ),
                      TextButton(
                        onPressed: onDelete,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentStat extends StatelessWidget {
  const _PaymentStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      shadow: false,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: context.isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.texts.labelSmall?.copyWith(
                    color: context.mutedColor,
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: context.texts.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BondPickerSheet extends StatelessWidget {
  const _BondPickerSheet({required this.bonds});

  final List<Bond> bonds;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Choose a bond',
              subtitle: 'Which bond received this payment?',
              padding: EdgeInsets.only(bottom: 8),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: bonds.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: context.borderColor),
                itemBuilder: (context, index) {
                  final bond = bonds[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: context.scheme.primaryContainer,
                      child: Text(
                        bond.name.isEmpty ? 'B' : bond.name[0].toUpperCase(),
                        style: context.texts.titleSmall?.copyWith(
                          color: context.scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(bond.name),
                    subtitle: Text(
                      '${bond.issuer} · ${Money.rate(bond.annualRate)}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).pop(bond),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
