import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';
import '../models/daily_stats.dart';
import '../services/database_service.dart';

class FitnessViewModel extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;

  DateTime _currentDate = DateTime.now();
  DailyStats? _todayStats;
  List<Workout> _todayWorkouts = [];
  List<DailyStats> _weeklyStats = [];
  List<Workout> _weeklyWorkouts = [];
  bool _isLoading = false;

  // Getters
  DateTime get currentDate => _currentDate;
  DailyStats? get todayStats => _todayStats;
  List<Workout> get todayWorkouts => _todayWorkouts;
  List<DailyStats> get weeklyStats => _weeklyStats;
  List<Workout> get weeklyWorkouts => _weeklyWorkouts;
  bool get isLoading => _isLoading;

  int get totalCaloriesBurned {
    if (_todayWorkouts.isEmpty) return 0;
    return _todayWorkouts.fold(0, (sum, workout) => sum + workout.calories);
  }

  // Formatting date for DB queries (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Initialize and load data for a specific date
  Future<void> loadDataForDate(DateTime date) async {
    _currentDate = DateTime(date.year, date.month, date.day);
    _isLoading = true;
    notifyListeners();

    try {
      final dateStr = _formatDate(_currentDate);
      
      // Load stats for current date
      _todayStats = await _dbService.getDailyStats(dateStr);
      
      // Load workouts for current date
      _todayWorkouts = await _dbService.getWorkoutsForDate(dateStr);

      // Load weekly data (last 7 days ending on current date)
      final startDate = _currentDate.subtract(const Duration(days: 6));
      final startDateStr = _formatDate(startDate);
      final endDateStr = _formatDate(_currentDate);

      final fetchedWeeklyStats = await _dbService.getWeeklyStats(startDateStr, endDateStr);
      _weeklyWorkouts = await _dbService.getWeeklyWorkouts(startDateStr, endDateStr);

      // Pad missing days in weeklyStats so there are always 7 entries
      _weeklyStats = [];
      for (int i = 0; i < 7; i++) {
        final day = startDate.add(Duration(days: i));
        final dayStr = _formatDate(day);
        
        // Find existing or create placeholder
        final existing = fetchedWeeklyStats.firstWhere(
          (element) => element.date == dayStr,
          orElse: () => DailyStats(date: dayStr),
        );
        _weeklyStats.add(existing);
      }
    } catch (e) {
      debugPrint('Error loading fitness data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Steps handling
  Future<void> updateSteps(int steps) async {
    if (_todayStats == null) return;
    
    // Steps shouldn't be negative
    final newSteps = steps < 0 ? 0 : steps;
    _todayStats = _todayStats!.copyWith(steps: newSteps);
    notifyListeners();

    await _dbService.updateDailyStats(_todayStats!);
    _updateWeeklyStatsCache(_todayStats!);
  }

  Future<void> addSteps(int increment) async {
    if (_todayStats == null) return;
    await updateSteps(_todayStats!.steps + increment);
  }

  // Water handling
  Future<void> updateWater(int waterMl) async {
    if (_todayStats == null) return;

    final newWater = waterMl < 0 ? 0 : waterMl;
    _todayStats = _todayStats!.copyWith(waterIntake: newWater);
    notifyListeners();

    await _dbService.updateDailyStats(_todayStats!);
    _updateWeeklyStatsCache(_todayStats!);
  }

  Future<void> addWater(int incrementMl) async {
    if (_todayStats == null) return;
    await updateWater(_todayStats!.waterIntake + incrementMl);
  }

  // Goals handling
  Future<void> updateGoals({int? targetSteps, int? targetCalories, int? targetWater}) async {
    if (_todayStats == null) return;

    _todayStats = _todayStats!.copyWith(
      targetSteps: targetSteps ?? _todayStats!.targetSteps,
      targetCalories: targetCalories ?? _todayStats!.targetCalories,
      targetWater: targetWater ?? _todayStats!.targetWater,
    );
    notifyListeners();

    await _dbService.updateDailyStats(_todayStats!);
    _updateWeeklyStatsCache(_todayStats!);
  }

  // Workout handling
  Future<void> addWorkout(Workout workout) async {
    // Save workout to db
    await _dbService.insertWorkout(workout);
    
    // Reload all data to keep ui in sync (recalculates daily total calories and weekly charts)
    await loadDataForDate(_currentDate);
  }

  Future<void> deleteWorkout(int workoutId) async {
    await _dbService.deleteWorkout(workoutId);
    
    // Reload all data
    await loadDataForDate(_currentDate);
  }

  // Helper to update weeklyCache lists in memory without full DB re-fetches (for real-time sliders)
  void _updateWeeklyStatsCache(DailyStats updated) {
    final index = _weeklyStats.indexWhere((element) => element.date == updated.date);
    if (index != -1) {
      _weeklyStats[index] = updated;
      notifyListeners();
    }
  }

  // Get total calories burned on a specific date in the weekly range
  int getCaloriesBurnedForDate(String dateStr) {
    final dayWorkouts = _weeklyWorkouts.where((w) {
      final wDate = DateFormat('yyyy-MM-dd').format(w.timestamp);
      return wDate == dateStr;
    });
    if (dayWorkouts.isEmpty) return 0;
    return dayWorkouts.fold(0, (sum, w) => sum + w.calories);
  }
}
