import 'package:hive/hive.dart';

part 'user_progress.g.dart';

/// User progress tracking for each phonics unit
@HiveType(typeId: 0)
class UserProgress extends HiveObject {
  @HiveField(0)
  final String unitId;

  @HiveField(1)
  int correctAttempts;

  @HiveField(2)
  int totalAttempts;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime? completedAt;

  @HiveField(5)
  List<String> completedWords;

  UserProgress({
    required this.unitId,
    this.correctAttempts = 0,
    this.totalAttempts = 0,
    this.isCompleted = false,
    this.completedAt,
    List<String>? completedWords,
  }) : completedWords = completedWords ?? [];

  /// Calculate completion percentage
  double get completionPercentage {
    if (totalAttempts == 0) return 0.0;
    return (correctAttempts / totalAttempts) * 100;
  }

  /// Calculate accuracy
  double get accuracy {
    if (totalAttempts == 0) return 0.0;
    return correctAttempts / totalAttempts;
  }

  /// Mark a word as completed
  void markWordCompleted(String wordId) {
    if (!completedWords.contains(wordId)) {
      completedWords.add(wordId);
    }
  }

  /// Record an attempt
  void recordAttempt({required bool isCorrect}) {
    totalAttempts++;
    if (isCorrect) {
      correctAttempts++;
    }
  }

  /// Mark unit as completed
  void markAsCompleted() {
    isCompleted = true;
    completedAt = DateTime.now();
  }

  /// Reset progress
  void reset() {
    correctAttempts = 0;
    totalAttempts = 0;
    isCompleted = false;
    completedAt = null;
    completedWords.clear();
  }

  UserProgress copyWith({
    String? unitId,
    int? correctAttempts,
    int? totalAttempts,
    bool? isCompleted,
    DateTime? completedAt,
    List<String>? completedWords,
  }) {
    return UserProgress(
      unitId: unitId ?? this.unitId,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      completedWords: completedWords ?? this.completedWords,
    );
  }
}
