import 'package:drift/drift.dart';
import 'package:bondtrack/data/database/app_database.dart';
import 'package:bondtrack/data/mappers.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/domain/repositories/schedule_repository.dart';

class DriftScheduleRepository implements ScheduleRepository {
  DriftScheduleRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<InterestSchedule>> watchAll() {
    final query = _db.select(_db.interestSchedules)
      ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Stream<List<InterestSchedule>> watchForBond(int bondId) {
    final query = _db.select(_db.interestSchedules)
      ..where((t) => t.bondId.equals(bondId))
      ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Future<List<InterestSchedule>> getForBond(int bondId) async {
    final query = _db.select(_db.interestSchedules)
      ..where((t) => t.bondId.equals(bondId))
      ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]);
    final rows = await query.get();
    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<List<InterestSchedule>> getAll() async {
    final rows = await _db.select(_db.interestSchedules).get();
    return rows.map((row) => row.toDomain()).toList();
  }
}
