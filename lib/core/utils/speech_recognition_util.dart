import 'dart:async';
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vosk_flutter/vosk_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/language.dart';

/// Result of speech comparison
enum MatchResult { exact, partial, none }

/// Speech recognition utility for pronunciation checking
class SpeechRecognitionUtil {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static VoskFlutterPlugin? _vosk;
  static Model? _voskModelEn;
  static Model? _voskModelTl;
  static Recognizer? _voskRecognizerEn;
  static Recognizer? _voskRecognizerTl;
  static SpeechService? _voskService;

  static bool _isInitialized = false;
  static bool _isVoskInitialized = false;
  static String _currentLocale = 'en-US';

  static Completer<void>? _voskInitCompleter;

  /// Initialize speech recognition
  static Function(dynamic)? _onNativeError;

  /// Initialize speech recognition
  static Future<bool> initialize() async {
    // 1. Initialize Native Speech to Text
    try {
      if (!_isInitialized) {
        _isInitialized = await _speech.initialize(
          onError: (error) {
            debugPrint('Native Speech error: $error');
            _onNativeError?.call(error);
          },
          onStatus: (status) => debugPrint('Native Speech status: $status'),
        );
      }
    } catch (e) {
      debugPrint('Error initializing native speech: $e');
    }

    // 2. Initialize Vosk (Offline Fallback)
    if (!kIsWeb) {
      try {
        if (!_isVoskInitialized) {
          debugPrint('Initializing Vosk...');
          _vosk = VoskFlutterPlugin.instance();

          // Load English Model
          debugPrint('Loading English Model...');
          final modelPathEn = await ModelLoader().loadFromAssets(
            'assets/models/vosk-model-small-en-us-0.15.zip',
          );
          _voskModelEn = await _vosk?.createModel(modelPathEn);

          // Load Filipino Model
          debugPrint('Loading Filipino Model...');
          final modelPathTl = await ModelLoader().loadFromAssets(
            'assets/models/vosk-model-tl-ph-generic-0.6.zip',
          );
          _voskModelTl = await _vosk?.createModel(modelPathTl);

          // Create Recognizers
          if (_voskModelEn != null) {
            _voskRecognizerEn = await _vosk?.createRecognizer(
              model: _voskModelEn!,
              sampleRate: 16000,
            );
          }

          if (_voskModelTl != null) {
            _voskRecognizerTl = await _vosk?.createRecognizer(
              model: _voskModelTl!,
              sampleRate: 16000,
            );
          }

          _isVoskInitialized =
              true; // Mark as init if at least attempted loading
          debugPrint('Vosk Offline Speech Initialized Successfully');
        }
      } catch (e) {
        debugPrint('Error initializing Vosk: $e');
      }
    } else {
      debugPrint('Vosk is not supported on Web. Skipping initialization.');
    }

    return _isInitialized || _isVoskInitialized;
  }

  /// Check if speech recognition is available
  static bool isAvailable() {
    return (_isInitialized && _speech.isAvailable) || _isVoskInitialized;
  }

  /// Set language for recognition
  static void setLanguage(LanguageType language) {
    _currentLocale = language.code;
  }

  /// Listen for speech and return recognized text
  static Future<String?> listen({
    required LanguageType language,
    Duration timeout = const Duration(seconds: 3),
    Function(double)? onSoundLevelChange,
  }) async {
    // Ensure both engines are initialized if possible
    await preWarm(language);

    setLanguage(language);

    String? result;

    // 1. Try Vosk (Offline) first
    if (_isVoskInitialized) {
      debugPrint('Attempting Vosk Offline Speech...');
      try {
        result = await _listenVosk(language, timeout, onSoundLevelChange);
      } catch (e) {
        debugPrint('Vosk attempt failed with error: $e');
      }
    } else {
      debugPrint('Vosk is NOT initialized. Skipping.');
    }

    // 2. If Vosk returned a result, return it
    if (result != null && result.isNotEmpty) {
      debugPrint('Vosk Speech Success: $result');
      return result;
    }

    // 3. Fallback to Native Speech Recognition if Vosk failed or returned nothing
    // BUT: If we are offline, Native Speech will fail with 'error_language_unavailable'.
    if (_isInitialized && _speech.isAvailable) {
      debugPrint(
        'Vosk failed or returned nothing. Attempting Native Speech fallback...',
      );
      final nativeResult = await _listenNative(
        language,
        timeout,
        onSoundLevelChange,
      );
      if (nativeResult != null) return nativeResult;
    } else {
      debugPrint('Native Speech is NOT initialized or available.');
    }

    return null;
  }

  static Future<String?> _listenNative(
    LanguageType language,
    Duration timeout,
    Function(double)? onSoundLevelChange,
  ) async {
    final completer = Completer<String?>();
    String recognizedText = '';

    // Hook into the native error callback to fail fast
    _onNativeError = (error) {
      if (!completer.isCompleted) {
        debugPrint('Native Speech fail-fast triggered.');
        completer.complete(null);
      }
    };

    try {
      final timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          _speech.stop();
          completer.complete(recognizedText.isNotEmpty ? recognizedText : null);
        }
      });

      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            recognizedText = result.recognizedWords;
          }
          if (result.finalResult && !completer.isCompleted) {
            timer.cancel();
            completer.complete(recognizedText);
          }
        },
        onSoundLevelChange: onSoundLevelChange,
        localeId: _currentLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
        ),
      );
      return await completer.future;
    } catch (e) {
      debugPrint('Native Speech Error: $e');
      return null;
    } finally {
      _onNativeError = null; // Clean up
    }
  }

  static Recognizer? _currentVoskRecognizer;

  static Future<String?> _listenVosk(
    LanguageType language,
    Duration timeout,
    Function(double)? onSoundLevelChange,
  ) async {
    Recognizer? targetRecognizer;

    // Select appropriate recognizer based on language
    if (language.code == 'en-US' || language.code == 'en') {
      targetRecognizer = _voskRecognizerEn;
    } else if (language.code == 'fil-PH' ||
        language.code == 'tl-PH' ||
        language.code == 'fil' ||
        language.code == 'hil-PH') {
      targetRecognizer = _voskRecognizerTl;
    } else {
      debugPrint('Vosk model not supported for ${language.code}');
      return null;
    }

    if (targetRecognizer == null) {
      debugPrint('Vosk recognizer for ${language.code} is missing.');
      return null;
    }

    // Check if service is ready (should be from pre-warming)
    if (_voskService == null || _currentVoskRecognizer != targetRecognizer) {
      debugPrint('Vosk service not ready or mismatch. Re-initializing...');
      await _initVoskService(language);
    }

    if (_voskService == null) return null;

    final completer = Completer<String?>();
    String recognizedText = '';

    // Use a flag to track if we've received any actual speech to extend timeout
    bool detectedSpeech = false;

    try {
      await _voskService!.start();

      // Partial results for early matching and UI feedback
      final partialSub = _voskService!.onPartial().listen((event) {
        final text = _extractTextFromJson(event);
        if (text.isNotEmpty) {
          detectedSpeech = true;
          debugPrint('Vosk Partial: $text');
          onSoundLevelChange?.call(
            5.0,
          ); // Simulate some noise level when text is being formed

          // Optimization: If partial exactly matches target, we could return early,
          // but comparing logic is in the screen/caller.
        }
      });

      final resultSub = _voskService!.onResult().listen((event) {
        final text = _extractTextFromJson(event);
        if (text.isNotEmpty) {
          recognizedText = text;
          debugPrint('Vosk Result (Intermediate): $recognizedText');
        }
      });

      // Timeout management
      Timer? timeoutTimer;
      void startTimeout(Duration duration) {
        timeoutTimer?.cancel();
        timeoutTimer = Timer(duration, () async {
          if (!completer.isCompleted) {
            await _voskService!.stop();
            partialSub.cancel();
            resultSub.cancel();
            completer.complete(
              recognizedText.isNotEmpty ? recognizedText : null,
            );
          }
        });
      }

      startTimeout(timeout);

      // We occasionally check if speech was detected to extend the timeout slightly
      // giving the user more time to finish their word.
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (completer.isCompleted) {
          timer.cancel();
          return;
        }
        if (detectedSpeech) {
          // If we detected speech, give it another 1.5s from now to finish
          startTimeout(const Duration(milliseconds: 1500));
          timer.cancel();
        }
      });

      return await completer.future;
    } catch (e) {
      debugPrint('Vosk Error: $e');
      return null;
    }
  }

  static String _extractTextFromJson(String jsonStr) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      return (data['text'] ?? data['partial'] ?? '') as String;
    } catch (e) {
      debugPrint('Error parsing Vosk JSON: $e');
    }
    return '';
  }

  /// Stop listening
  static Future<void> stop() async {
    if (_isInitialized) await _speech.stop();
    if (_isVoskInitialized) await _voskService?.stop();
  }

  /// Check if currently listening
  static bool isListening() {
    return _speech
        .isListening; // Simplified, mainly for UI feedback which relies on native mostly
  }

  /// Compare recognized text with target word
  static MatchResult compareWords(String recognized, String target) {
    if (recognized.isEmpty || target.isEmpty) return MatchResult.none;

    // Normalize both strings for comparison
    final normalizedRecognized = recognized.toLowerCase().trim();
    final normalizedTarget = target.toLowerCase().trim();

    // 1. Exact match
    if (normalizedRecognized == normalizedTarget) return MatchResult.exact;

    // 2. Check if recognized text contains the target word (as a whole word)
    final words = normalizedRecognized.split(' ');
    if (words.contains(normalizedTarget)) return MatchResult.exact;

    // 3. Special handling for single letters/short words
    if (normalizedTarget.length <= 3) {
      // Check homophone map for English
      if (_englishLetterHomophones.containsKey(normalizedTarget)) {
        final homophones = _englishLetterHomophones[normalizedTarget]!;
        for (final phone in homophones) {
          if (normalizedRecognized.contains(phone)) return MatchResult.exact;
        }
      }

      final similarity = _calculateSimilarity(
        normalizedRecognized,
        normalizedTarget,
      );
      if (similarity >= 0.8) return MatchResult.exact;
      if (similarity >= 0.5) return MatchResult.partial;
      return MatchResult.none;
    }

    // 4. Calculate similarity (Levenshtein distance based) for longer words
    final similarity = _calculateSimilarity(
      normalizedRecognized,
      normalizedTarget,
    );

    if (similarity >= 0.8) return MatchResult.exact;

    // Fuzzy matching for partial pronunciations
    // Check if recognized is a prefix of target (e.g., "app" for "apple")
    if (normalizedTarget.startsWith(normalizedRecognized) &&
        normalizedRecognized.length >= 3) {
      return MatchResult.partial;
    }

    if (similarity >= 0.6) return MatchResult.partial;

    return MatchResult.none;
  }

  /// Pre-warm the speech engines for a specific language
  static Future<void> preWarm(LanguageType language) async {
    // 1. Initialize Native (lightweight)
    if (!isAvailable()) await initialize();

    // 2. Initialize Vosk (heavyweight)
    if (!kIsWeb) {
      if (!_isVoskInitialized || _currentVoskRecognizer == null) {
        debugPrint('Pre-warming Vosk for ${language.code}...');
        await _initVoskService(language);
      } else {
        // Check if we need to switch language
        if (language.code == 'en-US' || language.code == 'en') {
          if (_currentVoskRecognizer != _voskRecognizerEn) {
            await _initVoskService(language);
          }
        } else if (language.code == 'fil-PH' ||
            language.code == 'tl-PH' ||
            language.code == 'fil' ||
            language.code == 'hil-PH') {
          if (_currentVoskRecognizer != _voskRecognizerTl) {
            await _initVoskService(language);
          }
        }
      }
    }
  }

  static Future<void> _initVoskService(LanguageType language) async {
    // Use a completer to prevent concurrent initialization attempts
    if (_voskInitCompleter != null && !_voskInitCompleter!.isCompleted) {
      await _voskInitCompleter!.future;
    }

    Recognizer? targetRecognizer = _getTargetRecognizer(language);
    if (targetRecognizer == null) return;

    if (_voskService != null && _currentVoskRecognizer == targetRecognizer) {
      return; // Already initialized with correct recognizer
    }

    _voskInitCompleter = Completer<void>();

    try {
      if (_voskService != null) {
        debugPrint('Disposing existing Vosk service...');
        try {
          await _voskService?.stop();
          await _voskService?.dispose();
        } catch (e) {
          debugPrint('Non-critical error disposing old Vosk service: $e');
        }
        _voskService = null;
      }

      try {
        debugPrint('Calling initSpeechService...');
        _voskService = await _vosk?.initSpeechService(targetRecognizer);
        _currentVoskRecognizer = targetRecognizer;
        debugPrint('Vosk service initialized for ${language.code}');
      } catch (e) {
        final errorStr = e.toString();
        if (errorStr.contains('SpeechService instance already exist')) {
          debugPrint(
            'Vosk SpeechService already exists in native layer. Clearing state for retry...',
          );
          // If we reached here, _voskService is null but native thinks it's not.
          // We clear the recognizer so we at least try again later.
          _currentVoskRecognizer = null;
          _voskService = null;
        } else {
          debugPrint('Error starting Vosk service: $e');
        }
      }
    } finally {
      if (!_voskInitCompleter!.isCompleted) {
        _voskInitCompleter!.complete();
      }
    }
  }

  static Recognizer? _getTargetRecognizer(LanguageType language) {
    if (language.code == 'en-US' || language.code == 'en') {
      return _voskRecognizerEn;
    } else if (language.code == 'fil-PH' ||
        language.code == 'tl-PH' ||
        language.code == 'fil' ||
        language.code == 'hil-PH') {
      return _voskRecognizerTl;
    }
    return null;
  }

  /// Calculate string similarity (Levenshtein distance based)
  static double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final len1 = s1.length;
    final len2 = s2.length;
    final maxLen = len1 > len2 ? len1 : len2;

    final distance = _levenshteinDistance(s1, s2);
    return 1.0 - (distance / maxLen);
  }

  /// Levenshtein distance algorithm
  static int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    for (var i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  // Homophone map for English letters (Names + Phonic Sounds)
  static final Map<String, List<String>> _englishLetterHomophones = {
    'a': ['ay', 'ey', 'eh', 'hey', 'ah', 'ahh', 'ae', 'aa', 'apple'],
    'b': ['bee', 'be', 'bi', 'buh', 'bah', 'beh'],
    'c': ['see', 'sea', 'si', 'kuh', 'kah', 'keh', 'cat'],
    'd': ['dee', 'di', 'the', 'duh', 'dah', 'deh'],
    'e': ['ee', 'ea', 'eh', 'hey', 'egg'],
    'f': ['ef', 'eff', 'fuh', 'fff'],
    'g': ['jee', 'ji', 'gee', 'guh', 'gah'],
    'h': ['aitch', 'etch', 'age', 'huh', 'hah', 'heh'],
    'i': ['eye', 'aye', 'high', 'ih', 'igloo'],
    'j': ['jay', 'jei', 'juh', 'jah'],
    'k': ['kay', 'key', 'cay', 'kuh', 'kah'],
    'l': ['el', 'ell', 'ale', 'lll', 'luh'],
    'm': ['em', 'am', 'hem', 'mmm', 'muh'],
    'n': ['en', 'an', 'hen', 'nnn', 'nuh'],
    'o': ['oh', 'ow', 'owe', 'aw', 'october'],
    'p': ['pee', 'pea', 'pi', 'puh', 'pah'],
    'q': ['cue', 'kue', 'queue', 'kwuh'],
    'r': ['are', 'ar', 'hour', 'rrr', 'ruh'],
    's': ['ess', 'es', 'yes', 'sss', 'suh'],
    't': ['tee', 'tea', 'ti', 'tuh', 'tah'],
    'u': ['you', 'yoo', 'ewe', 'uh', 'umbrella'],
    'v': ['vee', 'vi', 'we', 'vuh', 'vah'],
    'w': ['double', 'dub', 'u', 'wuh', 'wah'],
    'x': ['ex', 'axe', 'ks', 'kss'],
    'y': ['why', 'wai', 'yuh', 'yah'],
    'z': ['zee', 'zed', 'zzz', 'zuh'],
  };
}
