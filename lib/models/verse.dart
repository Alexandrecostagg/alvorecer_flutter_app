class Verse {
  final String book;
  final int chapter;
  final int number;
  final String text;

  Verse({
    required this.book,
    required this.chapter,
    required this.number,
    required this.text,
  });

  factory Verse.fromJson(Map<String, dynamic> json, String book, int chapter) {
    return Verse(
      book: book,
      chapter: chapter,
      number: json['number'],
      text: json['text'],
    );
  }
}