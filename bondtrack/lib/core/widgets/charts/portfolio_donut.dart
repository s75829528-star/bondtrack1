import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/theme/app_colors.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/domain/models/portfolio_models.dart';

class PortfolioDonut extends StatelessWidget {
  const PortfolioDonut({
    super.key,
    required this.slices,
    required this.formatter,
    required this.totalPaise,
    this.centerLabel = 'Invested',
    this.height = 220,
  });

  final List<PortfolioSlice> slices;
  final MoneyFormatter formatter;
  final int totalPaise;
  final String centerLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty || totalPaise <= 0) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No portfolio data yet',
            style: context.texts.bodySmall?.copyWith(color: context.mutedColor),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 440;
        final chart = SizedBox(
          width: wide ? 210 : 190,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: wide ? 62 : 56,
                  startDegreeOffset: -90,
                  borderData: FlBorderData(show: false),
                  sections: [
                    for (var i = 0; i < slices.length; i++)
                      PieChartSectionData(
                        value: slices[i].valuePaise.toDouble(),
                        color: AppColors.chart[i % AppColors.chart.length],
                        radius: 28,
                        showTitle: false,
                        cornerRadius: 3,
                      ),
                  ],
                ),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerLabel.toUpperCase(),
                    style: context.texts.labelSmall?.copyWith(
                      color: context.mutedColor,
                      letterSpacing: 1.1,
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter.format(totalPaise, compact: true),
                    style: context.texts.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        final legend = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < slices.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.chart[i % AppColors.chart.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        slices[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(slices[i].share * 100).toStringAsFixed(1)}%',
                      style: context.texts.labelSmall?.copyWith(
                        color: context.mutedColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 66,
                      child: Text(
                        formatter.format(slices[i].valuePaise, compact: true),
                        textAlign: TextAlign.right,
                        style: context.texts.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );

        if (wide) {
          return Row(
            children: [
              chart,
              const SizedBox(width: 12),
              Expanded(child: legend),
            ],
          );
        }
        return Column(children: [chart, const SizedBox(height: 8), legend]);
      },
    );
  }
}

class DistributionBar extends StatelessWidget {
  const DistributionBar({
    super.key,
    required this.label,
    required this.valuePaise,
    required this.totalPaise,
    required this.formatter,
    this.color,
  });

  final String label;
  final int valuePaise;
  final int totalPaise;
  final MoneyFormatter formatter;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final share = totalPaise <= 0 ? 0.0 : valuePaise / totalPaise;
    final accent = color ?? context.scheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                formatter.format(valuePaise, compact: true),
                style: context.texts.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(share * 100).toStringAsFixed(1)}%',
                style: context.texts.labelSmall?.copyWith(
                  color: context.mutedColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: share.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: accent.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ],
      ),
    );
  }
}
