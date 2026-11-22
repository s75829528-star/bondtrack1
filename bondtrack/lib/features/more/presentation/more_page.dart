import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/theme/app_colors.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/widgets/app_page.dart';
import 'package:bondtrack/core/widgets/brand_mark.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;
    final bonds = ref.watch(bondsProvider).valueOrNull ?? const [];
    final active = bonds.where((bond) => bond.isActive).length;

    return AppPage(
      title: 'More',
      subtitle: 'Everything else in your bond workspace',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumCard(
            gradient: AppColors.heroGradient,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                const BrandMark(size: 46, showWordmark: false, onDark: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your private bond office',
                        style: context.texts.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$active active ${active == 1 ? 'bond' : 'bonds'} · stored only on this device',
                        style: context.texts.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 2 : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;
              final tiles = <Widget>[
                _MoreTile(
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.emerald,
                  title: 'Payment history',
                  subtitle: 'Interest credits and maturities',
                  onTap: () => context.go('/payments'),
                ),
                _MoreTile(
                  icon: Icons.flag_rounded,
                  color: const Color(0xFF2E5AAC),
                  title: 'Maturity tracker',
                  subtitle: 'Upcoming principal repayments',
                  onTap: () => context.go('/maturity'),
                ),
                _MoreTile(
                  icon: Icons.table_chart_rounded,
                  color: const Color(0xFF0F8B8D),
                  title: 'Import & export',
                  subtitle: 'Excel import wizard, XLSX export',
                  onTap: () => context.push('/import'),
                ),
                _MoreTile(
                  icon: Icons.notifications_rounded,
                  color: AppColors.gold,
                  title: 'Notifications',
                  subtitle: unread > 0
                      ? '$unread unread reminder${unread == 1 ? '' : 's'}'
                      : 'You are all caught up',
                  badge: unread > 0 ? '$unread' : null,
                  onTap: () => context.push('/notifications'),
                ),
                _MoreTile(
                  icon: Icons.settings_rounded,
                  color: const Color(0xFF6C63C7),
                  title: 'Settings',
                  subtitle: 'Theme, currency, reminders and backups',
                  onTap: () => context.go('/settings'),
                ),
                _MoreTile(
                  icon: Icons.insights_rounded,
                  color: const Color(0xFFE07A5F),
                  title: 'Analytics',
                  subtitle: 'Yield, distribution and income trends',
                  onTap: () => context.go('/analytics'),
                ),
              ];
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final tile in tiles) SizedBox(width: width, child: tile),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          PremiumCard(
            shadow: false,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: context.scheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'BondTrack works fully offline. Your bonds, payments and notes are stored in a local SQLite database. No banking credentials are ever stored.',
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
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: context.isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.texts.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.scheme.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: context.texts.labelSmall?.copyWith(
                            color: context.scheme.onError,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: context.mutedColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}
