import 'bible_verse.dart';

class Book {
  final String name;                 // Nome do livro
  final int chapters;                 // Número de capítulos
  final List<BibleVerse> verses;      // Lista de versículos

  Book({
    required this.name,
    required this.chapters,
    required this.verses,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      name: json['name'] ?? '',
      chapters: json['chapters'] ?? 0,
      verses: (json['verses'] as List<dynamic>? ?? [])
          .map((v) => BibleVerse.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'chapters': chapters,
      'verses': verses.map((v) => v.toJson()).toList(),
    };
  }
}
