class BibleVerse {
  final int chapter;  // Capítulo do versículo
  final int number;   // Número do versículo
  final String text;  // Texto do versículo

  BibleVerse({
    required this.chapter,
    required this.number,
    required this.text,
  });

  /// Construtor a partir de JSON
  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      chapter: json['chapter'],
      number: json['number'],
      text: json['text'],
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'chapter': chapter,
      'number': number,
      'text': text,
    };
  }
}