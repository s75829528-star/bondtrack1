import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bondtrack/data/database/app_database.dart';
import 'package:bondtrack/domain/entities/app_notification.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/services/bond_identity.dart';

enum RestoreMode { replace, merge }

class RestoreResult {
  const RestoreResult({
    required this.bondsImported,
    required this.schedulesImported,
    required this.paymentsImported,
    required this.duplicatesSkipped,
    required this.mode,
  });

  final int bondsImported;
  final int schedulesImported;
  final int paymentsImported;
  final int duplicatesSkipped;
  final RestoreMode mode;
}

class LocalBackupFile {
  const LocalBackupFile({
    required this.path,
    required this.name,
    required this.createdAt,
    required this.sizeBytes,
  });

  final String path;
  final String name;
  final DateTime createdAt;
  final int sizeBytes;
}

/// Backup, restore and encryption service. The JSON envelope is versioned so
/// future schema changes remain readable. Encrypted backups use
/// PBKDF2-HMAC-SHA256 (150,000 iterations) and AES-256-GCM.
class BackupRestoreService {
  BackupRestoreService(this._db);

  final AppDatabase _db;

  static const _iterations = 150000;

  Future<Uint8List> createBackup({String? password}) async {
    final payload = await _payload();
    final json = const JsonEncoder.withIndent('  ').convert(payload);
    if (password == null || password.isEmpty) {
      return Uint8List.fromList(utf8.encode(json));
    }
    return _encrypt(json, password);
  }

  /// Creates a snapshot in the app's private documents directory. These files
  /// are included in Android auto-backup only if the user enables it.
  Future<LocalBackupFile> createLocalBackup({String? password}) async {
    final bytes = await createBackup(password: password);
    final directory = await _backupDirectory();
    final now = DateTime.now();
    final name =
        'bondtrack-local-${now.year}${_two(now.month)}${_two(now.day)}-'
        '${_two(now.hour)}${_two(now.minute)}${_two(now.second)}.json';
    final file = File('${directory.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return LocalBackupFile(
      path: file.path,
      name: name,
      createdAt: now,
      sizeBytes: bytes.length,
    );
  }

  Future<List<LocalBackupFile>> listLocalBackups() async {
    final directory = await _backupDirectory();
    final files = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .cast<File>()
        .toList();
    final result = <LocalBackupFile>[];
    for (final file in files) {
      final stat = await file.stat();
      result.add(
        LocalBackupFile(
          path: file.path,
          name: file.uri.pathSegments.last,
          createdAt: stat.modified,
          sizeBytes: stat.size,
        ),
      );
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<RestoreResult> restoreLocalBackup(
    String path, {
    String? password,
    RestoreMode mode = RestoreMode.replace,
  }) async {
    final bytes = await File(path).readAsBytes();
    return restore(bytes, password: password, mode: mode);
  }

  Future<RestoreResult> restore(
    Uint8List bytes, {
    String? password,
    RestoreMode mode = RestoreMode.replace,
  }) async {
    var decodedBytes = bytes;
    try {
      final preview = jsonDecode(utf8.decode(bytes));
      if (preview is Map && preview['format'] == 'bondtrack-encrypted-backup') {
        if (password == null || password.isEmpty) {
          throw const FormatException(
            'This backup is encrypted. Enter the password used when it was created.',
          );
        }
        decodedBytes = await _decrypt(
          preview.cast<String, dynamic>(),
          password,
        );
      }
    } on FormatException {
      rethrow;
    } catch (_) {
      // Not JSON or not an encrypted envelope; the normal parser below will
      // produce a precise error.
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(decodedBytes));
    } catch (_) {
      throw const FormatException('This is not a valid BondTrack backup.');
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != 'bondtrack-backup') {
      throw const FormatException('Unsupported or invalid backup format.');
    }
    final version = decoded['version'];
    if (version is! int || version < 1 || version > 2) {
      throw const FormatException('Unsupported backup version.');
    }
    final bondRecords = _records(decoded['bonds'], 'bonds');
    final scheduleRecords = _records(decoded['schedules'], 'schedules');
    final paymentRecords = _records(decoded['payments'], 'payments');
    final notificationRecords = _records(
      decoded['notifications'] ?? const [],
      'notifications',
    );
    final settings = decoded['settings'];
    if (settings is! Map) {
      throw const FormatException('The backup settings section is invalid.');
    }
    _validateBackup(
      bondRecords,
      scheduleRecords,
      paymentRecords,
      notificationRecords,
    );

    return mode == RestoreMode.replace
        ? _replace(
            bondRecords,
            scheduleRecords,
            paymentRecords,
            notificationRecords,
            settings,
          )
        : _merge(
            bondRecords,
            scheduleRecords,
            paymentRecords,
            notificationRecords,
            settings,
          );
  }

  Future<RestoreResult> _replace(
    List<Map<String, dynamic>> bonds,
    List<Map<String, dynamic>> schedules,
    List<Map<String, dynamic>> payments,
    List<Map<String, dynamic>> notifications,
    Map settings,
  ) async {
    await _db.transaction(() async {
      await _db.delete(_db.paymentTransactions).go();
      await _db.delete(_db.notifications).go();
      await _db.delete(_db.interestSchedules).go();
      await _db.delete(_db.bonds).go();
      await _db.delete(_db.appSettingsEntries).go();

      await _db.batch((batch) {
        batch.insertAll(_db.bonds, bonds.map(_bondCompanion).toList());
        batch.insertAll(
          _db.interestSchedules,
          schedules
              .map((record) => _scheduleCompanion(record, clearPaymentId: true))
              .toList(),
        );
        batch.insertAll(
          _db.paymentTransactions,
          payments.map(_paymentCompanion).toList(),
        );
        batch.insertAll(
          _db.notifications,
          notifications.map(_notificationCompanion).toList(),
        );
        batch.insertAll(
          _db.appSettingsEntries,
          settings.entries
              .map(
                (entry) => AppSettingsEntriesCompanion.insert(
                  key: entry.key.toString(),
                  value: entry.value.toString(),
                ),
              )
              .toList(),
        );
      });
      for (final record in schedules) {
        final paymentId = record['paymentId'];
        if (paymentId is int) {
          await (_db.update(_db.interestSchedules)
                ..where((t) => t.id.equals(_int(record, 'id'))))
              .write(InterestSchedulesCompanion(paymentId: Value(paymentId)));
        }
      }
    });
    return RestoreResult(
      bondsImported: bonds.length,
      schedulesImported: schedules.length,
      paymentsImported: payments.length,
      duplicatesSkipped: 0,
      mode: RestoreMode.replace,
    );
  }

  Future<RestoreResult> _merge(
    List<Map<String, dynamic>> bonds,
    List<Map<String, dynamic>> schedules,
    List<Map<String, dynamic>> payments,
    List<Map<String, dynamic>> notifications,
    Map settings,
  ) async {
    var importedBonds = 0;
    var importedSchedules = 0;
    var importedPayments = 0;
    var skipped = 0;
    final bondIdMap = <int, int>{};
    final scheduleIdMap = <int, int>{};
    final paymentIdMap = <int, int>{};

    await _db.transaction(() async {
      final existing = await _db.select(_db.bonds).get();
      final existingKeys = existing
          .map(
            (row) => bondDuplicateKey(
              name: row.name,
              issuer: row.issuer,
              purchaseDate: row.purchaseDate,
            ),
          )
          .toSet();

      for (final record in bonds) {
        final key = bondDuplicateKey(
          name: _string(record, 'name'),
          issuer: _string(record, 'issuer'),
          purchaseDate: _date(record, 'purchaseDate'),
        );
        if (existingKeys.contains(key)) {
          skipped++;
          continue;
        }
        final oldId = _int(record, 'id');
        final newId = await _db
            .into(_db.bonds)
            .insert(_bondCompanion(record, autoId: true));
        bondIdMap[oldId] = newId;
        existingKeys.add(key);
        importedBonds++;
      }

      for (final record in schedules) {
        final oldBondId = _int(record, 'bondId');
        final newBondId = bondIdMap[oldBondId];
        if (newBondId == null) continue;
        final oldId = _int(record, 'id');
        final newId = await _db
            .into(_db.interestSchedules)
            .insert(
              _scheduleCompanion(
                record,
                autoId: true,
                bondId: newBondId,
                clearPaymentId: true,
              ),
            );
        scheduleIdMap[oldId] = newId;
        importedSchedules++;
      }

      for (final record in payments) {
        final oldBondId = _int(record, 'bondId');
        final newBondId = bondIdMap[oldBondId];
        if (newBondId == null) continue;
        final oldId = _int(record, 'id');
        final scheduleId = record['scheduleId'];
        final newId = await _db
            .into(_db.paymentTransactions)
            .insert(
              _paymentCompanion(
                record,
                autoId: true,
                bondId: newBondId,
                scheduleId: scheduleId is int
                    ? scheduleIdMap[scheduleId]
                    : null,
                clearScheduleId: scheduleId is int
                    ? !scheduleIdMap.containsKey(scheduleId)
                    : true,
              ),
            );
        paymentIdMap[oldId] = newId;
        importedPayments++;
      }

      // Restore the schedule -> payment link after payment ids are known.
      for (final record in schedules) {
        final oldPaymentId = record['paymentId'];
        final newScheduleId = scheduleIdMap[_int(record, 'id')];
        final newPaymentId = oldPaymentId is int
            ? paymentIdMap[oldPaymentId]
            : null;
        if (newScheduleId != null && newPaymentId != null) {
          await (_db.update(
            _db.interestSchedules,
          )..where((t) => t.id.equals(newScheduleId))).write(
            InterestSchedulesCompanion(paymentId: Value(newPaymentId)),
          );
        }
      }

      for (final record in notifications) {
        final oldBondId = record['bondId'];
        final newBondId = oldBondId is int ? bondIdMap[oldBondId] : null;
        if (oldBondId is int && newBondId == null) continue;
        await _db
            .into(_db.notifications)
            .insert(
              _notificationCompanion(record, autoId: true, bondId: newBondId),
              mode: InsertMode.insertOrIgnore,
            );
      }

      // Merge settings without overwriting existing user preferences.
      final existingSettings = await _db.select(_db.appSettingsEntries).get();
      final existingSettingKeys = existingSettings
          .map((row) => row.key)
          .toSet();
      final newSettings = settings.entries
          .where((entry) => !existingSettingKeys.contains(entry.key.toString()))
          .map(
            (entry) => AppSettingsEntriesCompanion.insert(
              key: entry.key.toString(),
              value: entry.value.toString(),
            ),
          )
          .toList();
      if (newSettings.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.appSettingsEntries, newSettings);
        });
      }
    });

    return RestoreResult(
      bondsImported: importedBonds,
      schedulesImported: importedSchedules,
      paymentsImported: importedPayments,
      duplicatesSkipped: skipped,
      mode: RestoreMode.merge,
    );
  }

  Future<Map<String, dynamic>> _payload() async {
    final bonds = await _db.select(_db.bonds).get();
    final schedules = await _db.select(_db.interestSchedules).get();
    final payments = await _db.select(_db.paymentTransactions).get();
    final notifications = await _db.select(_db.notifications).get();
    final settings = await _db.select(_db.appSettingsEntries).get();
    return {
      'format': 'bondtrack-backup',
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'bonds': [
        for (final row in bonds)
          {
            'id': row.id,
            'name': row.name,
            'issuer': row.issuer,
            'principalPaise': row.principalPaise,
            'annualRate': row.annualRate,
            'purchaseDate': row.purchaseDate.toIso8601String(),
            'frequency': row.frequency.name,
            'firstInterestDate': row.firstInterestDate.toIso8601String(),
            'maturityDate': row.maturityDate.toIso8601String(),
            'expectedMaturityAmountPaise': row.expectedMaturityAmountPaise,
            'paymentAccount': row.paymentAccount,
            'notes': row.notes,
            'status': row.status.name,
            'interestMethod': row.interestMethod.name,
            'compoundingFrequency': row.compoundingFrequency.name,
            'dayCountConvention': row.dayCountConvention.name,
            'creditDay': row.creditDay,
            'manualInterestPerPeriodPaise': row.manualInterestPerPeriodPaise,
            'remindersEnabled': row.remindersEnabled,
            'interestReminderOffsets': row.interestReminderOffsets,
            'maturityReminderOffsets': row.maturityReminderOffsets,
            'createdAt': row.createdAt.toIso8601String(),
            'updatedAt': row.updatedAt.toIso8601String(),
            'archivedAt': row.archivedAt?.toIso8601String(),
          },
      ],
      'schedules': [
        for (final row in schedules)
          {
            'id': row.id,
            'bondId': row.bondId,
            'dueDate': row.dueDate.toIso8601String(),
            'periodStart': row.periodStart.toIso8601String(),
            'periodEnd': row.periodEnd.toIso8601String(),
            'expectedInterestPaise': row.expectedInterestPaise,
            'receivedPaise': row.receivedPaise,
            'status': row.status.name,
            'paidDate': row.paidDate?.toIso8601String(),
            'paymentId': row.paymentId,
          },
      ],
      'payments': [
        for (final row in payments)
          {
            'id': row.id,
            'bondId': row.bondId,
            'scheduleId': row.scheduleId,
            'amountPaise': row.amountPaise,
            'paidDate': row.paidDate.toIso8601String(),
            'type': row.type.name,
            'reference': row.reference,
            'notes': row.notes,
            'createdAt': row.createdAt.toIso8601String(),
          },
      ],
      'notifications': [
        for (final row in notifications)
          {
            'id': row.id,
            'bondId': row.bondId,
            'type': row.type.name,
            'title': row.title,
            'body': row.body,
            'scheduledAt': row.scheduledAt.toIso8601String(),
            'readAt': row.readAt?.toIso8601String(),
            'dedupeKey': row.dedupeKey,
            'createdAt': row.createdAt.toIso8601String(),
          },
      ],
      'settings': {for (final row in settings) row.key: row.value},
    };
  }

  List<Map<String, dynamic>> _records(dynamic value, String label) {
    if (value is! List) throw FormatException('Backup $label data is invalid.');
    return value.map((record) {
      if (record is! Map) {
        throw FormatException('A backup $label record is invalid.');
      }
      return Map<String, dynamic>.from(record);
    }).toList();
  }

  void _validateBackup(
    List<Map<String, dynamic>> bonds,
    List<Map<String, dynamic>> schedules,
    List<Map<String, dynamic>> payments,
    List<Map<String, dynamic>> notifications,
  ) {
    final bondIds = <int>{};
    final bondKeys = <String>{};
    for (final bond in bonds) {
      final id = _int(bond, 'id');
      final principal = _int(bond, 'principalPaise');
      final rate = _double(bond, 'annualRate');
      final purchase = _date(bond, 'purchaseDate');
      final maturity = _date(bond, 'maturityDate');
      if (!bondIds.add(id) ||
          principal <= 0 ||
          rate <= 0 ||
          rate > 100 ||
          !maturity.isAfter(purchase)) {
        throw const FormatException('Backup contains invalid bond data.');
      }
      final key = bondDuplicateKey(
        name: _string(bond, 'name'),
        issuer: _string(bond, 'issuer'),
        purchaseDate: purchase,
      );
      if (!bondKeys.add(key)) {
        throw const FormatException(
          'Backup contains duplicate bond records. Remove duplicates before restoring.',
        );
      }
      InterestFrequency.values.byName(_string(bond, 'frequency'));
      BondStatus.values.byName(_string(bond, 'status'));
      if (bond['interestMethod'] != null) {
        InterestMethod.values.byName(_string(bond, 'interestMethod'));
      }
      if (bond['compoundingFrequency'] != null) {
        CompoundingFrequency.values.byName(
          _string(bond, 'compoundingFrequency'),
        );
      }
      if (bond['dayCountConvention'] != null) {
        DayCountConvention.values.byName(_string(bond, 'dayCountConvention'));
      }
    }
    final scheduleIds = <int>{};
    for (final schedule in schedules) {
      final id = _int(schedule, 'id');
      if (!scheduleIds.add(id) ||
          !bondIds.contains(_int(schedule, 'bondId')) ||
          _int(schedule, 'expectedInterestPaise') < 0) {
        throw const FormatException(
          'Backup contains an invalid interest schedule.',
        );
      }
      ScheduleStatus.values.byName(_string(schedule, 'status'));
    }
    final paymentIds = <int>{};
    for (final payment in payments) {
      final id = _int(payment, 'id');
      if (!paymentIds.add(id) ||
          !bondIds.contains(_int(payment, 'bondId')) ||
          _int(payment, 'amountPaise') <= 0) {
        throw const FormatException('Backup contains an invalid payment.');
      }
      final scheduleId = payment['scheduleId'];
      if (scheduleId != null && !scheduleIds.contains(scheduleId as int)) {
        throw const FormatException(
          'Backup contains a payment linked to a missing schedule.',
        );
      }
      PaymentType.values.byName(_string(payment, 'type'));
    }
    for (final notification in notifications) {
      final bondId = notification['bondId'];
      if (bondId != null && !bondIds.contains(bondId as int)) {
        throw const FormatException('Backup contains an invalid notification.');
      }
      AppNotificationType.values.byName(_string(notification, 'type'));
    }
  }

  BondsCompanion _bondCompanion(
    Map<String, dynamic> row, {
    int? id,
    bool autoId = false,
  }) => BondsCompanion.insert(
    id: autoId ? const Value.absent() : Value(id ?? _int(row, 'id')),
    name: _string(row, 'name'),
    issuer: _string(row, 'issuer'),
    principalPaise: _int(row, 'principalPaise'),
    annualRate: _double(row, 'annualRate'),
    purchaseDate: _date(row, 'purchaseDate'),
    frequency: InterestFrequency.values.byName(_string(row, 'frequency')),
    firstInterestDate: _date(row, 'firstInterestDate'),
    maturityDate: _date(row, 'maturityDate'),
    expectedMaturityAmountPaise: _int(row, 'expectedMaturityAmountPaise'),
    paymentAccount: Value(row['paymentAccount'] as String?),
    notes: Value(row['notes'] as String?),
    status: Value(BondStatus.values.byName(_string(row, 'status'))),
    interestMethod: Value(
      row['interestMethod'] == null
          ? InterestMethod.simple
          : InterestMethod.values.byName(_string(row, 'interestMethod')),
    ),
    compoundingFrequency: Value(
      row['compoundingFrequency'] == null
          ? CompoundingFrequency.annual
          : CompoundingFrequency.values.byName(
              _string(row, 'compoundingFrequency'),
            ),
    ),
    dayCountConvention: Value(
      row['dayCountConvention'] == null
          ? DayCountConvention.equalPeriods
          : DayCountConvention.values.byName(
              _string(row, 'dayCountConvention'),
            ),
    ),
    creditDay: Value(row['creditDay'] as int?),
    manualInterestPerPeriodPaise: Value(
      row['manualInterestPerPeriodPaise'] as int?,
    ),
    remindersEnabled: Value(row['remindersEnabled'] as bool? ?? true),
    interestReminderOffsets: Value(
      row['interestReminderOffsets'] as String? ?? '7,3,1,0',
    ),
    maturityReminderOffsets: Value(
      row['maturityReminderOffsets'] as String? ?? '30,15,7,1,0',
    ),
    createdAt: _date(row, 'createdAt'),
    updatedAt: _date(row, 'updatedAt'),
    archivedAt: Value(_optionalDate(row['archivedAt'])),
  );

  InterestSchedulesCompanion _scheduleCompanion(
    Map<String, dynamic> row, {
    int? id,
    bool autoId = false,
    int? bondId,
    int? paymentId,
    bool clearPaymentId = false,
  }) => InterestSchedulesCompanion.insert(
    id: autoId ? const Value.absent() : Value(id ?? _int(row, 'id')),
    bondId: bondId ?? _int(row, 'bondId'),
    dueDate: _date(row, 'dueDate'),
    periodStart: _date(row, 'periodStart'),
    periodEnd: _date(row, 'periodEnd'),
    expectedInterestPaise: _int(row, 'expectedInterestPaise'),
    receivedPaise: Value(row['receivedPaise'] as int? ?? 0),
    status: Value(ScheduleStatus.values.byName(_string(row, 'status'))),
    paidDate: Value(_optionalDate(row['paidDate'])),
    paymentId: Value(
      clearPaymentId ? null : (paymentId ?? row['paymentId'] as int?),
    ),
  );

  PaymentTransactionsCompanion _paymentCompanion(
    Map<String, dynamic> row, {
    int? id,
    bool autoId = false,
    int? bondId,
    int? scheduleId,
    bool clearScheduleId = false,
  }) => PaymentTransactionsCompanion.insert(
    id: autoId ? const Value.absent() : Value(id ?? _int(row, 'id')),
    bondId: bondId ?? _int(row, 'bondId'),
    scheduleId: Value(
      clearScheduleId ? null : (scheduleId ?? row['scheduleId'] as int?),
    ),
    amountPaise: _int(row, 'amountPaise'),
    paidDate: _date(row, 'paidDate'),
    type: PaymentType.values.byName(_string(row, 'type')),
    reference: Value(row['reference'] as String?),
    notes: Value(row['notes'] as String?),
    createdAt: _date(row, 'createdAt'),
  );

  NotificationsCompanion _notificationCompanion(
    Map<String, dynamic> row, {
    int? id,
    bool autoId = false,
    int? bondId,
  }) => NotificationsCompanion.insert(
    id: autoId ? const Value.absent() : Value(id ?? _int(row, 'id')),
    bondId: Value(bondId ?? row['bondId'] as int?),
    type: AppNotificationType.values.byName(_string(row, 'type')),
    title: _string(row, 'title'),
    body: _string(row, 'body'),
    scheduledAt: _date(row, 'scheduledAt'),
    readAt: Value(_optionalDate(row['readAt'])),
    dedupeKey: _string(row, 'dedupeKey'),
    createdAt: _date(row, 'createdAt'),
  );

  int _int(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is int) return value;
    throw FormatException('Backup field "$key" must be an integer.');
  }

  double _double(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is num) return value.toDouble();
    throw FormatException('Backup field "$key" must be numeric.');
  }

  String _string(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is String) return value;
    throw FormatException('Backup field "$key" must be text.');
  }

  DateTime _date(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is String) {
      final date = DateTime.tryParse(value);
      if (date != null) return date;
    }
    throw FormatException('Backup field "$key" must be a date.');
  }

  DateTime? _optionalDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  Future<Directory> _backupDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/bondtrack_backups');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<Uint8List> _encrypt(String json, String password) async {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final nonce = List<int>.generate(12, (_) => random.nextInt(256));
    final key = await _deriveKey(password, salt);
    final algorithm = AesGcm.with256bits();
    final box = await algorithm.encrypt(
      utf8.encode(json),
      secretKey: key,
      nonce: nonce,
    );
    final envelope = {
      'format': 'bondtrack-encrypted-backup',
      'version': 1,
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': _iterations,
      'cipher': 'AES-256-GCM',
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'mac': base64Encode(box.mac.bytes),
      'ciphertext': base64Encode(box.cipherText),
    };
    return Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(envelope)),
    );
  }

  Future<Uint8List> _decrypt(
    Map<String, dynamic> envelope,
    String password,
  ) async {
    try {
      final salt = base64Decode(_string(envelope, 'salt'));
      final nonce = base64Decode(_string(envelope, 'nonce'));
      final mac = base64Decode(_string(envelope, 'mac'));
      final ciphertext = base64Decode(_string(envelope, 'ciphertext'));
      final key = await _deriveKey(password, salt);
      final algorithm = AesGcm.with256bits();
      final clear = await algorithm.decrypt(
        SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
      );
      return Uint8List.fromList(clear);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException(
        'Could not decrypt this backup. Check the password and try again.',
      );
    }
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt) {
    final kdf = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iterations,
      bits: 256,
    );
    return kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
