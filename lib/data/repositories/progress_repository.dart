import '../models/user_progress.dart';
import '../local/hive_service.dart';

/// Repository for managing user progress
class ProgressRepository {
  /// Get progress for a specific unit
  Future<UserProgress?> getProgress(String unitId) async {
    final box = HiveService.progressBox;
    return box.get(unitId);
  }

  /// Save progress for a unit
  Future<void> saveProgress(UserProgress progress) async {
    final box = HiveService.progressBox;
    await box.put(progress.unitId, progress);
  }

  /// Mark a unit as completed
  Future<void> markUnitComplete(String unitId) async {
    final progress = await getProgress(unitId);
    if (progress != null) {
      progress.markAsCompleted();
      await saveProgress(progress);
    } else {
      final newProgress = UserProgress(unitId: unitId)..markAsCompleted();
      await saveProgress(newProgress);
    }
  }

  /// Record an attempt for a unit
  Future<void> recordAttempt(String unitId, {required bool isCorrect}) async {
    var progress = await getProgress(unitId);
    progress ??= UserProgress(unitId: unitId);
    progress.recordAttempt(isCorrect: isCorrect);
    await saveProgress(progress);
  }

  /// Mark a word as completed in a unit
  Future<void> markWordCompleted(String unitId, String wordId) async {
    var progress = await getProgress(unitId);
    progress ??= UserProgress(unitId: unitId);
    progress.markWordCompleted(wordId);
    await saveProgress(progress);
  }

  /// Get overall progress percentage across all units
  Future<double> getOverallProgress() async {
    final box = HiveService.progressBox;
    if (box.isEmpty) return 0.0;

    int completedUnits = 0;
    int totalUnits = box.length;

    for (final progress in box.values) {
      if (progress.isCompleted) {
        completedUnits++;
      }
    }

    return (completedUnits / totalUnits) * 100;
  }

  /// Get all completed units
  Future<List<String>> getCompletedUnits() async {
    final box = HiveService.progressBox;
    return box.values
        .where((progress) => progress.isCompleted)
        .map((progress) => progress.unitId)
        .toList();
  }

  /// Reset all progress
  Future<void> resetAllProgress() async {
    final box = HiveService.progressBox;
    await box.clear();
  }

  /// Reset progress for a specific unit
  Future<void> resetUnitProgress(String unitId) async {
    final box = HiveService.progressBox;
    await box.delete(unitId);
  }
}
