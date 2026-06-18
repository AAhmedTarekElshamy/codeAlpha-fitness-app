import '../../../../models/daily_stats.dart';
import '../../../../models/workout.dart';

abstract class FitnessRepository {
  Future<DailyStats> getDailyStats(String date);
  Future<List<DailyStats>> getWeeklyStats(String startDate, String endDate);
  Future<void> updateDailyStats(DailyStats stats);
  Future<Workout> addWorkout(Workout workout);
  Future<void> deleteWorkout(int workoutId);
  Future<List<Workout>> getWorkoutsForDate(String date);
  Future<List<Workout>> getWeeklyWorkouts(String startDate, String endDate);
}
