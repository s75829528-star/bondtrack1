// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BondsTable extends Bonds with TableInfo<$BondsTable, BondRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BondsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issuerMeta = const VerificationMeta('issuer');
  @override
  late final GeneratedColumn<String> issuer = GeneratedColumn<String>(
    'issuer',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _principalPaiseMeta = const VerificationMeta(
    'principalPaise',
  );
  @override
  late final GeneratedColumn<int> principalPaise = GeneratedColumn<int>(
    'principal_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualRateMeta = const VerificationMeta(
    'annualRate',
  );
  @override
  late final GeneratedColumn<double> annualRate = GeneratedColumn<double>(
    'annual_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<InterestFrequency, String>
  frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<InterestFrequency>($BondsTable.$converterfrequency);
  static const VerificationMeta _firstInterestDateMeta = const VerificationMeta(
    'firstInterestDate',
  );
  @override
  late final GeneratedColumn<DateTime> firstInterestDate =
      GeneratedColumn<DateTime>(
        'first_interest_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _maturityDateMeta = const VerificationMeta(
    'maturityDate',
  );
  @override
  late final GeneratedColumn<DateTime> maturityDate = GeneratedColumn<DateTime>(
    'maturity_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedMaturityAmountPaiseMeta =
      const VerificationMeta('expectedMaturityAmountPaise');
  @override
  late final GeneratedColumn<int> expectedMaturityAmountPaise =
      GeneratedColumn<int>(
        'expected_maturity_amount_paise',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _paymentAccountMeta = const VerificationMeta(
    'paymentAccount',
  );
  @override
  late final GeneratedColumn<String> paymentAccount = GeneratedColumn<String>(
    'payment_account',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BondStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('active'),
      ).withConverter<BondStatus>($BondsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<InterestMethod, String>
  interestMethod = GeneratedColumn<String>(
    'interest_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('simple'),
  ).withConverter<InterestMethod>($BondsTable.$converterinterestMethod);
  @override
  late final GeneratedColumnWithTypeConverter<CompoundingFrequency, String>
  compoundingFrequency =
      GeneratedColumn<String>(
        'compounding_frequency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('annual'),
      ).withConverter<CompoundingFrequency>(
        $BondsTable.$convertercompoundingFrequency,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DayCountConvention, String>
  dayCountConvention = GeneratedColumn<String>(
    'day_count_convention',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('equalPeriods'),
  ).withConverter<DayCountConvention>($BondsTable.$converterdayCountConvention);
  static const VerificationMeta _creditDayMeta = const VerificationMeta(
    'creditDay',
  );
  @override
  late final GeneratedColumn<int> creditDay = GeneratedColumn<int>(
    'credit_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manualInterestPerPeriodPaiseMeta =
      const VerificationMeta('manualInterestPerPeriodPaise');
  @override
  late final GeneratedColumn<int> manualInterestPerPeriodPaise =
      GeneratedColumn<int>(
        'manual_interest_per_period_paise',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _remindersEnabledMeta = const VerificationMeta(
    'remindersEnabled',
  );
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
    'reminders_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminders_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _interestReminderOffsetsMeta =
      const VerificationMeta('interestReminderOffsets');
  @override
  late final GeneratedColumn<String> interestReminderOffsets =
      GeneratedColumn<String>(
        'interest_reminder_offsets',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('7,3,1,0'),
      );
  static const VerificationMeta _maturityReminderOffsetsMeta =
      const VerificationMeta('maturityReminderOffsets');
  @override
  late final GeneratedColumn<String> maturityReminderOffsets =
      GeneratedColumn<String>(
        'maturity_reminder_offsets',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('30,15,7,1,0'),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    issuer,
    principalPaise,
    annualRate,
    purchaseDate,
    frequency,
    firstInterestDate,
    maturityDate,
    expectedMaturityAmountPaise,
    paymentAccount,
    notes,
    status,
    interestMethod,
    compoundingFrequency,
    dayCountConvention,
    creditDay,
    manualInterestPerPeriodPaise,
    remindersEnabled,
    interestReminderOffsets,
    maturityReminderOffsets,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bonds';
  @override
  VerificationContext validateIntegrity(
    Insertable<BondRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('issuer')) {
      context.handle(
        _issuerMeta,
        issuer.isAcceptableOrUnknown(data['issuer']!, _issuerMeta),
      );
    } else if (isInserting) {
      context.missing(_issuerMeta);
    }
    if (data.containsKey('principal_paise')) {
      context.handle(
        _principalPaiseMeta,
        principalPaise.isAcceptableOrUnknown(
          data['principal_paise']!,
          _principalPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalPaiseMeta);
    }
    if (data.containsKey('annual_rate')) {
      context.handle(
        _annualRateMeta,
        annualRate.isAcceptableOrUnknown(data['annual_rate']!, _annualRateMeta),
      );
    } else if (isInserting) {
      context.missing(_annualRateMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('first_interest_date')) {
      context.handle(
        _firstInterestDateMeta,
        firstInterestDate.isAcceptableOrUnknown(
          data['first_interest_date']!,
          _firstInterestDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstInterestDateMeta);
    }
    if (data.containsKey('maturity_date')) {
      context.handle(
        _maturityDateMeta,
        maturityDate.isAcceptableOrUnknown(
          data['maturity_date']!,
          _maturityDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maturityDateMeta);
    }
    if (data.containsKey('expected_maturity_amount_paise')) {
      context.handle(
        _expectedMaturityAmountPaiseMeta,
        expectedMaturityAmountPaise.isAcceptableOrUnknown(
          data['expected_maturity_amount_paise']!,
          _expectedMaturityAmountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedMaturityAmountPaiseMeta);
    }
    if (data.containsKey('payment_account')) {
      context.handle(
        _paymentAccountMeta,
        paymentAccount.isAcceptableOrUnknown(
          data['payment_account']!,
          _paymentAccountMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('credit_day')) {
      context.handle(
        _creditDayMeta,
        creditDay.isAcceptableOrUnknown(data['credit_day']!, _creditDayMeta),
      );
    }
    if (data.containsKey('manual_interest_per_period_paise')) {
      context.handle(
        _manualInterestPerPeriodPaiseMeta,
        manualInterestPerPeriodPaise.isAcceptableOrUnknown(
          data['manual_interest_per_period_paise']!,
          _manualInterestPerPeriodPaiseMeta,
        ),
      );
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
        _remindersEnabledMeta,
        remindersEnabled.isAcceptableOrUnknown(
          data['reminders_enabled']!,
          _remindersEnabledMeta,
        ),
      );
    }
    if (data.containsKey('interest_reminder_offsets')) {
      context.handle(
        _interestReminderOffsetsMeta,
        interestReminderOffsets.isAcceptableOrUnknown(
          data['interest_reminder_offsets']!,
          _interestReminderOffsetsMeta,
        ),
      );
    }
    if (data.containsKey('maturity_reminder_offsets')) {
      context.handle(
        _maturityReminderOffsetsMeta,
        maturityReminderOffsets.isAcceptableOrUnknown(
          data['maturity_reminder_offsets']!,
          _maturityReminderOffsetsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BondRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BondRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      issuer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issuer'],
      )!,
      principalPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}principal_paise'],
      )!,
      annualRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_rate'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      frequency: $BondsTable.$converterfrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}frequency'],
        )!,
      ),
      firstInterestDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_interest_date'],
      )!,
      maturityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maturity_date'],
      )!,
      expectedMaturityAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_maturity_amount_paise'],
      )!,
      paymentAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_account'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: $BondsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      interestMethod: $BondsTable.$converterinterestMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}interest_method'],
        )!,
      ),
      compoundingFrequency: $BondsTable.$convertercompoundingFrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}compounding_frequency'],
        )!,
      ),
      dayCountConvention: $BondsTable.$converterdayCountConvention.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}day_count_convention'],
        )!,
      ),
      creditDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_day'],
      ),
      manualInterestPerPeriodPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manual_interest_per_period_paise'],
      ),
      remindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminders_enabled'],
      )!,
      interestReminderOffsets: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_reminder_offsets'],
      )!,
      maturityReminderOffsets: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maturity_reminder_offsets'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $BondsTable createAlias(String alias) {
    return $BondsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<InterestFrequency, String, String>
  $converterfrequency = const EnumNameConverter<InterestFrequency>(
    InterestFrequency.values,
  );
  static JsonTypeConverter2<BondStatus, String, String> $converterstatus =
      const EnumNameConverter<BondStatus>(BondStatus.values);
  static JsonTypeConverter2<InterestMethod, String, String>
  $converterinterestMethod = const EnumNameConverter<InterestMethod>(
    InterestMethod.values,
  );
  static JsonTypeConverter2<CompoundingFrequency, String, String>
  $convertercompoundingFrequency =
      const EnumNameConverter<CompoundingFrequency>(
        CompoundingFrequency.values,
      );
  static JsonTypeConverter2<DayCountConvention, String, String>
  $converterdayCountConvention = const EnumNameConverter<DayCountConvention>(
    DayCountConvention.values,
  );
}

class BondRow extends DataClass implements Insertable<BondRow> {
  final int id;
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const BondRow({
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
    this.paymentAccount,
    this.notes,
    required this.status,
    required this.interestMethod,
    required this.compoundingFrequency,
    required this.dayCountConvention,
    this.creditDay,
    this.manualInterestPerPeriodPaise,
    required this.remindersEnabled,
    required this.interestReminderOffsets,
    required this.maturityReminderOffsets,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['issuer'] = Variable<String>(issuer);
    map['principal_paise'] = Variable<int>(principalPaise);
    map['annual_rate'] = Variable<double>(annualRate);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    {
      map['frequency'] = Variable<String>(
        $BondsTable.$converterfrequency.toSql(frequency),
      );
    }
    map['first_interest_date'] = Variable<DateTime>(firstInterestDate);
    map['maturity_date'] = Variable<DateTime>(maturityDate);
    map['expected_maturity_amount_paise'] = Variable<int>(
      expectedMaturityAmountPaise,
    );
    if (!nullToAbsent || paymentAccount != null) {
      map['payment_account'] = Variable<String>(paymentAccount);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['status'] = Variable<String>(
        $BondsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['interest_method'] = Variable<String>(
        $BondsTable.$converterinterestMethod.toSql(interestMethod),
      );
    }
    {
      map['compounding_frequency'] = Variable<String>(
        $BondsTable.$convertercompoundingFrequency.toSql(compoundingFrequency),
      );
    }
    {
      map['day_count_convention'] = Variable<String>(
        $BondsTable.$converterdayCountConvention.toSql(dayCountConvention),
      );
    }
    if (!nullToAbsent || creditDay != null) {
      map['credit_day'] = Variable<int>(creditDay);
    }
    if (!nullToAbsent || manualInterestPerPeriodPaise != null) {
      map['manual_interest_per_period_paise'] = Variable<int>(
        manualInterestPerPeriodPaise,
      );
    }
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    map['interest_reminder_offsets'] = Variable<String>(
      interestReminderOffsets,
    );
    map['maturity_reminder_offsets'] = Variable<String>(
      maturityReminderOffsets,
    );
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  BondsCompanion toCompanion(bool nullToAbsent) {
    return BondsCompanion(
      id: Value(id),
      name: Value(name),
      issuer: Value(issuer),
      principalPaise: Value(principalPaise),
      annualRate: Value(annualRate),
      purchaseDate: Value(purchaseDate),
      frequency: Value(frequency),
      firstInterestDate: Value(firstInterestDate),
      maturityDate: Value(maturityDate),
      expectedMaturityAmountPaise: Value(expectedMaturityAmountPaise),
      paymentAccount: paymentAccount == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentAccount),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      interestMethod: Value(interestMethod),
      compoundingFrequency: Value(compoundingFrequency),
      dayCountConvention: Value(dayCountConvention),
      creditDay: creditDay == null && nullToAbsent
          ? const Value.absent()
          : Value(creditDay),
      manualInterestPerPeriodPaise:
          manualInterestPerPeriodPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(manualInterestPerPeriodPaise),
      remindersEnabled: Value(remindersEnabled),
      interestReminderOffsets: Value(interestReminderOffsets),
      maturityReminderOffsets: Value(maturityReminderOffsets),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory BondRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BondRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      issuer: serializer.fromJson<String>(json['issuer']),
      principalPaise: serializer.fromJson<int>(json['principalPaise']),
      annualRate: serializer.fromJson<double>(json['annualRate']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      frequency: $BondsTable.$converterfrequency.fromJson(
        serializer.fromJson<String>(json['frequency']),
      ),
      firstInterestDate: serializer.fromJson<DateTime>(
        json['firstInterestDate'],
      ),
      maturityDate: serializer.fromJson<DateTime>(json['maturityDate']),
      expectedMaturityAmountPaise: serializer.fromJson<int>(
        json['expectedMaturityAmountPaise'],
      ),
      paymentAccount: serializer.fromJson<String?>(json['paymentAccount']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: $BondsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      interestMethod: $BondsTable.$converterinterestMethod.fromJson(
        serializer.fromJson<String>(json['interestMethod']),
      ),
      compoundingFrequency: $BondsTable.$convertercompoundingFrequency.fromJson(
        serializer.fromJson<String>(json['compoundingFrequency']),
      ),
      dayCountConvention: $BondsTable.$converterdayCountConvention.fromJson(
        serializer.fromJson<String>(json['dayCountConvention']),
      ),
      creditDay: serializer.fromJson<int?>(json['creditDay']),
      manualInterestPerPeriodPaise: serializer.fromJson<int?>(
        json['manualInterestPerPeriodPaise'],
      ),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      interestReminderOffsets: serializer.fromJson<String>(
        json['interestReminderOffsets'],
      ),
      maturityReminderOffsets: serializer.fromJson<String>(
        json['maturityReminderOffsets'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'issuer': serializer.toJson<String>(issuer),
      'principalPaise': serializer.toJson<int>(principalPaise),
      'annualRate': serializer.toJson<double>(annualRate),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'frequency': serializer.toJson<String>(
        $BondsTable.$converterfrequency.toJson(frequency),
      ),
      'firstInterestDate': serializer.toJson<DateTime>(firstInterestDate),
      'maturityDate': serializer.toJson<DateTime>(maturityDate),
      'expectedMaturityAmountPaise': serializer.toJson<int>(
        expectedMaturityAmountPaise,
      ),
      'paymentAccount': serializer.toJson<String?>(paymentAccount),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(
        $BondsTable.$converterstatus.toJson(status),
      ),
      'interestMethod': serializer.toJson<String>(
        $BondsTable.$converterinterestMethod.toJson(interestMethod),
      ),
      'compoundingFrequency': serializer.toJson<String>(
        $BondsTable.$convertercompoundingFrequency.toJson(compoundingFrequency),
      ),
      'dayCountConvention': serializer.toJson<String>(
        $BondsTable.$converterdayCountConvention.toJson(dayCountConvention),
      ),
      'creditDay': serializer.toJson<int?>(creditDay),
      'manualInterestPerPeriodPaise': serializer.toJson<int?>(
        manualInterestPerPeriodPaise,
      ),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'interestReminderOffsets': serializer.toJson<String>(
        interestReminderOffsets,
      ),
      'maturityReminderOffsets': serializer.toJson<String>(
        maturityReminderOffsets,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  BondRow copyWith({
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
    Value<String?> paymentAccount = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    BondStatus? status,
    InterestMethod? interestMethod,
    CompoundingFrequency? compoundingFrequency,
    DayCountConvention? dayCountConvention,
    Value<int?> creditDay = const Value.absent(),
    Value<int?> manualInterestPerPeriodPaise = const Value.absent(),
    bool? remindersEnabled,
    String? interestReminderOffsets,
    String? maturityReminderOffsets,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => BondRow(
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
    paymentAccount: paymentAccount.present
        ? paymentAccount.value
        : this.paymentAccount,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    interestMethod: interestMethod ?? this.interestMethod,
    compoundingFrequency: compoundingFrequency ?? this.compoundingFrequency,
    dayCountConvention: dayCountConvention ?? this.dayCountConvention,
    creditDay: creditDay.present ? creditDay.value : this.creditDay,
    manualInterestPerPeriodPaise: manualInterestPerPeriodPaise.present
        ? manualInterestPerPeriodPaise.value
        : this.manualInterestPerPeriodPaise,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    interestReminderOffsets:
        interestReminderOffsets ?? this.interestReminderOffsets,
    maturityReminderOffsets:
        maturityReminderOffsets ?? this.maturityReminderOffsets,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  BondRow copyWithCompanion(BondsCompanion data) {
    return BondRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      issuer: data.issuer.present ? data.issuer.value : this.issuer,
      principalPaise: data.principalPaise.present
          ? data.principalPaise.value
          : this.principalPaise,
      annualRate: data.annualRate.present
          ? data.annualRate.value
          : this.annualRate,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      firstInterestDate: data.firstInterestDate.present
          ? data.firstInterestDate.value
          : this.firstInterestDate,
      maturityDate: data.maturityDate.present
          ? data.maturityDate.value
          : this.maturityDate,
      expectedMaturityAmountPaise: data.expectedMaturityAmountPaise.present
          ? data.expectedMaturityAmountPaise.value
          : this.expectedMaturityAmountPaise,
      paymentAccount: data.paymentAccount.present
          ? data.paymentAccount.value
          : this.paymentAccount,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      interestMethod: data.interestMethod.present
          ? data.interestMethod.value
          : this.interestMethod,
      compoundingFrequency: data.compoundingFrequency.present
          ? data.compoundingFrequency.value
          : this.compoundingFrequency,
      dayCountConvention: data.dayCountConvention.present
          ? data.dayCountConvention.value
          : this.dayCountConvention,
      creditDay: data.creditDay.present ? data.creditDay.value : this.creditDay,
      manualInterestPerPeriodPaise: data.manualInterestPerPeriodPaise.present
          ? data.manualInterestPerPeriodPaise.value
          : this.manualInterestPerPeriodPaise,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
      interestReminderOffsets: data.interestReminderOffsets.present
          ? data.interestReminderOffsets.value
          : this.interestReminderOffsets,
      maturityReminderOffsets: data.maturityReminderOffsets.present
          ? data.maturityReminderOffsets.value
          : this.maturityReminderOffsets,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BondRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('issuer: $issuer, ')
          ..write('principalPaise: $principalPaise, ')
          ..write('annualRate: $annualRate, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('frequency: $frequency, ')
          ..write('firstInterestDate: $firstInterestDate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('expectedMaturityAmountPaise: $expectedMaturityAmountPaise, ')
          ..write('paymentAccount: $paymentAccount, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('interestMethod: $interestMethod, ')
          ..write('compoundingFrequency: $compoundingFrequency, ')
          ..write('dayCountConvention: $dayCountConvention, ')
          ..write('creditDay: $creditDay, ')
          ..write(
            'manualInterestPerPeriodPaise: $manualInterestPerPeriodPaise, ',
          )
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('interestReminderOffsets: $interestReminderOffsets, ')
          ..write('maturityReminderOffsets: $maturityReminderOffsets, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    issuer,
    principalPaise,
    annualRate,
    purchaseDate,
    frequency,
    firstInterestDate,
    maturityDate,
    expectedMaturityAmountPaise,
    paymentAccount,
    notes,
    status,
    interestMethod,
    compoundingFrequency,
    dayCountConvention,
    creditDay,
    manualInterestPerPeriodPaise,
    remindersEnabled,
    interestReminderOffsets,
    maturityReminderOffsets,
    createdAt,
    updatedAt,
    archivedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BondRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.issuer == this.issuer &&
          other.principalPaise == this.principalPaise &&
          other.annualRate == this.annualRate &&
          other.purchaseDate == this.purchaseDate &&
          other.frequency == this.frequency &&
          other.firstInterestDate == this.firstInterestDate &&
          other.maturityDate == this.maturityDate &&
          other.expectedMaturityAmountPaise ==
              this.expectedMaturityAmountPaise &&
          other.paymentAccount == this.paymentAccount &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.interestMethod == this.interestMethod &&
          other.compoundingFrequency == this.compoundingFrequency &&
          other.dayCountConvention == this.dayCountConvention &&
          other.creditDay == this.creditDay &&
          other.manualInterestPerPeriodPaise ==
              this.manualInterestPerPeriodPaise &&
          other.remindersEnabled == this.remindersEnabled &&
          other.interestReminderOffsets == this.interestReminderOffsets &&
          other.maturityReminderOffsets == this.maturityReminderOffsets &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class BondsCompanion extends UpdateCompanion<BondRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> issuer;
  final Value<int> principalPaise;
  final Value<double> annualRate;
  final Value<DateTime> purchaseDate;
  final Value<InterestFrequency> frequency;
  final Value<DateTime> firstInterestDate;
  final Value<DateTime> maturityDate;
  final Value<int> expectedMaturityAmountPaise;
  final Value<String?> paymentAccount;
  final Value<String?> notes;
  final Value<BondStatus> status;
  final Value<InterestMethod> interestMethod;
  final Value<CompoundingFrequency> compoundingFrequency;
  final Value<DayCountConvention> dayCountConvention;
  final Value<int?> creditDay;
  final Value<int?> manualInterestPerPeriodPaise;
  final Value<bool> remindersEnabled;
  final Value<String> interestReminderOffsets;
  final Value<String> maturityReminderOffsets;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  const BondsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.issuer = const Value.absent(),
    this.principalPaise = const Value.absent(),
    this.annualRate = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.frequency = const Value.absent(),
    this.firstInterestDate = const Value.absent(),
    this.maturityDate = const Value.absent(),
    this.expectedMaturityAmountPaise = const Value.absent(),
    this.paymentAccount = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.interestMethod = const Value.absent(),
    this.compoundingFrequency = const Value.absent(),
    this.dayCountConvention = const Value.absent(),
    this.creditDay = const Value.absent(),
    this.manualInterestPerPeriodPaise = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.interestReminderOffsets = const Value.absent(),
    this.maturityReminderOffsets = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  BondsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String issuer,
    required int principalPaise,
    required double annualRate,
    required DateTime purchaseDate,
    required InterestFrequency frequency,
    required DateTime firstInterestDate,
    required DateTime maturityDate,
    required int expectedMaturityAmountPaise,
    this.paymentAccount = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.interestMethod = const Value.absent(),
    this.compoundingFrequency = const Value.absent(),
    this.dayCountConvention = const Value.absent(),
    this.creditDay = const Value.absent(),
    this.manualInterestPerPeriodPaise = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.interestReminderOffsets = const Value.absent(),
    this.maturityReminderOffsets = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
  }) : name = Value(name),
       issuer = Value(issuer),
       principalPaise = Value(principalPaise),
       annualRate = Value(annualRate),
       purchaseDate = Value(purchaseDate),
       frequency = Value(frequency),
       firstInterestDate = Value(firstInterestDate),
       maturityDate = Value(maturityDate),
       expectedMaturityAmountPaise = Value(expectedMaturityAmountPaise),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BondRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? issuer,
    Expression<int>? principalPaise,
    Expression<double>? annualRate,
    Expression<DateTime>? purchaseDate,
    Expression<String>? frequency,
    Expression<DateTime>? firstInterestDate,
    Expression<DateTime>? maturityDate,
    Expression<int>? expectedMaturityAmountPaise,
    Expression<String>? paymentAccount,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<String>? interestMethod,
    Expression<String>? compoundingFrequency,
    Expression<String>? dayCountConvention,
    Expression<int>? creditDay,
    Expression<int>? manualInterestPerPeriodPaise,
    Expression<bool>? remindersEnabled,
    Expression<String>? interestReminderOffsets,
    Expression<String>? maturityReminderOffsets,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (issuer != null) 'issuer': issuer,
      if (principalPaise != null) 'principal_paise': principalPaise,
      if (annualRate != null) 'annual_rate': annualRate,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (frequency != null) 'frequency': frequency,
      if (firstInterestDate != null) 'first_interest_date': firstInterestDate,
      if (maturityDate != null) 'maturity_date': maturityDate,
      if (expectedMaturityAmountPaise != null)
        'expected_maturity_amount_paise': expectedMaturityAmountPaise,
      if (paymentAccount != null) 'payment_account': paymentAccount,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (interestMethod != null) 'interest_method': interestMethod,
      if (compoundingFrequency != null)
        'compounding_frequency': compoundingFrequency,
      if (dayCountConvention != null)
        'day_count_convention': dayCountConvention,
      if (creditDay != null) 'credit_day': creditDay,
      if (manualInterestPerPeriodPaise != null)
        'manual_interest_per_period_paise': manualInterestPerPeriodPaise,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (interestReminderOffsets != null)
        'interest_reminder_offsets': interestReminderOffsets,
      if (maturityReminderOffsets != null)
        'maturity_reminder_offsets': maturityReminderOffsets,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  BondsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? issuer,
    Value<int>? principalPaise,
    Value<double>? annualRate,
    Value<DateTime>? purchaseDate,
    Value<InterestFrequency>? frequency,
    Value<DateTime>? firstInterestDate,
    Value<DateTime>? maturityDate,
    Value<int>? expectedMaturityAmountPaise,
    Value<String?>? paymentAccount,
    Value<String?>? notes,
    Value<BondStatus>? status,
    Value<InterestMethod>? interestMethod,
    Value<CompoundingFrequency>? compoundingFrequency,
    Value<DayCountConvention>? dayCountConvention,
    Value<int?>? creditDay,
    Value<int?>? manualInterestPerPeriodPaise,
    Value<bool>? remindersEnabled,
    Value<String>? interestReminderOffsets,
    Value<String>? maturityReminderOffsets,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
  }) {
    return BondsCompanion(
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
      creditDay: creditDay ?? this.creditDay,
      manualInterestPerPeriodPaise:
          manualInterestPerPeriodPaise ?? this.manualInterestPerPeriodPaise,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      interestReminderOffsets:
          interestReminderOffsets ?? this.interestReminderOffsets,
      maturityReminderOffsets:
          maturityReminderOffsets ?? this.maturityReminderOffsets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (issuer.present) {
      map['issuer'] = Variable<String>(issuer.value);
    }
    if (principalPaise.present) {
      map['principal_paise'] = Variable<int>(principalPaise.value);
    }
    if (annualRate.present) {
      map['annual_rate'] = Variable<double>(annualRate.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(
        $BondsTable.$converterfrequency.toSql(frequency.value),
      );
    }
    if (firstInterestDate.present) {
      map['first_interest_date'] = Variable<DateTime>(firstInterestDate.value);
    }
    if (maturityDate.present) {
      map['maturity_date'] = Variable<DateTime>(maturityDate.value);
    }
    if (expectedMaturityAmountPaise.present) {
      map['expected_maturity_amount_paise'] = Variable<int>(
        expectedMaturityAmountPaise.value,
      );
    }
    if (paymentAccount.present) {
      map['payment_account'] = Variable<String>(paymentAccount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $BondsTable.$converterstatus.toSql(status.value),
      );
    }
    if (interestMethod.present) {
      map['interest_method'] = Variable<String>(
        $BondsTable.$converterinterestMethod.toSql(interestMethod.value),
      );
    }
    if (compoundingFrequency.present) {
      map['compounding_frequency'] = Variable<String>(
        $BondsTable.$convertercompoundingFrequency.toSql(
          compoundingFrequency.value,
        ),
      );
    }
    if (dayCountConvention.present) {
      map['day_count_convention'] = Variable<String>(
        $BondsTable.$converterdayCountConvention.toSql(
          dayCountConvention.value,
        ),
      );
    }
    if (creditDay.present) {
      map['credit_day'] = Variable<int>(creditDay.value);
    }
    if (manualInterestPerPeriodPaise.present) {
      map['manual_interest_per_period_paise'] = Variable<int>(
        manualInterestPerPeriodPaise.value,
      );
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (interestReminderOffsets.present) {
      map['interest_reminder_offsets'] = Variable<String>(
        interestReminderOffsets.value,
      );
    }
    if (maturityReminderOffsets.present) {
      map['maturity_reminder_offsets'] = Variable<String>(
        maturityReminderOffsets.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BondsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('issuer: $issuer, ')
          ..write('principalPaise: $principalPaise, ')
          ..write('annualRate: $annualRate, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('frequency: $frequency, ')
          ..write('firstInterestDate: $firstInterestDate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('expectedMaturityAmountPaise: $expectedMaturityAmountPaise, ')
          ..write('paymentAccount: $paymentAccount, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('interestMethod: $interestMethod, ')
          ..write('compoundingFrequency: $compoundingFrequency, ')
          ..write('dayCountConvention: $dayCountConvention, ')
          ..write('creditDay: $creditDay, ')
          ..write(
            'manualInterestPerPeriodPaise: $manualInterestPerPeriodPaise, ',
          )
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('interestReminderOffsets: $interestReminderOffsets, ')
          ..write('maturityReminderOffsets: $maturityReminderOffsets, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class $PaymentTransactionsTable extends PaymentTransactions
    with TableInfo<$PaymentTransactionsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bondIdMeta = const VerificationMeta('bondId');
  @override
  late final GeneratedColumn<int> bondId = GeneratedColumn<int>(
    'bond_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bonds (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES interest_schedules (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidDateMeta = const VerificationMeta(
    'paidDate',
  );
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
    'paid_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentType>($PaymentTransactionsTable.$convertertype);
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bondId,
    scheduleId,
    amountPaise,
    paidDate,
    type,
    reference,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bond_id')) {
      context.handle(
        _bondIdMeta,
        bondId.isAcceptableOrUnknown(data['bond_id']!, _bondIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bondIdMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('paid_date')) {
      context.handle(
        _paidDateMeta,
        paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta),
      );
    } else if (isInserting) {
      context.missing(_paidDateMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bondId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bond_id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
      ),
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      paidDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_date'],
      )!,
      type: $PaymentTransactionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentTransactionsTable createAlias(String alias) {
    return $PaymentTransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentType, String, String> $convertertype =
      const EnumNameConverter<PaymentType>(PaymentType.values);
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final int id;
  final int bondId;
  final int? scheduleId;
  final int amountPaise;
  final DateTime paidDate;
  final PaymentType type;
  final String? reference;
  final String? notes;
  final DateTime createdAt;
  const PaymentRow({
    required this.id,
    required this.bondId,
    this.scheduleId,
    required this.amountPaise,
    required this.paidDate,
    required this.type,
    this.reference,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bond_id'] = Variable<int>(bondId);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = Variable<int>(scheduleId);
    }
    map['amount_paise'] = Variable<int>(amountPaise);
    map['paid_date'] = Variable<DateTime>(paidDate);
    {
      map['type'] = Variable<String>(
        $PaymentTransactionsTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentTransactionsCompanion toCompanion(bool nullToAbsent) {
    return PaymentTransactionsCompanion(
      id: Value(id),
      bondId: Value(bondId),
      scheduleId: scheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleId),
      amountPaise: Value(amountPaise),
      paidDate: Value(paidDate),
      type: Value(type),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<int>(json['id']),
      bondId: serializer.fromJson<int>(json['bondId']),
      scheduleId: serializer.fromJson<int?>(json['scheduleId']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      paidDate: serializer.fromJson<DateTime>(json['paidDate']),
      type: $PaymentTransactionsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      reference: serializer.fromJson<String?>(json['reference']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bondId': serializer.toJson<int>(bondId),
      'scheduleId': serializer.toJson<int?>(scheduleId),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'paidDate': serializer.toJson<DateTime>(paidDate),
      'type': serializer.toJson<String>(
        $PaymentTransactionsTable.$convertertype.toJson(type),
      ),
      'reference': serializer.toJson<String?>(reference),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaymentRow copyWith({
    int? id,
    int? bondId,
    Value<int?> scheduleId = const Value.absent(),
    int? amountPaise,
    DateTime? paidDate,
    PaymentType? type,
    Value<String?> reference = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => PaymentRow(
    id: id ?? this.id,
    bondId: bondId ?? this.bondId,
    scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
    amountPaise: amountPaise ?? this.amountPaise,
    paidDate: paidDate ?? this.paidDate,
    type: type ?? this.type,
    reference: reference.present ? reference.value : this.reference,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  PaymentRow copyWithCompanion(PaymentTransactionsCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      bondId: data.bondId.present ? data.bondId.value : this.bondId,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      type: data.type.present ? data.type.value : this.type,
      reference: data.reference.present ? data.reference.value : this.reference,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('bondId: $bondId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('paidDate: $paidDate, ')
          ..write('type: $type, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bondId,
    scheduleId,
    amountPaise,
    paidDate,
    type,
    reference,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.bondId == this.bondId &&
          other.scheduleId == this.scheduleId &&
          other.amountPaise == this.amountPaise &&
          other.paidDate == this.paidDate &&
          other.type == this.type &&
          other.reference == this.reference &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PaymentTransactionsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<int> id;
  final Value<int> bondId;
  final Value<int?> scheduleId;
  final Value<int> amountPaise;
  final Value<DateTime> paidDate;
  final Value<PaymentType> type;
  final Value<String?> reference;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const PaymentTransactionsCompanion({
    this.id = const Value.absent(),
    this.bondId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.type = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PaymentTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int bondId,
    this.scheduleId = const Value.absent(),
    required int amountPaise,
    required DateTime paidDate,
    required PaymentType type,
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
  }) : bondId = Value(bondId),
       amountPaise = Value(amountPaise),
       paidDate = Value(paidDate),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<PaymentRow> custom({
    Expression<int>? id,
    Expression<int>? bondId,
    Expression<int>? scheduleId,
    Expression<int>? amountPaise,
    Expression<DateTime>? paidDate,
    Expression<String>? type,
    Expression<String>? reference,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bondId != null) 'bond_id': bondId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (paidDate != null) 'paid_date': paidDate,
      if (type != null) 'type': type,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PaymentTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? bondId,
    Value<int?>? scheduleId,
    Value<int>? amountPaise,
    Value<DateTime>? paidDate,
    Value<PaymentType>? type,
    Value<String?>? reference,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return PaymentTransactionsCompanion(
      id: id ?? this.id,
      bondId: bondId ?? this.bondId,
      scheduleId: scheduleId ?? this.scheduleId,
      amountPaise: amountPaise ?? this.amountPaise,
      paidDate: paidDate ?? this.paidDate,
      type: type ?? this.type,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bondId.present) {
      map['bond_id'] = Variable<int>(bondId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $PaymentTransactionsTable.$convertertype.toSql(type.value),
      );
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('bondId: $bondId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('paidDate: $paidDate, ')
          ..write('type: $type, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $InterestSchedulesTable extends InterestSchedules
    with TableInfo<$InterestSchedulesTable, ScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterestSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bondIdMeta = const VerificationMeta('bondId');
  @override
  late final GeneratedColumn<int> bondId = GeneratedColumn<int>(
    'bond_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bonds (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta(
    'periodEnd',
  );
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
    'period_end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedInterestPaiseMeta =
      const VerificationMeta('expectedInterestPaise');
  @override
  late final GeneratedColumn<int> expectedInterestPaise = GeneratedColumn<int>(
    'expected_interest_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedPaiseMeta = const VerificationMeta(
    'receivedPaise',
  );
  @override
  late final GeneratedColumn<int> receivedPaise = GeneratedColumn<int>(
    'received_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<ScheduleStatus>($InterestSchedulesTable.$converterstatus);
  static const VerificationMeta _paidDateMeta = const VerificationMeta(
    'paidDate',
  );
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
    'paid_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<int> paymentId = GeneratedColumn<int>(
    'payment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payment_transactions (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bondId,
    dueDate,
    periodStart,
    periodEnd,
    expectedInterestPaise,
    receivedPaise,
    status,
    paidDate,
    paymentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interest_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bond_id')) {
      context.handle(
        _bondIdMeta,
        bondId.isAcceptableOrUnknown(data['bond_id']!, _bondIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bondIdMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(
        _periodEndMeta,
        periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta),
      );
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('expected_interest_paise')) {
      context.handle(
        _expectedInterestPaiseMeta,
        expectedInterestPaise.isAcceptableOrUnknown(
          data['expected_interest_paise']!,
          _expectedInterestPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedInterestPaiseMeta);
    }
    if (data.containsKey('received_paise')) {
      context.handle(
        _receivedPaiseMeta,
        receivedPaise.isAcceptableOrUnknown(
          data['received_paise']!,
          _receivedPaiseMeta,
        ),
      );
    }
    if (data.containsKey('paid_date')) {
      context.handle(
        _paidDateMeta,
        paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta),
      );
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bondId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bond_id'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
      periodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_end'],
      )!,
      expectedInterestPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_interest_paise'],
      )!,
      receivedPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_paise'],
      )!,
      status: $InterestSchedulesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      paidDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_date'],
      ),
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_id'],
      ),
    );
  }

  @override
  $InterestSchedulesTable createAlias(String alias) {
    return $InterestSchedulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ScheduleStatus, String, String> $converterstatus =
      const EnumNameConverter<ScheduleStatus>(ScheduleStatus.values);
}

class ScheduleRow extends DataClass implements Insertable<ScheduleRow> {
  final int id;
  final int bondId;
  final DateTime dueDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int expectedInterestPaise;
  final int receivedPaise;
  final ScheduleStatus status;
  final DateTime? paidDate;
  final int? paymentId;
  const ScheduleRow({
    required this.id,
    required this.bondId,
    required this.dueDate,
    required this.periodStart,
    required this.periodEnd,
    required this.expectedInterestPaise,
    required this.receivedPaise,
    required this.status,
    this.paidDate,
    this.paymentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bond_id'] = Variable<int>(bondId);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['period_end'] = Variable<DateTime>(periodEnd);
    map['expected_interest_paise'] = Variable<int>(expectedInterestPaise);
    map['received_paise'] = Variable<int>(receivedPaise);
    {
      map['status'] = Variable<String>(
        $InterestSchedulesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || paidDate != null) {
      map['paid_date'] = Variable<DateTime>(paidDate);
    }
    if (!nullToAbsent || paymentId != null) {
      map['payment_id'] = Variable<int>(paymentId);
    }
    return map;
  }

  InterestSchedulesCompanion toCompanion(bool nullToAbsent) {
    return InterestSchedulesCompanion(
      id: Value(id),
      bondId: Value(bondId),
      dueDate: Value(dueDate),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      expectedInterestPaise: Value(expectedInterestPaise),
      receivedPaise: Value(receivedPaise),
      status: Value(status),
      paidDate: paidDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paidDate),
      paymentId: paymentId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentId),
    );
  }

  factory ScheduleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleRow(
      id: serializer.fromJson<int>(json['id']),
      bondId: serializer.fromJson<int>(json['bondId']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime>(json['periodEnd']),
      expectedInterestPaise: serializer.fromJson<int>(
        json['expectedInterestPaise'],
      ),
      receivedPaise: serializer.fromJson<int>(json['receivedPaise']),
      status: $InterestSchedulesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      paidDate: serializer.fromJson<DateTime?>(json['paidDate']),
      paymentId: serializer.fromJson<int?>(json['paymentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bondId': serializer.toJson<int>(bondId),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime>(periodEnd),
      'expectedInterestPaise': serializer.toJson<int>(expectedInterestPaise),
      'receivedPaise': serializer.toJson<int>(receivedPaise),
      'status': serializer.toJson<String>(
        $InterestSchedulesTable.$converterstatus.toJson(status),
      ),
      'paidDate': serializer.toJson<DateTime?>(paidDate),
      'paymentId': serializer.toJson<int?>(paymentId),
    };
  }

  ScheduleRow copyWith({
    int? id,
    int? bondId,
    DateTime? dueDate,
    DateTime? periodStart,
    DateTime? periodEnd,
    int? expectedInterestPaise,
    int? receivedPaise,
    ScheduleStatus? status,
    Value<DateTime?> paidDate = const Value.absent(),
    Value<int?> paymentId = const Value.absent(),
  }) => ScheduleRow(
    id: id ?? this.id,
    bondId: bondId ?? this.bondId,
    dueDate: dueDate ?? this.dueDate,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    expectedInterestPaise: expectedInterestPaise ?? this.expectedInterestPaise,
    receivedPaise: receivedPaise ?? this.receivedPaise,
    status: status ?? this.status,
    paidDate: paidDate.present ? paidDate.value : this.paidDate,
    paymentId: paymentId.present ? paymentId.value : this.paymentId,
  );
  ScheduleRow copyWithCompanion(InterestSchedulesCompanion data) {
    return ScheduleRow(
      id: data.id.present ? data.id.value : this.id,
      bondId: data.bondId.present ? data.bondId.value : this.bondId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      expectedInterestPaise: data.expectedInterestPaise.present
          ? data.expectedInterestPaise.value
          : this.expectedInterestPaise,
      receivedPaise: data.receivedPaise.present
          ? data.receivedPaise.value
          : this.receivedPaise,
      status: data.status.present ? data.status.value : this.status,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRow(')
          ..write('id: $id, ')
          ..write('bondId: $bondId, ')
          ..write('dueDate: $dueDate, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('expectedInterestPaise: $expectedInterestPaise, ')
          ..write('receivedPaise: $receivedPaise, ')
          ..write('status: $status, ')
          ..write('paidDate: $paidDate, ')
          ..write('paymentId: $paymentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bondId,
    dueDate,
    periodStart,
    periodEnd,
    expectedInterestPaise,
    receivedPaise,
    status,
    paidDate,
    paymentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleRow &&
          other.id == this.id &&
          other.bondId == this.bondId &&
          other.dueDate == this.dueDate &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.expectedInterestPaise == this.expectedInterestPaise &&
          other.receivedPaise == this.receivedPaise &&
          other.status == this.status &&
          other.paidDate == this.paidDate &&
          other.paymentId == this.paymentId);
}

class InterestSchedulesCompanion extends UpdateCompanion<ScheduleRow> {
  final Value<int> id;
  final Value<int> bondId;
  final Value<DateTime> dueDate;
  final Value<DateTime> periodStart;
  final Value<DateTime> periodEnd;
  final Value<int> expectedInterestPaise;
  final Value<int> receivedPaise;
  final Value<ScheduleStatus> status;
  final Value<DateTime?> paidDate;
  final Value<int?> paymentId;
  const InterestSchedulesCompanion({
    this.id = const Value.absent(),
    this.bondId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.expectedInterestPaise = const Value.absent(),
    this.receivedPaise = const Value.absent(),
    this.status = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.paymentId = const Value.absent(),
  });
  InterestSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int bondId,
    required DateTime dueDate,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int expectedInterestPaise,
    this.receivedPaise = const Value.absent(),
    this.status = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.paymentId = const Value.absent(),
  }) : bondId = Value(bondId),
       dueDate = Value(dueDate),
       periodStart = Value(periodStart),
       periodEnd = Value(periodEnd),
       expectedInterestPaise = Value(expectedInterestPaise);
  static Insertable<ScheduleRow> custom({
    Expression<int>? id,
    Expression<int>? bondId,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<int>? expectedInterestPaise,
    Expression<int>? receivedPaise,
    Expression<String>? status,
    Expression<DateTime>? paidDate,
    Expression<int>? paymentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bondId != null) 'bond_id': bondId,
      if (dueDate != null) 'due_date': dueDate,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (expectedInterestPaise != null)
        'expected_interest_paise': expectedInterestPaise,
      if (receivedPaise != null) 'received_paise': receivedPaise,
      if (status != null) 'status': status,
      if (paidDate != null) 'paid_date': paidDate,
      if (paymentId != null) 'payment_id': paymentId,
    });
  }

  InterestSchedulesCompanion copyWith({
    Value<int>? id,
    Value<int>? bondId,
    Value<DateTime>? dueDate,
    Value<DateTime>? periodStart,
    Value<DateTime>? periodEnd,
    Value<int>? expectedInterestPaise,
    Value<int>? receivedPaise,
    Value<ScheduleStatus>? status,
    Value<DateTime?>? paidDate,
    Value<int?>? paymentId,
  }) {
    return InterestSchedulesCompanion(
      id: id ?? this.id,
      bondId: bondId ?? this.bondId,
      dueDate: dueDate ?? this.dueDate,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      expectedInterestPaise:
          expectedInterestPaise ?? this.expectedInterestPaise,
      receivedPaise: receivedPaise ?? this.receivedPaise,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
      paymentId: paymentId ?? this.paymentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bondId.present) {
      map['bond_id'] = Variable<int>(bondId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (expectedInterestPaise.present) {
      map['expected_interest_paise'] = Variable<int>(
        expectedInterestPaise.value,
      );
    }
    if (receivedPaise.present) {
      map['received_paise'] = Variable<int>(receivedPaise.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $InterestSchedulesTable.$converterstatus.toSql(status.value),
      );
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<int>(paymentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterestSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('bondId: $bondId, ')
          ..write('dueDate: $dueDate, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('expectedInterestPaise: $expectedInterestPaise, ')
          ..write('receivedPaise: $receivedPaise, ')
          ..write('status: $status, ')
          ..write('paidDate: $paidDate, ')
          ..write('paymentId: $paymentId')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, NotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bondIdMeta = const VerificationMeta('bondId');
  @override
  late final GeneratedColumn<int> bondId = GeneratedColumn<int>(
    'bond_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bonds (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppNotificationType, String>
  type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<AppNotificationType>($NotificationsTable.$convertertype);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bondId,
    type,
    title,
    body,
    scheduledAt,
    readAt,
    dedupeKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bond_id')) {
      context.handle(
        _bondIdMeta,
        bondId.isAcceptableOrUnknown(data['bond_id']!, _bondIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dedupeKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bondId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bond_id'],
      ),
      type: $NotificationsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppNotificationType, String, String>
  $convertertype = const EnumNameConverter<AppNotificationType>(
    AppNotificationType.values,
  );
}

class NotificationRow extends DataClass implements Insertable<NotificationRow> {
  final int id;
  final int? bondId;
  final AppNotificationType type;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final DateTime? readAt;
  final String dedupeKey;
  final DateTime createdAt;
  const NotificationRow({
    required this.id,
    this.bondId,
    required this.type,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.readAt,
    required this.dedupeKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || bondId != null) {
      map['bond_id'] = Variable<int>(bondId);
    }
    {
      map['type'] = Variable<String>(
        $NotificationsTable.$convertertype.toSql(type),
      );
    }
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['dedupe_key'] = Variable<String>(dedupeKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      bondId: bondId == null && nullToAbsent
          ? const Value.absent()
          : Value(bondId),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      scheduledAt: Value(scheduledAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      dedupeKey: Value(dedupeKey),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRow(
      id: serializer.fromJson<int>(json['id']),
      bondId: serializer.fromJson<int?>(json['bondId']),
      type: $NotificationsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bondId': serializer.toJson<int?>(bondId),
      'type': serializer.toJson<String>(
        $NotificationsTable.$convertertype.toJson(type),
      ),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationRow copyWith({
    int? id,
    Value<int?> bondId = const Value.absent(),
    AppNotificationType? type,
    String? title,
    String? body,
    DateTime? scheduledAt,
    Value<DateTime?> readAt = const Value.absent(),
    String? dedupeKey,
    DateTime? createdAt,
  }) => NotificationRow(
    id: id ?? this.id,
    bondId: bondId.present ? bondId.value : this.bondId,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    readAt: readAt.present ? readAt.value : this.readAt,
    dedupeKey: dedupeKey ?? this.dedupeKey,
    createdAt: createdAt ?? this.createdAt,
  );
  NotificationRow copyWithCompanion(NotificationsCompanion data) {
    return NotificationRow(
      id: data.id.present ? data.id.value : this.id,
      bondId: data.bondId.present ? data.bondId.value : this.bondId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('id: $id, ')
          ..write('bondId: $bondId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('readAt: $readAt, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bondId,
    type,
    title,
    body,
    scheduledAt,
    readAt,
    dedupeKey,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.id == this.id &&
          other.bondId == this.bondId &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.scheduledAt == this.scheduledAt &&
          other.readAt == this.readAt &&
          other.dedupeKey == this.dedupeKey &&
          other.createdAt == this.createdAt);
}

class NotificationsCompanion extends UpdateCompanion<NotificationRow> {
  final Value<int> id;
  final Value<int?> bondId;
  final Value<AppNotificationType> type;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> scheduledAt;
  final Value<DateTime?> readAt;
  final Value<String> dedupeKey;
  final Value<DateTime> createdAt;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.bondId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotificationsCompanion.insert({
    this.id = const Value.absent(),
    this.bondId = const Value.absent(),
    required AppNotificationType type,
    required String title,
    required String body,
    required DateTime scheduledAt,
    this.readAt = const Value.absent(),
    required String dedupeKey,
    required DateTime createdAt,
  }) : type = Value(type),
       title = Value(title),
       body = Value(body),
       scheduledAt = Value(scheduledAt),
       dedupeKey = Value(dedupeKey),
       createdAt = Value(createdAt);
  static Insertable<NotificationRow> custom({
    Expression<int>? id,
    Expression<int>? bondId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? readAt,
    Expression<String>? dedupeKey,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bondId != null) 'bond_id': bondId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (readAt != null) 'read_at': readAt,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotificationsCompanion copyWith({
    Value<int>? id,
    Value<int?>? bondId,
    Value<AppNotificationType>? type,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? scheduledAt,
    Value<DateTime?>? readAt,
    Value<String>? dedupeKey,
    Value<DateTime>? createdAt,
  }) {
    return NotificationsCompanion(
      id: id ?? this.id,
      bondId: bondId ?? this.bondId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      readAt: readAt ?? this.readAt,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bondId.present) {
      map['bond_id'] = Variable<int>(bondId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $NotificationsTable.$convertertype.toSql(type.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('bondId: $bondId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('readAt: $readAt, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsEntriesTable extends AppSettingsEntries
    with TableInfo<$AppSettingsEntriesTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsEntriesTable createAlias(String alias) {
    return $AppSettingsEntriesTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(AppSettingsEntriesCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsEntriesCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BondsTable bonds = $BondsTable(this);
  late final $PaymentTransactionsTable paymentTransactions =
      $PaymentTransactionsTable(this);
  late final $InterestSchedulesTable interestSchedules =
      $InterestSchedulesTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $AppSettingsEntriesTable appSettingsEntries =
      $AppSettingsEntriesTable(this);
  late final Index idxBondsStatus = Index(
    'idx_bonds_status',
    'CREATE INDEX idx_bonds_status ON bonds (status)',
  );
  late final Index idxBondsMaturity = Index(
    'idx_bonds_maturity',
    'CREATE INDEX idx_bonds_maturity ON bonds (maturity_date)',
  );
  late final Index idxSchedulesBond = Index(
    'idx_schedules_bond',
    'CREATE INDEX idx_schedules_bond ON interest_schedules (bond_id)',
  );
  late final Index idxSchedulesDue = Index(
    'idx_schedules_due',
    'CREATE INDEX idx_schedules_due ON interest_schedules (due_date)',
  );
  late final Index idxSchedulesStatus = Index(
    'idx_schedules_status',
    'CREATE INDEX idx_schedules_status ON interest_schedules (status)',
  );
  late final Index idxPaymentsBond = Index(
    'idx_payments_bond',
    'CREATE INDEX idx_payments_bond ON payment_transactions (bond_id)',
  );
  late final Index idxPaymentsDate = Index(
    'idx_payments_date',
    'CREATE INDEX idx_payments_date ON payment_transactions (paid_date)',
  );
  late final Index idxNotificationsDedupe = Index(
    'idx_notifications_dedupe',
    'CREATE UNIQUE INDEX idx_notifications_dedupe ON notifications (dedupe_key)',
  );
  late final Index idxNotificationsRead = Index(
    'idx_notifications_read',
    'CREATE INDEX idx_notifications_read ON notifications (read_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bonds,
    paymentTransactions,
    interestSchedules,
    notifications,
    appSettingsEntries,
    idxBondsStatus,
    idxBondsMaturity,
    idxSchedulesBond,
    idxSchedulesDue,
    idxSchedulesStatus,
    idxPaymentsBond,
    idxPaymentsDate,
    idxNotificationsDedupe,
    idxNotificationsRead,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bonds',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payment_transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'interest_schedules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payment_transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bonds',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('interest_schedules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'payment_transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('interest_schedules', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bonds',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('notifications', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BondsTableCreateCompanionBuilder = BondsCompanion Function({
  Value<int> id,
  required String name,
  required String issuer,
  required int principalPaise,
  required double annualRate,
  required DateTime purchaseDate,
  required InterestFrequency frequency,
  required DateTime firstInterestDate,
  required DateTime maturityDate,
  required int expectedMaturityAmountPaise,
  Value<String?> paymentAccount,
  Value<String?> notes,
  Value<BondStatus> status,
  Value<InterestMethod> interestMethod,
  Value<CompoundingFrequency> compoundingFrequency,
  Value<DayCountConvention> dayCountConvention,
  Value<int?> creditDay,
  Value<int?> manualInterestPerPeriodPaise,
  Value<bool> remindersEnabled,
  Value<String> interestReminderOffsets,
  Value<String> maturityReminderOffsets,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> archivedAt,
});
typedef $$BondsTableUpdateCompanionBuilder = BondsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> issuer,
  Value<int> principalPaise,
  Value<double> annualRate,
  Value<DateTime> purchaseDate,
  Value<InterestFrequency> frequency,
  Value<DateTime> firstInterestDate,
  Value<DateTime> maturityDate,
  Value<int> expectedMaturityAmountPaise,
  Value<String?> paymentAccount,
  Value<String?> notes,
  Value<BondStatus> status,
  Value<InterestMethod> interestMethod,
  Value<CompoundingFrequency> compoundingFrequency,
  Value<DayCountConvention> dayCountConvention,
  Value<int?> creditDay,
  Value<int?> manualInterestPerPeriodPaise,
  Value<bool> remindersEnabled,
  Value<String> interestReminderOffsets,
  Value<String> maturityReminderOffsets,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
});

final class $$BondsTableReferences
    extends BaseReferences<_$AppDatabase, $BondsTable, BondRow> {
  $$BondsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PaymentTransactionsTable, List<PaymentRow>>
  _paymentTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentTransactions,
        aliasName: 'bonds__id__payment_transactions__bond_id',
      );

  $$PaymentTransactionsTableProcessedTableManager get paymentTransactionsRefs {
    final manager = $$PaymentTransactionsTableTableManager(
      $_db,
      $_db.paymentTransactions,
    ).filter((f) => f.bondId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InterestSchedulesTable, List<ScheduleRow>>
  _interestSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.interestSchedules,
        aliasName: 'bonds__id__interest_schedules__bond_id',
      );

  $$InterestSchedulesTableProcessedTableManager get interestSchedulesRefs {
    final manager = $$InterestSchedulesTableTableManager(
      $_db,
      $_db.interestSchedules,
    ).filter((f) => f.bondId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _interestSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotificationsTable, List<NotificationRow>>
  _notificationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.notifications,
    aliasName: 'bonds__id__notifications__bond_id',
  );

  $$NotificationsTableProcessedTableManager get notificationsRefs {
    final manager = $$NotificationsTableTableManager(
      $_db,
      $_db.notifications,
    ).filter((f) => f.bondId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notificationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BondsTableFilterComposer extends Composer<_$AppDatabase, $BondsTable> {
  $$BondsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get principalPaise => $composableBuilder(
    column: $table.principalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualRate => $composableBuilder(
    column: $table.annualRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<InterestFrequency, InterestFrequency, String>
  get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get firstInterestDate => $composableBuilder(
    column: $table.firstInterestDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedMaturityAmountPaise => $composableBuilder(
    column: $table.expectedMaturityAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentAccount => $composableBuilder(
    column: $table.paymentAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BondStatus, BondStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<InterestMethod, InterestMethod, String>
  get interestMethod => $composableBuilder(
    column: $table.interestMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    CompoundingFrequency,
    CompoundingFrequency,
    String
  >
  get compoundingFrequency => $composableBuilder(
    column: $table.compoundingFrequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DayCountConvention, DayCountConvention, String>
  get dayCountConvention => $composableBuilder(
    column: $table.dayCountConvention,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get creditDay => $composableBuilder(
    column: $table.creditDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manualInterestPerPeriodPaise => $composableBuilder(
    column: $table.manualInterestPerPeriodPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestReminderOffsets => $composableBuilder(
    column: $table.interestReminderOffsets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maturityReminderOffsets => $composableBuilder(
    column: $table.maturityReminderOffsets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> paymentTransactionsRefs(
    Expression<bool> Function($$PaymentTransactionsTableFilterComposer f) f,
  ) {
    final $$PaymentTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentTransactions,
      getReferencedColumn: (t) => t.bondId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.paymentTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> interestSchedulesRefs(
    Expression<bool> Function($$InterestSchedulesTableFilterComposer f) f,
  ) {
    final $$InterestSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.interestSchedules,
      getReferencedColumn: (t) => t.bondId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InterestSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.interestSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notificationsRefs(
    Expression<bool> Function($$NotificationsTableFilterComposer f) f,
  ) {
    final $$NotificationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notifications,
      getReferencedColumn: (t) => t.bondId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotificationsTableFilterComposer(
            $db: $db,
            $table: $db.notifications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BondsTableOrderingComposer
    extends Composer<_$AppDatabase, $BondsTable> {
  $$BondsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get principalPaise => $composableBuilder(
    column: $table.principalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualRate => $composableBuilder(
    column: $table.annualRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstInterestDate => $composableBuilder(
    column: $table.firstInterestDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedMaturityAmountPaise => $composableBuilder(
    column: $table.expectedMaturityAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentAccount => $composableBuilder(
    column: $table.paymentAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestMethod => $composableBuilder(
    column: $table.interestMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compoundingFrequency => $composableBuilder(
    column: $table.compoundingFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayCountConvention => $composableBuilder(
    column: $table.dayCountConvention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditDay => $composableBuilder(
    column: $table.creditDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manualInterestPerPeriodPaise => $composableBuilder(
    column: $table.manualInterestPerPeriodPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestReminderOffsets => $composableBuilder(
    column: $table.interestReminderOffsets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maturityReminderOffsets => $composableBuilder(
    column: $table.maturityReminderOffsets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BondsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BondsTable> {
  $$BondsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get issuer =>
      $composableBuilder(column: $table.issuer, builder: (column) => column);

  GeneratedColumn<int> get principalPaise => $composableBuilder(
    column: $table.principalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<double> get annualRate => $composableBuilder(
    column: $table.annualRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<InterestFrequency, String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get firstInterestDate => $composableBuilder(
    column: $table.firstInterestDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedMaturityAmountPaise => $composableBuilder(
    column: $table.expectedMaturityAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentAccount => $composableBuilder(
    column: $table.paymentAccount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BondStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<InterestMethod, String> get interestMethod =>
      $composableBuilder(
        column: $table.interestMethod,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<CompoundingFrequency, String>
  get compoundingFrequency => $composableBuilder(
    column: $table.compoundingFrequency,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DayCountConvention, String>
  get dayCountConvention => $composableBuilder(
    column: $table.dayCountConvention,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditDay =>
      $composableBuilder(column: $table.creditDay, builder: (column) => column);

  GeneratedColumn<int> get manualInterestPerPeriodPaise => $composableBuilder(
    column: $table.manualInterestPerPeriodPaise,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interestReminderOffsets => $composableBuilder(
    column: $table.interestReminderOffsets,
    builder: (column) => column,
  );

  GeneratedColumn<String> get maturityReminderOffsets => $composableBuilder(
    column: $table.maturityReminderOffsets,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> paymentTransactionsRefs<T extends Object>(
    Expression<T> Function($$PaymentTransactionsTableAnnotationComposer a) f,
  ) {
    final $$PaymentTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paymentTransactions,
          getReferencedColumn: (t) => t.bondId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.paymentTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> interestSchedulesRefs<T extends Object>(
    Expression<T> Function($$InterestSchedulesTableAnnotationComposer a) f,
  ) {
    final $$InterestSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.interestSchedules,
          getReferencedColumn: (t) => t.bondId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InterestSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.interestSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> notificationsRefs<T extends Object>(
    Expression<T> Function($$NotificationsTableAnnotationComposer a) f,
  ) {
    final $$NotificationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notifications,
      getReferencedColumn: (t) => t.bondId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotificationsTableAnnotationComposer(
            $db: $db,
            $table: $db.notifications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BondsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BondsTable,
          BondRow,
          $$BondsTableFilterComposer,
          $$BondsTableOrderingComposer,
          $$BondsTableAnnotationComposer,
          $$BondsTableCreateCompanionBuilder,
          $$BondsTableUpdateCompanionBuilder,
          (BondRow, $$BondsTableReferences),
          BondRow,
          PrefetchHooks Function({
            bool paymentTransactionsRefs,
            bool interestSchedulesRefs,
            bool notificationsRefs,
          })
        > {
  $$BondsTableTableManager(_$AppDatabase db, $BondsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BondsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BondsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BondsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> issuer = const Value.absent(),
                Value<int> principalPaise = const Value.absent(),
                Value<double> annualRate = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<InterestFrequency> frequency = const Value.absent(),
                Value<DateTime> firstInterestDate = const Value.absent(),
                Value<DateTime> maturityDate = const Value.absent(),
                Value<int> expectedMaturityAmountPaise = const Value.absent(),
                Value<String?> paymentAccount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<BondStatus> status = const Value.absent(),
                Value<InterestMethod> interestMethod = const Value.absent(),
                Value<CompoundingFrequency> compoundingFrequency =
                    const Value.absent(),
                Value<DayCountConvention> dayCountConvention =
                    const Value.absent(),
                Value<int?> creditDay = const Value.absent(),
                Value<int?> manualInterestPerPeriodPaise = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<String> interestReminderOffsets = const Value.absent(),
                Value<String> maturityReminderOffsets = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => BondsCompanion(
                id: id,
                name: name,
                issuer: issuer,
                principalPaise: principalPaise,
                annualRate: annualRate,
                purchaseDate: purchaseDate,
                frequency: frequency,
                firstInterestDate: firstInterestDate,
                maturityDate: maturityDate,
                expectedMaturityAmountPaise: expectedMaturityAmountPaise,
                paymentAccount: paymentAccount,
                notes: notes,
                status: status,
                interestMethod: interestMethod,
                compoundingFrequency: compoundingFrequency,
                dayCountConvention: dayCountConvention,
                creditDay: creditDay,
                manualInterestPerPeriodPaise: manualInterestPerPeriodPaise,
                remindersEnabled: remindersEnabled,
                interestReminderOffsets: interestReminderOffsets,
                maturityReminderOffsets: maturityReminderOffsets,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String issuer,
                required int principalPaise,
                required double annualRate,
                required DateTime purchaseDate,
                required InterestFrequency frequency,
                required DateTime firstInterestDate,
                required DateTime maturityDate,
                required int expectedMaturityAmountPaise,
                Value<String?> paymentAccount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<BondStatus> status = const Value.absent(),
                Value<InterestMethod> interestMethod = const Value.absent(),
                Value<CompoundingFrequency> compoundingFrequency =
                    const Value.absent(),
                Value<DayCountConvention> dayCountConvention =
                    const Value.absent(),
                Value<int?> creditDay = const Value.absent(),
                Value<int?> manualInterestPerPeriodPaise = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<String> interestReminderOffsets = const Value.absent(),
                Value<String> maturityReminderOffsets = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => BondsCompanion.insert(
                id: id,
                name: name,
                issuer: issuer,
                principalPaise: principalPaise,
                annualRate: annualRate,
                purchaseDate: purchaseDate,
                frequency: frequency,
                firstInterestDate: firstInterestDate,
                maturityDate: maturityDate,
                expectedMaturityAmountPaise: expectedMaturityAmountPaise,
                paymentAccount: paymentAccount,
                notes: notes,
                status: status,
                interestMethod: interestMethod,
                compoundingFrequency: compoundingFrequency,
                dayCountConvention: dayCountConvention,
                creditDay: creditDay,
                manualInterestPerPeriodPaise: manualInterestPerPeriodPaise,
                remindersEnabled: remindersEnabled,
                interestReminderOffsets: interestReminderOffsets,
                maturityReminderOffsets: maturityReminderOffsets,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BondsTable, BondRow>(table),
                  $$BondsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                paymentTransactionsRefs = false,
                interestSchedulesRefs = false,
                notificationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentTransactionsRefs) db.paymentTransactions,
                    if (interestSchedulesRefs) db.interestSchedules,
                    if (notificationsRefs) db.notifications,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentTransactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          BondRow,
                          $BondsTable,
                          PaymentRow,
                          $PaymentTransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BondsTableReferences
                              ._paymentTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BondsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentTransactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'bond_id',
                          typedResults: items,
                        ),
                      if (interestSchedulesRefs)
                        await $_getPrefetchedDataByColumns<
                          BondRow,
                          $BondsTable,
                          ScheduleRow,
                          $InterestSchedulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$BondsTableReferences
                              ._interestSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BondsTableReferences(
                                db,
                                table,
                                p0,
                              ).interestSchedulesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'bond_id',
                          typedResults: items,
                        ),
                      if (notificationsRefs)
                        await $_getPrefetchedDataByColumns<
                          BondRow,
                          $BondsTable,
                          NotificationRow,
                          $NotificationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BondsTableReferences
                              ._notificationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BondsTableReferences(
                                db,
                                table,
                                p0,
                              ).notificationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'bond_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BondsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BondsTable,
      BondRow,
      $$BondsTableFilterComposer,
      $$BondsTableOrderingComposer,
      $$BondsTableAnnotationComposer,
      $$BondsTableCreateCompanionBuilder,
      $$BondsTableUpdateCompanionBuilder,
      (BondRow, $$BondsTableReferences),
      BondRow,
      PrefetchHooks Function({
        bool paymentTransactionsRefs,
        bool interestSchedulesRefs,
        bool notificationsRefs,
      })
    >;
typedef $$PaymentTransactionsTableCreateCompanionBuilder =
    PaymentTransactionsCompanion Function({
      Value<int> id,
      required int bondId,
      Value<int?> scheduleId,
      required int amountPaise,
      required DateTime paidDate,
      required PaymentType type,
      Value<String?> reference,
      Value<String?> notes,
      required DateTime createdAt,
    });
typedef $$PaymentTransactionsTableUpdateCompanionBuilder =
    PaymentTransactionsCompanion Function({
      Value<int> id,
      Value<int> bondId,
      Value<int?> scheduleId,
      Value<int> amountPaise,
      Value<DateTime> paidDate,
      Value<PaymentType> type,
      Value<String?> reference,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$PaymentTransactionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PaymentTransactionsTable, PaymentRow> {
  $$PaymentTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BondsTable _bondIdTable(_$AppDatabase db) =>
      db.bonds.createAlias('payment_transactions__bond_id__bonds__id');

  $$BondsTableProcessedTableManager get bondId {
    final $_column = $_itemColumn<int>('bond_id')!;

    final manager = $$BondsTableTableManager(
      $_db,
      $_db.bonds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bondIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InterestSchedulesTable _scheduleIdTable(_$AppDatabase db) => db
      .interestSchedules
      .createAlias('payment_transactions__schedule_id__interest_schedules__id');

  $$InterestSchedulesTableProcessedTableManager? get scheduleId {
    final $_column = $_itemColumn<int>('schedule_id');
    if ($_column == null) return null;
    final manager = $$InterestSchedulesTableTableManager(
      $_db,
      $_db.interestSchedules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InterestSchedulesTable, List<ScheduleRow>>
  _interestSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.interestSchedules,
        aliasName: 'payment_transactions__id__interest_schedules__payment_id',
      );

  $$InterestSchedulesTableProcessedTableManager get interestSchedulesRefs {
    final manager = $$InterestSchedulesTableTableManager(
      $_db,
      $_db.interestSchedules,
    ).filter((f) => f.paymentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _interestSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentTransactionsTable> {
  $$PaymentTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentType, PaymentType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BondsTableFilterComposer get bondId {
    final $$BondsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bondId,
      referencedTable: $db.bonds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BondsTableFilterComposer(
            $db: $db,
            $table: $db.bonds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InterestSchedulesTableFilterComposer get scheduleId {
    final $$InterestSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.interestSchedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InterestSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.interestSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> interestSchedulesRefs(
    Expression<bool> Function($$InterestSchedulesTableFilterComposer f) f,
  ) {
    final $$InterestSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.interestSchedules,
      getReferencedColumn: (t) => t.paymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InterestSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.interestSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentTransactionsTable> {
  $$PaymentTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BondsTableOrderingComposer get bondId {
    final $$BondsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bondId,
      referencedTable: $db.bonds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BondsTableOrderingComposer(
            $db: $db,
            $table: $db.bonds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InterestSchedulesTableOrderingComposer get scheduleId {
    final $$InterestSchedulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.interestSchedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InterestSchedulesTableOrderingComposer(
            $db: $db,
            $table: $db.interestSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentTransactionsTable> {
  $$PaymentTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BondsTableAnnotationComposer get bondId {
    final $$BondsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bondId,
      referencedTable: $db.bonds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BondsTableAnnotationComposer(
            $db: $db,
            $table: $db.bonds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InterestSchedulesTableAnnotationComposer get scheduleId {
    final $$InterestSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleId,
          referencedTable: $db.interestSchedules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InterestSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.interestSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> interestSchedulesRefs<T extends Object>(
    Expression<T> Function($$InterestSchedulesTableAnnotationComposer a) f,
  ) {
    final $$InterestSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.interestSchedules,
          getReferencedColumn: (t) => t.paymentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InterestSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.interestSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PaymentTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentTransactionsTable,
          PaymentRow,
          $$PaymentTransactionsTableFilterComposer,
          $$PaymentTransactionsTableOrderingComposer,
          $$PaymentTransactionsTableAnnotationComposer,
          $$PaymentTransactionsTableCreateCompanionBuilder,
          $$PaymentTransactionsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentTransactionsTableReferences),
          PaymentRow,
          PrefetchHooks Function({
            bool bondId,
            bool scheduleId,
            bool interestSchedulesRefs,
          })
        > {
  $$PaymentTransactionsTableTableManager(
    _$AppDatabase db,
    $PaymentTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PaymentTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bondId = const Value.absent(),
                Value<int?> scheduleId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime> paidDate = const Value.absent(),
                Value<PaymentType> type = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentTransactionsCompanion(
                id: id,
                bondId: bondId,
                scheduleId: scheduleId,
                amountPaise: amountPaise,
                paidDate: paidDate,
                type: type,
                reference: reference,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bondId,
                Value<int?> scheduleId = const Value.absent(),
                required int amountPaise,
                required DateTime paidDate,
                required PaymentType type,
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
              }) => PaymentTransactionsCompanion.insert(
                id: id,
                bondId: bondId,
                scheduleId: scheduleId,
                amountPaise: amountPaise,
                paidDate: paidDate,
                type: type,
                reference: reference,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentTransactionsTable, PaymentRow>(table),
                  $$PaymentTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                bondId = false,
                scheduleId = false,
                interestSchedulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (interestSchedulesRefs) db.interestSchedules,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bondId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bondId,
                            referencedTable:
                                $$PaymentTransactionsTableReferences
                                    ._bondIdTable(db),
                            referencedColumn:
                                $$PaymentTransactionsTableReferences
                                    ._bondIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (scheduleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.scheduleId,
                            referencedTable:
                                $$PaymentTransactionsTableReferences
                                    ._scheduleIdTable(db),
                            referencedColumn:
                                $$PaymentTransactionsTableReferences
                                    ._scheduleIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (interestSchedulesRefs)
                        await $_getPrefetchedDataByColumns<
                          PaymentRow,
                          $PaymentTransactionsTable,
                          ScheduleRow,
                          $InterestSchedulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentTransactionsTableReferences
                              ._interestSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentTransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).interestSchedulesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'payment_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PaymentTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentTransactionsTable,
      PaymentRow,
      $$PaymentTransactionsTableFilterComposer,
      $$PaymentTransactionsTableOrderingComposer,
      $$PaymentTransactionsTableAnnotationComposer,
      $$PaymentTransactionsTableCreateCompanionBuilder,
      $$PaymentTransactionsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentTransactionsTableReferences),
      PaymentRow,
      PrefetchHooks Function({
        bool bondId,
        bool scheduleId,
        bool interestSchedulesRefs,
      })
    >;
typedef $$InterestSchedulesTableCreateCompanionBuilder =
    InterestSchedulesCompanion Function({
      Value<int> id,
      required int bondId,
      required DateTime dueDate,
      required DateTime periodStart,
      required DateTime periodEnd,
      required int expectedInterestPaise,
      Value<int> receivedPaise,
      Value<ScheduleStatus> status,
      Value<DateTime?> paidDate,
      Value<int?> paymentId,
    });
typedef $$InterestSchedulesTableUpdateCompanionBuilder =
    InterestSchedulesCompanion Function({
      Value<int> id,
      Value<int> bondId,
      Value<DateTime> dueDate,
      Value<DateTime> periodStart,
      Value<DateTime> periodEnd,
      Value<int> expectedInterestPaise,
      Value<int> receivedPaise,
      Value<ScheduleStatus> status,
      Value<DateTime?> paidDate,
      Value<int?> paymentId,
    });

final class $$InterestSchedulesTableReferences
    extends
        BaseReferences<_$AppDatabase, $InterestSchedulesTable, ScheduleRow> {
  $$InterestSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BondsTable _bondIdTable(_$AppDatabase db) =>
      db.bonds.createAlias('interest_schedules__bond_id__bonds__id');

  $$BondsTableProcessedTableManager get bondId {
    final $_column = $_itemColumn<int>('bond_id')!;

    final manager = $$BondsTableTableManager(
      $_db,
      $_db.bonds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bondIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PaymentTransactionsTable _paymentIdTable(_$AppDatabase db) => db
      .paymentTransactions
      .createAlias('interest_schedules__payment_id__payment_transactions__id');

  $$PaymentTransactionsTableProcessedTableManager? get paymentId {
    final $_column = $_itemColumn<int>('payment_id');
    if ($_column == null) return null;
    final manager = $$PaymentTransactionsTableTableManager(
      $_db,
      $_db.paymentTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentTransactionsTable, List<PaymentRow>>
  _paymentTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentTransactions,
        aliasName: 'interest_schedules__id__payment_transactions__schedule_id',
      );

  $$PaymentTransactionsTableProcessedTableManager get paymentTransactionsRefs {
    final manager = $$PaymentTransactionsTableTableManager(
      $_db,
      $_db.paymentTransactions,
    ).filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InterestSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $InterestSchedulesTable> {
  $$InterestSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedInterestPaise => $composableBuilder(
    column: $table.expectedInterestPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedPaise => $composableBuilder(
    column: $table.receivedPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ScheduleStatus, ScheduleStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnFilters(column),
  );

  $$BondsTableFilterComposer get bondId {
    final $$BondsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bondId,
      referencedTable: $db.bonds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BondsTableFilterComposer(
            $db: $db,
            $table: $db.bonds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentTransactionsTableFilterComposer get paymentId {
    final $$PaymentTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.paymentTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.paymentTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentTransactionsRefs(
    Expression<bool> Function($$PaymentTransactionsTableFilterComposer f) f,
  ) {
    final $$PaymentTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentTransactions,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.paymentTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InterestSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $InterestSchedulesTable> {
  $$InterestSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedInterestPaise => $composableBuilder(
    column: $table.expectedInterestPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedPaise => $composableBuilder(
    column: $table.receivedPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$BondsTableOrderingComposer get bondId {
    final $$BondsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bondId,
      referencedTable: $db.bonds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BondsTableOrderingComposer(
            $db: $db,
            $table: $db.bonds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentTransactionsTableOrderingComposer get paymentId {
    final $$PaymentTransactionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.paymentId,
          referencedTable: $db.paymentTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentTransactionsTableOrderingComposer(
                $db: $db,
                $table: $db.paymentTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$InterestSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InterestSchedulesTable> {
  $$InterestSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<int> get expectedInterestPaise => $composableBuilder(
    column: $table.expectedInterestPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receivedPaise => $composableBuilder(
    column: $table.receivedPaise,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ScheduleStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  $$BondsTableAnnotationComposer get bondId {
    final $$BondsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bondId,
      referencedTable: $db.bonds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BondsTableAnnotationComposer(
            $db: $db,
            $table: $db.bonds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentTransactionsTableAnnotationComposer get paymentId {
    final $$PaymentTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.paymentId,
          referencedTable: $db.paymentTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.paymentTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> paymentTransactionsRefs<T extends Object>(
    Expression<T> Function($$PaymentTransactionsTableAnnotationComposer a) f,
  ) {
    final $$PaymentTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paymentTransactions,
          getReferencedColumn: (t) => t.scheduleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.paymentTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InterestSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InterestSchedulesTable,
          ScheduleRow,
          $$InterestSchedulesTableFilterComposer,
          $$InterestSchedulesTableOrderingComposer,
          $$InterestSchedulesTableAnnotationComposer,
          $$InterestSchedulesTableCreateCompanionBuilder,
          $$InterestSchedulesTableUpdateCompanionBuilder,
          (ScheduleRow, $$InterestSchedulesTableReferences),
          ScheduleRow,
          PrefetchHooks Function({
            bool bondId,
            bool paymentId,
            bool paymentTransactionsRefs,
          })
        > {
  $$InterestSchedulesTableTableManager(
    _$AppDatabase db,
    $InterestSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterestSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InterestSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InterestSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bondId = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
                Value<DateTime> periodEnd = const Value.absent(),
                Value<int> expectedInterestPaise = const Value.absent(),
                Value<int> receivedPaise = const Value.absent(),
                Value<ScheduleStatus> status = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<int?> paymentId = const Value.absent(),
              }) => InterestSchedulesCompanion(
                id: id,
                bondId: bondId,
                dueDate: dueDate,
                periodStart: periodStart,
                periodEnd: periodEnd,
                expectedInterestPaise: expectedInterestPaise,
                receivedPaise: receivedPaise,
                status: status,
                paidDate: paidDate,
                paymentId: paymentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bondId,
                required DateTime dueDate,
                required DateTime periodStart,
                required DateTime periodEnd,
                required int expectedInterestPaise,
                Value<int> receivedPaise = const Value.absent(),
                Value<ScheduleStatus> status = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<int?> paymentId = const Value.absent(),
              }) => InterestSchedulesCompanion.insert(
                id: id,
                bondId: bondId,
                dueDate: dueDate,
                periodStart: periodStart,
                periodEnd: periodEnd,
                expectedInterestPaise: expectedInterestPaise,
                receivedPaise: receivedPaise,
                status: status,
                paidDate: paidDate,
                paymentId: paymentId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InterestSchedulesTable, ScheduleRow>(table),
                  $$InterestSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                bondId = false,
                paymentId = false,
                paymentTransactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentTransactionsRefs) db.paymentTransactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bondId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bondId,
                            referencedTable: $$InterestSchedulesTableReferences
                                ._bondIdTable(db),
                            referencedColumn: $$InterestSchedulesTableReferences
                                ._bondIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (paymentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.paymentId,
                            referencedTable: $$InterestSchedulesTableReferences
                                ._paymentIdTable(db),
                            referencedColumn: $$InterestSchedulesTableReferences
                                ._paymentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentTransactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          ScheduleRow,
                          $InterestSchedulesTable,
                          PaymentRow,
                          $PaymentTransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$InterestSchedulesTableReferences
                              ._paymentTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InterestSchedulesTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentTransactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'schedule_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InterestSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InterestSchedulesTable,
      ScheduleRow,
      $$InterestSchedulesTableFilterComposer,
      $$InterestSchedulesTableOrderingComposer,
      $$InterestSchedulesTableAnnotationComposer,
      $$InterestSchedulesTableCreateCompanionBuilder,
      $$InterestSchedulesTableUpdateCompanionBuilder,
      (ScheduleRow, $$InterestSchedulesTableReferences),
      ScheduleRow,
      PrefetchHooks Function({
        bool bondId,
        bool paymentId,
        bool paymentTransactionsRefs,
      })
    >;
typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      Value<int> id,
      Value<int?> bondId,
      required AppNotificationType type,
      required String title,
      required String body,
      required DateTime scheduledAt,
      Value<DateTime?> readAt,
      required String dedupeKey,
      required DateTime createdAt,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      Value<int> id,
      Value<int?> bondId,
      Value<AppNotificationType> type,
      Value<String> title,
      Value<String> body,
      Value<DateTime> scheduledAt,
      Value<DateTime?> readAt,
      Value<String> dedupeKey,
      Value<DateTime> createdAt,
    });

final class $$NotificationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $NotificationsTable, NotificationRow> {
  $$NotificationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BondsTable _bondIdTable(_$AppDatabase db) =>
      db.bonds.createAlias('notifications__bond_id__bonds__id');

  $$BondsTableProcessedTableManager? get bondId {
    final $_column = $_itemColumn<int>('bond_id');
    if ($_column == null) return null;
    final manager = $$BondsTableTableManager(
      $_db,
      $_db.bonds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bondIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    AppNotificationType,
    AppNotificationType,
    String
  >
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BondsTableFilterComposer get bondId {
    final $$BondsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bondId,
      referencedTable: $db.bonds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BondsTableFilterComposer(
            $db: $db,
            $table: $db.bonds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BondsTableOrderingComposer get bondId {
    final $$BondsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bondId,
      referencedTable: $db.bonds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BondsTableOrderingComposer(
            $db: $db,
            $table: $db.bonds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppNotificationType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BondsTableAnnotationComposer get bondId {
    final $$BondsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bondId,
      referencedTable: $db.bonds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BondsTableAnnotationComposer(
            $db: $db,
            $table: $db.bonds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsTable,
          NotificationRow,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (NotificationRow, $$NotificationsTableReferences),
          NotificationRow,
          PrefetchHooks Function({bool bondId})
        > {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> bondId = const Value.absent(),
                Value<AppNotificationType> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NotificationsCompanion(
                id: id,
                bondId: bondId,
                type: type,
                title: title,
                body: body,
                scheduledAt: scheduledAt,
                readAt: readAt,
                dedupeKey: dedupeKey,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> bondId = const Value.absent(),
                required AppNotificationType type,
                required String title,
                required String body,
                required DateTime scheduledAt,
                Value<DateTime?> readAt = const Value.absent(),
                required String dedupeKey,
                required DateTime createdAt,
              }) => NotificationsCompanion.insert(
                id: id,
                bondId: bondId,
                type: type,
                title: title,
                body: body,
                scheduledAt: scheduledAt,
                readAt: readAt,
                dedupeKey: dedupeKey,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotificationsTable, NotificationRow>(table),
                  $$NotificationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bondId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bondId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bondId,
                        referencedTable: $$NotificationsTableReferences
                            ._bondIdTable(db),
                        referencedColumn: $$NotificationsTableReferences
                            ._bondIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsTable,
      NotificationRow,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (NotificationRow, $$NotificationsTableReferences),
      NotificationRow,
      PrefetchHooks Function({bool bondId})
    >;
typedef $$AppSettingsEntriesTableCreateCompanionBuilder =
    AppSettingsEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsEntriesTableUpdateCompanionBuilder =
    AppSettingsEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsEntriesTable,
          SettingRow,
          $$AppSettingsEntriesTableFilterComposer,
          $$AppSettingsEntriesTableOrderingComposer,
          $$AppSettingsEntriesTableAnnotationComposer,
          $$AppSettingsEntriesTableCreateCompanionBuilder,
          $$AppSettingsEntriesTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsEntriesTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsEntriesTableTableManager(
    _$AppDatabase db,
    $AppSettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsEntriesTable, SettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsEntriesTable,
                    SettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsEntriesTable,
      SettingRow,
      $$AppSettingsEntriesTableFilterComposer,
      $$AppSettingsEntriesTableOrderingComposer,
      $$AppSettingsEntriesTableAnnotationComposer,
      $$AppSettingsEntriesTableCreateCompanionBuilder,
      $$AppSettingsEntriesTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsEntriesTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BondsTableTableManager get bonds =>
      $$BondsTableTableManager(_db, _db.bonds);
  $$PaymentTransactionsTableTableManager get paymentTransactions =>
      $$PaymentTransactionsTableTableManager(_db, _db.paymentTransactions);
  $$InterestSchedulesTableTableManager get interestSchedules =>
      $$InterestSchedulesTableTableManager(_db, _db.interestSchedules);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$AppSettingsEntriesTableTableManager get appSettingsEntries =>
      $$AppSettingsEntriesTableTableManager(_db, _db.appSettingsEntries);
}
