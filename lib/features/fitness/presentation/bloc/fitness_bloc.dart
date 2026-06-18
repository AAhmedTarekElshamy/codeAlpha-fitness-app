import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../core/cache/fitness_cache_service.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../core/telemetry/firebase_telemetry_service.dart';
import '../../../../models/daily_stats.dart';
import '../../../../models/workout.dart';
import '../../domain/repositories/fitness_repository.dart';
import '../../domain/repositories/recommendation_repository.dart';

part 'fitness_event.dart';
part 'fitness_state.dart';

@injectable
class FitnessBloc extends Bloc<FitnessEvent, FitnessState> {
  FitnessBloc(
    this._fitnessRepository,
    this._recommendationRepository,
    this._cacheService,
    this._notificationService,
    this._telemetryService,
  ) : super(FitnessState.initial()) {
    on<FitnessStarted>(_onStarted);
    on<FitnessDateSelected>(_onDateSelected);
    on<FitnessStepsUpdated>(_onStepsUpdated);
    on<FitnessStepsAdded>(_onStepsAdded);
    on<FitnessWaterUpdated>(_onWaterUpdated);
    on<FitnessWaterAdded>(_onWaterAdded);
    on<FitnessGoalsUpdated>(_onGoalsUpdated);
    on<FitnessWorkoutAdded>(_onWorkoutAdded);
    on<FitnessWorkoutDeleted>(_onWorkoutDeleted);
  }

  final FitnessRepository _fitnessRepository;
  final RecommendationRepository _recommendationRepository;
  final FitnessCacheService _cacheService;
  final PushNotificationService _notificationService;
  final FirebaseTelemetryService _telemetryService;

  Future<void> _onStarted(FitnessStarted event, Emitter<FitnessState> emit) async {
    final cachedDate = await _cacheService.getSelectedDate();
    final date = cachedDate == null ? DateTime.now() : DateTime.tryParse(cachedDate) ?? DateTime.now();
    await _loadDate(date, emit);
  }

  Future<void> _onDateSelected(FitnessDateSelected event, Emitter<FitnessState> emit) async {
    await _loadDate(event.date, emit);
  }

  Future<void> _onStepsUpdated(FitnessStepsUpdated event, Emitter<FitnessState> emit) async {
    final stats = state.todayStats;
    if (stats == null) return;

    final updated = stats.copyWith(steps: event.steps < 0 ? 0 : event.steps);
    await _fitnessRepository.updateDailyStats(updated);
    await _maybeNotifyGoalReached(updated);
    await _telemetryService.logEvent('steps_updated', parameters: {'steps': updated.steps});
    await _refreshAfterMutation(emit, updated);
  }

  Future<void> _onStepsAdded(FitnessStepsAdded event, Emitter<FitnessState> emit) async {
    final stats = state.todayStats;
    if (stats == null) return;
    add(FitnessStepsUpdated(stats.steps + event.increment));
  }

  Future<void> _onWaterUpdated(FitnessWaterUpdated event, Emitter<FitnessState> emit) async {
    final stats = state.todayStats;
    if (stats == null) return;

    final updated = stats.copyWith(waterIntake: event.waterMl < 0 ? 0 : event.waterMl);
    await _fitnessRepository.updateDailyStats(updated);
    await _telemetryService.logEvent('water_updated', parameters: {'water_ml': updated.waterIntake});
    await _refreshAfterMutation(emit, updated);
  }

  Future<void> _onWaterAdded(FitnessWaterAdded event, Emitter<FitnessState> emit) async {
    final stats = state.todayStats;
    if (stats == null) return;
    add(FitnessWaterUpdated(stats.waterIntake + event.incrementMl));
  }

  Future<void> _onGoalsUpdated(FitnessGoalsUpdated event, Emitter<FitnessState> emit) async {
    final stats = state.todayStats;
    if (stats == null) return;

    final updated = stats.copyWith(
      targetSteps: event.targetSteps ?? stats.targetSteps,
      targetCalories: event.targetCalories ?? stats.targetCalories,
      targetWater: event.targetWater ?? stats.targetWater,
    );
    await _fitnessRepository.updateDailyStats(updated);
    await _telemetryService.logEvent('goals_updated');
    await _refreshAfterMutation(emit, updated);
  }

  Future<void> _onWorkoutAdded(FitnessWorkoutAdded event, Emitter<FitnessState> emit) async {
    await _fitnessRepository.addWorkout(event.workout);
    await _telemetryService.logEvent(
      'workout_added',
      parameters: {'type': event.workout.type, 'calories': event.workout.calories},
    );
    await _loadDate(state.currentDate, emit, showLoading: false);
  }

  Future<void> _onWorkoutDeleted(FitnessWorkoutDeleted event, Emitter<FitnessState> emit) async {
    await _fitnessRepository.deleteWorkout(event.workoutId);
    await _telemetryService.logEvent('workout_deleted');
    await _loadDate(state.currentDate, emit, showLoading: false);
  }

  Future<void> _loadDate(DateTime date, Emitter<FitnessState> emit, {bool showLoading = true}) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (showLoading) {
      emit(state.copyWith(currentDate: normalizedDate, status: FitnessStatus.loading));
    }

    try {
      final dateStr = _formatDate(normalizedDate);
      await _cacheService.saveSelectedDate(dateStr);

      final startDate = normalizedDate.subtract(const Duration(days: 6));
      final startDateStr = _formatDate(startDate);
      final endDateStr = _formatDate(normalizedDate);

      final stats = await _fitnessRepository.getDailyStats(dateStr);
      final todayWorkouts = await _fitnessRepository.getWorkoutsForDate(dateStr);
      final fetchedWeeklyStats = await _fitnessRepository.getWeeklyStats(startDateStr, endDateStr);
      final weeklyWorkouts = await _fitnessRepository.getWeeklyWorkouts(startDateStr, endDateStr);
      final weeklyStats = _padWeeklyStats(startDate, fetchedWeeklyStats);
      final recommendation = await _recommendationRepository.getDailyRecommendation(
        stats: stats,
        workouts: todayWorkouts,
        weeklyStats: weeklyStats,
      );

      emit(
        state.copyWith(
          currentDate: normalizedDate,
          status: FitnessStatus.success,
          todayStats: stats,
          todayWorkouts: todayWorkouts,
          weeklyStats: weeklyStats,
          weeklyWorkouts: weeklyWorkouts,
          recommendation: recommendation,
        ),
      );
    } catch (error, stackTrace) {
      await _telemetryService.recordError(error, stackTrace);
      emit(state.copyWith(status: FitnessStatus.failure, errorMessage: error.toString()));
    }
  }

  Future<void> _refreshAfterMutation(Emitter<FitnessState> emit, DailyStats updatedStats) async {
    final weeklyStats = [...state.weeklyStats];
    final index = weeklyStats.indexWhere((stats) => stats.date == updatedStats.date);
    if (index != -1) {
      weeklyStats[index] = updatedStats;
    }

    final recommendation = await _recommendationRepository.getDailyRecommendation(
      stats: updatedStats,
      workouts: state.todayWorkouts,
      weeklyStats: weeklyStats,
    );

    emit(
      state.copyWith(
        status: FitnessStatus.success,
        todayStats: updatedStats,
        weeklyStats: weeklyStats,
        recommendation: recommendation,
      ),
    );
  }

  Future<void> _maybeNotifyGoalReached(DailyStats stats) async {
    if (stats.steps >= stats.targetSteps) {
      await _notificationService.showGoalReached(
        'Step goal reached',
        'You hit ${stats.targetSteps} steps today.',
      );
    }
  }

  List<DailyStats> _padWeeklyStats(DateTime startDate, List<DailyStats> fetchedWeeklyStats) {
    return List.generate(7, (index) {
      final day = startDate.add(Duration(days: index));
      final dayStr = _formatDate(day);
      return fetchedWeeklyStats.firstWhere(
        (element) => element.date == dayStr,
        orElse: () => DailyStats(date: dayStr),
      );
    });
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
}
