import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class BackgroundMusicManager {
  static final BackgroundMusicManager _instance =
      BackgroundMusicManager._internal();
  static BackgroundMusicManager get instance => _instance;

  final AudioPlayer _player = AudioPlayer();
  String? _currentTrack;
  bool _isPlaying = false;
  bool _isMutedForSpeech = false;
  bool _isMusicEnabled = true;
  double _volume = 0.3; // Default volume

  BackgroundMusicManager._internal();

  bool get isMusicEnabled => _isMusicEnabled;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentTrack = prefs.getString('selected_background_music');
    _isMusicEnabled = prefs.getBool('music_enabled') ?? true;

    // Set default music if none is selected (first time run)
    if (_currentTrack == null || _currentTrack!.isEmpty) {
      _currentTrack = 'childrenadventure.m4a';
      await prefs.setString('selected_background_music', _currentTrack!);
    }

    // Configure AudioContext to allow mixing
    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
    );
    await AudioPlayer.global.setAudioContext(audioContext);

    // Set release mode to loop
    await _player.setReleaseMode(ReleaseMode.loop);

    if (_currentTrack != null && _currentTrack!.isNotEmpty) {
      await play(_currentTrack!);
    }
  }

  Future<void> toggleMusic(bool enabled) async {
    _isMusicEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', enabled);

    if (!enabled) {
      await _player.setVolume(0);
    } else if (!_isMutedForSpeech) {
      await _player.setVolume(_volume);
    }
  }

  Future<void> play(String assetPath) async {
    try {
      if (assetPath.isEmpty) {
        await stop();
        return;
      }

      _currentTrack = assetPath;

      // Save selection
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_background_music', assetPath);

      if (!_isMutedForSpeech) {
        await _player.setVolume(_isMusicEnabled ? _volume : 0);
        await _player.play(AssetSource('audio/sfx/$assetPath'));
        _isPlaying = true;
      }
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentTrack = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_background_music');
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> resume() async {
    if (_currentTrack != null && !_isMutedForSpeech) {
      await _player.resume();
      _isPlaying = true;
    }
  }

  Future<void> muteForSpeech() async {
    _isMutedForSpeech = true;
    await _player.setVolume(
      0,
    ); // Fade out could be better, but instant mute is safer for recognition
  }

  Future<void> unmuteAfterSpeech() async {
    _isMutedForSpeech = false;
    if (_isPlaying) {
      await _player.setVolume(_isMusicEnabled ? _volume : 0);
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    if (!_isMutedForSpeech) {
      await _player.setVolume(volume);
    }
  }
}
