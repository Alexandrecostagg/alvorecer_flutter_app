import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bible_service.dart';

class BibleTest extends StatefulWidget {
  const BibleTest({Key? key}) : super(key: key);

  @override
  _BibleTestState createState() => _BibleTestState();
}

class _BibleTestState extends State<BibleTest> {
  final BibleService _bibleService = BibleService();
  List<dynamic> books = [];
  List<dynamic> chapters = [];
  List<dynamic> verses = [];
  
  String selectedBook = '';
  int selectedChapter = 0;
  
  @override
  void initState() {
    super.initState();
    _loadBooks();
  }
  
  Future<void> _loadBooks() async {
    try {
      final loadedBooks = await _bibleService.getBooks();
      setState(() {
        books = loadedBooks;
      });
    } catch (e) {
      print('Erro ao carregar livros: $e');
    }
  }
  
  Future<void> _loadChapters(String bookId) async {
    try {
      final loadedChapters = await _bibleService.getChapters(bookId);
      setState(() {
        chapters = loadedChapters;
        selectedBook = bookId;
      });
    } catch (e) {
      print('Erro ao carregar capítulos: $e');
    }
  }
  
  Future<void> _loadVerses(String bookId, int chapterNumber) async {
    try {
      final loadedVerses = await _bibleService.getVerses(bookId, chapterNumber);
      setState(() {
        verses = loadedVerses;
        selectedChapter = chapterNumber;
      });
    } catch (e) {
      print('Erro ao carregar versículos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste da Bíblia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Seção de livros
            Text('Livros', style: Theme.of(context).textTheme.headline6),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                      onPressed: () => _loadChapters(book['id']),
                      child: Text(book['name']),
                    ),
                  );
                },
              ),
            ),
            
            // Seção de capítulos (se um livro foi selecionado)
            if (selectedBook.isNotEmpty) ...[
              SizedBox(height: 20),
              Text('Capítulos de $selectedBook', style: Theme.of(context).textTheme.headline6),
              Container(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () => _loadVerses(selectedBook, chapter),
                        child: Text('$chapter'),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Seção de versículos (se um capítulo foi selecionado)
            if (verses.isNotEmpty) ...[
              SizedBox(height: 20),
              Text('$selectedBook $selectedChapter', style: Theme.of(context).textTheme.headline6),
              Expanded(
                child: ListView.builder(
                  itemCount: verses.length,
                  itemBuilder: (context, index) {
                    final verse = verses[index];
                    return ListTile(
                      leading: Text('${verse['number']}'),
                      title: Text(verse['text']),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}