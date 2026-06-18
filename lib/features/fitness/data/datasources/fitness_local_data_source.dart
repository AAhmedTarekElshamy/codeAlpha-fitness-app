import 'package:injectable/injectable.dart';

import '../../../../models/daily_stats.dart';
import '../../../../models/workout.dart';
import '../../../../services/database_service.dart';

abstract class FitnessLocalDataSource {
  Future<DailyStats> getDailyStats(String date);
  Future<List<DailyStats>> getWeeklyStats(String startDate, String endDate);
  Future<void> updateDailyStats(DailyStats stats);
  Future<Workout> insertWorkout(Workout workout);
  Future<void> deleteWorkout(int workoutId);
  Future<List<Workout>> getWorkoutsForDate(String date);
  Future<List<Workout>> getWeeklyWorkouts(String startDate, String endDate);
}

@LazySingleton(as: FitnessLocalDataSource)
class SqfliteFitnessLocalDataSource implements FitnessLocalDataSource {
  SqfliteFitnessLocalDataSource() : _databaseService = DatabaseService.instance;

  final DatabaseService _databaseService;

  @override
  Future<DailyStats> getDailyStats(String date) => _databaseService.getDailyStats(date);

  @override
  Future<List<DailyStats>> getWeeklyStats(String startDate, String endDate) {
    return _databaseService.getWeeklyStats(startDate, endDate);
  }

  @override
  Future<void> updateDailyStats(DailyStats stats) => _databaseService.updateDailyStats(stats);

  @override
  Future<Workout> insertWorkout(Workout workout) => _databaseService.insertWorkout(workout);

  @override
  Future<void> deleteWorkout(int workoutId) async {
    await _databaseService.deleteWorkout(workoutId);
  }

  @override
  Future<List<Workout>> getWorkoutsForDate(String date) {
    return _databaseService.getWorkoutsForDate(date);
  }

  @override
  Future<List<Workout>> getWeeklyWorkouts(String startDate, String endDate) {
    return _databaseService.getWeeklyWorkouts(startDate, endDate);
  }
}
