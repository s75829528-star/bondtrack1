import 'package:bondtrack/domain/entities/interest_schedule.dart';

abstract interface class ScheduleRepository {
  Stream<List<InterestSchedule>> watchAll();

  Stream<List<InterestSchedule>> watchForBond(int bondId);

  Future<List<InterestSchedule>> getForBond(int bondId);

  Future<List<InterestSchedule>> getAll();
}
