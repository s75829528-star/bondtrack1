import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bondtrack/core/theme/app_colors.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/domain/models/portfolio_models.dart';

class MonthlyIncomeChart extends StatelessWidget {
  const MonthlyIncomeChart({
    super.key,
    required this.points,
    required this.formatter,
    this.height = 210,
  });

  final List<MonthlyIncomePoint> points;
  final MoneyFormatter formatter;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No income data yet',
            style: context.texts.bodySmall?.copyWith(color: context.mutedColor),
          ),
        ),
      );
    }
    final maxValue = points.fold<int>(
      0,
      (max, point) => point.receivedPaise > max ? point.receivedPaise : max,
    );
    final expectedMax = points.fold<int>(
      0,
      (max, point) => point.expectedPaise > max ? point.expectedPaise : max,
    );
    final ceiling = [maxValue, expectedMax, 1].reduce((a, b) => a > b ? a : b);
    final maxY = _niceCeiling(ceiling / 100);
    final showEvery = points.length > 9 ? 2 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Legend(color: AppColors.emerald, label: 'Received'),
            const SizedBox(width: 16),
            _Legend(
              color: AppColors.teal.withValues(alpha: 0.35),
              label: 'Scheduled',
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              groupsSpace: 6,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 3,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: context.borderColor.withValues(alpha: 0.7),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 46,
                    interval: maxY / 3,
                    getTitlesWidget: (value, meta) {
                      if (value == maxY) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          Money.formatPaise(
                            (value * 100).round(),
                            currencyCode: formatter.currencyCode,
                            compact: true,
                          ),
                          style: context.texts.labelSmall?.copyWith(
                            color: context.mutedColor,
                            fontSize: 9.5,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      if (index % showEvery != 0) {
                        return const SizedBox.shrink();
                      }
                      final point = points[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          Money.monthShort(point.month),
                          style: context.texts.labelSmall?.copyWith(
                            color: context.mutedColor,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => context.isDark
                      ? AppColors.darkSurfaceMuted
                      : AppColors.navy,
                  tooltipBorderRadius: BorderRadius.circular(10),
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final point = points[group.x];
                    final isReceived = rodIndex == 0;
                    final amount = isReceived
                        ? point.receivedPaise
                        : point.expectedPaise;
                    return BarTooltipItem(
                      '${Money.monthYear(point.month)}\n',
                      context.texts.labelSmall!.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      children: [
                        TextSpan(
                          text: '${isReceived ? 'Received' : 'Scheduled'}  ',
                          style: context.texts.labelSmall!.copyWith(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        TextSpan(
                          text: formatter.format(amount),
                          style: context.texts.labelMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              barGroups: [
                for (var i = 0; i < points.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 2,
                    barRods: [
                      BarChartRodData(
                        toY: points[i].receivedPaise / 100,
                        width: points.length > 9 ? 6 : 9,
                        color: AppColors.emerald,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: points[i].expectedPaise / 100,
                        width: points.length > 9 ? 6 : 9,
                        color: AppColors.teal.withValues(alpha: 0.28),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }

  double _niceCeiling(double value) {
    if (value <= 0) return 100;
    final magnitude = math
        .pow(10, (math.log(value) / math.ln10).floor())
        .toDouble();
    final normalised = value / magnitude;
    final step = normalised <= 1
        ? 1
        : normalised <= 2
        ? 2
        : normalised <= 5
        ? 5
        : 10;
    return step * magnitude;
  }
}

class AnnualIncomeChart extends StatelessWidget {
  const AnnualIncomeChart({
    super.key,
    required this.points,
    required this.formatter,
    this.height = 200,
  });

  final List<AnnualIncomePoint> points;
  final MoneyFormatter formatter;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }
    final maxValue = points.fold<int>(
      0,
      (max, p) => [
        p.receivedPaise,
        p.expectedPaise,
        max,
      ].reduce((a, b) => a > b ? a : b),
    );
    final maxY = (maxValue / 100).clamp(100, double.infinity).toDouble() * 1.15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Legend(color: AppColors.emerald, label: 'Received'),
            const SizedBox(width: 16),
            _Legend(
              color: AppColors.teal.withValues(alpha: 0.35),
              label: 'Scheduled',
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 3,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: context.borderColor.withValues(alpha: 0.7),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: maxY / 3,
                    getTitlesWidget: (value, meta) {
                      if (value == maxY) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          Money.formatPaise(
                            (value * 100).round(),
                            currencyCode: formatter.currencyCode,
                            compact: true,
                          ),
                          style: context.texts.labelSmall?.copyWith(
                            color: context.mutedColor,
                            fontSize: 9.5,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${points[index].year}',
                          style: context.texts.labelSmall?.copyWith(
                            color: context.mutedColor,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => context.isDark
                      ? AppColors.darkSurfaceMuted
                      : AppColors.navy,
                  tooltipBorderRadius: BorderRadius.circular(10),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final point = points[group.x];
                    final isReceived = rodIndex == 0;
                    return BarTooltipItem(
                      '${point.year} · ${isReceived ? 'Received' : 'Scheduled'}\n',
                      context.texts.labelSmall!.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      children: [
                        TextSpan(
                          text: formatter.format(
                            isReceived
                                ? point.receivedPaise
                                : point.expectedPaise,
                          ),
                          style: context.texts.labelMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              barGroups: [
                for (var i = 0; i < points.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 3,
                    barRods: [
                      BarChartRodData(
                        toY: points[i].receivedPaise / 100,
                        width: 9,
                        color: AppColors.emerald,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: points[i].expectedPaise / 100,
                        width: 9,
                        color: AppColors.teal.withValues(alpha: 0.28),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.texts.labelSmall?.copyWith(
            color: context.mutedColor,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}
