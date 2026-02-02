/// Asset paths for images, audio, and data files
class AppAssets {
  // Character Images
  static const String boyCharacter = 'assets/images/characters/boy_character.png';
  static const String girlCharacter = 'assets/images/characters/girl_character.png';
  
  // Flag Images
  static const String usFlag = 'assets/images/flags/us_flag.png';
  static const String phFlag = 'assets/images/flags/ph_flag.png';
  
  // UI Images
  static const String logo = 'assets/images/ui/logo.png';
  static const String beeLogo = 'assets/images/ui/bee_logo.png';
  static const String confetti = 'assets/images/ui/confetti.png';
  static const String bunting = 'assets/images/ui/bunting.png';
  
  // Sound Effects
  static const String correctSound = 'assets/audio/sfx/correct.mp3';
  static const String incorrectSound = 'assets/audio/sfx/incorrect.mp3';
  static const String celebrationSound = 'assets/audio/sfx/celebration.mp3';
  static const String tapSound = 'assets/audio/sfx/tap.mp3';
  
  // Data Files
  static const String lessonsData = 'assets/data/lessons.json';
  
  // Helper methods for dynamic paths
  static String wordImage(String wordId) => 'assets/images/words/$wordId.png';
  
  static String englishAudio(String wordId) => 'assets/audio/english/$wordId.mp3';
  
  static String filipinoAudio(String wordId) => 'assets/audio/filipino/$wordId.mp3';
}
