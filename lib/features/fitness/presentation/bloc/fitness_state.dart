part of 'fitness_bloc.dart';

enum FitnessStatus { initial, loading, success, failure }

class FitnessState extends Equatable {
  const FitnessState({
    required this.currentDate,
    this.status = FitnessStatus.initial,
    this.todayStats,
    this.todayWorkouts = const [],
    this.weeklyStats = const [],
    this.weeklyWorkouts = const [],
    this.recommendation = '',
    this.errorMessage,
  });

  factory FitnessState.initial() {
    final now = DateTime.now();
    return FitnessState(currentDate: DateTime(now.year, now.month, now.day));
  }

  final DateTime currentDate;
  final FitnessStatus status;
  final DailyStats? todayStats;
  final List<Workout> todayWorkouts;
  final List<DailyStats> weeklyStats;
  final List<Workout> weeklyWorkouts;
  final String recommendation;
  final String? errorMessage;

  bool get isLoading => status == FitnessStatus.loading;

  int get totalCaloriesBurned {
    return todayWorkouts.fold(0, (sum, workout) => sum + workout.calories);
  }

  int getCaloriesBurnedForDate(String dateStr) {
    final dayWorkouts = weeklyWorkouts.where((workout) {
      return DateFormat('yyyy-MM-dd').format(workout.timestamp) == dateStr;
    });
    return dayWorkouts.fold(0, (sum, workout) => sum + workout.calories);
  }

  FitnessState copyWith({
    DateTime? currentDate,
    FitnessStatus? status,
    DailyStats? todayStats,
    List<Workout>? todayWorkouts,
    List<DailyStats>? weeklyStats,
    List<Workout>? weeklyWorkouts,
    String? recommendation,
    String? errorMessage,
  }) {
    return FitnessState(
      currentDate: currentDate ?? this.currentDate,
      status: status ?? this.status,
      todayStats: todayStats ?? this.todayStats,
      todayWorkouts: todayWorkouts ?? this.todayWorkouts,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      weeklyWorkouts: weeklyWorkouts ?? this.weeklyWorkouts,
      recommendation: recommendation ?? this.recommendation,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentDate,
        status,
        todayStats,
        todayWorkouts,
        weeklyStats,
        weeklyWorkouts,
        recommendation,
        errorMessage,
      ];
}
