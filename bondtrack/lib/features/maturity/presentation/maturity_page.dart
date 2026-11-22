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
import 'package:bondtrack/core/widgets/pills.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/core/widgets/section_header.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/models/portfolio_models.dart';
import 'package:bondtrack/features/payments/presentation/widgets/record_payment_dialog.dart';

class MaturityPage extends ConsumerWidget {
  const MaturityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketsAsync = ref.watch(maturityBucketsProvider);
    final formatter = ref.watch(moneyFormatterProvider);

    return AppPage(
      title: 'Maturity tracker',
      subtitle: 'Principal repayments, sorted by time to maturity',
      child: AsyncValueView<List<MaturityBucket>>(
        value: bucketsAsync,
        loading: const LoadingView(cards: 3),
        errorBuilder: (error, stack) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(bondsProvider),
        ),
        builder: (buckets) {
          if (buckets.isEmpty) {
            return EmptyState(
              icon: Icons.flag_outlined,
              title: 'No maturities to track',
              message: 'Add a bond with a maturity date and it will appear here with a progress tracker.',
              primaryLabel: 'Add bond',
              onPrimary: () => context.push('/bonds/new'),
            );
          }
          final active =
              buckets
                  .expand((bucket) => bucket.bonds)
                  .where((bond) => !bond.isMatured && !bond.isArchived)
                  .toList()
                ..sort((a, b) => a.maturityDate.compareTo(b.maturityDate));
          final totalExpected = active.fold(
            0,
            (sum, bond) => sum + bond.expectedMaturityAmountPaise,
          );
          final next = active.isEmpty ? null : active.first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      'EXPECTED MATURITY VALUE',
                      style: context.texts.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.4,
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatter.format(totalExpected),
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
                          child: _HeroStat(
                            label: 'Upcoming maturities',
                            value: '${active.length}',
                          ),
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: 'Next maturity',
                            value: next == null
                                ? '—'
                                : Money.date(next.maturityDate),
                          ),
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: 'Next value',
                            value: next == null
                                ? '—'
                                : formatter.format(
                                    next.expectedMaturityAmountPaise,
                                    compact: true,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              for (final bucket in buckets) ...[
                _MaturityBucketSection(
                  bucket: bucket,
                  formatter: formatter,
                  onRecordPayout: (bond) async {
                    final success = await showRecordPaymentDialog(
                      context,
                      ref: ref,
                      bond: bond,
                      initialType: PaymentType.maturity,
                    );
                    if (success && context.mounted) {
                      showAppSnackBar(
                        context,
                        'Maturity payout recorded. Bond marked as matured.',
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
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

class _MaturityBucketSection extends StatelessWidget {
  const _MaturityBucketSection({
    required this.bucket,
    required this.formatter,
    required this.onRecordPayout,
  });

  final MaturityBucket bucket;
  final MoneyFormatter formatter;
  final ValueChanged<Bond> onRecordPayout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: bucket.label,
          subtitle:
              '${bucket.bonds.length} ${bucket.bonds.length == 1 ? 'bond' : 'bonds'} · ${formatter.format(bucket.expectedPaise)} expected',
        ),
        for (final bond in bucket.bonds)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MaturityCard(
              bond: bond,
              formatter: formatter,
              onRecordPayout: () => onRecordPayout(bond),
            ),
          ),
      ],
    );
  }
}

class _MaturityCard extends StatelessWidget {
  const _MaturityCard({
    required this.bond,
    required this.formatter,
    required this.onRecordPayout,
  });

  final Bond bond;
  final MoneyFormatter formatter;
  final VoidCallback onRecordPayout;

  @override
  Widget build(BuildContext context) {
    final matured = bond.isMatured || bond.isArchived;
    final days = bond.daysToMaturity;
    return PremiumCard(
      onTap: () => context.push('/bonds/${bond.id}'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (matured ? const Color(0xFF2E5AAC) : AppColors.teal)
                      .withValues(alpha: context.isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  matured ? Icons.flag_rounded : Icons.timelapse_rounded,
                  size: 19,
                  color: matured ? const Color(0xFF2E5AAC) : AppColors.teal,
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
                    Text(
                      bond.issuer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.mutedColor,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BondStatusPill(status: bond.status, dense: true),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MaturityStat(
                  label: 'Principal',
                  value: formatter.format(bond.principalPaise),
                ),
              ),
              Expanded(
                child: _MaturityStat(
                  label: 'Expected payout',
                  value: formatter.format(bond.expectedMaturityAmountPaise),
                  accent: AppColors.emerald,
                ),
              ),
              Expanded(
                child: _MaturityStat(
                  label: matured ? 'Matured on' : 'Days left',
                  value: matured ? Money.dateShort(bond.maturityDate) : '$days',
                  accent: matured ? null : const Color(0xFF2E5AAC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppProgressBar(
                  value: matured ? 1 : bond.progressToMaturity,
                  height: 6,
                  gradient: matured
                      ? const LinearGradient(
                          colors: [Color(0xFF2E5AAC), Color(0xFF5B8BD0)],
                        )
                      : AppColors.tealGradient,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                matured
                    ? '100%'
                    : '${(bond.progressToMaturity * 100).round()}%',
                style: context.texts.labelSmall?.copyWith(
                  color: context.mutedColor,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
          if (!matured) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event_outlined, size: 14, color: context.mutedColor),
                const SizedBox(width: 5),
                Text(
                  'Matures ${Money.date(bond.maturityDate)}',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                    fontSize: 10.5,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onRecordPayout,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 15),
                  label: const Text('Record payout'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MaturityStat extends StatelessWidget {
  const _MaturityStat({required this.label, required this.value, this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}
