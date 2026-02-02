import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/speech_recognition_util.dart';
import '../utils/background_music_manager.dart';
import '../utils/audio_player_util.dart';
import '../../data/models/language.dart';

class ListeningButton extends StatefulWidget {
  final String languageType;
  final Function(String?) onResult;
  final VoidCallback? onListeningStarted;
  final VoidCallback? onListeningEnded;

  const ListeningButton({
    super.key,
    required this.languageType,
    required this.onResult,
    this.onListeningStarted,
    this.onListeningEnded,
  });

  @override
  State<ListeningButton> createState() => _ListeningButtonState();
}

class _ListeningButtonState extends State<ListeningButton> {
  bool _isListening = false;
  double _soundLevel = 0.0;
  DateTime _lastSoundUpdate = DateTime.now();

  Future<void> _startListening() async {
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _soundLevel = 0.0;
    });

    widget.onListeningStarted?.call();

    try {
      // Fire-and-forget mute to prevent start-up delay
      BackgroundMusicManager.instance.muteForSpeech();
      // Ensure any active lesson audio is stopped to prevent interference
      await AudioPlayerUtil.stopAudio();

      final language = LanguageType.fromString(widget.languageType);

      final result = await SpeechRecognitionUtil.listen(
        language: language,
        onSoundLevelChange: (level) {
          // Throttle updates to ~60fps (16ms)
          final now = DateTime.now();
          if (now.difference(_lastSoundUpdate).inMilliseconds > 16) {
            if (mounted) {
              setState(() {
                _soundLevel = level;
              });
              _lastSoundUpdate = now;
            }
          }
        },
      );

      if (mounted) {
        widget.onResult(result);
      }
    } catch (e) {
      debugPrint('Error in ListeningButton: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        widget.onResult(null);
      }
    } finally {
      await BackgroundMusicManager.instance.unmuteAfterSpeech();
      if (mounted) {
        setState(() {
          _isListening = false;
          _soundLevel = 0.0;
        });
        widget.onListeningEnded?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine label
    final label = _isListening
        ? LanguageType.fromString(widget.languageType).listeningLabel
        : 'Speak'; // Or use an icon-only approach if preferred, but matching existing design

    // Existing design uses Expanded, but here we are inside a specific container context in the parent usually.
    // We will return the button container.
    // Parent should wrap this in Expanded if needed.

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _isListening
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 10 + (_soundLevel.clamp(0, 10) * 2),
                  spreadRadius: _soundLevel.clamp(0, 5),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: _isListening ? null : _startListening,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isListening
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : const Icon(Icons.mic, size: 28, color: Colors.white),
      ),
    );
  }
}
