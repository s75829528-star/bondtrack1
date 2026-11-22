import 'package:flutter/material.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/domain/entities/bond.dart';

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.color,
    this.background,
    this.icon,
    this.dense = false,
  });

  final String label;
  final Color color;
  final Color? background;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color:
            background ?? color.withValues(alpha: context.isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 11 : 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: context.texts.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: dense ? 10.5 : 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class BondStatusPill extends StatelessWidget {
  const BondStatusPill({super.key, required this.status, this.dense = false});

  final BondStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      BondStatus.active => const Color(0xFF0FA37F),
      BondStatus.matured => const Color(0xFF2E5AAC),
      BondStatus.archived => const Color(0xFF6B7C93),
    };
    final icon = switch (status) {
      BondStatus.active => Icons.check_circle_rounded,
      BondStatus.matured => Icons.flag_rounded,
      BondStatus.archived => Icons.inventory_2_outlined,
    };
    return Pill(label: status.label, color: color, icon: icon, dense: dense);
  }
}

class ScheduleStatusPill extends StatelessWidget {
  const ScheduleStatusPill({
    super.key,
    required this.status,
    this.isOverdue = false,
    this.dense = false,
  });

  final ScheduleStatus status;
  final bool isOverdue;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = isOverdue
        ? const Color(0xFFD64545)
        : switch (status) {
            ScheduleStatus.paid => const Color(0xFF0FA37F),
            ScheduleStatus.partiallyPaid => const Color(0xFFB7791F),
            ScheduleStatus.pending => const Color(0xFF0F8B8D),
            ScheduleStatus.skipped => const Color(0xFF6B7C93),
          };
    final label = isOverdue ? 'Overdue' : status.label;
    return Pill(
      label: label,
      color: color,
      icon: isOverdue
          ? Icons.error_outline_rounded
          : switch (status) {
              ScheduleStatus.paid => Icons.check_rounded,
              ScheduleStatus.partiallyPaid => Icons.pie_chart_outline_rounded,
              ScheduleStatus.pending => Icons.schedule_rounded,
              ScheduleStatus.skipped => Icons.remove_circle_outline,
            },
      dense: dense,
    );
  }
}

class FrequencyPill extends StatelessWidget {
  const FrequencyPill({super.key, required this.frequency, this.dense = false});

  final InterestFrequency frequency;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Pill(
      label: frequency.label,
      color: context.scheme.tertiary,
      icon: Icons.repeat_rounded,
      dense: dense,
    );
  }
}
