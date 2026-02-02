import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Audio player utility for playing sounds and pronunciations
class AudioPlayerUtil {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();

  static bool _isSfxEnabled = true;

  static bool get isSfxEnabled => _isSfxEnabled;

  static bool get _isTest => const bool.fromEnvironment('flutter.test');

  /// Stream of player state changes
  static Stream<PlayerState> get onPlayerStateChanged =>
      _player.onPlayerStateChanged;

  /// Initialize audio settings
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSfxEnabled = prefs.getBool('sfx_enabled') ?? true;
  }

  /// Toggle SFX on/off
  static Future<void> toggleSfx(bool enabled) async {
    _isSfxEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_enabled', enabled);
  }

  /// Play audio from asset path or local file
  static Future<void> playAudio(String audioPath) async {
    if (_isTest) return;
    try {
      await _player.stop();

      if (audioPath.isEmpty) {
        debugPrint('Audio path is empty');
        return;
      }

      // Check if it's an asset path or local file
      if (audioPath.startsWith('assets/')) {
        // Asset audio - remove 'assets/' prefix for AssetSource
        await _player.play(AssetSource(audioPath.replaceFirst('assets/', '')));
      } else {
        // Local file audio - use DeviceFileSource
        await _player.play(DeviceFileSource(audioPath));
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  /// Stop currently playing audio
  static Future<void> stopAudio() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  /// Play correct answer sound effect
  static Future<void> playCorrectSound() async {
    if (!_isSfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/correct.mp3'));
    } catch (e) {
      debugPrint('Error playing correct sound: $e');
    }
  }

  /// Play incorrect answer sound effect
  static Future<void> playIncorrectSound() async {
    if (!_isSfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/incorrect.mp3'));
    } catch (e) {
      debugPrint('Error playing incorrect sound: $e');
    }
  }

  /// Play celebration sound effect
  static Future<void> playCelebrationSound() async {
    if (!_isSfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/celebration.mp3'));
    } catch (e) {
      debugPrint('Error playing celebration sound: $e');
    }
  }

  /// Play tap/button sound effect
  static Future<void> playTapSound() async {
    if (!_isSfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/tap.mp3'));
    } catch (e) {
      debugPrint('Error playing tap sound: $e');
    }
  }

  /// Play wet button sound effect
  static Future<void> playButtonSound() async {
    if (_isTest || !_isSfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/wetbutton.m4a'));
    } catch (e) {
      debugPrint('Error playing button sound: $e');
    }
  }

  /// Dispose audio players
  static Future<void> dispose() async {
    await _player.dispose();
    await _sfxPlayer.dispose();
  }
}
