import 'package:flutter_test/flutter_test.dart';
import 'package:iread/data/models/language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Data Loading Tests', () {
    test('LanguageType.fromString works correctly', () {
      expect(LanguageType.fromString('english'), LanguageType.english);
      expect(LanguageType.fromString('filipino'), LanguageType.filipino);
      expect(LanguageType.fromString('English'), LanguageType.english); // Case insensitive check
    });

    test('JsonLoader loads data correctly', () async {
      // Note: This requires assets to be available in test environment
      // We might need to mock rootBundle if running as unit test
      // But let's see if we can verify the logic structure first
    });
  });
}
