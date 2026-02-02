import '../models/language.dart';
import '../models/phonics_category.dart';
import '../models/phonics_unit.dart';
import '../models/word_example.dart';
import '../local/json_loader.dart';
import '../local/hive_service.dart';
import 'package:flutter/foundation.dart';

/// Repository for managing lesson content
class LessonRepository {
  /// Get all categories for a specific language
  Future<List<PhonicsCategory>> getCategoriesByLanguage(
    LanguageType language,
  ) async {
    return await JsonLoader.getCategoriesByLanguage(language);
  }

  /// Get all units for a specific language (merging local JSON and Hive data)
  Future<List<PhonicsUnit>> getUnitsByLanguage(LanguageType language) async {
    // 1. Load base units from JSON
    final baseUnits = await JsonLoader.getUnitsByLanguage(language);
    
    // 2. Load custom/edited units from Hive
    final box = HiveService.lessonsBox;
    final customUnitsMap = box.toMap();
    
    // 3. Merge: Hive data overrides JSON data if IDs match
    final Map<String, PhonicsUnit> mergedUnits = {
      for (var unit in baseUnits) unit.id: unit,
    };

    for (var key in customUnitsMap.keys) {
      try {
        final dynamic value = customUnitsMap[key];
        if (value is Map) {
          final unitJson = Map<String, dynamic>.from(value);
          final unit = PhonicsUnit.fromJson(unitJson);
          if (unit.language == language) {
            mergedUnits[unit.id] = unit;
          }
        }
      } catch (e) {
        debugPrint('Error parsing custom unit $key: $e');
        // Continue to next item
      }
    }

    return mergedUnits.values.toList();
  }

  /// Get units by category (merging local JSON and Hive data)
  Future<List<PhonicsUnit>> getUnitsByCategory(
    LanguageType language,
    String categoryId,
  ) async {
    final allUnits = await getUnitsByLanguage(language);
    return allUnits.where((u) => u.categoryId == categoryId).toList();
  }

  /// Get a specific unit by ID
  Future<PhonicsUnit?> getUnitById(String unitId) async {
    // Check Hive first
    final box = HiveService.lessonsBox;
    if (box.containsKey(unitId)) {
      final unitJson = Map<String, dynamic>.from(box.get(unitId));
      return PhonicsUnit.fromJson(unitJson);
    }
    // Fallback to JSON
    return await JsonLoader.getUnitById(unitId);
  }

  /// Update or Add a lesson (for teacher mode)
  Future<void> updateLesson(PhonicsUnit unit) async {
    final box = HiveService.lessonsBox;
    await box.put(unit.id, unit.toJson());
  }

  /// Add a word example to a unit
  Future<void> addWordExample(String unitId, WordExample word) async {
    final unit = await getUnitById(unitId);
    if (unit != null) {
      final updatedExamples = List<WordExample>.from(unit.examples)..add(word);
      final updatedUnit = unit.copyWith(examples: updatedExamples);
      await updateLesson(updatedUnit);
    }
  }

  /// Delete a word example from a unit
  Future<void> deleteWordExample(String unitId, String wordId) async {
    final unit = await getUnitById(unitId);
    if (unit != null) {
      final updatedExamples = unit.examples.where((w) => w.id != wordId).toList();
      final updatedUnit = unit.copyWith(examples: updatedExamples);
      await updateLesson(updatedUnit);
    }
  }

  /// Check if a unit can be deleted (exists in Hive, not just JSON)
  bool canDeleteUnit(String unitId) {
    final box = HiveService.lessonsBox;
    return box.containsKey(unitId);
  }

  /// Delete a phonics unit (for teacher mode)
  /// Returns true if deleted successfully, false if unit doesn't exist in Hive
  Future<bool> deleteUnit(String unitId) async {
    final box = HiveService.lessonsBox;
    if (box.containsKey(unitId)) {
      await box.delete(unitId);
      return true;
    }
    return false; // Unit doesn't exist in Hive (might be JSON only)
  }
}
