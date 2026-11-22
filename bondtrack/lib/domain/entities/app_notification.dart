enum AppNotificationType {
  interestDue,
  maturityDue,
  system;

  String get label => switch (this) {
    AppNotificationType.interestDue => 'Interest due',
    AppNotificationType.maturityDue => 'Maturity',
    AppNotificationType.system => 'Reminder',
  };
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.createdAt,
    required this.dedupeKey,
    this.bondId,
    this.readAt,
  });

  final int id;
  final int? bondId;
  final AppNotificationType type;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final DateTime? readAt;
  final String dedupeKey;
  final DateTime createdAt;

  bool get isRead => readAt != null;
}
