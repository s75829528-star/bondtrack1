import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bondtrack/core/utils/date_utils.dart' as dates;
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/models/portfolio_models.dart';

enum BondStatusFilter {
  all,
  active,
  matured,
  archived;

  String get label => switch (this) {
    BondStatusFilter.all => 'All',
    BondStatusFilter.active => 'Active',
    BondStatusFilter.matured => 'Matured',
    BondStatusFilter.archived => 'Archived',
  };
}

enum BondSort {
  maturity,
  principal,
  rate,
  name;

  String get label => switch (this) {
    BondSort.maturity => 'Maturity date',
    BondSort.principal => 'Investment amount',
    BondSort.rate => 'Interest rate',
    BondSort.name => 'Bond name',
  };
}

class BondListState {
  const BondListState({
    this.query = '',
    this.status = BondStatusFilter.all,
    this.sort = BondSort.maturity,
    this.descending = false,
  });

  final String query;
  final BondStatusFilter status;
  final BondSort sort;
  final bool descending;

  BondListState copyWith({
    String? query,
    BondStatusFilter? status,
    BondSort? sort,
    bool? descending,
  }) {
    return BondListState(
      query: query ?? this.query,
      status: status ?? this.status,
      sort: sort ?? this.sort,
      descending: descending ?? this.descending,
    );
  }
}

class BondListNotifier extends Notifier<BondListState> {
  @override
  BondListState build() => const BondListState();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setStatus(BondStatusFilter status) =>
      state = state.copyWith(status: status);

  void setSort(BondSort sort, {bool? descending}) {
    state = state.copyWith(
      sort: sort,
      descending: descending ?? state.descending,
    );
  }

  void toggleDirection() {
    state = state.copyWith(descending: !state.descending);
  }

  void reset() => state = const BondListState();
}

final bondListProvider = NotifierProvider<BondListNotifier, BondListState>(
  BondListNotifier.new,
);

List<Bond> applyBondListState(List<Bond> bonds, BondListState state) {
  final query = state.query.trim().toLowerCase();
  var result = bonds.where((bond) {
    if (state.status == BondStatusFilter.active &&
        bond.status != BondStatus.active) {
      return false;
    }
    if (state.status == BondStatusFilter.matured &&
        bond.status != BondStatus.matured) {
      return false;
    }
    if (state.status == BondStatusFilter.archived &&
        bond.status != BondStatus.archived) {
      return false;
    }
    if (query.isEmpty) return true;
    return bond.name.toLowerCase().contains(query) ||
        bond.issuer.toLowerCase().contains(query) ||
        (bond.notes ?? '').toLowerCase().contains(query);
  }).toList();

  int compare(Bond a, Bond b) {
    final value = switch (state.sort) {
      BondSort.maturity => a.maturityDate.compareTo(b.maturityDate),
      BondSort.principal => a.principalPaise.compareTo(b.principalPaise),
      BondSort.rate => a.annualRate.compareTo(b.annualRate),
      BondSort.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    };
    return state.descending ? -value : value;
  }

  result.sort(compare);
  return result;
}

class CalendarMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => dates.startOfMonth(DateTime.now());

  void previous() => state = DateTime(state.year, state.month - 1);

  void next() => state = DateTime(state.year, state.month + 1);

  void goTo(DateTime value) => state = DateTime(value.year, value.month);
}

final calendarMonthProvider = NotifierProvider<CalendarMonthNotifier, DateTime>(
  CalendarMonthNotifier.new,
);

final selectedCalendarDayProvider = StateProvider<DateTime>(
  (ref) => dates.today(),
);

enum PaymentFilter {
  all,
  interest,
  maturity;

  String get label => switch (this) {
    PaymentFilter.all => 'All',
    PaymentFilter.interest => 'Interest',
    PaymentFilter.maturity => 'Maturity',
  };
}

class PaymentFilterState {
  const PaymentFilterState({this.query = '', this.filter = PaymentFilter.all});

  final String query;
  final PaymentFilter filter;

  PaymentFilterState copyWith({String? query, PaymentFilter? filter}) =>
      PaymentFilterState(
        query: query ?? this.query,
        filter: filter ?? this.filter,
      );
}

class PaymentFilterNotifier extends Notifier<PaymentFilterState> {
  @override
  PaymentFilterState build() => const PaymentFilterState();

  void setQuery(String value) => state = state.copyWith(query: value);

  void setFilter(PaymentFilter filter) =>
      state = state.copyWith(filter: filter);
}

final paymentFilterProvider =
    NotifierProvider<PaymentFilterNotifier, PaymentFilterState>(
      PaymentFilterNotifier.new,
    );

class AnalyticsFilterState {
  const AnalyticsFilterState({
    this.period = AnalyticsPeriod.all,
    this.customStart,
    this.customEnd,
  });

  final AnalyticsPeriod period;
  final DateTime? customStart;
  final DateTime? customEnd;

  AnalyticsFilterState copyWith({
    AnalyticsPeriod? period,
    DateTime? customStart,
    DateTime? customEnd,
  }) => AnalyticsFilterState(
    period: period ?? this.period,
    customStart: customStart ?? this.customStart,
    customEnd: customEnd ?? this.customEnd,
  );
}

class AnalyticsFilterNotifier extends Notifier<AnalyticsFilterState> {
  @override
  AnalyticsFilterState build() => const AnalyticsFilterState();

  void setPeriod(AnalyticsPeriod period) {
    state = AnalyticsFilterState(
      period: period,
      customStart: state.customStart,
      customEnd: state.customEnd,
    );
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = AnalyticsFilterState(
      period: AnalyticsPeriod.custom,
      customStart: dates.dateOnly(start),
      customEnd: dates.dateOnly(end),
    );
  }
}

final analyticsFilterProvider =
    NotifierProvider<AnalyticsFilterNotifier, AnalyticsFilterState>(
      AnalyticsFilterNotifier.new,
    );
