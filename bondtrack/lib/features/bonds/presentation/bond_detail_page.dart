import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/theme/app_colors.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/core/widgets/app_page.dart';
import 'package:bondtrack/core/widgets/common.dart';
import 'package:bondtrack/core/widgets/empty_state.dart';
import 'package:bondtrack/core/widgets/loading_view.dart';
import 'package:bondtrack/core/widgets/metric_card.dart';
import 'package:bondtrack/core/widgets/pills.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/core/widgets/section_header.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';
import 'package:bondtrack/features/payments/presentation/widgets/record_payment_dialog.dart';

class BondDetailPage extends ConsumerStatefulWidget {
  const BondDetailPage({super.key, required this.bondId});

  final int bondId;

  @override
  ConsumerState<BondDetailPage> createState() => _BondDetailPageState();
}

class _BondDetailPageState extends ConsumerState<BondDetailPage> {
  bool _showAllSchedules = false;
  bool _showAllPayments = false;

  Future<void> _archive(Bond bond) async {
    final confirmed = await showConfirmDialog(
      context,
      title: bond.isArchived ? 'Restore bond?' : 'Archive bond?',
      message: bond.isArchived
          ? 'This bond will return to your active portfolio and reminders.'
          : 'The bond and its history stay safe, but it will be excluded from active totals and reminders.',
      confirmLabel: bond.isArchived ? 'Restore' : 'Archive',
      icon: Icons.inventory_2_outlined,
    );
    if (!confirmed) return;
    final repo = ref.read(bondRepositoryProvider);
    if (bond.isArchived) {
      await repo.restore(bond.id);
    } else {
      await repo.archive(bond.id);
    }
    if (mounted) {
      showAppSnackBar(
        context,
        bond.isArchived ? 'Bond restored.' : 'Bond archived.',
      );
    }
  }

  Future<void> _markMatured(Bond bond) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Mark bond as matured?',
      message: 'The bond will move to your matured holdings. You can still record its final payment.',
      confirmLabel: 'Mark matured',
      icon: Icons.flag_rounded,
    );
    if (!confirmed) return;
    await ref.read(bondRepositoryProvider).markMatured(bond.id);
    if (mounted) showAppSnackBar(context, 'Bond marked as matured.');
  }

  Future<void> _delete(Bond bond) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${bond.name}?',
      message: 'This permanently removes the bond, its interest schedule and every recorded payment. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    await ref.read(bondRepositoryProvider).delete(bond.id);
    if (mounted) {
      Navigator.of(context).pop();
      showAppSnackBar(context, 'Bond deleted.');
    }
  }

  Future<void> _markPaid(Bond bond, InterestSchedule schedule) async {
    final success = await showRecordPaymentDialog(
      context,
      ref: ref,
      bond: bond,
      schedule: schedule,
    );
    if (success && mounted) {
      showAppSnackBar(context, 'Interest payment recorded.');
    }
  }

  Future<void> _deletePayment(PaymentTransaction payment) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete this payment?',
      message: 'The payment will be removed and its interest schedule will return to pending.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    await ref.read(paymentRepositoryProvider).deletePayment(payment.id);
    if (mounted) showAppSnackBar(context, 'Payment removed.');
  }

  @override
  Widget build(BuildContext context) {
    final bondAsync = ref.watch(bondByIdProvider(widget.bondId));
    final schedulesAsync = ref.watch(schedulesForBondProvider(widget.bondId));
    final paymentsAsync = ref.watch(paymentsForBondProvider(widget.bondId));

    if (bondAsync.isLoading ||
        schedulesAsync.isLoading ||
        paymentsAsync.isLoading) {
      return const AppPage(
        showBack: true,
        title: 'Bond details',
        child: LoadingView(cards: 3),
      );
    }
    if (bondAsync.hasError) {
      return AppPage(
        showBack: true,
        title: 'Bond details',
        child: ErrorView(
          error: bondAsync.error!,
          onRetry: () => ref.invalidate(bondByIdProvider(widget.bondId)),
        ),
      );
    }
    final bond = bondAsync.valueOrNull;
    if (bond == null) {
      return AppPage(
        showBack: true,
        title: 'Bond not found',
        child: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'This bond no longer exists',
          message: 'It may have been deleted. Return to your portfolio.',
          primaryLabel: 'Back to bonds',
          onPrimary: () => context.go('/bonds'),
        ),
      );
    }

    final schedules = schedulesAsync.valueOrNull ?? const <InterestSchedule>[];
    final payments = paymentsAsync.valueOrNull ?? const <PaymentTransaction>[];
    final formatter = ref.watch(moneyFormatterProvider);
    final pending =
        schedules
            .where((schedule) => schedule.status == ScheduleStatus.pending)
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final overdue = pending.where((schedule) => schedule.isOverdue).toList();
    final upcoming = pending.where((schedule) => !schedule.isOverdue).toList();
    final sortedPayments = [...payments]
      ..sort((a, b) => b.paidDate.compareTo(a.paidDate));
    final totalReceived = payments
        .where((payment) => payment.type == PaymentType.interest)
        .fold(0, (sum, payment) => sum + payment.amountPaise);
    final visibleSchedules = _showAllSchedules
        ? [...overdue, ...upcoming]
        : [...overdue, ...upcoming.take(6)];
    final visiblePayments = _showAllPayments
        ? sortedPayments
        : sortedPayments.take(5).toList();

    return AppPage(
      showBack: true,
      title: bond.name,
      subtitle: bond.issuer,
      actions: [
        IconButton(
          tooltip: 'Edit bond',
          onPressed: () => context.push('/bonds/${bond.id}/edit'),
          icon: const Icon(Icons.edit_outlined),
        ),
        PopupMenuButton<String>(
          tooltip: 'Bond actions',
          onSelected: (value) {
            switch (value) {
              case 'archive':
                _archive(bond);
              case 'mature':
                _markMatured(bond);
              case 'delete':
                _delete(bond);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(
                    bond.isArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(bond.isArchived ? 'Restore bond' : 'Archive bond'),
                ],
              ),
            ),
            if (!bond.isMatured)
              const PopupMenuItem(
                value: 'mature',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Mark as matured'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.danger,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Delete bond',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              BondStatusPill(status: bond.status),
              const SizedBox(width: 7),
              FrequencyPill(frequency: bond.frequency, dense: true),
              const SizedBox(width: 7),
              if (!bond.isArchived)
                Pill(
                  label: bond.daysToMaturity <= 0
                      ? 'Matured'
                      : '${bond.daysToMaturity} days to maturity',
                  color: bond.daysToMaturity <= 0
                      ? const Color(0xFF2E5AAC)
                      : context.scheme.primary,
                  icon: Icons.timelapse_rounded,
                  dense: true,
                ),
            ],
          ),
          if (bond.isArchived) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: context.scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: context.mutedColor,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'This bond is archived. It is excluded from portfolio totals and reminders.',
                      style: context.texts.bodySmall?.copyWith(
                        color: context.mutedColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _archive(bond),
                    child: const Text('Restore'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _BondHero(
            bond: bond,
            formatter: formatter,
            totalReceived: totalReceived,
          ),
          const SizedBox(height: 14),
          ResponsiveGrid(
            minItemWidth: 150,
            maxColumns: 4,
            children: [
              _DetailMetric(
                label: 'Annual interest',
                value: formatter.format(bond.annualInterestPaise),
                icon: Icons.trending_up_rounded,
                color: AppColors.emerald,
              ),
              _DetailMetric(
                label: 'Per credit',
                value: formatter.format(bond.interestPerPeriodPaise),
                icon: Icons.payments_outlined,
                color: AppColors.teal,
              ),
              _DetailMetric(
                label: 'Interest received',
                value: formatter.format(totalReceived),
                icon: Icons.savings_outlined,
                color: const Color(0xFF2E5AAC),
              ),
              _DetailMetric(
                label: 'Expected maturity',
                value: formatter.format(bond.expectedMaturityAmountPaise),
                icon: Icons.flag_outlined,
                color: AppColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final overview = _OverviewCard(bond: bond, formatter: formatter);
              final timeline = _TimelineCard(
                bond: bond,
                schedules: schedules,
                payments: payments,
                formatter: formatter,
              );
              if (constraints.maxWidth >= 880) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: overview),
                    const SizedBox(width: 14),
                    Expanded(flex: 3, child: timeline),
                  ],
                );
              }
              return Column(
                children: [overview, const SizedBox(height: 14), timeline],
              );
            },
          ),
          const SizedBox(height: 14),
          _ScheduleCard(
            bond: bond,
            schedules: schedules,
            visible: visibleSchedules,
            total: schedules.length,
            showAll: _showAllSchedules,
            onToggle: () =>
                setState(() => _showAllSchedules = !_showAllSchedules),
            formatter: formatter,
            onMarkPaid: (schedule) => _markPaid(bond, schedule),
          ),
          const SizedBox(height: 14),
          _PaymentHistoryCard(
            payments: visiblePayments,
            total: payments.length,
            showAll: _showAllPayments,
            onToggle: () =>
                setState(() => _showAllPayments = !_showAllPayments),
            formatter: formatter,
            onDelete: _deletePayment,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/bonds/${bond.id}/edit'),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit bond'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _archive(bond),
                  icon: Icon(
                    bond.isArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                    size: 18,
                  ),
                  label: Text(bond.isArchived ? 'Restore' : 'Archive'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BondHero extends StatelessWidget {
  const _BondHero({
    required this.bond,
    required this.formatter,
    required this.totalReceived,
  });

  final Bond bond;
  final MoneyFormatter formatter;
  final int totalReceived;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PRINCIPAL INVESTED',
                style: context.texts.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 1.4,
                  fontSize: 9.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  Money.rate(bond.annualRate),
                  style: context.texts.labelSmall?.copyWith(
                    color: AppColors.mint,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatter.format(bond.principalPaise),
              style: context.texts.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.9,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroMini(
                  label: 'Maturity value',
                  value: formatter.format(
                    bond.expectedMaturityAmountPaise,
                    compact: true,
                  ),
                ),
              ),
              Expanded(
                child: _HeroMini(
                  label: 'Interest received',
                  value: formatter.format(totalReceived, compact: true),
                ),
              ),
              Expanded(
                child: _HeroMini(
                  label: 'Maturity',
                  value: Money.dateShort(bond.maturityDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppProgressBar(
                  value: bond.progressToMaturity,
                  height: 6,
                  gradient: const LinearGradient(
                    colors: [AppColors.mint, Color(0xFF8DE8CF)],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(bond.progressToMaturity * 100).round()}%',
                style: context.texts.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMini extends StatelessWidget {
  const _HeroMini({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.texts.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
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
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: context.isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  style: context.texts.labelSmall?.copyWith(
                    color: context.mutedColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.bond, required this.formatter});

  final Bond bond;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Investment overview',
            subtitle: 'Terms and key dates',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          InfoRow(
            label: 'Issuer',
            value: bond.issuer,
            icon: Icons.business_outlined,
          ),
          InfoRow(
            label: 'Purchase date',
            value: Money.date(bond.purchaseDate),
            icon: Icons.shopping_bag_outlined,
          ),
          InfoRow(
            label: 'First credit',
            value: Money.date(bond.firstInterestDate),
            icon: Icons.event_available_outlined,
          ),
          InfoRow(
            label: 'Frequency',
            value: bond.frequency.label,
            icon: Icons.repeat_rounded,
          ),
          InfoRow(
            label: 'Maturity date',
            value: Money.date(bond.maturityDate),
            icon: Icons.event_outlined,
          ),
          InfoRow(
            label: 'Time remaining',
            value: bond.daysToMaturity <= 0
                ? 'Matured'
                : '${bond.daysToMaturity} days',
            icon: Icons.timelapse_rounded,
          ),
          InfoRow(
            label: 'Annual interest',
            value: formatter.format(bond.annualInterestPaise),
            icon: Icons.trending_up_rounded,
          ),
          if (bond.paymentAccount != null) ...[
            const Divider(height: 22),
            InfoRow(
              label: 'Payment account',
              value: bond.paymentAccount!,
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
          if (bond.notes != null) ...[
            const Divider(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes_rounded, size: 16, color: context.mutedColor),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: context.texts.labelSmall?.copyWith(
                          color: context.mutedColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bond.notes!,
                        style: context.texts.bodySmall?.copyWith(height: 1.55),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.bond,
    required this.schedules,
    required this.visible,
    required this.total,
    required this.showAll,
    required this.onToggle,
    required this.formatter,
    required this.onMarkPaid,
  });

  final Bond bond;
  final List<InterestSchedule> schedules;
  final List<InterestSchedule> visible;
  final int total;
  final bool showAll;
  final VoidCallback onToggle;
  final MoneyFormatter formatter;
  final ValueChanged<InterestSchedule> onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final paidCount = schedules.where((s) => s.isPaid).length;
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Interest schedule',
            subtitle:
                '$paidCount of $total credits received · ${bond.frequency.label.toLowerCase()}',
            actionLabel: total > visible.length || showAll
                ? (showAll ? 'Show less' : 'Show all')
                : null,
            onAction: total > visible.length || showAll ? onToggle : null,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          if (schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'No interest schedule was generated for this bond.',
                style: context.texts.bodySmall?.copyWith(
                  color: context.mutedColor,
                ),
              ),
            )
          else
            for (var i = 0; i < visible.length; i++) ...[
              _ScheduleRow(
                schedule: visible[i],
                bond: bond,
                formatter: formatter,
                onMarkPaid: () => onMarkPaid(visible[i]),
              ),
              if (i != visible.length - 1)
                Divider(height: 1, color: context.borderColor),
            ],
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.schedule,
    required this.bond,
    required this.formatter,
    required this.onMarkPaid,
  });

  final InterestSchedule schedule;
  final Bond bond;
  final MoneyFormatter formatter;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final overdue = schedule.isOverdue;
    final paid = schedule.isPaid;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  (paid
                          ? AppColors.emerald
                          : overdue
                          ? AppColors.danger
                          : context.scheme.primary)
                      .withValues(alpha: context.isDark ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              paid
                  ? Icons.check_rounded
                  : overdue
                  ? Icons.error_outline_rounded
                  : Icons.schedule_rounded,
              size: 19,
              color: paid
                  ? AppColors.emerald
                  : overdue
                  ? AppColors.danger
                  : context.scheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Money.date(schedule.dueDate),
                  style: context.texts.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  paid
                      ? 'Credited ${schedule.paidDate == null ? '' : Money.date(schedule.paidDate!)}'
                      : overdue
                      ? '${-schedule.daysUntilDue} days overdue'
                      : schedule.daysUntilDue == 0
                      ? 'Due today'
                      : 'In ${schedule.daysUntilDue} days',
                  style: context.texts.bodySmall?.copyWith(
                    color: overdue ? AppColors.danger : context.mutedColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(schedule.expectedInterestPaise),
                style: context.texts.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              if (paid)
                const ScheduleStatusPill(
                  status: ScheduleStatus.paid,
                  dense: true,
                )
              else
                GestureDetector(
                  onTap: onMarkPaid,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: context.scheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Mark paid',
                      style: context.texts.labelSmall?.copyWith(
                        color: context.scheme.primary,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({
    required this.payments,
    required this.total,
    required this.showAll,
    required this.onToggle,
    required this.formatter,
    required this.onDelete,
  });

  final List<PaymentTransaction> payments;
  final int total;
  final bool showAll;
  final VoidCallback onToggle;
  final MoneyFormatter formatter;
  final ValueChanged<PaymentTransaction> onDelete;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Payment history',
            subtitle: '$total recorded ${total == 1 ? 'payment' : 'payments'}',
            actionLabel: total > payments.length || showAll
                ? (showAll ? 'Show less' : 'Show all')
                : null,
            onAction: total > payments.length || showAll ? onToggle : null,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          if (payments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'No payments recorded yet. Mark a scheduled credit as paid to start your history.',
                style: context.texts.bodySmall?.copyWith(
                  color: context.mutedColor,
                ),
              ),
            )
          else
            for (var i = 0; i < payments.length; i++) ...[
              _PaymentHistoryRow(
                payment: payments[i],
                formatter: formatter,
                onDelete: () => onDelete(payments[i]),
              ),
              if (i != payments.length - 1)
                Divider(height: 1, color: context.borderColor),
            ],
        ],
      ),
    );
  }
}

class _PaymentHistoryRow extends StatelessWidget {
  const _PaymentHistoryRow({
    required this.payment,
    required this.formatter,
    required this.onDelete,
  });

  final PaymentTransaction payment;
  final MoneyFormatter formatter;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(
                alpha: context.isDark ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.south_west_rounded,
              size: 17,
              color: AppColors.emerald,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${payment.type.label} credited',
                  style: context.texts.titleSmall,
                ),
                Text(
                  payment.scheduleId == null
                      ? 'Manual entry · ${Money.date(payment.paidDate)}'
                      : 'Scheduled credit · ${Money.date(payment.paidDate)}',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                    fontSize: 11,
                  ),
                ),
                if (payment.notes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    payment.notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.mutedColor,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatter.format(payment.amountPaise),
            style: context.texts.titleSmall?.copyWith(
              color: AppColors.emerald,
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            tooltip: 'Delete payment',
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 17,
              color: context.mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.bond,
    required this.schedules,
    required this.payments,
    required this.formatter,
  });

  final Bond bond;
  final List<InterestSchedule> schedules;
  final List<PaymentTransaction> payments;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final events = <_TimelineEvent>[
      _TimelineEvent(
        date: bond.purchaseDate,
        icon: Icons.shopping_bag_outlined,
        title: 'Bond purchased',
        subtitle:
            '${formatter.format(bond.principalPaise)} at ${Money.rate(bond.annualRate)}',
        color: AppColors.teal,
      ),
      for (final payment in payments)
        _TimelineEvent(
          date: payment.paidDate,
          icon: Icons.south_west_rounded,
          title: '${payment.type.label} credited',
          subtitle: formatter.format(payment.amountPaise),
          color: AppColors.emerald,
        ),
      for (final schedule in schedules.where(
        (s) => s.status == ScheduleStatus.pending,
      ))
        _TimelineEvent(
          date: schedule.dueDate,
          icon: schedule.isOverdue
              ? Icons.error_outline_rounded
              : Icons.schedule_rounded,
          title: schedule.isOverdue
              ? 'Interest overdue'
              : 'Interest credit scheduled',
          subtitle: formatter.format(schedule.expectedInterestPaise),
          color: schedule.isOverdue ? AppColors.danger : AppColors.gold,
        ),
      _TimelineEvent(
        date: bond.maturityDate,
        icon: Icons.flag_outlined,
        title: 'Maturity',
        subtitle: formatter.format(bond.expectedMaturityAmountPaise),
        color: const Color(0xFF2E5AAC),
      ),
      if (bond.archivedAt != null)
        _TimelineEvent(
          date: bond.archivedAt!,
          icon: Icons.inventory_2_outlined,
          title: 'Bond archived',
          subtitle: 'Excluded from active portfolio totals',
          color: context.mutedColor,
        ),
    ]..sort((a, b) => a.date.compareTo(b.date));

    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Event timeline',
            subtitle: 'Every milestone in this investment',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < events.length; i++)
            _TimelineRow(
              event: events[i],
              first: i == 0,
              last: i == events.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.date,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final DateTime date;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.first,
    required this.last,
  });

  final _TimelineEvent event;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 8,
                  color: first ? Colors.transparent : context.borderColor,
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: event.color.withValues(
                      alpha: context.isDark ? 0.22 : 0.12,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: event.color.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(event.icon, size: 11, color: event.color),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: last ? Colors.transparent : context.borderColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: context.texts.titleSmall,
                        ),
                      ),
                      Text(
                        Money.date(event.date),
                        style: context.texts.labelSmall?.copyWith(
                          color: context.mutedColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.mutedColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
