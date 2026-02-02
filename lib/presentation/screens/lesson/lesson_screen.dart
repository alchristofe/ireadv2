import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/widgets/custom_button.dart';
import 'package:iread/core/widgets/animated_text.dart';
import 'package:iread/core/widgets/progress_bar.dart';
import 'package:iread/core/routes/route_names.dart';
import 'package:iread/core/utils/audio_player_util.dart';
import 'package:iread/core/utils/speech_recognition_util.dart';

import 'package:iread/data/models/language.dart';
import 'package:iread/data/models/phonics_unit.dart';
import 'package:iread/data/models/word_example.dart';
import 'package:iread/data/repositories/lesson_repository.dart';
import 'package:iread/core/widgets/listening_button.dart';
import 'package:iread/data/repositories/progress_repository.dart';
import 'package:iread/core/widgets/app_rive_animation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'dart:async';

/// Main lesson screen with word examples and speech recognition
class LessonScreen extends StatefulWidget {
  final String unitId;
  final String languageType;

  const LessonScreen({
    super.key,
    required this.unitId,
    required this.languageType,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  final LessonRepository _lessonRepository = LessonRepository();
  final ProgressRepository _progressRepository = ProgressRepository();

  PhonicsUnit? _unit;
  int _currentWordIndex = 0;
  bool _isLoading = true;
  bool _isAudioPlaying = false;
  StreamSubscription? _audioSubscription;

  String? _feedbackMessage;
  MatchResult? _matchResult;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _loadLesson();
    _initializeSpeechRecognition();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _audioSubscription = AudioPlayerUtil.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  Future<void> _loadLesson() async {
    final unit = await _lessonRepository.getUnitById(widget.unitId);
    setState(() {
      _unit = unit;
      _isLoading = false;
    });

    // Auto-play audio when loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _playAudio();
    });
  }

  Future<void> _initializeSpeechRecognition() async {
    // Pre-warm the engine for the current language
    await SpeechRecognitionUtil.preWarm(
      LanguageType.fromString(widget.languageType),
    );
  }

  WordExample? get _currentWord {
    if (_unit == null || _unit!.examples.isEmpty) return null;
    return _unit!.examples[_currentWordIndex];
  }

  double get _progress {
    if (_unit == null || _unit!.examples.isEmpty) return 0.0;
    return (_currentWordIndex + 1) / _unit!.examples.length;
  }

  Future<void> _playAudio() async {
    if (_currentWord != null) {
      await AudioPlayerUtil.playAudio(_currentWord!.audioAsset);
    }
  }

  void _onListeningStarted() {
    setState(() {
      _feedbackMessage = null;
      _matchResult = null;
    });
  }

  Future<void> _onSpeechResult(String? recognizedText) async {
    if (_currentWord == null) return;

    if (recognizedText != null && recognizedText.isNotEmpty) {
      final result = SpeechRecognitionUtil.compareWords(
        recognizedText,
        _currentWord!.word,
      );

      setState(() {
        _matchResult = result;
        if (result == MatchResult.exact) {
          _feedbackMessage = LanguageType.fromString(
            widget.languageType,
          ).correctFeedback;
        } else if (result == MatchResult.partial) {
          _feedbackMessage = LanguageType.fromString(
            widget.languageType,
          ).almostCorrectFeedback;
        } else {
          _feedbackMessage =
              '${LanguageType.fromString(widget.languageType).incorrectFeedbackPrefix} "$recognizedText"${LanguageType.fromString(widget.languageType).incorrectFeedbackSuffix}';
        }
      });

      if (result == MatchResult.exact) {
        await AudioPlayerUtil.playCorrectSound();
        await _progressRepository.recordAttempt(widget.unitId, isCorrect: true);
        await _progressRepository.markWordCompleted(
          widget.unitId,
          _currentWord!.id,
        );
      } else if (result == MatchResult.partial) {
        await AudioPlayerUtil.playTapSound(); // Or a "Close" sound if available
      } else {
        await AudioPlayerUtil.playIncorrectSound();
        await _progressRepository.recordAttempt(
          widget.unitId,
          isCorrect: false,
        );
      }
    } else {
      setState(() {
        _feedbackMessage = LanguageType.fromString(
          widget.languageType,
        ).noSoundFeedback;
        _matchResult = MatchResult.none;
      });
    }
  }

  void _nextWord() {
    setState(() {
      _feedbackMessage = null;
      _matchResult = null;
    });

    if (_unit != null && _currentWordIndex < _unit!.examples.length - 1) {
      setState(() {
        _currentWordIndex++;
      });
      _playAudio(); // Auto-play next word
    } else {
      // Lesson completed
      _completeLesson();
    }
  }

  void _previousWord() {
    if (_currentWordIndex > 0) {
      setState(() {
        _currentWordIndex--;
        _feedbackMessage = null;
        _matchResult = null;
      });
      _playAudio(); // Auto-play previous word
    }
  }

  Future<void> _completeLesson() async {
    await _progressRepository.markUnitComplete(widget.unitId);
    await AudioPlayerUtil.playCelebrationSound();

    final message = LanguageType.fromString(
      widget.languageType,
    ).getCompletionMessage(_unit!.letter);

    if (mounted) {
      context.pushReplacement(
        RouteNames.congratulations,
        extra: {
          'unitId': widget.unitId,
          'categoryId': _unit!.categoryId,
          'message': message,
          'language': widget.languageType,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_unit == null || _currentWord == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            LanguageType.fromString(widget.languageType).lessonNotFoundLabel,
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      // Progress Bar
                      ProgressBar(progress: _progress),
                      const SizedBox(height: 16),

                      // Rive Character Animation
                      const SizedBox(
                        width: 120,
                        height: 120,
                        child: AppRiveAnimation.asset(
                          'assets/rive/antfly.riv',
                          animations: ['idle'],
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedTypewriterText(
                        text:
                            '${LanguageType.fromString(widget.languageType).sayTheWordLabel}: ${_currentWord!.word}',
                        style: AppTextStyles.heading3.copyWith(
                          color: const Color(0xFF3D2C29),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        duration: const Duration(milliseconds: 60),
                      ),
                      const SizedBox(height: 16),

                      // Letter Display
                      Text(
                        _unit!.letter.toUpperCase(),
                        style: AppTextStyles.letterDisplay,
                      ),
                      const SizedBox(height: 20),

                      // Word Image and Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.cardBorder,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _currentWord!.imageAsset.isNotEmpty
                                  ? (_currentWord!.imageAsset.startsWith(
                                          'assets/',
                                        )
                                        ? Image.asset(
                                            _currentWord!.imageAsset,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      size: 60,
                                                      color: AppColors
                                                          .disabledGray,
                                                    ),
                                                  );
                                                },
                                          )
                                        : (!kIsWeb
                                              ? Image.file(
                                                  io.File(
                                                    _currentWord!.imageAsset,
                                                  ),
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return const Center(
                                                          child: Icon(
                                                            Icons.image,
                                                            size: 60,
                                                            color: AppColors
                                                                .disabledGray,
                                                          ),
                                                        );
                                                      },
                                                )
                                              : const Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 60,
                                                    color:
                                                        AppColors.disabledGray,
                                                  ),
                                                )))
                                  : const Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 60,
                                        color: AppColors.disabledGray,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentWord!.word,
                            style: AppTextStyles.wordLabel,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Feedback Message
                      if (_feedbackMessage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: _matchResult == MatchResult.exact
                                ? AppColors.success.withValues(alpha: 0.1)
                                : (_matchResult == MatchResult.partial
                                      ? AppColors.warning.withValues(alpha: 0.1)
                                      : AppColors.error.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _matchResult == MatchResult.exact
                                  ? AppColors.success
                                  : (_matchResult == MatchResult.partial
                                        ? AppColors.warning
                                        : AppColors.error),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _matchResult == MatchResult.exact
                                    ? Icons.check_circle
                                    : (_matchResult == MatchResult.partial
                                          ? Icons.info_outline
                                          : Icons.cancel),
                                color: _matchResult == MatchResult.exact
                                    ? AppColors.success
                                    : (_matchResult == MatchResult.partial
                                          ? AppColors.warning
                                          : AppColors.error),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _feedbackMessage!,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: _matchResult == MatchResult.exact
                                        ? AppColors.success
                                        : (_matchResult == MatchResult.partial
                                              ? AppColors.warning
                                              : AppColors.error),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEEDDB8), // Soft beige
              ),
              child: Column(
                children: [
                  // Control Buttons
                  Row(
                    children: [
                      // Audio Button
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: _isAudioPlaying
                                    ? [
                                        BoxShadow(
                                          color: AppColors.secondary.withValues(
                                            alpha: 0.6,
                                          ),
                                          blurRadius: 8 + _glowAnimation.value,
                                          spreadRadius:
                                              1 + (_glowAnimation.value / 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: child,
                            );
                          },
                          child: ElevatedButton(
                            onPressed: _playAudio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Icon(
                              Icons.volume_up,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Mic Button
                      Expanded(
                        flex: 2,
                        child: ListeningButton(
                          languageType: widget.languageType,
                          onListeningStarted: _onListeningStarted,
                          onResult: _onSpeechResult,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Navigation Buttons
                  Row(
                    children: [
                      if (_currentWordIndex > 0)
                        Expanded(
                          child: CustomButton(
                            text: LanguageType.fromString(
                              widget.languageType,
                            ).previousLabel,
                            onPressed: _previousWord,
                            backgroundColor: AppColors.textMedium,
                          ),
                        ),
                      if (_currentWordIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: _matchResult == MatchResult.exact
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.6,
                                          ),
                                          blurRadius: 10 + _glowAnimation.value,
                                          spreadRadius:
                                              2 + (_glowAnimation.value / 2),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 5 + _glowAnimation.value,
                                          spreadRadius:
                                              _glowAnimation.value / 4,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: child,
                            );
                          },
                          child: CustomButton(
                            text: _currentWordIndex < _unit!.examples.length - 1
                                ? LanguageType.fromString(
                                    widget.languageType,
                                  ).nextLabel
                                : LanguageType.fromString(
                                    widget.languageType,
                                  ).finishLabel,
                            onPressed: _nextWord,
                            backgroundColor: _matchResult == MatchResult.exact
                                ? AppColors.success
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _glowController.dispose();
    AudioPlayerUtil.stopAudio();
    super.dispose();
  }
}
