import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/cache/fitness_cache_service.dart';
import '../../../../models/daily_stats.dart';
import '../../../../models/workout.dart';
import '../../domain/repositories/recommendation_repository.dart';

@LazySingleton(as: RecommendationRepository)
class RecommendationRepositoryImpl implements RecommendationRepository {
  RecommendationRepositoryImpl(this._apiClient, this._cacheService);

  final ApiClient _apiClient;
  final FitnessCacheService _cacheService;

  @override
  Future<String> getDailyRecommendation({
    required DailyStats stats,
    required List<Workout> workouts,
    required List<DailyStats> weeklyStats,
  }) async {
    final remote = await _fetchRemoteRecommendation(stats);
    if (remote != null && remote.isNotEmpty) {
      await _cacheService.saveRecommendation(remote);
      return remote;
    }

    final local = _buildLocalRecommendation(stats, workouts, weeklyStats);
    await _cacheService.saveRecommendation(local);
    return local;
  }

  Future<String?> _fetchRemoteRecommendation(DailyStats stats) async {
    final json = await _apiClient.getJson('/recommendations/daily?date=${stats.date}');
    return json?['message'] as String?;
  }

  String _buildLocalRecommendation(
    DailyStats stats,
    List<Workout> workouts,
    List<DailyStats> weeklyStats,
  ) {
    final calories = workouts.fold<int>(0, (sum, workout) => sum + workout.calories);
    final activeDays = weeklyStats.where((day) => day.steps > 0 || day.waterIntake > 0).length;

    if (stats.steps < stats.targetSteps * 0.5) {
      return 'A 15 minute walk would close the biggest gap in today\'s plan.';
    }
    if (stats.waterIntake < stats.targetWater * 0.6) {
      return 'Hydration is trailing today. Add 500ml over the next hour.';
    }
    if (calories < stats.targetCalories) {
      return 'You are close. A short strength or cycling session can finish the calorie goal.';
    }
    if (activeDays >= 5) {
      return 'Strong weekly consistency. Consider a lighter recovery session tomorrow.';
    }
    return 'Today is balanced. Keep the pace steady and log one focused workout.';
  }
}
