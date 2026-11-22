import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bondtrack/core/providers/ui_state_providers.dart';
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/data/database/app_database.dart';
import 'package:bondtrack/data/repositories/drift_bond_repository.dart';
import 'package:bondtrack/data/repositories/drift_notification_repository.dart';
import 'package:bondtrack/data/repositories/drift_payment_repository.dart';
import 'package:bondtrack/data/repositories/drift_schedule_repository.dart';
import 'package:bondtrack/data/repositories/drift_settings_repository.dart';
import 'package:bondtrack/domain/entities/app_notification.dart';
import 'package:bondtrack/domain/entities/app_settings.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/entities/payment_transaction.dart';
import 'package:bondtrack/domain/models/portfolio_models.dart';
import 'package:bondtrack/domain/repositories/bond_repository.dart';
import 'package:bondtrack/domain/repositories/notification_repository.dart';
import 'package:bondtrack/domain/repositories/payment_repository.dart';
import 'package:bondtrack/domain/repositories/schedule_repository.dart';
import 'package:bondtrack/domain/repositories/settings_repository.dart';
import 'package:bondtrack/domain/services/portfolio_calculator.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final bondRepositoryProvider = Provider<BondRepository>((ref) {
  return DriftBondRepository(ref.watch(databaseProvider));
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return DriftScheduleRepository(ref.watch(databaseProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return DriftPaymentRepository(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return DriftSettingsRepository(ref.watch(databaseProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return DriftNotificationRepository(ref.watch(databaseProvider));
});

final bondsProvider = StreamProvider<List<Bond>>((ref) {
  return ref.watch(bondRepositoryProvider).watchAll();
});

final schedulesProvider = StreamProvider<List<InterestSchedule>>((ref) {
  return ref.watch(scheduleRepositoryProvider).watchAll();
});

final paymentsProvider = StreamProvider<List<PaymentTransaction>>((ref) {
  return ref.watch(paymentRepositoryProvider).watchAll();
});

final settingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchAll();
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  return ref.watch(notificationRepositoryProvider).watchUnreadCount();
});

final bondByIdProvider = StreamProvider.family<Bond?, int>((ref, id) {
  return ref.watch(bondRepositoryProvider).watchById(id);
});

final schedulesForBondProvider =
    StreamProvider.family<List<InterestSchedule>, int>((ref, bondId) {
      return ref.watch(scheduleRepositoryProvider).watchForBond(bondId);
    });

final paymentsForBondProvider =
    StreamProvider.family<List<PaymentTransaction>, int>((ref, bondId) {
      return ref.watch(paymentRepositoryProvider).watchForBond(bondId);
    });

final activeBondsProvider = Provider<AsyncValue<List<Bond>>>((ref) {
  return ref
      .watch(bondsProvider)
      .whenData(
        (bonds) =>
            bonds.where((bond) => bond.status == BondStatus.active).toList(),
      );
});

final dashboardProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final bonds = ref.watch(bondsProvider);
  final schedules = ref.watch(schedulesProvider);
  final payments = ref.watch(paymentsProvider);
  for (final value in [bonds, schedules, payments]) {
    if (value.hasError) {
      return AsyncError(value.error!, value.stackTrace ?? StackTrace.current);
    }
  }
  if (bonds.isLoading || schedules.isLoading || payments.isLoading) {
    return const AsyncLoading();
  }
  return AsyncData(
    PortfolioCalculator.dashboard(
      bonds: bonds.requireValue,
      schedules: schedules.requireValue,
      payments: payments.requireValue,
    ),
  );
});

final analyticsProvider = Provider<AsyncValue<AnalyticsData>>((ref) {
  final bonds = ref.watch(bondsProvider);
  final schedules = ref.watch(schedulesProvider);
  final payments = ref.watch(paymentsProvider);
  final filter = ref.watch(analyticsFilterProvider);
  for (final value in [bonds, schedules, payments]) {
    if (value.hasError) {
      return AsyncError(value.error!, value.stackTrace ?? StackTrace.current);
    }
  }
  if (bonds.isLoading || schedules.isLoading || payments.isLoading) {
    return const AsyncLoading();
  }
  return AsyncData(
    PortfolioCalculator.analytics(
      bonds: bonds.requireValue,
      schedules: schedules.requireValue,
      payments: payments.requireValue,
      period: filter.period,
      customStart: filter.customStart,
      customEnd: filter.customEnd,
    ),
  );
});

final maturityBucketsProvider = Provider<AsyncValue<List<MaturityBucket>>>((
  ref,
) {
  return ref
      .watch(bondsProvider)
      .whenData((bonds) => PortfolioCalculator.maturityBuckets(bonds: bonds));
});

final settingsValueProvider = Provider<AppSettings>((ref) {
  return ref.watch(settingsProvider).valueOrNull ?? AppSettings.defaults;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return switch (ref.watch(settingsValueProvider).themeMode) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };
});

class MoneyFormatter {
  const MoneyFormatter(this.currencyCode);

  final String currencyCode;

  String format(int paise, {bool compact = false, bool decimals = false}) =>
      Money.formatPaise(
        paise,
        currencyCode: currencyCode,
        compact: compact,
        showDecimals: decimals,
      );

  String formatRupees(double rupees, {bool compact = false}) =>
      Money.formatRupees(rupees, currencyCode: currencyCode, compact: compact);
}

final moneyFormatterProvider = Provider<MoneyFormatter>((ref) {
  return MoneyFormatter(ref.watch(settingsValueProvider).currencyCode);
});
