import 'package:flutter/material.dart';
import '../services/bible_service.dart';

class BibleTestScreen extends StatefulWidget {
  const BibleTestScreen({Key? key}) : super(key: key);

  @override
  _BibleTestScreenState createState() => _BibleTestScreenState();
}

class _BibleTestScreenState extends State<BibleTestScreen> {
  final BibleService _bibleService = BibleService();
  List<dynamic> books = [];
  List<dynamic> chapters = [];
  List<dynamic> verses = [];
  
  String selectedBook = '';
  String selectedBookName = '';
  int selectedChapter = 0;
  
  bool isLoading = true;
  String errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadBooks();
  }
  
  Future<void> _loadBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      final jsAvailable = _bibleService.checkJavaScriptAvailability();
      print('JavaScript disponível: $jsAvailable');
      
      final loadedBooks = await _bibleService.getBooks();
      
      setState(() {
        books = loadedBooks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar livros: $e';
        isLoading = false;
      });
      print(errorMessage);
    }
  }
  
  Future<void> _loadChapters(String bookId, String bookName) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      chapters = [];
      verses = [];
    });
    
    try {
      final loadedChapters = await _bibleService.getChapters(bookId);
      
      setState(() {
        chapters = loadedChapters;
        selectedBook = bookId;
        selectedBookName = bookName;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar capítulos: $e';
        isLoading = false;
      });
      print(errorMessage);
    }
  }
  
  Future<void> _loadVerses(String bookId, int chapterNumber) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      final loadedVerses = await _bibleService.getVerses(bookId, chapterNumber);
      
      setState(() {
        verses = loadedVerses;
        selectedChapter = chapterNumber;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar versículos: $e';
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste da Bíblia'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBooks,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erro: $errorMessage', 
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadBooks,
                        child: Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seção de livros
                      Text('Livros', style: Theme.of(context).textTheme.headline6),
                      books.isEmpty
                          ? Center(child: Text('Nenhum livro encontrado'))
                          : Container(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: books.length,
                                itemBuilder: (context, index) {
                                  final book = books[index];
                                  final bool isSelected = book['id'] == selectedBook;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ElevatedButton(
                                      onPressed: () => _loadChapters(book['id'], book['name']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSelected ? Colors.blue.shade700 : null,
                                      ),
                                      child: Text(book['name']),
                                    ),
                                  );
                                },
                              ),
                            ),
                      
                      SizedBox(height: 20),
                      
                      // Seção de capítulos
                      if (selectedBook.isNotEmpty)
                        Text('Capítulos de $selectedBookName', 
                            style: Theme.of(context).textTheme.headline6),
                      
                      if (selectedBook.isNotEmpty)
                        chapters.isEmpty
                            ? Center(child: Text('Nenhum capítulo encontrado'))
                            : Container(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: chapters.length,
                                  itemBuilder: (context, index) {
                                    final chapter = chapters[index];
                                    final bool isSelected = chapter == selectedChapter;
                                    
                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ElevatedButton(
                                        onPressed: () => _loadVerses(selectedBook, chapter),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSelected ? Colors.blue.shade700 : null,
                                        ),
                                        child: Text('$chapter'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      
                      SizedBox(height: 20),
                      
                      // Seção de versículos
                      if (verses.isNotEmpty)
                        Text('$selectedBookName $selectedChapter', 
                            style: Theme.of(context).textTheme.headline6),
                      
                      if (verses.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: verses.length,
                            itemBuilder: (context, index) {
                              final verse = verses[index];
                              return ListTile(
                                leading: Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${verse['number']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(verse['text']),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}