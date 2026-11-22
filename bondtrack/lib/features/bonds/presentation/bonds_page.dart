import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/providers/ui_state_providers.dart';
import 'package:bondtrack/core/theme/app_colors.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/core/widgets/app_page.dart';
import 'package:bondtrack/core/widgets/common.dart';
import 'package:bondtrack/core/widgets/empty_state.dart';
import 'package:bondtrack/core/widgets/loading_view.dart';
import 'package:bondtrack/core/widgets/pills.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';

class BondsPage extends ConsumerStatefulWidget {
  const BondsPage({super.key});

  @override
  ConsumerState<BondsPage> createState() => _BondsPageState();
}

class _BondsPageState extends ConsumerState<BondsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _archive(Bond bond) async {
    final confirmed = await showConfirmDialog(
      context,
      title: bond.isArchived ? 'Restore bond?' : 'Archive bond?',
      message: bond.isArchived
          ? 'This bond will return to your active portfolio and reminders.'
          : 'The bond and its history stay safe, but it will be removed from active totals and reminders.',
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

  Future<void> _delete(Bond bond) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${bond.name}?',
      message: 'This permanently removes the bond, its interest schedule and all recorded payments. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    await ref.read(bondRepositoryProvider).delete(bond.id);
    if (mounted) showAppSnackBar(context, 'Bond deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final bondsAsync = ref.watch(bondsProvider);
    final schedules = ref.watch(schedulesProvider).valueOrNull ?? const [];
    final state = ref.watch(bondListProvider);
    final formatter = ref.watch(moneyFormatterProvider);
    final bonds = bondsAsync.valueOrNull ?? const <Bond>[];
    final filtered = applyBondListState(bonds, state);

    final active = bonds.where((bond) => bond.isActive).toList();
    final activePrincipal = active.fold(
      0,
      (sum, bond) => sum + bond.principalPaise,
    );
    final nextSchedule = _nextScheduleByBond(schedules);

    return AppPage(
      title: 'My bonds',
      subtitle: 'Every investment, schedule and status in one place',
      actions: [
        IconButton(
          tooltip: 'Import from Excel',
          onPressed: () => context.push('/import'),
          icon: const Icon(Icons.upload_file_rounded),
        ),
      ],
      fab: FloatingActionButton.extended(
        onPressed: () => context.push('/bonds/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add bond'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumCard(
            gradient: AppColors.navyGradient,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryStat(
                    label: 'Active principal',
                    value: formatter.format(activePrincipal),
                    light: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryStat(
                    label: 'Active bonds',
                    value: '${active.length}',
                    light: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryStat(
                    label: 'Archived',
                    value: '${bonds.where((b) => b.isArchived).length}',
                    light: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SearchField(
            controller: _searchController,
            hintText: 'Search bond name, issuer or notes',
            onChanged: ref.read(bondListProvider.notifier).setQuery,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final filter in BondStatusFilter.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 7),
                          child: ChoiceChip(
                            label: Text(filter.label),
                            selected: state.status == filter,
                            onSelected: (_) => ref
                                .read(bondListProvider.notifier)
                                .setStatus(filter),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _SortButton(
                sort: state.sort,
                descending: state.descending,
                onSelected: (sort) =>
                    ref.read(bondListProvider.notifier).setSort(sort),
                onToggleDirection: () =>
                    ref.read(bondListProvider.notifier).toggleDirection(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bondsAsync.hasError)
            ErrorView(
              error: bondsAsync.error!,
              onRetry: () => ref.invalidate(bondsProvider),
            )
          else if (bondsAsync.isLoading && bonds.isEmpty)
            const LoadingView()
          else if (bonds.isEmpty)
            EmptyState(
              icon: Icons.account_balance_rounded,
              title: 'No bonds yet',
              message: 'Add a bond manually or import your existing Excel sheet. Interest schedules and maturity dates are generated automatically.',
              primaryLabel: 'Add bond',
              onPrimary: () => context.push('/bonds/new'),
              secondaryLabel: 'Import from Excel',
              onSecondary: () => context.push('/import'),
            )
          else if (filtered.isEmpty)
            EmptyState(
              compact: true,
              icon: Icons.search_off_rounded,
              title: 'No matching bonds',
              message: 'Try a different search term or clear the status filter to see your full portfolio.',
              secondaryLabel: 'Clear filters',
              onSecondary: () {
                _searchController.clear();
                ref.read(bondListProvider.notifier).reset();
              },
            )
          else ...[
            Row(
              children: [
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'bond' : 'bonds'}',
                  style: context.texts.labelMedium?.copyWith(
                    color: context.mutedColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${state.sort.label} ${state.descending ? '↓' : '↑'}',
                  style: context.texts.labelSmall?.copyWith(
                    color: context.mutedColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final bond in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BondListCard(
                  bond: bond,
                  nextSchedule: nextSchedule[bond.id],
                  formatter: formatter,
                  onTap: () => context.push('/bonds/${bond.id}'),
                  onEdit: () => context.push('/bonds/${bond.id}/edit'),
                  onArchive: () => _archive(bond),
                  onDelete: () => _delete(bond),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Map<int, InterestSchedule> _nextScheduleByBond(
    List<InterestSchedule> schedules,
  ) {
    final today = DateTime.now();
    final result = <int, InterestSchedule>{};
    for (final schedule in schedules) {
      if (schedule.status != ScheduleStatus.pending) continue;
      if (schedule.dueDate.isBefore(
        DateTime(today.year, today.month, today.day),
      )) {
        continue;
      }
      final current = result[schedule.bondId];
      if (current == null || schedule.dueDate.isBefore(current.dueDate)) {
        result[schedule.bondId] = schedule;
      }
    }
    return result;
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    this.light = false,
  });

  final String label;
  final String value;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.texts.labelSmall?.copyWith(
            color: light
                ? Colors.white.withValues(alpha: 0.58)
                : context.mutedColor,
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
              color: light ? Colors.white : null,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.sort,
    required this.descending,
    required this.onSelected,
    required this.onToggleDirection,
  });

  final BondSort sort;
  final bool descending;
  final ValueChanged<BondSort> onSelected;
  final VoidCallback onToggleDirection;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<BondSort>(
      tooltip: 'Sort bonds',
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final option in BondSort.values)
          PopupMenuItem(
            value: option,
            child: Row(
              children: [
                Icon(
                  option == sort
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: option == sort
                      ? context.scheme.primary
                      : context.mutedColor,
                ),
                const SizedBox(width: 10),
                Text(option.label),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: sort,
          onTap: onToggleDirection,
          child: Row(
            children: [
              Icon(
                descending
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(descending ? 'Descending' : 'Ascending'),
            ],
          ),
        ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 18),
            const SizedBox(width: 5),
            Text(
              descending ? '↓' : '↑',
              style: context.texts.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BondListCard extends StatelessWidget {
  const BondListCard({
    super.key,
    required this.bond,
    required this.formatter,
    required this.onTap,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    this.nextSchedule,
  });

  final Bond bond;
  final InterestSchedule? nextSchedule;
  final MoneyFormatter formatter;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  String get _initials {
    final words = bond.issuer.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return 'B';
    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length.clamp(0, 2))
          .toUpperCase();
    }
    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final archived = bond.isArchived;
    return Opacity(
      opacity: archived ? 0.72 : 1,
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: archived
                        ? const LinearGradient(
                            colors: [Color(0xFF9AA9B8), Color(0xFF6B7C93)],
                          )
                        : AppColors.tealGradient,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials,
                    style: context.texts.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                              style: context.texts.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          BondStatusPill(status: bond.status, dense: true),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bond.issuer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodySmall?.copyWith(
                          color: context.mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                PopupMenuButton<String>(
                  tooltip: 'Bond actions',
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: context.mutedColor,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                      case 'archive':
                        onArchive();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Edit bond'),
                        ],
                      ),
                    ),
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
                          Text(bond.isArchived ? 'Restore' : 'Archive'),
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
                            'Delete',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _CardStat(
                    label: 'Principal',
                    value: formatter.format(bond.principalPaise),
                  ),
                ),
                Expanded(
                  child: _CardStat(
                    label: 'Coupon',
                    value: Money.rate(bond.annualRate),
                    accent: AppColors.emerald,
                  ),
                ),
                Expanded(
                  child: _CardStat(
                    label: 'Per credit',
                    value: formatter.format(bond.interestPerPeriodPaise),
                    accent: AppColors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.scheme.surfaceContainerHighest.withValues(
                  alpha: context.isDark ? 0.55 : 0.6,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    nextSchedule != null
                        ? Icons.event_available_rounded
                        : Icons.event_note_rounded,
                    size: 15,
                    color: context.mutedColor,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      nextSchedule != null
                          ? 'Next interest ${Money.date(nextSchedule!.dueDate)} · ${formatter.format(nextSchedule!.expectedInterestPaise)}'
                          : bond.isArchived
                          ? 'Archived · no reminders scheduled'
                          : 'No pending interest credits',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.mutedColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Matures ${Money.dateShort(bond.maturityDate)}',
                    style: context.texts.labelSmall?.copyWith(
                      color: context.mutedColor,
                      fontSize: 9.5,
                    ),
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

class _CardStat extends StatelessWidget {
  const _CardStat({required this.label, required this.value, this.accent});

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
