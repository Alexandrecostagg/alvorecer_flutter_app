import 'package:flutter/material.dart';
import '../services/bible_service.dart';
import '../models/book.dart';
import '../models/bible_verse.dart';

class BibleReader extends StatefulWidget {
  const BibleReader({Key? key}) : super(key: key);

  @override
  State<BibleReader> createState() => _BibleReaderState();
}

class _BibleReaderState extends State<BibleReader> {
  final BibleService _bibleService = BibleService();

  List<Book> _books = [];
  List<int> _chapters = [];
  List<BibleVerse> _verses = [];

  Book? _selectedBook;
  int? _selectedChapter;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _loading = true);
    final books = await _bibleService.getBooks();
    setState(() {
      _books = books;
      _loading = false;
    });
  }

  Future<void> _loadChapters(Book book) async {
    setState(() {
      _selectedBook = book;
      _selectedChapter = null;
      _chapters = [];
      _verses = [];
      _loading = true;
    });

    final chapters = await _bibleService.getChapters(book.name);
    setState(() {
      _chapters = chapters;
      _loading = false;
    });
  }

  Future<void> _loadVerses(int chapter) async {
    setState(() {
      _selectedChapter = chapter;
      _verses = [];
      _loading = true;
    });

    final verses = await _bibleService.getVerses(_selectedBook!.name, chapter);
    setState(() {
      _verses = verses;
      _loading = false;
    });
  }

  void _goBack() {
    if (_selectedChapter != null) {
      // Volta para capítulos
      setState(() => _selectedChapter = null);
    } else if (_selectedBook != null) {
      // Volta para livros
      setState(() => _selectedBook = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _selectedBook == null
              ? _buildBookList()
              : _selectedChapter == null
                  ? _buildChapterList()
                  : _buildVerseList(),
    );
  }

  Widget _buildBookList() {
    return ListView.builder(
      key: const ValueKey('books'),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return ListTile(
          title: Text(book.name),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _loadChapters(book),
        );
      },
    );
  }

  Widget _buildChapterList() {
    return Column(
      key: const ValueKey('chapters'),
      children: [
        _buildBackButton(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _chapters.length,
            itemBuilder: (context, index) {
              final chapter = _chapters[index];
              return ElevatedButton(
                onPressed: () => _loadVerses(chapter),
                child: Text('$chapter'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerseList() {
    return Column(
      key: const ValueKey('verses'),
      children: [
        _buildBackButton(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _verses.length,
            itemBuilder: (context, index) {
              final verse = _verses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${verse.number}. ${verse.text}',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Voltar'),
        ),
      ),
    );
  }
}