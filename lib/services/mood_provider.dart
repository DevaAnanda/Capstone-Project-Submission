import 'package:flutter/material.dart';
import '../models/mood_model.dart';
import '../services/database_helper.dart';

class MoodProvider with ChangeNotifier {
  List<MoodEntry> _moods = [];
  bool _isLoading = false;

  List<MoodEntry> get moods => _moods;
  bool get isLoading => _isLoading;

  // Load all moods from database
  Future<void> loadMoods() async {
    _isLoading = true;
    notifyListeners();

    _moods = await DatabaseHelper.instance.readAllMoods();
    
    _isLoading = false;
    notifyListeners();
  }

  // Add new mood
  Future<void> addMood(MoodEntry mood) async {
    final newMood = await DatabaseHelper.instance.create(mood);
    _moods.insert(0, newMood);
    notifyListeners();
  }

  // Update existing mood
  Future<void> updateMood(MoodEntry mood) async {
    await DatabaseHelper.instance.update(mood);
    final index = _moods.indexWhere((m) => m.id == mood.id);
    if (index != -1) {
      _moods[index] = mood;
      notifyListeners();
    }
  }

  // Delete mood
  Future<void> deleteMood(int id) async {
    await DatabaseHelper.instance.delete(id);
    _moods.removeWhere((mood) => mood.id == id);
    notifyListeners();
  }

  // Get mood statistics
  Future<Map<String, int>> getMoodStatistics() async {
    return await DatabaseHelper.instance.getMoodStatistics();
  }

  // Get moods for a specific date range
  Future<List<MoodEntry>> getMoodsByDateRange(
      DateTime start, DateTime end) async {
    return await DatabaseHelper.instance.readMoodsByDateRange(start, end);
  }
}
