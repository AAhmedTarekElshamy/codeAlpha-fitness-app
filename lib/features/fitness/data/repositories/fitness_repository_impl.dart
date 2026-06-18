import 'package:injectable/injectable.dart';

import '../../../../models/daily_stats.dart';
import '../../../../models/workout.dart';
import '../../domain/repositories/fitness_repository.dart';
import '../datasources/fitness_local_data_source.dart';

@LazySingleton(as: FitnessRepository)
class FitnessRepositoryImpl implements FitnessRepository {
  FitnessRepositoryImpl(this._localDataSource);

  final FitnessLocalDataSource _localDataSource;

  @override
  Future<DailyStats> getDailyStats(String date) => _localDataSource.getDailyStats(date);

  @override
  Future<List<DailyStats>> getWeeklyStats(String startDate, String endDate) {
    return _localDataSource.getWeeklyStats(startDate, endDate);
  }

  @override
  Future<void> updateDailyStats(DailyStats stats) => _localDataSource.updateDailyStats(stats);

  @override
  Future<Workout> addWorkout(Workout workout) => _localDataSource.insertWorkout(workout);

  @override
  Future<void> deleteWorkout(int workoutId) => _localDataSource.deleteWorkout(workoutId);

  @override
  Future<List<Workout>> getWorkoutsForDate(String date) {
    return _localDataSource.getWorkoutsForDate(date);
  }

  @override
  Future<List<Workout>> getWeeklyWorkouts(String startDate, String endDate) {
    return _localDataSource.getWeeklyWorkouts(startDate, endDate);
  }
}
