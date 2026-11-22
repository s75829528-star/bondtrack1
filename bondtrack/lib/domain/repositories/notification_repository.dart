import 'package:bondtrack/domain/entities/app_notification.dart';

abstract interface class NotificationRepository {
  Stream<List<AppNotification>> watchAll();

  Stream<int> watchUnreadCount();

  Future<List<AppNotification>> getAll();

  Future<void> addIfAbsent(AppNotification notification);

  Future<void> markRead(int id);

  Future<void> markAllRead();

  Future<void> deleteForBond(int bondId);

  Future<void> clearAll();
}
