import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../models/bible_verse.dart';

class BibleService {
  static Map<String, dynamic>? _bibleData;

  /// Carrega o JSON uma vez na memória
  Future<void> _loadBibleData() async {
    if (_bibleData != null) return;
    final jsonString =
        await rootBundle.loadString('assets/data/bible/nvi_bible.json');
    _bibleData = jsonDecode(jsonString);
  }

  /// Retorna lista de livros da Bíblia
  Future<List<Book>> getBooks() async {
    await _loadBibleData();

    final booksJson = _bibleData?['books'] as List<dynamic>;
    return booksJson.map((b) {
      return Book(
        name: b['name'],
        abbreviation: b['abbrev'] ?? '',
        testament: b['testament'] ?? '',
        chapters: (b['chapters'] as List).length,
      );
    }).toList();
  }

  /// Retorna lista de capítulos (1..N) de um livro
  Future<List<int>> getChapters(String bookName) async {
    await _loadBibleData();

    final booksJson = _bibleData?['books'] as List<dynamic>;
    final book = booksJson.firstWhere(
      (b) => b['name'] == bookName,
      orElse: () => throw Exception('Livro não encontrado: $bookName'),
    );

    final chapters = (book['chapters'] as List);
    return List.generate(chapters.length, (i) => i + 1);
  }

  /// Retorna todos os versículos de um capítulo específico
  Future<List<BibleVerse>> getVerses(String bookName, int chapter) async {
    await _loadBibleData();

    final booksJson = _bibleData?['books'] as List<dynamic>;
    final book = booksJson.firstWhere(
      (b) => b['name'] == bookName,
      orElse: () => throw Exception('Livro não encontrado: $bookName'),
    );

    final chapters = (book['chapters'] as List);
    if (chapter < 1 || chapter > chapters.length) {
      throw Exception('Capítulo inválido: $chapter');
    }

    final versesJson = chapters[chapter - 1] as List;
    return List.generate(
      versesJson.length,
      (index) => BibleVerse(
        book: bookName,
        chapter: chapter,
        verse: index + 1,
        text: versesJson[index],
      ),
    );
  }
}