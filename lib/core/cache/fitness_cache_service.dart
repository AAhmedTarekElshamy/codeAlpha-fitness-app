import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class FitnessCacheService {
  static const _selectedDateKey = 'selected_date';
  static const _recommendationKey = 'latest_ai_recommendation';

  Future<void> saveSelectedDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedDateKey, date);
  }

  Future<String?> getSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedDateKey);
  }

  Future<void> saveRecommendation(String recommendation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recommendationKey, recommendation);
  }

  Future<String?> getRecommendation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_recommendationKey);
  }
}
