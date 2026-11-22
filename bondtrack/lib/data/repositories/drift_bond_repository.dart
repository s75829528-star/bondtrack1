import 'package:drift/drift.dart';
import 'package:bondtrack/data/database/app_database.dart';
import 'package:bondtrack/data/mappers.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/repositories/bond_repository.dart';
import 'package:bondtrack/domain/services/bond_identity.dart';
import 'package:bondtrack/domain/services/schedule_generator.dart';

class DriftBondRepository implements BondRepository {
  DriftBondRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Bond>> watchAll() {
    final query = _db.select(_db.bonds)
      ..orderBy([
        (t) => OrderingTerm(expression: t.status),
        (t) => OrderingTerm(expression: t.maturityDate),
      ]);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Stream<Bond?> watchById(int id) {
    final query = _db.select(_db.bonds)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().map((row) => row?.toDomain());
  }

  @override
  Future<Bond?> getById(int id) async {
    final query = _db.select(_db.bonds)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<List<Bond>> getAll() async {
    final rows = await _db.select(_db.bonds).get();
    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<int> create(BondDraft draft) {
    return _db.transaction(() async {
      final now = DateTime.now();
      final id = await _db
          .into(_db.bonds)
          .insert(
            BondsCompanion.insert(
              name: draft.name.trim(),
              issuer: draft.issuer.trim(),
              principalPaise: draft.principalPaise,
              annualRate: draft.annualRate,
              purchaseDate: draft.purchaseDate,
              frequency: draft.frequency,
              firstInterestDate: draft.firstInterestDate,
              maturityDate: draft.maturityDate,
              expectedMaturityAmountPaise: draft.expectedMaturityAmountPaise,
              paymentAccount: Value(_nullable(draft.paymentAccount)),
              notes: Value(_nullable(draft.notes)),
              status: Value(draft.status),
              interestMethod: Value(draft.interestMethod),
              compoundingFrequency: Value(draft.compoundingFrequency),
              dayCountConvention: Value(draft.dayCountConvention),
              creditDay: Value(draft.creditDay),
              manualInterestPerPeriodPaise: Value(
                draft.manualInterestPerPeriodPaise,
              ),
              remindersEnabled: Value(draft.remindersEnabled),
              interestReminderOffsets: Value(draft.interestReminderOffsets),
              maturityReminderOffsets: Value(draft.maturityReminderOffsets),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _insertGeneratedSchedules(id, draft);
      return id;
    });
  }

  @override
  Future<void> update(BondDraft draft) {
    return _db.transaction(() => _updateInTransaction(draft));
  }

  Future<void> _updateInTransaction(BondDraft draft) async {
    final id = draft.id;
    if (id == null) {
      throw ArgumentError('A bond id is required to update a bond.');
    }
    final existing = await (_db.select(
      _db.bonds,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) {
      throw StateError('Bond no longer exists.');
    }
    final now = DateTime.now();
    await (_db.update(_db.bonds)..where((t) => t.id.equals(id))).write(
      bondDraftToCompanion(
        draft,
        now: now,
        createdAt: existing.createdAt,
      ).copyWith(archivedAt: const Value.absent()),
    );

    // Preserve every real receipt (including partial receipts) as history.
    // Unpaid schedule rows are regenerated from the updated bond terms.
    final existingSchedules = await (_db.select(
      _db.interestSchedules,
    )..where((t) => t.bondId.equals(id))).get();
    final paidDueDates = existingSchedules
        .where((s) => s.receivedPaise > 0)
        .map((s) => _dayKey(s.dueDate))
        .toSet();
    await (_db.delete(
      _db.interestSchedules,
    )..where((t) => t.bondId.equals(id) & t.receivedPaise.equals(0))).go();

    final generated = ScheduleGenerator.generate(
      purchaseDate: draft.purchaseDate,
      firstInterestDate: draft.firstInterestDate,
      maturityDate: draft.maturityDate,
      frequency: draft.frequency,
      principalPaise: draft.principalPaise,
      annualRate: draft.annualRate,
      method: draft.interestMethod,
      compounding: draft.compoundingFrequency,
      dayCount: draft.dayCountConvention,
      creditDay: draft.creditDay,
      manualInterestPerPeriodPaise: draft.manualInterestPerPeriodPaise,
    );
    final toInsert = generated
        .where((s) => !paidDueDates.contains(_dayKey(s.dueDate)))
        .map((s) => generatedScheduleToCompanion(id, s))
        .toList();
    if (toInsert.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(_db.interestSchedules, toInsert);
      });
    }
  }

  @override
  Future<void> archive(int id) async {
    final now = DateTime.now();
    await (_db.update(_db.bonds)..where((t) => t.id.equals(id))).write(
      BondsCompanion(
        status: const Value(BondStatus.archived),
        archivedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> restore(int id) async {
    final now = DateTime.now();
    await (_db.update(_db.bonds)..where((t) => t.id.equals(id))).write(
      BondsCompanion(
        status: const Value(BondStatus.active),
        archivedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> markMatured(int id) async {
    final now = DateTime.now();
    await (_db.update(_db.bonds)..where((t) => t.id.equals(id))).write(
      BondsCompanion(
        status: const Value(BondStatus.matured),
        archivedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.bonds)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<int> importAll(List<BondDraft> drafts) {
    return _db.transaction(() => _insertDrafts(drafts));
  }

  @override
  Future<int> syncImport({
    required List<BondDraft> newBonds,
    required List<BondDraft> updates,
  }) {
    return _db.transaction(() async {
      final imported = await _insertDrafts(newBonds);
      for (final draft in updates) {
        await _updateInTransaction(draft);
      }
      return imported;
    });
  }

  Future<int> _insertDrafts(List<BondDraft> drafts) async {
    final now = DateTime.now();
    var imported = 0;
    for (final draft in drafts) {
      final id = await _db
          .into(_db.bonds)
          .insert(
            BondsCompanion.insert(
              name: draft.name.trim(),
              issuer: draft.issuer.trim(),
              principalPaise: draft.principalPaise,
              annualRate: draft.annualRate,
              purchaseDate: draft.purchaseDate,
              frequency: draft.frequency,
              firstInterestDate: draft.firstInterestDate,
              maturityDate: draft.maturityDate,
              expectedMaturityAmountPaise: draft.expectedMaturityAmountPaise,
              paymentAccount: Value(_nullable(draft.paymentAccount)),
              notes: Value(_nullable(draft.notes)),
              status: Value(draft.status),
              interestMethod: Value(draft.interestMethod),
              compoundingFrequency: Value(draft.compoundingFrequency),
              dayCountConvention: Value(draft.dayCountConvention),
              creditDay: Value(draft.creditDay),
              manualInterestPerPeriodPaise: Value(
                draft.manualInterestPerPeriodPaise,
              ),
              remindersEnabled: Value(draft.remindersEnabled),
              interestReminderOffsets: Value(draft.interestReminderOffsets),
              maturityReminderOffsets: Value(draft.maturityReminderOffsets),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _insertGeneratedSchedules(id, draft);
      imported++;
    }
    return imported;
  }

  @override
  Future<Set<String>> existingDuplicateKeys() async {
    final rows = await _db.select(_db.bonds).get();
    return rows
        .map(
          (row) => bondDuplicateKey(
            name: row.name,
            issuer: row.issuer,
            purchaseDate: row.purchaseDate,
          ),
        )
        .toSet();
  }

  Future<void> _insertGeneratedSchedules(int bondId, BondDraft draft) async {
    final generated = ScheduleGenerator.generate(
      purchaseDate: draft.purchaseDate,
      firstInterestDate: draft.firstInterestDate,
      maturityDate: draft.maturityDate,
      frequency: draft.frequency,
      principalPaise: draft.principalPaise,
      annualRate: draft.annualRate,
      method: draft.interestMethod,
      compounding: draft.compoundingFrequency,
      dayCount: draft.dayCountConvention,
      creditDay: draft.creditDay,
      manualInterestPerPeriodPaise: draft.manualInterestPerPeriodPaise,
    );
    if (generated.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.interestSchedules,
        generated.map((s) => generatedScheduleToCompanion(bondId, s)).toList(),
      );
    });
  }

  String? _nullable(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  String _dayKey(DateTime value) => '${value.year}-${value.month}-${value.day}';
}
