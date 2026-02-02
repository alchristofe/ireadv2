import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/language.dart';
import '../models/phonics_category.dart';
import '../models/phonics_unit.dart';

/// JSON data loader for lessons
class JsonLoader {
  /// Load lessons data from JSON file
  static Future<Map<String, dynamic>> loadLessonsData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/lessons.json');
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading lessons data: $e');
      return {};
    }
  }

  /// Get categories for a specific language
  static Future<List<PhonicsCategory>> getCategoriesByLanguage(
    LanguageType language,
  ) async {
    final data = await loadLessonsData();
    final languages = data['languages'] as List<dynamic>? ?? [];

    for (final lang in languages) {
      final langMap = lang as Map<String, dynamic>;
      if (langMap['type'] == language.name) {
        final categories = langMap['categories'] as List<dynamic>? ?? [];
        return categories
            .map((e) => PhonicsCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

  /// Get all units for a specific language
  static Future<List<PhonicsUnit>> getUnitsByLanguage(
    LanguageType language,
  ) async {
    final categories = await getCategoriesByLanguage(language);
    final List<PhonicsUnit> allUnits = [];

    for (final category in categories) {
      allUnits.addAll(category.units);
    }

    return allUnits;
  }

  /// Get a specific unit by ID
  static Future<PhonicsUnit?> getUnitById(String unitId) async {
    final data = await loadLessonsData();
    final languages = data['languages'] as List<dynamic>? ?? [];

    for (final lang in languages) {
      final langMap = lang as Map<String, dynamic>;
      final categories = langMap['categories'] as List<dynamic>? ?? [];

      for (final cat in categories) {
        final catMap = cat as Map<String, dynamic>;
        final units = catMap['units'] as List<dynamic>? ?? [];

        for (final unit in units) {
          final unitMap = unit as Map<String, dynamic>;
          if (unitMap['id'] == unitId) {
            return PhonicsUnit.fromJson(unitMap);
          }
        }
      }
    }

    return null;
  }
}
