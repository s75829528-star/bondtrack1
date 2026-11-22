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
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/domain/entities/app_notification.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications =
        ref.watch(notificationsProvider).valueOrNull ?? const [];
    final unread = notifications
        .where((notification) => !notification.isRead)
        .length;
    final bondById = {
      for (final bond in ref.watch(bondsProvider).valueOrNull ?? const [])
        bond.id: bond,
    };

    return AppPage(
      showBack: true,
      title: 'Notifications',
      subtitle: unread == 0
          ? 'You are all caught up'
          : '$unread unread reminder${unread == 1 ? '' : 's'}',
      actions: [
        if (unread > 0)
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              if (context.mounted) {
                showAppSnackBar(context, 'All reminders marked as read.');
              }
            },
            child: const Text('Mark all read'),
          ),
        if (notifications.isNotEmpty)
          PopupMenuButton<String>(
            tooltip: 'Notification actions',
            onSelected: (value) async {
              if (value == 'clear') {
                final confirmed = await showConfirmDialog(
                  context,
                  title: 'Clear all notifications?',
                  message: 'This removes the in-app reminder history.',
                  confirmLabel: 'Clear all',
                  destructive: true,
                  icon: Icons.delete_outline_rounded,
                );
                if (confirmed) {
                  await ref.read(notificationRepositoryProvider).clearAll();
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
      ],
      child: notifications.isEmpty
          ? EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No reminders yet',
              message: 'BondTrack will list upcoming interest and maturity reminders here. Enable reminders in Settings to schedule Android notifications.',
              primaryLabel: 'Open settings',
              onPrimary: () => context.go('/settings'),
              compact: true,
            )
          : Column(
              children: [
                for (final notification in notifications)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _NotificationCard(
                      notification: notification,
                      bondName: bondById[notification.bondId]?.name,
                      onTap: () async {
                        await ref
                            .read(notificationRepositoryProvider)
                            .markRead(notification.id);
                        final bondId = notification.bondId;
                        if (bondId != null && context.mounted) {
                          context.push('/bonds/$bondId');
                        }
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    this.bondName,
  });

  final AppNotification notification;
  final String? bondName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final maturity = notification.type == AppNotificationType.maturityDue;
    final color = maturity ? const Color(0xFF2E5AAC) : AppColors.teal;
    final isFuture = notification.scheduledAt.isAfter(DateTime.now());
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      shadow: false,
      color: notification.isRead
          ? context.cardColor
          : context.scheme.primaryContainer.withValues(
              alpha: context.isDark ? 0.32 : 0.28,
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: context.isDark ? 0.23 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              maturity ? Icons.flag_outlined : Icons.payments_outlined,
              size: 20,
              color: color,
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
                        notification.title,
                        style: context.texts.titleSmall,
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: context.scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isFuture
                      ? 'Reminder on ${Money.date(notification.scheduledAt)}'
                      : 'Reminder ${Money.date(notification.scheduledAt)}',
                  style: context.texts.labelSmall?.copyWith(
                    color: color,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Icon(
            Icons.chevron_right_rounded,
            color: context.mutedColor,
            size: 19,
          ),
        ],
      ),
    );
  }
}
