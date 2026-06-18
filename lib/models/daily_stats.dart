class DailyStats {
  final String date; // YYYY-MM-DD format
  final int steps;
  final int waterIntake; // in ml
  final int targetSteps;
  final int targetCalories;
  final int targetWater; // in ml

  DailyStats({
    required this.date,
    this.steps = 0,
    this.waterIntake = 0,
    this.targetSteps = 10000,
    this.targetCalories = 500,
    this.targetWater = 2000,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'steps': steps,
      'waterIntake': waterIntake,
      'targetSteps': targetSteps,
      'targetCalories': targetCalories,
      'targetWater': targetWater,
    };
  }

  factory DailyStats.fromMap(Map<String, dynamic> map) {
    return DailyStats(
      date: map['date'] as String,
      steps: map['steps'] as int? ?? 0,
      waterIntake: map['waterIntake'] as int? ?? 0,
      targetSteps: map['targetSteps'] as int? ?? 10000,
      targetCalories: map['targetCalories'] as int? ?? 500,
      targetWater: map['targetWater'] as int? ?? 2000,
    );
  }

  DailyStats copyWith({
    String? date,
    int? steps,
    int? waterIntake,
    int? targetSteps,
    int? targetCalories,
    int? targetWater,
  }) {
    return DailyStats(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      waterIntake: waterIntake ?? this.waterIntake,
      targetSteps: targetSteps ?? this.targetSteps,
      targetCalories: targetCalories ?? this.targetCalories,
      targetWater: targetWater ?? this.targetWater,
    );
  }
}
