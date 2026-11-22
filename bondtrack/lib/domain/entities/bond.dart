import 'package:bondtrack/core/utils/date_utils.dart' as dates;

/// How often a bond pays interest.
enum InterestFrequency {
  monthly,
  quarterly,
  halfYearly,
  annual;

  /// Number of months between interest credits.
  int get months => switch (this) {
    InterestFrequency.monthly => 1,
    InterestFrequency.quarterly => 3,
    InterestFrequency.halfYearly => 6,
    InterestFrequency.annual => 12,
  };

  int get paymentsPerYear => 12 ~/ months;

  String get label => switch (this) {
    InterestFrequency.monthly => 'Monthly',
    InterestFrequency.quarterly => 'Quarterly',
    InterestFrequency.halfYearly => 'Half-yearly',
    InterestFrequency.annual => 'Annual',
  };

  String get shortLabel => switch (this) {
    InterestFrequency.monthly => 'Monthly',
    InterestFrequency.quarterly => 'Quarterly',
    InterestFrequency.halfYearly => 'Half-yearly',
    InterestFrequency.annual => 'Annual',
  };

  static InterestFrequency fromText(String? value) {
    final text = (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (text.contains('month') || text == 'm') return monthly;
    if (text.contains('quarter') || text == 'q') return quarterly;
    if (text.contains('half') || text.contains('semi') || text == 'h') {
      return halfYearly;
    }
    if (text.contains('annual') ||
        text.contains('year') ||
        text == 'y' ||
        text == 'a') {
      return annual;
    }
    return monthly;
  }
}

/// Interest calculation method. Simple interest always accrues on the original
/// principal. Compound interest accrues on principal plus interest that has not
/// been withdrawn; the schedule therefore represents a reinvestment model.
enum InterestMethod {
  simple,
  compound;

  String get label => switch (this) {
    InterestMethod.simple => 'Simple interest',
    InterestMethod.compound => 'Compound interest',
  };

  String get description => switch (this) {
    InterestMethod.simple =>
      'Each coupon is calculated on the original principal.',
    InterestMethod.compound =>
      'Interest is added to principal and earns interest in later periods.',
  };

  static InterestMethod fromText(String? value) {
    final text = (value ?? '').toLowerCase();
    if (text.contains('compound') || text.contains('cumulative')) {
      return compound;
    }
    return simple;
  }
}

/// Compounding cadence for compound-interest bonds.
enum CompoundingFrequency {
  annual,
  halfYearly,
  quarterly,
  monthly;

  int get months => switch (this) {
    CompoundingFrequency.annual => 12,
    CompoundingFrequency.halfYearly => 6,
    CompoundingFrequency.quarterly => 3,
    CompoundingFrequency.monthly => 1,
  };

  int get periodsPerYear => 12 ~/ months;

  String get label => switch (this) {
    CompoundingFrequency.annual => 'Annual',
    CompoundingFrequency.halfYearly => 'Half-yearly',
    CompoundingFrequency.quarterly => 'Quarterly',
    CompoundingFrequency.monthly => 'Monthly',
  };

  static CompoundingFrequency fromText(String? value) {
    final text = (value ?? '').toLowerCase();
    if (text.contains('month')) return monthly;
    if (text.contains('quarter')) return quarterly;
    if (text.contains('half') || text.contains('semi')) return halfYearly;
    return annual;
  }
}

/// Day-count convention used by the calculation engine. `equalPeriods`
/// preserves the classic coupon model (principal × rate × months / 12), while
/// the others calculate actual accrued days and therefore handle leap years.
enum DayCountConvention {
  equalPeriods,
  actual365,
  actualActual,
  thirty360;

  String get label => switch (this) {
    DayCountConvention.equalPeriods => 'Equal coupon periods',
    DayCountConvention.actual365 => 'Actual / 365',
    DayCountConvention.actualActual => 'Actual / actual',
    DayCountConvention.thirty360 => '30 / 360',
  };

  String get description => switch (this) {
    DayCountConvention.equalPeriods =>
      'Every coupon period uses the same month fraction.',
    DayCountConvention.actual365 =>
      'Interest uses actual days over a fixed 365-day year.',
    DayCountConvention.actualActual =>
      'Interest uses actual days and 366 days in leap years.',
    DayCountConvention.thirty360 =>
      'Interest uses 30-day months over a 360-day year.',
  };

  static DayCountConvention fromText(String? value) {
    final text = (value ?? '').toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    if (text.contains('actualactual') || text == 'actact') {
      return actualActual;
    }
    if (text.contains('30360') || text.contains('thirty360')) {
      return thirty360;
    }
    if (text.contains('actual365') || text.contains('act365')) {
      return actual365;
    }
    return equalPeriods;
  }
}

/// Lifecycle state of a bond.
enum BondStatus {
  active,
  matured,
  archived;

  String get label => switch (this) {
    BondStatus.active => 'Active',
    BondStatus.matured => 'Matured',
    BondStatus.archived => 'Archived',
  };

  static BondStatus fromText(String? value) {
    final text = (value ?? '').toLowerCase();
    if (text.contains('archiv')) return archived;
    if (text.contains('matur') || text.contains('closed')) return matured;
    return active;
  }
}

enum ScheduleStatus {
  pending,
  partiallyPaid,
  paid,
  skipped;

  String get label => switch (this) {
    ScheduleStatus.pending => 'Pending',
    ScheduleStatus.partiallyPaid => 'Partially received',
    ScheduleStatus.paid => 'Received',
    ScheduleStatus.skipped => 'Skipped',
  };

  bool get isReceived =>
      this == ScheduleStatus.paid || this == ScheduleStatus.partiallyPaid;
}

enum PaymentType {
  interest,
  maturity,
  principal;

  String get label => switch (this) {
    PaymentType.interest => 'Interest',
    PaymentType.maturity => 'Maturity',
    PaymentType.principal => 'Principal',
  };

  static PaymentType fromText(String? value) {
    final text = (value ?? '').toLowerCase();
    if (text.contains('matur')) return maturity;
    if (text.contains('principal')) return principal;
    return interest;
  }
}

/// A bond investment. Monetary values are stored as integer paise to avoid
/// floating point drift. Rates are percentages (8.5 == 8.5%).
class Bond {
  const Bond({
    required this.id,
    required this.name,
    required this.issuer,
    required this.principalPaise,
    required this.annualRate,
    required this.purchaseDate,
    required this.frequency,
    required this.firstInterestDate,
    required this.maturityDate,
    required this.expectedMaturityAmountPaise,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.paymentAccount,
    this.notes,
    this.archivedAt,
    this.interestMethod = InterestMethod.simple,
    this.compoundingFrequency = CompoundingFrequency.annual,
    this.dayCountConvention = DayCountConvention.equalPeriods,
    this.creditDay,
    this.manualInterestPerPeriodPaise,
    this.remindersEnabled = true,
    this.interestReminderOffsets = '',
    this.maturityReminderOffsets = '',
  });

  final int id;
  final String name;
  final String issuer;
  final int principalPaise;
  final double annualRate;
  final DateTime purchaseDate;
  final InterestFrequency frequency;

  /// First date on which interest is credited.
  final DateTime firstInterestDate;
  final DateTime maturityDate;
  final int expectedMaturityAmountPaise;
  final String? paymentAccount;
  final String? notes;
  final BondStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  /// Calculation configuration. Older records default to simple interest and
  /// equal coupon periods, preserving the original app's results.
  final InterestMethod interestMethod;
  final CompoundingFrequency compoundingFrequency;
  final DayCountConvention dayCountConvention;

  /// Preferred day of month for credits (1..31). Month-end dates are clamped.
  final int? creditDay;

  /// Optional manual override for every coupon. Useful for step-up coupons,
  /// tax-adjusted payouts or bonds with special terms.
  final int? manualInterestPerPeriodPaise;

  final bool remindersEnabled;

  /// Comma-separated reminder lead times in days. `0` means on the due date.
  final String interestReminderOffsets;
  final String maturityReminderOffsets;

  double get principal => principalPaise / 100;

  double get expectedMaturityAmount => expectedMaturityAmountPaise / 100;

  /// Simple coupon interest for one payment period, honouring a manual
  /// override. Advanced calculations live in `InterestEngine`.
  int get interestPerPeriodPaise {
    if (manualInterestPerPeriodPaise != null) {
      return manualInterestPerPeriodPaise!;
    }
    return (principalPaise * annualRate / 100 * frequency.months / 12).round();
  }

  int get annualInterestPaise => (principalPaise * annualRate / 100).round();

  int get monthlyInterestPaise => (principalPaise * annualRate / 1200).round();

  bool get isActive => status == BondStatus.active;

  bool get isArchived => status == BondStatus.archived;

  bool get isMatured =>
      status == BondStatus.matured ||
      dates.dateOnly(maturityDate).isBefore(dates.today());

  int get daysToMaturity => dates.daysBetween(dates.today(), maturityDate);

  double get progressToMaturity {
    final total = maturityDate.difference(purchaseDate).inDays;
    if (total <= 0) return 1;
    final elapsed = dates.today().difference(purchaseDate).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  List<int> get interestReminderDays =>
      _parseOffsets(interestReminderOffsets, const [7, 3, 1, 0]);

  List<int> get maturityReminderDays =>
      _parseOffsets(maturityReminderOffsets, const [30, 15, 7, 1, 0]);

  static List<int> _parseOffsets(String value, List<int> fallback) {
    final result = <int>{};
    for (final part in value.split(',')) {
      final parsed = int.tryParse(part.trim());
      if (parsed != null && parsed >= 0 && parsed <= 365) result.add(parsed);
    }
    if (result.isEmpty) return fallback;
    return result.toList()..sort((a, b) => b.compareTo(a));
  }

  Bond copyWith({
    int? id,
    String? name,
    String? issuer,
    int? principalPaise,
    double? annualRate,
    DateTime? purchaseDate,
    InterestFrequency? frequency,
    DateTime? firstInterestDate,
    DateTime? maturityDate,
    int? expectedMaturityAmountPaise,
    String? paymentAccount,
    String? notes,
    BondStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    bool clearPaymentAccount = false,
    bool clearNotes = false,
    InterestMethod? interestMethod,
    CompoundingFrequency? compoundingFrequency,
    DayCountConvention? dayCountConvention,
    int? creditDay,
    int? manualInterestPerPeriodPaise,
    bool clearCreditDay = false,
    bool clearManualInterest = false,
    bool? remindersEnabled,
    String? interestReminderOffsets,
    String? maturityReminderOffsets,
  }) {
    return Bond(
      id: id ?? this.id,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      principalPaise: principalPaise ?? this.principalPaise,
      annualRate: annualRate ?? this.annualRate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      frequency: frequency ?? this.frequency,
      firstInterestDate: firstInterestDate ?? this.firstInterestDate,
      maturityDate: maturityDate ?? this.maturityDate,
      expectedMaturityAmountPaise:
          expectedMaturityAmountPaise ?? this.expectedMaturityAmountPaise,
      paymentAccount: clearPaymentAccount
          ? null
          : (paymentAccount ?? this.paymentAccount),
      notes: clearNotes ? null : (notes ?? this.notes),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      interestMethod: interestMethod ?? this.interestMethod,
      compoundingFrequency: compoundingFrequency ?? this.compoundingFrequency,
      dayCountConvention: dayCountConvention ?? this.dayCountConvention,
      creditDay: clearCreditDay ? null : (creditDay ?? this.creditDay),
      manualInterestPerPeriodPaise: clearManualInterest
          ? null
          : (manualInterestPerPeriodPaise ?? this.manualInterestPerPeriodPaise),
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      interestReminderOffsets:
          interestReminderOffsets ?? this.interestReminderOffsets,
      maturityReminderOffsets:
          maturityReminderOffsets ?? this.maturityReminderOffsets,
    );
  }
}

/// Editable payload used by create, update and import flows.
class BondDraft {
  const BondDraft({
    this.id,
    required this.name,
    required this.issuer,
    required this.principalPaise,
    required this.annualRate,
    required this.purchaseDate,
    required this.frequency,
    required this.firstInterestDate,
    required this.maturityDate,
    required this.expectedMaturityAmountPaise,
    this.paymentAccount,
    this.notes,
    this.status = BondStatus.active,
    this.interestMethod = InterestMethod.simple,
    this.compoundingFrequency = CompoundingFrequency.annual,
    this.dayCountConvention = DayCountConvention.equalPeriods,
    this.creditDay,
    this.manualInterestPerPeriodPaise,
    this.remindersEnabled = true,
    this.interestReminderOffsets = '',
    this.maturityReminderOffsets = '',
  });

  final int? id;
  final String name;
  final String issuer;
  final int principalPaise;
  final double annualRate;
  final DateTime purchaseDate;
  final InterestFrequency frequency;
  final DateTime firstInterestDate;
  final DateTime maturityDate;
  final int expectedMaturityAmountPaise;
  final String? paymentAccount;
  final String? notes;
  final BondStatus status;
  final InterestMethod interestMethod;
  final CompoundingFrequency compoundingFrequency;
  final DayCountConvention dayCountConvention;
  final int? creditDay;
  final int? manualInterestPerPeriodPaise;
  final bool remindersEnabled;
  final String interestReminderOffsets;
  final String maturityReminderOffsets;

  factory BondDraft.fromBond(Bond bond) => BondDraft(
    id: bond.id,
    name: bond.name,
    issuer: bond.issuer,
    principalPaise: bond.principalPaise,
    annualRate: bond.annualRate,
    purchaseDate: bond.purchaseDate,
    frequency: bond.frequency,
    firstInterestDate: bond.firstInterestDate,
    maturityDate: bond.maturityDate,
    expectedMaturityAmountPaise: bond.expectedMaturityAmountPaise,
    paymentAccount: bond.paymentAccount,
    notes: bond.notes,
    status: bond.status,
    interestMethod: bond.interestMethod,
    compoundingFrequency: bond.compoundingFrequency,
    dayCountConvention: bond.dayCountConvention,
    creditDay: bond.creditDay,
    manualInterestPerPeriodPaise: bond.manualInterestPerPeriodPaise,
    remindersEnabled: bond.remindersEnabled,
    interestReminderOffsets: bond.interestReminderOffsets,
    maturityReminderOffsets: bond.maturityReminderOffsets,
  );

  int get interestPerPeriodPaise {
    if (manualInterestPerPeriodPaise != null) {
      return manualInterestPerPeriodPaise!;
    }
    return (principalPaise * annualRate / 100 * frequency.months / 12).round();
  }

  BondDraft copyWith({
    int? id,
    String? name,
    String? issuer,
    int? principalPaise,
    double? annualRate,
    DateTime? purchaseDate,
    InterestFrequency? frequency,
    DateTime? firstInterestDate,
    DateTime? maturityDate,
    int? expectedMaturityAmountPaise,
    String? paymentAccount,
    String? notes,
    BondStatus? status,
    InterestMethod? interestMethod,
    CompoundingFrequency? compoundingFrequency,
    DayCountConvention? dayCountConvention,
    int? creditDay,
    int? manualInterestPerPeriodPaise,
    bool clearCreditDay = false,
    bool clearManualInterest = false,
    bool? remindersEnabled,
    String? interestReminderOffsets,
    String? maturityReminderOffsets,
  }) {
    return BondDraft(
      id: id ?? this.id,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      principalPaise: principalPaise ?? this.principalPaise,
      annualRate: annualRate ?? this.annualRate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      frequency: frequency ?? this.frequency,
      firstInterestDate: firstInterestDate ?? this.firstInterestDate,
      maturityDate: maturityDate ?? this.maturityDate,
      expectedMaturityAmountPaise:
          expectedMaturityAmountPaise ?? this.expectedMaturityAmountPaise,
      paymentAccount: paymentAccount ?? this.paymentAccount,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      interestMethod: interestMethod ?? this.interestMethod,
      compoundingFrequency: compoundingFrequency ?? this.compoundingFrequency,
      dayCountConvention: dayCountConvention ?? this.dayCountConvention,
      creditDay: clearCreditDay ? null : (creditDay ?? this.creditDay),
      manualInterestPerPeriodPaise: clearManualInterest
          ? null
          : (manualInterestPerPeriodPaise ?? this.manualInterestPerPeriodPaise),
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      interestReminderOffsets:
          interestReminderOffsets ?? this.interestReminderOffsets,
      maturityReminderOffsets:
          maturityReminderOffsets ?? this.maturityReminderOffsets,
    );
  }
}
