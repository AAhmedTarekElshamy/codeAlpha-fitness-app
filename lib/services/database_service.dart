import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/workout.dart';
import '../models/daily_stats.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  // In-memory fallback database for Web
  final Map<String, DailyStats> _mockDailyStats = {};
  final List<Workout> _mockWorkouts = [];
  int _mockWorkoutIdCounter = 1;

  DatabaseService._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite native not supported on Web. Web uses in-memory mock database.');
    }
    if (_database != null) return _database!;
    _database = await _initDB('fitness_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_stats (
        date TEXT PRIMARY KEY,
        steps INTEGER NOT NULL DEFAULT 0,
        waterIntake INTEGER NOT NULL DEFAULT 0,
        targetSteps INTEGER NOT NULL DEFAULT 10000,
        targetCalories INTEGER NOT NULL DEFAULT 500,
        targetWater INTEGER NOT NULL DEFAULT 2000
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  // --- Daily Stats Queries ---

  Future<DailyStats> getDailyStats(String date) async {
    if (kIsWeb) {
      if (_mockDailyStats.containsKey(date)) {
        return _mockDailyStats[date]!;
      } else {
        final defaultStats = DailyStats(date: date);
        _mockDailyStats[date] = defaultStats;
        return defaultStats;
      }
    }

    final db = await instance.database;
    final maps = await db.query(
      'daily_stats',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (maps.isNotEmpty) {
      return DailyStats.fromMap(maps.first);
    } else {
      // Create a default entry for this date if it doesn't exist yet
      final defaultStats = DailyStats(date: date);
      await insertDailyStats(defaultStats);
      return defaultStats;
    }
  }

  Future<void> insertDailyStats(DailyStats stats) async {
    if (kIsWeb) {
      _mockDailyStats[stats.date] = stats;
      return;
    }

    final db = await instance.database;
    await db.insert(
      'daily_stats',
      stats.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDailyStats(DailyStats stats) async {
    if (kIsWeb) {
      _mockDailyStats[stats.date] = stats;
      return;
    }

    final db = await instance.database;
    await db.update(
      'daily_stats',
      stats.toMap(),
      where: 'date = ?',
      whereArgs: [stats.date],
    );
  }

  Future<List<DailyStats>> getWeeklyStats(String startDate, String endDate) async {
    if (kIsWeb) {
      final List<DailyStats> results = [];
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      
      for (var dateStr in _mockDailyStats.keys) {
        final date = DateTime.parse(dateStr);
        if ((date.isAfter(start) || date.isAtSameMomentAs(start)) &&
            (date.isBefore(end) || date.isAtSameMomentAs(end))) {
          results.add(_mockDailyStats[dateStr]!);
        }
      }
      results.sort((a, b) => a.date.compareTo(b.date));
      return results;
    }

    final db = await instance.database;
    final maps = await db.query(
      'daily_stats',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );

    return maps.map((map) => DailyStats.fromMap(map)).toList();
  }

  // --- Workouts Queries ---

  Future<Workout> insertWorkout(Workout workout) async {
    if (kIsWeb) {
      final savedWorkout = workout.copyWith(id: _mockWorkoutIdCounter++);
      _mockWorkouts.add(savedWorkout);
      return savedWorkout;
    }

    final db = await instance.database;
    final id = await db.insert('workouts', workout.toMap());
    return workout.copyWith(id: id);
  }

  Future<List<Workout>> getWorkoutsForDate(String date) async {
    if (kIsWeb) {
      return _mockWorkouts.where((w) {
        final wDate = w.timestamp.toIso8601String().substring(0, 10);
        return wDate == date;
      }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    final db = await instance.database;
    // Matching ISO8601 timestamps starting with YYYY-MM-DD
    final maps = await db.query(
      'workouts',
      where: 'timestamp LIKE ?',
      whereArgs: ['$date%'],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => Workout.fromMap(map)).toList();
  }

  Future<List<Workout>> getWeeklyWorkouts(String startDate, String endDate) async {
    if (kIsWeb) {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return _mockWorkouts.where((w) {
        final wDate = DateTime(w.timestamp.year, w.timestamp.month, w.timestamp.day);
        return (wDate.isAfter(start) || wDate.isAtSameMomentAs(start)) &&
            (wDate.isBefore(end) || wDate.isAtSameMomentAs(end));
      }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }

    final db = await instance.database;
    // Filter workouts in range. Since timestamps are strings, we match prefix dates
    // Using SUBSTR(timestamp, 1, 10) to compare only dates
    final maps = await db.query(
      'workouts',
      where: 'SUBSTR(timestamp, 1, 10) BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => Workout.fromMap(map)).toList();
  }

  Future<int> deleteWorkout(int id) async {
    if (kIsWeb) {
      final initialLength = _mockWorkouts.length;
      _mockWorkouts.removeWhere((w) => w.id == id);
      return initialLength - _mockWorkouts.length;
    }

    final db = await instance.database;
    return await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db.close();
  }
}
