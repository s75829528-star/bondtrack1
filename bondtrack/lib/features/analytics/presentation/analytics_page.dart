import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/providers/ui_state_providers.dart';
import 'package:bondtrack/core/theme/app_colors.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/core/widgets/app_page.dart';
import 'package:bondtrack/core/widgets/charts/portfolio_donut.dart';
import 'package:bondtrack/core/widgets/empty_state.dart';
import 'package:bondtrack/core/widgets/metric_card.dart';
import 'package:bondtrack/core/widgets/loading_view.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/core/widgets/section_header.dart';
import 'package:bondtrack/domain/models/portfolio_models.dart';
import 'package:bondtrack/features/dashboard/presentation/widgets/monthly_income_chart.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final formatter = ref.watch(moneyFormatterProvider);
    final filter = ref.watch(analyticsFilterProvider);
    return AppPage(
      title: 'Analytics',
      subtitle: 'A clear view of your income, yield and concentration',
      child: AsyncValueView<AnalyticsData>(
        value: analytics,
        loading: const LoadingView(cards: 4),
        errorBuilder: (error, stack) => ErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(bondsProvider);
            ref.invalidate(schedulesProvider);
            ref.invalidate(paymentsProvider);
          },
        ),
        builder: (data) {
          if (data.isEmpty) {
            return EmptyState(
              icon: Icons.insights_rounded,
              title: 'Insights start with your first bond',
              message: 'Add investments or import your portfolio to see yield, income projections and issuer concentration.',
              primaryLabel: 'Add a bond',
              onPrimary: () => context.push('/bonds/new'),
              secondaryLabel: 'Import from Excel',
              onSecondary: () => context.push('/import'),
            );
          }
          return _AnalyticsContent(
            data: data,
            formatter: formatter,
            period: filter.period,
            onPeriodChanged: (period) async {
              if (period != AnalyticsPeriod.custom) {
                ref.read(analyticsFilterProvider.notifier).setPeriod(period);
                return;
              }
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(1980),
                lastDate: DateTime(2100, 12, 31),
                initialDateRange: DateTimeRange(
                  start: filter.customStart ?? data.rangeStart,
                  end: filter.customEnd ?? data.rangeEnd,
                ),
              );
              if (range != null) {
                ref
                    .read(analyticsFilterProvider.notifier)
                    .setCustomRange(range.start, range.end);
              }
            },
          );
        },
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({
    required this.data,
    required this.formatter,
    required this.period,
    required this.onPeriodChanged,
  });

  final AnalyticsData data;
  final MoneyFormatter formatter;
  final AnalyticsPeriod period;
  final ValueChanged<AnalyticsPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumCard(
          shadow: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Income date range',
                  style: context.texts.titleSmall,
                ),
              ),
              DropdownButton<AnalyticsPeriod>(
                value: period,
                underline: const SizedBox.shrink(),
                items: [
                  for (final option in AnalyticsPeriod.values)
                    DropdownMenuItem(value: option, child: Text(option.label)),
                ],
                onChanged: (value) {
                  if (value != null) onPeriodChanged(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PremiumCard(
          shadow: false,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${Money.date(data.rangeStart)} – ${Money.date(data.rangeEnd)}',
                style: context.texts.titleSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  _RangeAmount(
                    label: 'Expected',
                    amount: formatter.format(data.expectedInRangePaise),
                  ),
                  _RangeAmount(
                    label: 'Received',
                    amount: formatter.format(data.receivedInRangePaise),
                  ),
                  _RangeAmount(
                    label: 'Overdue',
                    amount: formatter.format(data.overdueAmountPaise),
                  ),
                  _RangeAmount(
                    label: 'Maturity exposure · 12m',
                    amount: formatter.format(
                      data.upcomingMaturityExposurePaise,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
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
              Text(
                'PORTFOLIO YIELD',
                style: context.texts.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.58),
                  letterSpacing: 1.5,
                  fontSize: 9.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${data.weightedYield.toStringAsFixed(2)}%',
                    style: context.texts.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text(
                      'weighted by principal',
                      style: context.texts.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      label: 'Annual projection',
                      value: formatter.format(
                        data.projectedAnnualIncomePaise,
                        compact: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _HeroMetric(
                      label: 'Next 12 months',
                      value: formatter.format(
                        data.next12MonthsInterestPaise,
                        compact: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _HeroMetric(
                      label: 'Avg. to maturity',
                      value: '${data.averageMonthsToMaturity.round()} months',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ResponsiveGrid(
          minItemWidth: 155,
          maxColumns: 4,
          children: [
            MetricCard(
              label: 'Principal invested',
              value: formatter.format(data.totalInvestedPaise),
              icon: Icons.account_balance_outlined,
              caption: '${data.activeBondCount} active bonds',
              accent: AppColors.teal,
            ),
            MetricCard(
              label: 'Interest this year',
              value: formatter.format(data.interestThisYearPaise),
              icon: Icons.calendar_today_rounded,
              caption: '${DateTime.now().year} actual credits',
              accent: AppColors.emerald,
            ),
            MetricCard(
              label: 'Lifetime interest',
              value: formatter.format(data.lifetimeInterestPaise),
              icon: Icons.savings_outlined,
              caption: '${data.paymentCount} interest credits',
              accent: const Color(0xFF2E5AAC),
            ),
            MetricCard(
              label: 'Payment on-time rate',
              value: '${(data.paidOnTimeRate * 100).round()}%',
              icon: Icons.verified_outlined,
              caption: 'Based on recorded schedule history',
              accent: AppColors.gold,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final income = _IncomeAnalysisCard(
              data: data,
              formatter: formatter,
            );
            final issuers = _IssuerAnalysisCard(
              data: data,
              formatter: formatter,
            );
            if (constraints.maxWidth >= 880) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: income),
                  const SizedBox(width: 14),
                  Expanded(flex: 2, child: issuers),
                ],
              );
            }
            return Column(
              children: [income, const SizedBox(height: 14), issuers],
            );
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final frequency = _FrequencyCard(data: data);
            final holdings = _HoldingsCard(data: data, formatter: formatter);
            if (constraints.maxWidth >= 880) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: frequency),
                  const SizedBox(width: 14),
                  Expanded(flex: 2, child: holdings),
                ],
              );
            }
            return Column(
              children: [frequency, const SizedBox(height: 14), holdings],
            );
          },
        ),
        const SizedBox(height: 14),
        PremiumCard(
          padding: const EdgeInsets.all(16),
          shadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: context.mutedColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Projections use each bond’s stated coupon and do not account for taxes, reinvestment, default risk, or fees. The on-time rate only includes schedules with a recorded payment date or that are currently overdue.',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.texts.labelSmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 9,
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

class _IncomeAnalysisCard extends StatelessWidget {
  const _IncomeAnalysisCard({required this.data, required this.formatter});

  final AnalyticsData data;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Annual income outlook',
            subtitle: 'Received vs scheduled coupons',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 14),
          AnnualIncomeChart(
            points: data.annualSeries,
            formatter: formatter,
            height: 220,
          ),
        ],
      ),
    );
  }
}

class _IssuerAnalysisCard extends StatelessWidget {
  const _IssuerAnalysisCard({required this.data, required this.formatter});

  final AnalyticsData data;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Issuer concentration',
            subtitle: 'Principal by issuer',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          if (data.issuerSlices.isEmpty)
            const SizedBox(height: 140)
          else
            for (var i = 0; i < data.issuerSlices.length; i++)
              DistributionBar(
                label: data.issuerSlices[i].label,
                valuePaise: data.issuerSlices[i].valuePaise,
                totalPaise: data.totalInvestedPaise,
                formatter: formatter,
                color: AppColors.chart[i % AppColors.chart.length],
              ),
        ],
      ),
    );
  }
}

class _FrequencyCard extends StatelessWidget {
  const _FrequencyCard({required this.data});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final total = data.frequencySlices.fold(
      0,
      (sum, slice) => sum + slice.valuePaise,
    );
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Payout frequency',
            subtitle: 'Principal by coupon frequency',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < data.frequencySlices.length; i++)
            DistributionBar(
              label: data.frequencySlices[i].label,
              valuePaise: data.frequencySlices[i].valuePaise,
              totalPaise: total,
              formatter: const MoneyFormatter('INR'),
              color: AppColors.chart[i % AppColors.chart.length],
            ),
          if (data.frequencySlices.isEmpty)
            Text(
              'No payout frequency data',
              style: context.texts.bodySmall?.copyWith(
                color: context.mutedColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _HoldingsCard extends StatelessWidget {
  const _HoldingsCard({required this.data, required this.formatter});

  final AnalyticsData data;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Largest holdings',
            subtitle: 'Top bonds by principal amount',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < data.topHoldings.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 27,
                    height: 27,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.chart[i % AppColors.chart.length]
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: context.texts.labelSmall?.copyWith(
                        color: AppColors.chart[i % AppColors.chart.length],
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.topHoldings[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.labelMedium,
                        ),
                        Text(
                          '${data.topHoldings[i].issuer} · ${Money.rate(data.topHoldings[i].annualRate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.bodySmall?.copyWith(
                            color: context.mutedColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatter.format(
                      data.topHoldings[i].principalPaise,
                      compact: true,
                    ),
                    style: context.texts.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          if (data.topHoldings.isEmpty)
            Text(
              'No holdings yet',
              style: context.texts.bodySmall?.copyWith(
                color: context.mutedColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _RangeAmount extends StatelessWidget {
  const _RangeAmount({required this.label, required this.amount});

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
        Text(
          amount,
          style: context.texts.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
