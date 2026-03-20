import 'language.dart';

/// Word example with image, audio, and text
class WordExample {
  final String id;
  final String word;
  final String imageAsset;
  final String audioAsset;
  final String phonetic;
  final LanguageType language;
  final DateTime? updatedAt;

  WordExample({
    required this.id,
    required this.word,
    required this.imageAsset,
    required this.audioAsset,
    required this.phonetic,
    required this.language,
    this.updatedAt,
  });

  factory WordExample.fromJson(Map<String, dynamic> json) {
    return WordExample(
      id: json['id'] as String,
      word: json['word'] as String,
      imageAsset: json['imageAsset'] as String,
      audioAsset: json['audioAsset'] as String,
      phonetic: json['phonetic'] as String? ?? '',
      language: LanguageType.fromString(json['language'] as String? ?? 'english'),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
              : DateTime.tryParse(json['updatedAt'].toString()))
          : null,
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
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  WordExample copyWith({
    String? id,
    String? word,
    String? imageAsset,
    String? audioAsset,
    String? phonetic,
    LanguageType? language,
    DateTime? updatedAt,
  }) {
    return WordExample(
      id: id ?? this.id,
      word: word ?? this.word,
      imageAsset: imageAsset ?? this.imageAsset,
      audioAsset: audioAsset ?? this.audioAsset,
      phonetic: phonetic ?? this.phonetic,
      language: language ?? this.language,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
