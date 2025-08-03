import 'bible_verse.dart';

class Book {
  final String name;          // Nome do livro (ex: "Gênesis")
  final int chapters;         // Quantidade de capítulos
  final List<BibleVerse> verses; // Lista de versículos

  Book({
    required this.name,
    required this.chapters,
    required this.verses,
  });

  /// Construtor a partir de JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      name: json['name'],
      chapters: json['chapters'],
      verses: (json['verses'] as List)
          .map((v) => BibleVerse.fromJson(v))
          .toList(),
    );
  }

  /// Converte para JSON (se precisar salvar localmente)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'chapters': chapters,
      'verses': verses.map((v) => v.toJson()).toList(),
    };
  }
}