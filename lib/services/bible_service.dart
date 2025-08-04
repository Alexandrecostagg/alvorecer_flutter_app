import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/book.dart';
import '../models/bible_verse.dart';

class BibleService {
  static final BibleService _instance = BibleService._internal();
  factory BibleService() => _instance;
  BibleService._internal();

  List<Book> _books = [];

  /// Carrega a Bíblia NVI do arquivo JSON localizado em assets/data/bible/nvi_bible.json
  Future<void> loadBible() async {
    if (_books.isNotEmpty) return; // já carregado

    final String jsonString =
        await rootBundle.loadString('assets/data/bible/nvi_bible.json');

    final List<dynamic> jsonData = jsonDecode(jsonString);

    _books = jsonData.map((bookJson) => Book.fromJson(bookJson)).toList();
  }

  /// Retorna todos os livros
  List<Book> getAllBooks() => _books;

  /// Retorna um livro pelo nome
  Book? getBookByName(String name) {
    try {
      return _books.firstWhere(
        (b) => b.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Retorna todos os versículos de um capítulo específico
  List<BibleVerse> getChapter(String bookName, int chapter) {
    final book = getBookByName(bookName);
    if (book == null) return [];
    return book.verses.where((v) => v.chapter == chapter).toList();
  }

  /// Retorna um versículo específico
  BibleVerse? getVerse(String bookName, int chapter, int verseNumber) {
    return getChapter(bookName, chapter)
        .firstWhere((v) => v.number == verseNumber, orElse: () => BibleVerse(chapter: 0, number: 0, text: ''));
  }
}
