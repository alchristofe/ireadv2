import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'data/local/hive_service.dart';
import 'core/utils/background_music_manager.dart';
import 'core/utils/audio_player_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveService.init();

  // Initialize Background Music
  await BackgroundMusicManager.instance.initialize();
  
  // Initialize Audio Player Utils (SFX settings)
  await AudioPlayerUtil.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const IReadApp());
}
