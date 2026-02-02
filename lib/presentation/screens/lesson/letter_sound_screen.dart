import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/routes/route_names.dart';
import 'package:iread/core/widgets/custom_button.dart';
import 'package:iread/core/widgets/speech_bubble.dart';
import 'package:iread/core/utils/audio_player_util.dart';
import 'package:iread/core/utils/speech_recognition_util.dart';

import 'package:iread/data/models/language.dart';
import 'package:iread/data/models/phonics_unit.dart';
import 'package:iread/data/repositories/lesson_repository.dart';
import 'package:iread/core/widgets/listening_button.dart';

import 'package:iread/core/widgets/app_rive_animation.dart';
import 'dart:async';

class LetterSoundScreen extends StatefulWidget {
  final String unitId;
  final String languageType;

  const LetterSoundScreen({
    super.key,
    required this.unitId,
    required this.languageType,
  });

  @override
  State<LetterSoundScreen> createState() => _LetterSoundScreenState();
}

class _LetterSoundScreenState extends State<LetterSoundScreen>
    with SingleTickerProviderStateMixin {
  final LessonRepository _lessonRepository = LessonRepository();
  PhonicsUnit? _unit;
  bool _isLoading = true;

  String? _feedbackMessage;
  MatchResult? _matchResult;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isAudioPlaying = false;
  StreamSubscription? _audioSubscription;

  @override
  void initState() {
    super.initState();
    _loadUnit();
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

  Future<void> _loadUnit() async {
    try {
      final unit = await _lessonRepository.getUnitById(widget.unitId);
      if (mounted) {
        setState(() {
          _unit = unit;
          _isLoading = false;
        });
        // Auto-play audio when loaded
        _playAudio();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading unit: $e')));
      }
    }
  }

  Future<void> _initializeSpeechRecognition() async {
    await SpeechRecognitionUtil.preWarm(
      LanguageType.fromString(widget.languageType),
    );
  }

  Future<void> _playAudio() async {
    if (_unit != null) {
      String audioPath;
      if (_unit!.letterAudio != null && _unit!.letterAudio!.isNotEmpty) {
        audioPath = _unit!.letterAudio!;
      } else {
        // Fallback to convention
        final language = widget.languageType.toLowerCase();
        final letter = _unit!.letter.toUpperCase();
        audioPath = 'assets/audio/$language/letter_$letter.mp3';
      }

      await AudioPlayerUtil.playAudio(audioPath);
    }
  }

  void _onListeningStarted() {
    setState(() {
      _feedbackMessage = null;
      _matchResult = null;
    });
  }

  Future<void> _onSpeechResult(String? recognizedText) async {
    if (_unit == null) return;

    if (recognizedText != null && recognizedText.isNotEmpty) {
      final letterResult = SpeechRecognitionUtil.compareWords(
        recognizedText,
        _unit!.letter,
      );
      final soundResult = SpeechRecognitionUtil.compareWords(
        recognizedText,
        _unit!.sound.replaceAll('/', ''),
      );

      // Take the best result
      MatchResult finalResult;
      if (letterResult == MatchResult.exact ||
          soundResult == MatchResult.exact) {
        finalResult = MatchResult.exact;
      } else if (letterResult == MatchResult.partial ||
          soundResult == MatchResult.partial) {
        finalResult = MatchResult.partial;
      } else {
        finalResult = MatchResult.none;
      }

      setState(() {
        _matchResult = finalResult;
        if (finalResult == MatchResult.exact) {
          _feedbackMessage = LanguageType.fromString(
            widget.languageType,
          ).correctFeedback;
        } else if (finalResult == MatchResult.partial) {
          _feedbackMessage = LanguageType.fromString(
            widget.languageType,
          ).almostCorrectFeedback;
        } else {
          _feedbackMessage =
              '${LanguageType.fromString(widget.languageType).incorrectFeedbackPrefix} "$recognizedText"${LanguageType.fromString(widget.languageType).incorrectFeedbackSuffix}';
        }
      });

      if (finalResult == MatchResult.exact) {
        await AudioPlayerUtil.playCorrectSound();
      } else if (finalResult == MatchResult.partial) {
        await AudioPlayerUtil.playTapSound();
      } else {
        await AudioPlayerUtil.playIncorrectSound();
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

  void _onContinue() {
    context.pushReplacement(
      RouteNames.lesson,
      extra: {'unitId': widget.unitId, 'languageType': widget.languageType},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_unit == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            LanguageType.fromString(widget.languageType).unitNotFoundLabel,
          ),
        ),
      );
    }

    final instructionText = LanguageType.fromString(
      widget.languageType,
    ).getLetterInstruction(_unit!.letter.toUpperCase(), _unit!.sound);

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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Character and Speech Bubble
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 120,
                            height: 150,
                            child: AppRiveAnimation.asset(
                              'assets/rive/antfly.riv',
                              animations: ['idle'],
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SpeechBubble(
                              text: instructionText,
                              tailOnLeft: true,
                              backgroundColor: const Color(0xFFFFF9F0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Large Letter Card
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _unit!.letter.toUpperCase(),
                            style: AppTextStyles.letterDisplay.copyWith(
                              fontSize: 120,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        '${LanguageType.fromString(widget.languageType).pronunciationLabel}: /${_unit!.sound.replaceAll('/', '')}/',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMedium,
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Feedback Message
                      if (_feedbackMessage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
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
              decoration: const BoxDecoration(color: Color(0xFFEEDDB8)),
              child: Column(
                children: [
                  // Control Buttons (Audio & Mic)
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

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: LanguageType.fromString(
                        widget.languageType,
                      ).continueLabel,
                      onPressed: _onContinue,
                      backgroundColor: Colors.orange,
                      textColor: Colors.white,
                    ),
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
