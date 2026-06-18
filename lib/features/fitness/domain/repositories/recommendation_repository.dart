import '../../../../models/daily_stats.dart';
import '../../../../models/workout.dart';

abstract class RecommendationRepository {
  Future<String> getDailyRecommendation({
    required DailyStats stats,
    required List<Workout> workouts,
    required List<DailyStats> weeklyStats,
  });
}
