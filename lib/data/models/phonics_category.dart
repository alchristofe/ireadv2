import 'phonics_unit.dart';

/// Phonics category types
enum CategoryType {
  consonants,
  vowels,
  blends;

  String get displayName {
    switch (this) {
      case CategoryType.consonants:
        return 'Consonants';
      case CategoryType.vowels:
        return 'Vowels';
      case CategoryType.blends:
        return 'Consonant Blends';
    }
  }

  String get description {
    switch (this) {
      case CategoryType.consonants:
        return 'Learn consonant sounds';
      case CategoryType.vowels:
        return 'Learn vowel sounds';
      case CategoryType.blends:
        return 'Learn consonant blends';
    }
  }

  String get imageAsset {
    switch (this) {
      case CategoryType.consonants:
        return 'assets/images/categories/consonants.png';
      case CategoryType.vowels:
        return 'assets/images/categories/vowels.png';
      case CategoryType.blends:
        return 'assets/images/categories/blends.png';
    }
  }

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => CategoryType.vowels,
    );
  }
}

/// Phonics category model (consonants or vowels)
class PhonicsCategory {
  final String id;
  final CategoryType type;
  final String name;
  final String description;
  final List<PhonicsUnit> units;

  PhonicsCategory({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.units,
  });

  factory PhonicsCategory.fromJson(Map<String, dynamic> json) {
    return PhonicsCategory(
      id: json['id'] as String? ?? '',
      type: CategoryType.fromString(json['type'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      units: (json['units'] as List<dynamic>?)
              ?.map((e) => PhonicsUnit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'units': units.map((e) => e.toJson()).toList(),
    };
  }

  PhonicsCategory copyWith({
    String? id,
    CategoryType? type,
    String? name,
    String? description,
    List<PhonicsUnit>? units,
  }) {
    return PhonicsCategory(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      units: units ?? this.units,
    );
  }
}
