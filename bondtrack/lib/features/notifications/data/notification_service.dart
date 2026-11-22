import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:bondtrack/domain/entities/app_notification.dart';
import 'package:bondtrack/domain/entities/app_settings.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/repositories/notification_repository.dart';
import 'package:bondtrack/domain/services/notification_planner.dart';

/// Executes the pure [NotificationPlanner] plan on Android. Android scheduling
/// is persisted by flutter_local_notifications, so reminders survive process
/// death. The manifest boot receiver reschedules them after a reboot.
class NotificationService {
  NotificationService(this._repository);

  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialised = false;
  String? _launchPayload;

  /// Invoked when the user taps a notification or the app is opened from one.
  void Function(String payload)? onPayload;

  String? get launchPayload => _launchPayload;

  static const _channels = <AndroidNotificationChannel>[
    AndroidNotificationChannel(
      'bond_interest',
      'Interest reminders',
      description: 'Advance and due-date reminders for bond interest credits',
      importance: Importance.high,
    ),
    AndroidNotificationChannel(
      'bond_overdue',
      'Overdue payment alerts',
      description: 'Follow-ups for interest that has not been confirmed',
      importance: Importance.high,
    ),
    AndroidNotificationChannel(
      'bond_maturity',
      'Maturity reminders',
      description: 'Reminders for bond maturity and principal repayment',
      importance: Importance.high,
    ),
  ];

  Future<void> initialise() async {
    if (_initialised) return;
    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      // Keep UTC as a safe fallback when the platform timezone is unavailable.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) onPayload?.call(payload);
      },
    );
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    for (final channel in _channels) {
      await android?.createNotificationChannel(channel);
    }
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _launchPayload = launchDetails?.notificationResponse?.payload;
      if (_launchPayload != null && _launchPayload!.isNotEmpty) {
        onPayload?.call(_launchPayload!);
      }
    }
    _initialised = true;
  }

  Future<bool> requestPermission() async {
    await initialise();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final already = await android?.areNotificationsEnabled() ?? false;
    if (already) return true;
    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<bool> notificationsEnabled() async {
    await initialise();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.areNotificationsEnabled() ?? false;
  }

  /// Reconciles persisted reminders with the current database state. Any
  /// notification that is no longer valid is cancelled, which handles bond
  /// edits, payment confirmation and deletion.
  Future<void> refreshReminders({
    required List<Bond> bonds,
    required List<InterestSchedule> schedules,
    required AppSettings settings,
    required bool permissionGranted,
    DateTime? now,
  }) async {
    await initialise();
    final plan = NotificationPlanner.plan(
      bonds: bonds,
      schedules: schedules,
      settings: settings,
      now: now,
    );
    final nowValue = now ?? DateTime.now();
    final validNotificationIds = <int>{};

    for (final reminder in plan) {
      await _repository.addIfAbsent(
        AppNotification(
          id: 0,
          bondId: reminder.bondId,
          type: reminder.kind == ReminderKind.maturity ||
                  reminder.kind == ReminderKind.overdueMaturity
              ? AppNotificationType.maturityDue
              : AppNotificationType.interestDue,
          title: reminder.title,
          body: reminder.body,
          scheduledAt: reminder.scheduledAt,
          dedupeKey: reminder.dedupeKey,
          createdAt: nowValue,
        ),
      );

      if (!permissionGranted || !settings.systemNotifications) continue;
      if (!reminder.scheduledAt.isAfter(nowValue)) continue;
      validNotificationIds.add(reminder.notificationId);
      await _plugin.zonedSchedule(
        id: reminder.notificationId,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.scheduledAt, tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            reminder.channelId,
            _channelName(reminder.channelId),
            channelDescription: _channelDescription(reminder.channelId),
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            category: AndroidNotificationCategory.reminder,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.payload,
      );
    }

    final scheduled = await _plugin.pendingNotificationRequests();
    for (final notification in scheduled) {
      if (!validNotificationIds.contains(notification.id)) {
        await _plugin.cancel(id: notification.id);
      }
    }
  }

  /// Cancels every pending Android notification for a deleted bond.
  Future<void> cancelForBond(int bondId) async {
    await initialise();
    final scheduled = await _plugin.pendingNotificationRequests();
    final payload = 'bond:$bondId';
    for (final notification in scheduled) {
      if (notification.payload == payload) {
        await _plugin.cancel(id: notification.id);
      }
    }
    await _repository.deleteForBond(bondId);
  }

  Future<void> cancelAll() async {
    await initialise();
    await _plugin.cancelAll();
  }

  String _channelName(String id) => switch (id) {
    'bond_interest' => 'Interest reminders',
    'bond_overdue' => 'Overdue payment alerts',
    _ => 'Maturity reminders',
  };

  String _channelDescription(String id) => switch (id) {
    'bond_interest' => 'Advance and due-date reminders for interest credits',
    'bond_overdue' => 'Follow-ups for unconfirmed interest',
    _ => 'Bond maturity and principal repayment reminders',
  };
}
