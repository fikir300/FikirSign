/// Represents a curated Ethiopian Sign Language / medical phrase pair.
class Phrase {
  final String id;
  final String en;
  final String am;
  final String category;

  const Phrase({
    required this.id,
    required this.en,
    required this.am,
    required this.category,
  });

  factory Phrase.fromJson(Map<String, dynamic> json) {
    return Phrase(
      id: json['id'] as String? ?? '',
      en: json['en'] as String? ?? '',
      am: json['am'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'en': en,
      'am': am,
      'category': category,
    };
  }

  Phrase copyWith({
    String? id,
    String? en,
    String? am,
    String? category,
  }) {
    return Phrase(
      id: id ?? this.id,
      en: en ?? this.en,
      am: am ?? this.am,
      category: category ?? this.category,
    );
  }
}
