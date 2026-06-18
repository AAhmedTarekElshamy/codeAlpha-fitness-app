class Workout {
  final int? id;
  final String type;
  final int duration; // in minutes
  final int calories; // in kcal
  final DateTime timestamp;
  final String? notes;

  Workout({
    this.id,
    required this.type,
    required this.duration,
    required this.calories,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'duration': duration,
      'calories': calories,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as int?,
      type: map['type'] as String,
      duration: map['duration'] as int,
      calories: map['calories'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      notes: map['notes'] as String?,
    );
  }

  Workout copyWith({
    int? id,
    String? type,
    int? duration,
    int? calories,
    DateTime? timestamp,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }
}
