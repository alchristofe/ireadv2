import 'language.dart';
import 'word_example.dart';

/// Individual phonics lesson unit (e.g., letter A, letter B)
class PhonicsUnit {
  final String id;
  final String letter;
  final String sound;
  final String description;
  final List<WordExample> examples;
  final String categoryId;
  final LanguageType language;
  final String? letterAudio;

  PhonicsUnit({
    required this.id,
    required this.letter,
    required this.sound,
    required this.description,
    required this.examples,
    required this.categoryId,
    required this.language,
    this.letterAudio,
  });

  factory PhonicsUnit.fromJson(Map<String, dynamic> json) {
    return PhonicsUnit(
      id: json['id'] as String,
      letter: json['letter'] as String,
      sound: json['sound'] as String,
      description: json['description'] as String? ?? '',
      examples:
          (json['examples'] as List<dynamic>?)
              ?.map(
                (e) =>
                    WordExample.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          [],
      categoryId: json['categoryId'] as String? ?? '',
      language: LanguageType.fromString(
        json['language'] as String? ?? 'english',
      ),
      letterAudio:
          json['letterAudio'] as String? ?? json['audioAsset'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'letter': letter,
      'sound': sound,
      'description': description,
      'examples': examples.map((e) => e.toJson()).toList(),
      'categoryId': categoryId,
      'language': language.name,
      'letterAudio': letterAudio,
    };
  }

  PhonicsUnit copyWith({
    String? id,
    String? letter,
    String? sound,
    String? description,
    List<WordExample>? examples,
    String? categoryId,
    LanguageType? language,
    String? letterAudio,
  }) {
    return PhonicsUnit(
      id: id ?? this.id,
      letter: letter ?? this.letter,
      sound: sound ?? this.sound,
      description: description ?? this.description,
      examples: examples ?? this.examples,
      categoryId: categoryId ?? this.categoryId,
      language: language ?? this.language,
      letterAudio: letterAudio ?? this.letterAudio,
    );
  }
}
