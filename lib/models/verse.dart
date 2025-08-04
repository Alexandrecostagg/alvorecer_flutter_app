class BibleVerse {
  final int chapter;   // Capítulo
  final int number;    // Número do versículo
  final String text;   // Texto do versículo

  BibleVerse({
    required this.chapter,
    required this.number,
    required this.text,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      chapter: json['chapter'] ?? 0,
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter': chapter,
      'number': number,
      'text': text,
    };
  }
}
