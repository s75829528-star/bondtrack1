enum AppThemeMode {
  system,
  light,
  dark;

  String get label => switch (this) {
    AppThemeMode.system => 'System',
    AppThemeMode.light => 'Light',
    AppThemeMode.dark => 'Dark',
  };

  static AppThemeMode fromText(String? value) {
    return switch ((value ?? '').toLowerCase()) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
  }
}

class AppSettings {
  const AppSettings({
    required this.currencyCode,
    required this.themeMode,
    required this.remindersEnabled,
    required this.interestReminders,
    required this.maturityReminders,
    required this.systemNotifications,
    required this.reminderDays,
    required this.defaultFrequency,
    required this.onboardingComplete,
    this.lastBackupAt,
    this.interestReminderOffsets = '7,3,1,0',
    this.maturityReminderOffsets = '30,15,7,1,0',
    this.overdueRemindersEnabled = true,
    this.quietHoursEnabled = false,
    this.quietStartHour = 22,
    this.quietEndHour = 7,
    this.appLockEnabled = false,
  });

  static const defaults = AppSettings(
    currencyCode: 'INR',
    themeMode: AppThemeMode.system,
    remindersEnabled: true,
    interestReminders: true,
    maturityReminders: true,
    systemNotifications: true,
    reminderDays: 7,
    defaultFrequency: 'monthly',
    onboardingComplete: false,
  );

  final String currencyCode;
  final AppThemeMode themeMode;
  final bool remindersEnabled;
  final bool interestReminders;
  final bool maturityReminders;
  final bool systemNotifications;
  final int reminderDays;
  final String defaultFrequency;
  final bool onboardingComplete;
  final DateTime? lastBackupAt;

  /// Global reminder offsets used when a bond has no per-bond override.
  final String interestReminderOffsets;
  final String maturityReminderOffsets;
  final bool overdueRemindersEnabled;

  /// Quiet hours suppress notification delivery. Reminders that would fire in
  /// this window are moved to the end of the window.
  final bool quietHoursEnabled;
  final int quietStartHour;
  final int quietEndHour;

  final bool appLockEnabled;

  String get currencySymbol => switch (currencyCode) {
    'INR' => '₹',
    'USD' => '\$',
    'EUR' => '€',
    'GBP' => '£',
    'AED' => 'د.إ',
    _ => currencyCode,
  };

  List<int> get interestReminderDays =>
      parseOffsets(interestReminderOffsets, const [7, 3, 1, 0]);

  List<int> get maturityReminderDays =>
      parseOffsets(maturityReminderOffsets, const [30, 15, 7, 1, 0]);

  static List<int> parseOffsets(String value, List<int> fallback) {
    final result = <int>{};
    for (final part in value.split(',')) {
      final parsed = int.tryParse(part.trim());
      if (parsed != null && parsed >= 0 && parsed <= 365) result.add(parsed);
    }
    if (result.isEmpty) return fallback;
    return result.toList()..sort((a, b) => b.compareTo(a));
  }

  AppSettings copyWith({
    String? currencyCode,
    AppThemeMode? themeMode,
    bool? remindersEnabled,
    bool? interestReminders,
    bool? maturityReminders,
    bool? systemNotifications,
    int? reminderDays,
    String? defaultFrequency,
    bool? onboardingComplete,
    DateTime? lastBackupAt,
    String? interestReminderOffsets,
    String? maturityReminderOffsets,
    bool? overdueRemindersEnabled,
    bool? quietHoursEnabled,
    int? quietStartHour,
    int? quietEndHour,
    bool? appLockEnabled,
  }) {
    return AppSettings(
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      interestReminders: interestReminders ?? this.interestReminders,
      maturityReminders: maturityReminders ?? this.maturityReminders,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      reminderDays: reminderDays ?? this.reminderDays,
      defaultFrequency: defaultFrequency ?? this.defaultFrequency,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      interestReminderOffsets:
          interestReminderOffsets ?? this.interestReminderOffsets,
      maturityReminderOffsets:
          maturityReminderOffsets ?? this.maturityReminderOffsets,
      overdueRemindersEnabled:
          overdueRemindersEnabled ?? this.overdueRemindersEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    );
  }
}
