import 'language.dart';

/// Word example with image, audio, and text
class WordExample {
  final String id;
  final String word;
  final String imageAsset;
  final String audioAsset;
  final String phonetic;
  final LanguageType language;

  WordExample({
    required this.id,
    required this.word,
    required this.imageAsset,
    required this.audioAsset,
    required this.phonetic,
    required this.language,
  });

  factory WordExample.fromJson(Map<String, dynamic> json) {
    return WordExample(
      id: json['id'] as String,
      word: json['word'] as String,
      imageAsset: json['imageAsset'] as String,
      audioAsset: json['audioAsset'] as String,
      phonetic: json['phonetic'] as String? ?? '',
      language: LanguageType.fromString(json['language'] as String? ?? 'english'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'imageAsset': imageAsset,
      'audioAsset': audioAsset,
      'phonetic': phonetic,
      'language': language.name,
    };
  }

  WordExample copyWith({
    String? id,
    String? word,
    String? imageAsset,
    String? audioAsset,
    String? phonetic,
    LanguageType? language,
  }) {
    return WordExample(
      id: id ?? this.id,
      word: word ?? this.word,
      imageAsset: imageAsset ?? this.imageAsset,
      audioAsset: audioAsset ?? this.audioAsset,
      phonetic: phonetic ?? this.phonetic,
      language: language ?? this.language,
    );
  }
}
