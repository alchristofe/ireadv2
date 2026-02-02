/// Language types supported by the app
enum LanguageType {
  english,
  filipino,
  hiligaynon;

  String get displayName {
    switch (this) {
      case LanguageType.english:
        return 'English';
      case LanguageType.filipino:
        return 'Filipino';
      case LanguageType.hiligaynon:
        return 'Hiligaynon';
    }
  }

  String get code {
    switch (this) {
      case LanguageType.english:
        return 'en-US';
      case LanguageType.filipino:
        return 'fil-PH';
      case LanguageType.hiligaynon:
        return 'hil-PH';
    }
  }

  String get flagAsset {
    switch (this) {
      case LanguageType.english:
        return 'assets/images/flags/english.png';
      case LanguageType.filipino:
        return 'assets/images/flags/filipino.png';
      case LanguageType.hiligaynon:
        return 'assets/images/flags/Hili_flag.png';
    }
  }

  String? get mascotAsset {
    switch (this) {
      case LanguageType.hiligaynon:
        return 'assets/images/mascots/hiligaynon_mascot.png';
      default:
        return null; // English/Filipino don't use a separate mascot image (Filipino uses Rive)
    }
  }

  String get listeningLabel {
    switch (this) {
      case LanguageType.english:
        return 'Listening...';
      case LanguageType.filipino:
        return 'Nakikinig...';
      case LanguageType.hiligaynon:
        return 'Nagapamati...';
    }
  }

  String get sayTheWordLabel {
    switch (this) {
      case LanguageType.english:
        return 'Say the word';
      case LanguageType.filipino:
        return 'Sabihin ang salitang';
      case LanguageType.hiligaynon:
        return 'Hambala ang tinaga';
    }
  }

  String get nextLabel {
    switch (this) {
      case LanguageType.english:
        return 'Next';
      case LanguageType.filipino:
        return 'Susunod';
      case LanguageType.hiligaynon:
        return 'Sunod';
    }
  }

  String get previousLabel {
    switch (this) {
      case LanguageType.english:
        return 'Previous';
      case LanguageType.filipino:
        return 'Nakaraan';
      case LanguageType.hiligaynon:
        return 'Nagligad';
    }
  }

  String get chooseLetterLabel {
    switch (this) {
      case LanguageType.english:
        return 'Choose a Letter';
      case LanguageType.filipino:
        return 'Pumili ng Titik';
      case LanguageType.hiligaynon:
        return 'Pilia ang Letra';
    }
  }

  String get finishLabel {
    switch (this) {
      case LanguageType.english:
        return 'Finish';
      case LanguageType.filipino:
        return 'Tapusin';
      case LanguageType.hiligaynon:
        return 'Tapusa';
    }
  }

  String get pronunciationLabel {
    switch (this) {
      case LanguageType.english:
        return 'Pronunciation';
      case LanguageType.filipino:
        return 'Pagbigkas';
      case LanguageType.hiligaynon:
        return 'Pagmitlang';
    }
  }

  String get correctFeedback {
    switch (this) {
      case LanguageType.english:
        return 'Correct! Great job!';
      case LanguageType.filipino:
        return 'Tama! Mahusay!';
      case LanguageType.hiligaynon:
        return 'Husto! Maayo gid!';
    }
  }

  String get incorrectFeedbackPrefix {
    switch (this) {
      case LanguageType.english:
        return 'I heard';
      case LanguageType.filipino:
        return 'Ang narinig ko ay';
      case LanguageType.hiligaynon:
        return 'Ang nabatian ko';
    }
  }

  String get incorrectFeedbackSuffix {
    switch (this) {
      case LanguageType.english:
        return '. Try again!';
      case LanguageType.filipino:
        return '. Subukan muli!';
      case LanguageType.hiligaynon:
        return '. Tilawi liwat!';
    }
  }

  String get almostCorrectFeedback {
    switch (this) {
      case LanguageType.english:
        return "Close! Try one more time!";
      case LanguageType.filipino:
        return 'Malapit na! Subukan muli!';
      case LanguageType.hiligaynon:
        return 'Malapit na lang! Tilawi pa gid!';
    }
  }

  String get noSoundFeedback {
    switch (this) {
      case LanguageType.english:
        return "I'm listening! Give it a try!";
      case LanguageType.filipino:
        return 'Nakikinig ako! Subukan mo!';
      case LanguageType.hiligaynon:
        return 'Nagapamati ako! Tilawi bala!';
    }
  }

  String get lessonNotFoundLabel {
    switch (this) {
      case LanguageType.english:
        return 'Lesson not found';
      case LanguageType.filipino:
        return 'Hindi makita ang aralin';
      case LanguageType.hiligaynon:
        return 'Wala makita ang leksyon';
    }
  }

  String get unitNotFoundLabel {
    switch (this) {
      case LanguageType.english:
        return 'Unit not found';
      case LanguageType.filipino:
        return 'Hindi makita ang yunit';
      case LanguageType.hiligaynon:
        return 'Wala makita ang yunit';
    }
  }

  String get continueLabel {
    switch (this) {
      case LanguageType.english:
        return 'CONTINUE';
      case LanguageType.filipino:
        return 'MAGPATULOY';
      case LanguageType.hiligaynon:
        return 'PADAYON';
    }
  }

  String getCompletionMessage(String letter) {
    switch (this) {
      case LanguageType.english:
        return 'You completed $letter!';
      case LanguageType.filipino:
        return 'Natapos mo ang $letter!';
      case LanguageType.hiligaynon:
        return 'Natapos mo ang $letter!';
    }
  }

  String getLetterInstruction(String letter, String sound) {
    switch (this) {
      case LanguageType.english:
        return 'This is $letter! Say, $sound!';
      case LanguageType.filipino:
        return 'Ito ang $letter! Sabihin mo, $sound!';
      case LanguageType.hiligaynon:
        return 'Ini ang $letter! Hambala, $sound!';
    }
  }

  static LanguageType fromString(String value) {
    return LanguageType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => LanguageType.english,
    );
  }
}

/// Language model
class Language {
  final LanguageType type;
  final String name;
  final String code;
  final String flagAsset;
  final String? mascotAsset;

  Language({
    required this.type,
    required this.name,
    required this.code,
    required this.flagAsset,
    this.mascotAsset,
  });

  factory Language.fromType(LanguageType type) {
    return Language(
      type: type,
      name: type.displayName,
      code: type.code,
      flagAsset: type.flagAsset,
      mascotAsset: type.mascotAsset,
    );
  }

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      type: LanguageType.fromString(json['type'] as String),
      name: json['name'] as String,
      code: json['code'] as String,
      flagAsset: json['flagAsset'] as String,
      mascotAsset: json['mascotAsset'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'code': code,
      'flagAsset': flagAsset,
      'mascotAsset': mascotAsset,
    };
  }
}
