import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_progress.dart';

/// Hive database service for local storage
class HiveService {
  static const String _progressBoxName = 'progress';
  static const String _settingsBoxName = 'settings';
  static const String _lessonsBoxName = 'lessons';

  /// Initialize Hive database
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProgressAdapter());
    }
    
    // Open boxes
    await Hive.openBox<UserProgress>(_progressBoxName);
    await Hive.openBox(_settingsBoxName);
    await Hive.openBox(_lessonsBoxName);
  }

  /// Get progress box
  static Box<UserProgress> get progressBox {
    return Hive.box<UserProgress>(_progressBoxName);
  }

  /// Get settings box
  static Box get settingsBox {
    return Hive.box(_settingsBoxName);
  }

  /// Get lessons box
  static Box get lessonsBox {
    return Hive.box(_lessonsBoxName);
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }

  /// Clear all data (for testing or reset)
  static Future<void> clearAll() async {
    await progressBox.clear();
    await settingsBox.clear();
  }
}
