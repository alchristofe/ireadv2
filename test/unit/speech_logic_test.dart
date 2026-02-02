import 'package:flutter_test/flutter_test.dart';
import 'package:iread/core/utils/speech_recognition_util.dart';

void main() {
  group('SpeechRecognitionUtil.compareWords', () {
    test('Exact matches should return exact result', () {
      expect(
        SpeechRecognitionUtil.compareWords('apple', 'apple'),
        MatchResult.exact,
      );
      expect(
        SpeechRecognitionUtil.compareWords('APPLE', 'apple'),
        MatchResult.exact,
      );
      expect(
        SpeechRecognitionUtil.compareWords('  apple  ', 'apple'),
        MatchResult.exact,
      );
    });

    test('Homophones for letters should return exact result', () {
      expect(SpeechRecognitionUtil.compareWords('ay', 'a'), MatchResult.exact);
      expect(SpeechRecognitionUtil.compareWords('bee', 'b'), MatchResult.exact);
      expect(SpeechRecognitionUtil.compareWords('see', 'c'), MatchResult.exact);
    });

    test('Fuzzy matches should return exact result if similarity >= 0.8', () {
      // "aple" vs "apple" -> len 5, distance 1 -> similarity 1 - 1/5 = 0.8
      expect(
        SpeechRecognitionUtil.compareWords('aple', 'apple'),
        MatchResult.exact,
      );
    });

    test('Partial matches should return partial result', () {
      // "app" for "apple"
      expect(
        SpeechRecognitionUtil.compareWords('app', 'apple'),
        MatchResult.partial,
      );

      // Multi-word results containing target
      expect(
        SpeechRecognitionUtil.compareWords('i see apple', 'apple'),
        MatchResult.exact,
      );
    });

    test('Unrelated words should return none', () {
      expect(
        SpeechRecognitionUtil.compareWords('banana', 'apple'),
        MatchResult.none,
      );
      expect(SpeechRecognitionUtil.compareWords('', 'apple'), MatchResult.none);
    });
  });
}
