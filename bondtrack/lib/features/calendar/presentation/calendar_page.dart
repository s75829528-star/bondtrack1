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
import 'package:bondtrack/core/widgets/metric_card.dart';
import 'package:bondtrack/core/widgets/pills.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/core/widgets/section_header.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/features/payments/presentation/widgets/record_payment_dialog.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final selected = ref.watch(selectedCalendarDayProvider);
    final schedules = ref.watch(schedulesProvider).valueOrNull ?? const [];
    final payments = ref.watch(paymentsProvider).valueOrNull ?? const [];
    final bonds = ref.watch(bondsProvider).valueOrNull ?? const [];
    final formatter = ref.watch(moneyFormatterProvider);

    final bondById = {for (final bond in bonds) bond.id: bond};
    final monthSchedules = schedules.where((schedule) {
      final bond = bondById[schedule.bondId];
      return bond != null &&
          bond.status != BondStatus.archived &&
          dates.isSameMonth(schedule.dueDate, month);
    }).toList();
    final monthMaturities = bonds.where((bond) {
      return bond.status != BondStatus.archived &&
          dates.isSameMonth(bond.maturityDate, month);
    }).toList();
    final expectedThisMonth = monthSchedules.fold(
      0,
      (sum, schedule) => sum + schedule.expectedInterestPaise,
    );
    final receivedThisMonth = payments
        .where((payment) => dates.isSameMonth(payment.paidDate, month))
        .fold(0, (sum, payment) => sum + payment.amountPaise);
    final pendingCount = monthSchedules
        .where((schedule) => schedule.status == ScheduleStatus.pending)
        .length;

    final daySchedules =
        monthSchedules
            .where((schedule) => dates.isSameDay(schedule.dueDate, selected))
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final dayMaturities = monthMaturities
        .where((bond) => dates.isSameDay(bond.maturityDate, selected))
        .toList();
    final dayPayments = payments
        .where((payment) => dates.isSameDay(payment.paidDate, selected))
        .toList();

    return AppPage(
      title: 'Interest calendar',
      subtitle: 'Every credit and maturity, month by month',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveGrid(
            minItemWidth: 150,
            maxColumns: 3,
            children: [
              _CalendarStat(
                label: 'Scheduled this month',
                value: formatter.format(expectedThisMonth),
                icon: Icons.event_available_rounded,
                color: AppColors.teal,
              ),
              _CalendarStat(
                label: 'Received this month',
                value: formatter.format(receivedThisMonth),
                icon: Icons.savings_outlined,
                color: AppColors.emerald,
              ),
              _CalendarStat(
                label: 'Pending credits',
                value: '$pendingCount',
                icon: Icons.pending_actions_rounded,
                color: AppColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Previous month',
                      onPressed: () {
                        ref.read(calendarMonthProvider.notifier).previous();
                        ref
                            .read(selectedCalendarDayProvider.notifier)
                            .state = dates.startOfMonth(
                          DateTime(month.year, month.month - 1),
                        );
                      },
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            Money.monthYear(month),
                            style: context.texts.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${monthSchedules.length} interest events · ${monthMaturities.length} maturities',
                            style: context.texts.bodySmall?.copyWith(
                              color: context.mutedColor,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next month',
                      onPressed: () {
                        ref.read(calendarMonthProvider.notifier).next();
                        ref
                            .read(selectedCalendarDayProvider.notifier)
                            .state = dates.startOfMonth(
                          DateTime(month.year, month.month + 1),
                        );
                      },
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    for (final day in const [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ])
                      Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: context.texts.labelSmall?.copyWith(
                              color: context.mutedColor,
                              fontSize: 9.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _MonthGrid(
                  month: month,
                  selected: selected,
                  schedules: monthSchedules,
                  maturities: monthMaturities,
                  onSelect: (day) =>
                      ref.read(selectedCalendarDayProvider.notifier).state =
                          day,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(
                      color: AppColors.teal,
                      label: 'Pending interest',
                    ),
                    const SizedBox(width: 14),
                    _LegendDot(color: AppColors.emerald, label: 'Received'),
                    const SizedBox(width: 14),
                    _LegendDot(
                      color: const Color(0xFF2E5AAC),
                      label: 'Maturity',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PremiumCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dates.isSameDay(selected, dates.today())
                                ? 'Today'
                                : Money.dateWithWeekday(selected),
                            style: context.texts.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            daySchedules.isEmpty &&
                                    dayMaturities.isEmpty &&
                                    dayPayments.isEmpty
                                ? 'No events on this date'
                                : '${daySchedules.length + dayMaturities.length + dayPayments.length} event${daySchedules.length + dayMaturities.length + dayPayments.length == 1 ? '' : 's'}',
                            style: context.texts.bodySmall?.copyWith(
                              color: context.mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        final today = dates.today();
                        ref.read(calendarMonthProvider.notifier).goTo(today);
                        ref.read(selectedCalendarDayProvider.notifier).state =
                            today;
                      },
                      icon: const Icon(Icons.today_rounded, size: 16),
                      label: const Text('Today'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (daySchedules.isEmpty &&
                    dayMaturities.isEmpty &&
                    dayPayments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 28,
                            color: context.mutedColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nothing scheduled for this day.',
                            style: context.texts.bodySmall?.copyWith(
                              color: context.mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  for (final schedule in daySchedules)
                    if (bondById[schedule.bondId] != null)
                      _AgendaInterestRow(
                        bond: bondById[schedule.bondId]!,
                        schedule: schedule,
                        formatter: formatter,
                        onMarkPaid: () async {
                          final success = await showRecordPaymentDialog(
                            context,
                            ref: ref,
                            bond: bondById[schedule.bondId]!,
                            schedule: schedule,
                          );
                          if (success && context.mounted) {
                            showAppSnackBar(
                              context,
                              'Interest payment recorded.',
                            );
                          }
                        },
                      ),
                  for (final bond in dayMaturities)
                    _AgendaMaturityRow(bond: bond, formatter: formatter),
                  for (final payment in dayPayments)
                    if (bondById[payment.bondId] != null)
                      _AgendaPaymentRow(
                        bond: bondById[payment.bondId]!,
                        amountPaise: payment.amountPaise,
                        label: payment.type.label,
                        formatter: formatter,
                      ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MonthUpcoming(
            schedules: monthSchedules,
            bonds: bondById,
            formatter: formatter,
            selected: selected,
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.schedules,
    required this.maturities,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final List<InterestSchedule> schedules;
  final List<Bond> maturities;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final days = dates.monthGrid(month);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 50,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        final inMonth = dates.isSameMonth(day, month);
        final isToday = dates.isSameDay(day, dates.today());
        final isSelected = dates.isSameDay(day, selected);
        final daySchedules = schedules
            .where((schedule) => dates.isSameDay(schedule.dueDate, day))
            .toList();
        final dayMaturities = maturities
            .where((bond) => dates.isSameDay(bond.maturityDate, day))
            .toList();

        final markers = <Color>[
          for (final schedule in daySchedules.take(2))
            schedule.isPaid
                ? AppColors.emerald
                : schedule.isOverdue
                ? AppColors.danger
                : AppColors.teal,
          if (dayMaturities.isNotEmpty) const Color(0xFF2E5AAC),
        ];

        return InkWell(
          onTap: () => onSelect(day),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? context.scheme.primary
                  : isToday
                  ? context.scheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(
                      color: context.scheme.primary.withValues(alpha: 0.35),
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: context.texts.labelMedium?.copyWith(
                    color: isSelected
                        ? context.scheme.onPrimary
                        : inMonth
                        ? context.scheme.onSurface
                        : context.mutedColor.withValues(alpha: 0.45),
                    fontWeight: isToday || isSelected
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  height: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final color in markers.take(3))
                        Container(
                          width: 4.5,
                          height: 4.5,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.85)
                                : color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: context.texts.labelSmall?.copyWith(
            color: context.mutedColor,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}

class _CalendarStat extends StatelessWidget {
  const _CalendarStat({
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

class _AgendaInterestRow extends StatelessWidget {
  const _AgendaInterestRow({
    required this.bond,
    required this.schedule,
    required this.formatter,
    required this.onMarkPaid,
  });

  final Bond bond;
  final InterestSchedule schedule;
  final MoneyFormatter formatter;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/bonds/${bond.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(
                  alpha: context.isDark ? 0.2 : 0.1,
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.payments_outlined,
                size: 18,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bond.name, style: context.texts.titleSmall),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      ScheduleStatusPill(
                        status: schedule.status,
                        isOverdue: schedule.isOverdue,
                        dense: true,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        schedule.isOverdue
                            ? '${-schedule.daysUntilDue} days overdue'
                            : 'Interest credit',
                        style: context.texts.bodySmall?.copyWith(
                          color: context.mutedColor,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatter.format(schedule.expectedInterestPaise),
                  style: context.texts.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!schedule.isPaid)
                  GestureDetector(
                    onTap: onMarkPaid,
                    child: Text(
                      'Mark paid',
                      style: context.texts.labelSmall?.copyWith(
                        color: context.scheme.primary,
                        fontSize: 9.5,
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

class _AgendaMaturityRow extends StatelessWidget {
  const _AgendaMaturityRow({required this.bond, required this.formatter});

  final Bond bond;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/bonds/${bond.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF2E5AAC)
                    .withValues(alpha: context.isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.flag_outlined,
                size: 18,
                color: Color(0xFF2E5AAC),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bond.name, style: context.texts.titleSmall),
                  Text(
                    'Maturity · ${bond.frequency.label}',
                    style: context.texts.bodySmall?.copyWith(
                      color: context.mutedColor,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatter.format(bond.expectedMaturityAmountPaise),
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaPaymentRow extends StatelessWidget {
  const _AgendaPaymentRow({
    required this.bond,
    required this.amountPaise,
    required this.label,
    required this.formatter,
  });

  final Bond bond;
  final int amountPaise;
  final String label;
  final MoneyFormatter formatter;

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
              size: 18,
              color: AppColors.emerald,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bond.name, style: context.texts.titleSmall),
                Text(
                  '$label received',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatter.format(amountPaise),
            style: context.texts.titleSmall?.copyWith(
              color: AppColors.emerald,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthUpcoming extends ConsumerWidget {
  const _MonthUpcoming({
    required this.schedules,
    required this.bonds,
    required this.formatter,
    required this.selected,
  });

  final List<InterestSchedule> schedules;
  final Map<int, Bond> bonds;
  final MoneyFormatter formatter;
  final DateTime selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming =
        schedules
            .where(
              (schedule) =>
                  schedule.status == ScheduleStatus.pending &&
                  !dates.dateOnly(schedule.dueDate).isBefore(selected),
            )
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (upcoming.isEmpty) return const SizedBox.shrink();
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Still ahead this month',
            subtitle: 'Upcoming credits after the selected date',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < upcoming.length; i++) ...[
            if (bonds[upcoming[i].bondId] != null)
              _AgendaInterestRow(
                bond: bonds[upcoming[i].bondId]!,
                schedule: upcoming[i],
                formatter: formatter,
                onMarkPaid: () async {
                  final success = await showRecordPaymentDialog(
                    context,
                    ref: ref,
                    bond: bonds[upcoming[i].bondId]!,
                    schedule: upcoming[i],
                  );
                  if (success && context.mounted) {
                    showAppSnackBar(context, 'Interest payment recorded.');
                  }
                },
              ),
            if (i != upcoming.length - 1)
              Divider(height: 1, color: context.borderColor),
          ],
        ],
      ),
    );
  }
}
