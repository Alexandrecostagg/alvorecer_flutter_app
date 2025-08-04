import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/bible_verse.dart';
import '../services/bible_service.dart';

class BibleReader extends StatefulWidget {
  const BibleReader({Key? key}) : super(key: key);

  @override
  State<BibleReader> createState() => _BibleReaderState();
}

class _BibleReaderState extends State<BibleReader> {
  List<Book> _books = [];
  Book? _selectedBook;
  int _selectedChapter = 1;

  @override
  void initState() {
    super.initState();
    _loadBible();
  }

  /// Carrega a Bíblia do JSON
  Future<void> _loadBible() async {
    final books = await BibleService().loadBooks();
    if (!mounted) return;
    setState(() {
      _books = books;
      _selectedBook = books.isNotEmpty ? books.first : null;
      _selectedChapter = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedBook == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filtra os versículos do capítulo selecionado
    final verses = _selectedBook!.verses
        .where((v) => v.chapter == _selectedChapter)
        .toList();

    return Column(
      children: [
        // Dropdown para escolher o livro
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<Book>(
            value: _selectedBook,
            isExpanded: true,
            onChanged: (book) {
              setState(() {
                _selectedBook = book;
                _selectedChapter = 1;
              });
            },
            items: _books.map((book) {
              return DropdownMenuItem<Book>(
                value: book,
                child: Text(book.name),
              );
            }).toList(),
          ),
        ),

        // Botões de capítulos
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_selectedBook!.chapters, (index) {
              final chapter = index + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedChapter == chapter
                        ? Colors.blue
                        : Colors.grey.shade300,
                    foregroundColor:
                        _selectedChapter == chapter ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedChapter = chapter;
                    });
                  },
                  child: Text('$chapter'),
                ),
              );
            }),
          ),
        ),

        const Divider(),

        // Lista de versículos
        Expanded(
          child: ListView.builder(
            itemCount: verses.length,
            itemBuilder: (context, index) {
              final verse = verses[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Text(
                  '${verse.verse}. ${verse.text}',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
