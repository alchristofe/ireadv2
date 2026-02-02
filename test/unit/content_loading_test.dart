import 'package:flutter_test/flutter_test.dart';
import 'package:iread/data/models/language.dart';
import 'package:iread/data/models/phonics_category.dart';
import 'package:iread/data/models/phonics_unit.dart';
import 'dart:convert';

void main() {
  group('Model Parsing Tests', () {
    const String sampleCategoryJson = '''
    {
      "id": "vowels",
      "type": "vowels",
      "name": "Vowels",
      "description": "Learn vowel sounds",
      "units": [
        {
          "id": "a",
          "letter": "A",
          "sound": "ah",
          "description": "Short A sound",
          "examples": [],
          "categoryId": "vowels",
          "language": "english"
        }
      ]
    }
    ''';

    test('PhonicsCategory.fromJson should correctly map to objects', () {
      final Map<String, dynamic> data = json.decode(sampleCategoryJson);
      final category = PhonicsCategory.fromJson(data);

      expect(category.id, 'vowels');
      expect(category.type, CategoryType.vowels);
      expect(category.units.length, 1);
      expect(category.units[0].letter, 'A');
      expect(category.units[0].language, LanguageType.english);
    });

    test('LanguageType extensions should return correct metadata', () {
      expect(LanguageType.english.displayName, 'English');
      expect(LanguageType.filipino.displayName, 'Filipino');
    });
  });
}
