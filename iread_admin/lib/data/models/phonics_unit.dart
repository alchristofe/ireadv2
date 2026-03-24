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
  final DateTime? updatedAt;
  final bool isDeleted;

  PhonicsUnit({
    required this.id,
    required this.letter,
    required this.sound,
    required this.description,
    required this.examples,
    required this.categoryId,
    required this.language,
    this.letterAudio,
    this.updatedAt,
    this.isDeleted = false,
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
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
              : DateTime.tryParse(json['updatedAt'].toString()))
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
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
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
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
    DateTime? updatedAt,
    bool? isDeleted,
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
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
