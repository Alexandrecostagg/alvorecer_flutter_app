import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/bible_verse.dart';
import '../services/bible_service.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({Key? key}) : super(key: key);

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final BibleService _bibleService = BibleService();

  List<Book> _books = [];
  Book? _selectedBook;
  int _selectedChapter = 1;
  List<BibleVerse> _verses = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBible();
  }

  Future<void> _loadBible() async {
    await _bibleService.loadBible();
    final books = _bibleService.getAllBooks();

    setState(() {
      _books = books;
      if (_books.isNotEmpty) {
        _selectedBook = _books.first;
        _selectedChapter = 1;
        _verses = _bibleService.getChapter(_selectedBook!.name, _selectedChapter);
      }
      _loading = false;
    });
  }

  void _changeBook(Book book) {
    setState(() {
      _selectedBook = book;
      _selectedChapter = 1;
      _verses = _bibleService.getChapter(book.name, 1);
    });
  }

  void _changeChapter(int chapter) {
    setState(() {
      _selectedChapter = chapter;
      _verses = _bibleService.getChapter(_selectedBook!.name, chapter);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedBook != null
              ? '${_selectedBook!.name} $_selectedChapter'
              : 'Bíblia NVI',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Dropdown de livros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<Book>(
              value: _selectedBook,
              isExpanded: true,
              onChanged: (book) {
                if (book != null) _changeBook(book);
              },
              items: _books.map((book) {
                return DropdownMenuItem<Book>(
                  value: book,
                  child: Text(book.name),
                );
              }).toList(),
            ),
          ),

          // Lista de capítulos (horizontal)
          if (_selectedBook != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_selectedBook!.chapters, (i) {
                  final chapter = i + 1;
                  final isSelected = chapter == _selectedChapter;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(chapter.toString()),
                      selected: isSelected,
                      onSelected: (_) => _changeChapter(chapter),
                    ),
                  );
                }),
              ),
            ),

          const Divider(),

          // Lista de versículos
          Expanded(
            child: ListView.builder(
              itemCount: _verses.length,
              itemBuilder: (context, index) {
                final verse = _verses[index];
                return ListTile(
                  title: Text(
                    '${verse.number}. ${verse.text}',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
