import 'package:drift/drift.dart';
import 'package:bondtrack/data/database/app_database.dart';
import 'package:bondtrack/data/mappers.dart';
import 'package:bondtrack/domain/entities/app_notification.dart';
import 'package:bondtrack/domain/repositories/notification_repository.dart';

class DriftNotificationRepository implements NotificationRepository {
  DriftNotificationRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<AppNotification>> watchAll() {
    final query = _db.select(_db.notifications)
      ..orderBy([
        (t) => OrderingTerm(expression: t.scheduledAt, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Stream<int> watchUnreadCount() {
    return _db
        .select(_db.notifications)
        .watch()
        .map((rows) => rows.where((row) => row.readAt == null).length);
  }

  @override
  Future<List<AppNotification>> getAll() async {
    final rows = await _db.select(_db.notifications).get();
    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<void> addIfAbsent(AppNotification notification) async {
    await _db
        .into(_db.notifications)
        .insert(
          NotificationsCompanion.insert(
            bondId: Value(notification.bondId),
            type: notification.type,
            title: notification.title,
            body: notification.body,
            scheduledAt: notification.scheduledAt,
            dedupeKey: notification.dedupeKey,
            createdAt: notification.createdAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> markRead(int id) async {
    await (_db.update(_db.notifications)..where((t) => t.id.equals(id))).write(
      NotificationsCompanion(readAt: Value(DateTime.now())),
    );
  }

  @override
  Future<void> markAllRead() async {
    await (_db.update(_db.notifications)..where((t) => t.readAt.isNull()))
        .write(NotificationsCompanion(readAt: Value(DateTime.now())));
  }

  @override
  Future<void> deleteForBond(int bondId) async {
    await (_db.delete(
      _db.notifications,
    )..where((t) => t.bondId.equals(bondId))).go();
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_db.notifications).go();
  }
}
