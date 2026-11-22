import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/theme/app_colors.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/core/widgets/app_page.dart';
import 'package:bondtrack/core/widgets/brand_mark.dart';
import 'package:bondtrack/core/widgets/charts/portfolio_donut.dart';
import 'package:bondtrack/core/widgets/common.dart';
import 'package:bondtrack/core/widgets/empty_state.dart';
import 'package:bondtrack/core/widgets/metric_card.dart';
import 'package:bondtrack/core/widgets/loading_view.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/core/widgets/section_header.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';
import 'package:bondtrack/domain/models/portfolio_models.dart';
import 'package:bondtrack/features/dashboard/presentation/widgets/monthly_income_chart.dart';
import 'package:bondtrack/features/payments/presentation/widgets/record_payment_dialog.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final unread = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return AppPage(
      header: _DashboardHeader(unread: unread),
      child: AsyncValueView<DashboardData>(
        value: dashboard,
        loading: const LoadingView(cards: 4),
        errorBuilder: (error, stack) => ErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(bondsProvider);
            ref.invalidate(schedulesProvider);
            ref.invalidate(paymentsProvider);
          },
        ),
        builder: (data) => _DashboardBody(data: data),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BrandMark(size: 38),
            const Spacer(),
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifications',
              badge: unread > 0 ? unread : null,
              onTap: () => context.push('/notifications'),
            ),
            const SizedBox(width: 8),
            _HeaderIconButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Portfolio overview',
          style: context.texts.headlineLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          Money.dateWithWeekday(DateTime.now()),
          style: context.texts.bodyMedium?.copyWith(color: context.mutedColor),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: context.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: BorderSide(color: context.borderColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: onTap,
            child: Tooltip(
              message: tooltip,
              child: SizedBox(
                width: 42,
                height: 42,
                child: Icon(icon, size: 21),
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              constraints: const BoxConstraints(minWidth: 17),
              decoration: BoxDecoration(
                color: context.scheme.error,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.scaffoldColor, width: 2),
              ),
              child: Text(
                badge! > 9 ? '9+' : '$badge',
                textAlign: TextAlign.center,
                style: context.texts.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  Future<void> _markPaid(
    BuildContext context,
    WidgetRef ref,
    ScheduleWithBond item,
  ) async {
    final success = await showRecordPaymentDialog(
      context,
      ref: ref,
      bond: item.bond,
      schedule: item.schedule,
    );
    if (success && context.mounted) {
      showAppSnackBar(context, 'Interest payment recorded.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(moneyFormatterProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PortfolioHero(data: data, formatter: formatter),
        const SizedBox(height: 16),
        ResponsiveGrid(
          minItemWidth: 150,
          maxColumns: 4,
          children: [
            _QuickAction(
              icon: Icons.add_card_rounded,
              label: 'Add bond',
              color: AppColors.teal,
              onTap: () => context.push('/bonds/new'),
            ),
            _QuickAction(
              icon: Icons.upload_file_rounded,
              label: 'Import Excel',
              color: AppColors.emerald,
              onTap: () => context.push('/import'),
            ),
            _QuickAction(
              icon: Icons.calendar_month_rounded,
              label: 'Calendar',
              color: const Color(0xFF2E5AAC),
              onTap: () => context.go('/calendar'),
            ),
            _QuickAction(
              icon: Icons.receipt_long_rounded,
              label: 'Payments',
              color: AppColors.gold,
              onTap: () => context.go('/payments'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (data.isEmpty)
          EmptyState(
            icon: Icons.account_balance_rounded,
            title: 'Build your bond portfolio',
            message: 'Add your first bond or import your existing Excel sheet. BondTrack will build the interest calendar, maturity tracker and analytics automatically.',
            primaryLabel: 'Add your first bond',
            onPrimary: () => context.push('/bonds/new'),
            secondaryLabel: 'Import from Excel',
            onSecondary: () => context.push('/import'),
          )
        else ...[
          ResponsiveGrid(
            minItemWidth: 155,
            maxColumns: 4,
            children: [
              MetricCard(
                label: 'Expected monthly interest',
                value: formatter.format(data.expectedMonthlyInterestPaise),
                caption:
                    '${formatter.format(data.expectedAnnualInterestPaise)} per year',
                icon: Icons.payments_outlined,
                accent: AppColors.emerald,
              ),
              MetricCard(
                label: 'Interest received',
                value: formatter.format(data.totalInterestReceivedPaise),
                caption: 'Across all recorded credits',
                icon: Icons.account_balance_wallet_outlined,
                accent: AppColors.teal,
              ),
              MetricCard(
                label: 'Pending interest',
                value: formatter.format(data.pendingInterestPaise),
                caption: data.overdueCount > 0
                    ? '${data.overdueCount} overdue payment${data.overdueCount == 1 ? '' : 's'}'
                    : 'All scheduled credits on track',
                icon: Icons.schedule_rounded,
                accent: data.overdueCount > 0
                    ? AppColors.danger
                    : AppColors.gold,
              ),
              MetricCard(
                label: 'Active bonds',
                value: '${data.activeBondCount}',
                caption: 'Weighted yield ${Money.rate(data.weightedYield)}',
                icon: Icons.account_balance_outlined,
                accent: const Color(0xFF2E5AAC),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PremiumCard(
            shadow: false,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      color: data.healthScore < 60
                          ? AppColors.danger
                          : AppColors.emerald,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Portfolio health · ${data.healthLabel}',
                        style: context.texts.titleSmall,
                      ),
                    ),
                    Text(
                      '${data.healthScore}/100',
                      style: context.texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _DashboardAmount(
                      label: 'Expected this month',
                      amount: formatter.format(data.expectedThisMonthPaise),
                    ),
                    _DashboardAmount(
                      label: 'Received this month',
                      amount: formatter.format(data.receivedThisMonthPaise),
                    ),
                    _DashboardAmount(
                      label: 'Overdue',
                      amount: formatter.format(data.overdueAmountPaise),
                    ),
                  ],
                ),
                if (data.upcomingTimeline.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: context.borderColor),
                  const SizedBox(height: 10),
                  Text('Upcoming events', style: context.texts.labelLarge),
                  const SizedBox(height: 4),
                  for (final event in data.upcomingTimeline.take(4))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        switch (event.type) {
                          UpcomingEventType.interest => Icons.payments_outlined,
                          UpcomingEventType.maturity => Icons.flag_outlined,
                          UpcomingEventType.overdue =>
                            Icons.warning_amber_rounded,
                        },
                        color: event.type == UpcomingEventType.overdue
                            ? AppColors.danger
                            : context.scheme.primary,
                      ),
                      title: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${Money.date(event.date)} · ${event.subtitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: event.bondId == null
                          ? null
                          : () => context.push('/bonds/${event.bondId}'),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 880) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _IncomeCard(data: data, formatter: formatter),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 350,
                      child: _DistributionCard(
                        data: data,
                        formatter: formatter,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _IncomeCard(data: data, formatter: formatter),
                  const SizedBox(height: 14),
                  _DistributionCard(data: data, formatter: formatter),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final payments = _UpcomingPaymentsCard(
                data: data,
                formatter: formatter,
                onMarkPaid: (item) => _markPaid(context, ref, item),
              );
              final maturities = _UpcomingMaturitiesCard(
                data: data,
                formatter: formatter,
              );
              if (constraints.maxWidth >= 880) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: payments),
                    const SizedBox(width: 14),
                    Expanded(flex: 2, child: maturities),
                  ],
                );
              }
              return Column(
                children: [payments, const SizedBox(height: 14), maturities],
              );
            },
          ),
          const SizedBox(height: 18),
          _RecentActivityCard(data: data, formatter: formatter),
        ],
      ],
    );
  }
}

class _PortfolioHero extends StatelessWidget {
  const _PortfolioHero({required this.data, required this.formatter});

  final DashboardData data;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.26),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _HeroPatternPainter())),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TOTAL INVESTED',
                        style: context.texts.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.62),
                          letterSpacing: 1.6,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.mint,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${data.activeBondCount} active',
                              style: context.texts.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatter.format(data.totalInvestedPaise),
                      style: context.texts.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Expected maturity ${formatter.format(data.maturityValuePaise)}',
                    style: context.texts.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.62),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroStat(
                          label: 'Annual income',
                          value: formatter.format(
                            data.expectedAnnualInterestPaise,
                            compact: true,
                          ),
                        ),
                      ),
                      _HeroDivider(),
                      Expanded(
                        child: _HeroStat(
                          label: 'Received',
                          value: formatter.format(
                            data.totalInterestReceivedPaise,
                            compact: true,
                          ),
                        ),
                      ),
                      _HeroDivider(),
                      Expanded(
                        child: _HeroStat(
                          label: 'Yield',
                          value: Money.rate(data.weightedYield),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

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
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: context.texts.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}

class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.9, -size.height * 0.15),
        size.width * (0.2 + i * 0.09),
        paint,
      );
    }
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    final accent = Paint()
      ..color = AppColors.mint.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.9),
      size.width * 0.22,
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      shadow: false,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: context.isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeCard extends StatelessWidget {
  const _IncomeCard({required this.data, required this.formatter});

  final DashboardData data;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Income rhythm',
            subtitle: 'Actual interest received vs scheduled credits',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          MonthlyIncomeChart(points: data.monthlySeries, formatter: formatter),
        ],
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.data, required this.formatter});

  final DashboardData data;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Portfolio mix',
            subtitle: 'Principal by issuer',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 14),
          PortfolioDonut(
            slices: data.distribution,
            formatter: formatter,
            totalPaise: data.totalInvestedPaise,
          ),
        ],
      ),
    );
  }
}

class _UpcomingPaymentsCard extends StatelessWidget {
  const _UpcomingPaymentsCard({
    required this.data,
    required this.formatter,
    required this.onMarkPaid,
  });

  final DashboardData data;
  final MoneyFormatter formatter;
  final ValueChanged<ScheduleWithBond> onMarkPaid;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Upcoming interest',
            subtitle: 'Next credits across your portfolio',
            actionLabel: 'Calendar',
            onAction: () => context.go('/calendar'),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          if (data.upcomingPayments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No pending interest payments.',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < data.upcomingPayments.length; i++) ...[
              _PaymentRow(
                item: data.upcomingPayments[i],
                formatter: formatter,
                onMarkPaid: () => onMarkPaid(data.upcomingPayments[i]),
              ),
              if (i != data.upcomingPayments.length - 1)
                Divider(height: 1, color: context.borderColor),
            ],
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.item,
    required this.formatter,
    required this.onMarkPaid,
  });

  final ScheduleWithBond item;
  final MoneyFormatter formatter;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final schedule = item.schedule;
    final overdue = schedule.isOverdue;
    return InkWell(
      onTap: () => context.push('/bonds/${item.bond.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 46,
              decoration: BoxDecoration(
                color: (overdue ? AppColors.danger : context.scheme.primary)
                    .withValues(alpha: context.isDark ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Money.dayNumber(schedule.dueDate),
                    style: context.texts.titleSmall?.copyWith(
                      color: overdue
                          ? AppColors.danger
                          : context.scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    Money.monthShort(schedule.dueDate).toUpperCase(),
                    style: context.texts.labelSmall?.copyWith(
                      color: overdue
                          ? AppColors.danger
                          : context.scheme.primary,
                      fontSize: 8.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.bond.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    overdue
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
                const SizedBox(height: 4),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: context.scheme.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Mark paid',
                          style: context.texts.labelSmall?.copyWith(
                            color: context.scheme.primary,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
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

class _UpcomingMaturitiesCard extends StatelessWidget {
  const _UpcomingMaturitiesCard({required this.data, required this.formatter});

  final DashboardData data;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Maturities',
            subtitle: 'Principal coming back',
            actionLabel: 'Track',
            onAction: () => context.go('/maturity'),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          if (data.upcomingMaturities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No upcoming maturities.',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < data.upcomingMaturities.length; i++) ...[
              _MaturityRow(
                bond: data.upcomingMaturities[i],
                formatter: formatter,
              ),
              if (i != data.upcomingMaturities.length - 1)
                Divider(height: 1, color: context.borderColor),
            ],
        ],
      ),
    );
  }
}

class _MaturityRow extends StatelessWidget {
  const _MaturityRow({required this.bond, required this.formatter});

  final Bond bond;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/bonds/${bond.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bond.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.titleSmall,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatter.format(bond.principalPaise, compact: true),
                  style: context.texts.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Text(
                  Money.date(bond.maturityDate),
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  bond.daysToMaturity <= 0
                      ? 'Matured'
                      : '${bond.daysToMaturity} days left',
                  style: context.texts.labelSmall?.copyWith(
                    color: context.mutedColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            AppProgressBar(
              value: bond.progressToMaturity,
              height: 5,
              gradient: AppColors.tealGradient,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.data, required this.formatter});

  final DashboardData data;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent activity',
            subtitle: 'Latest recorded payments',
            actionLabel: 'History',
            onAction: () => context.go('/payments'),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          if (data.recentPayments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Recorded payments will appear here.',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < data.recentPayments.length; i++) ...[
              _ActivityRow(item: data.recentPayments[i], formatter: formatter),
              if (i != data.recentPayments.length - 1)
                Divider(height: 1, color: context.borderColor),
            ],
        ],
      ),
    );
  }
}

class _DashboardAmount extends StatelessWidget {
  const _DashboardAmount({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.texts.labelSmall?.copyWith(color: context.mutedColor),
        ),
        const SizedBox(height: 2),
        Text(amount, style: context.texts.labelLarge),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item, required this.formatter});

  final PaymentWithBond item;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final payment = item.payment;
    final isMaturity = payment.type == PaymentType.maturity;
    return InkWell(
      onTap: () => context.push('/bonds/${item.bond.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (isMaturity ? AppColors.gold : AppColors.emerald)
                    .withValues(alpha: context.isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                isMaturity ? Icons.flag_rounded : Icons.south_west_rounded,
                size: 17,
                color: isMaturity ? AppColors.gold : AppColors.emerald,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.bond.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.titleSmall,
                  ),
                  Text(
                    '${payment.type.label} · ${Money.date(payment.paidDate)}',
                    style: context.texts.bodySmall?.copyWith(
                      color: context.mutedColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+${formatter.format(payment.amountPaise)}',
              style: context.texts.titleSmall?.copyWith(
                color: AppColors.emerald,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
