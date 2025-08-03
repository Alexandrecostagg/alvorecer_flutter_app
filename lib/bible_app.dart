import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'dart:convert';
import 'dart:async';
import 'glorify_bible_view.dart';  // Importação adicional

class BibleApp extends StatefulWidget {
  const BibleApp({Key? key}) : super(key: key);

  @override
  _BibleAppState createState() => _BibleAppState();
}

class _BibleAppState extends State<BibleApp> with TickerProviderStateMixin {
  List<dynamic> _books = [];
  List<dynamic> _filteredBooks = [];
  List<dynamic> _currentVerses = [];
  Map<String, dynamic>? _currentBook;
  int? _currentChapter;
  bool _isLoading = true;
  String _statusMessage = 'Carregando...';
  bool _isOldTestament = true;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // Nova flag para controlar qual interface mostrar
  bool _useGlorifyView = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initializeBible();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _isOldTestament = _tabController.index == 0;
        _filterBooksByTestament();
      });
    }
  }
  
  void _initializeBible() {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Inicializando módulo da Bíblia...';
    });
    
    // Verifica se a integração JavaScript está funcionando
    try {
      final hasBibleManager = js.context.hasProperty('bibleManager');
      
      if (!hasBibleManager) {
        setState(() {
          _statusMessage = 'Erro: BibleManager não está disponível';
          _isLoading = false;
        });
        return;
      }
      
      _loadBooks();
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro na integração JavaScript: $e';
        _isLoading = false;
      });
    }
  }
  
  void _loadBooks() {
    try {
      // Chamar a função JavaScript para obter os livros
      final jsResult = js.context.callMethod('getBibleBooks');
      
      if (jsResult != null) {
        final parsedBooks = json.decode(jsResult.toString());
        setState(() {
          _books = parsedBooks;
          _filterBooksByTestament();
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusMessage = 'Erro: Não foi possível carregar os livros';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao carregar livros: $e';
        _isLoading = false;
      });
    }
  }

  void _filterBooksByTestament() {
    if (_books.isEmpty) return;
    
    setState(() {
      if (_isOldTestament) {
        _filteredBooks = _books.where((book) => book['testament'] == 'Antigo').toList();
      } else {
        _filteredBooks = _books.where((book) => book['testament'] == 'Novo').toList();
      }
    });
  }

  void _loadChapter(String bookId, int chapterNumber) {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Carregando $bookId $chapterNumber...';
      _currentVerses = [];
    });
    
    try {
      // Registrar o callback para receber os versículos
      js.context['onBibleVersesLoaded'] = (String jsonVerses) {
        if (mounted) {
          setState(() {
            try {
              final parsedVerses = json.decode(jsonVerses);
              _currentVerses = parsedVerses;
              _currentBook = _books.firstWhere((b) => b['id'] == bookId, 
                orElse: () => {'id': bookId, 'name': bookId.toUpperCase(), 'chapters': 1});
              _currentChapter = chapterNumber;
              _isLoading = false;
            } catch (e) {
              _currentVerses = [
                {'number': 1, 'text': 'Erro ao processar os versículos: $e'}
              ];
              _isLoading = false;
            }
          });
        }
      };
      
      // Chamar a função JavaScript para obter os versículos
      js.context.callMethod('getBibleVerses', [bookId, chapterNumber]);
      
      // Iniciar verificação de fallback
      _checkVersesLoadingStatus();
      
      // Adicionar timeout de segurança para não travar o carregamento
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
            _currentVerses = [
              {'number': 1, 'text': 'Não foi possível carregar este capítulo no momento.'},
              {'number': 2, 'text': 'Verifique sua conexão ou tente novamente mais tarde.'}
            ];
            _currentBook = _books.firstWhere((b) => b['id'] == bookId, 
              orElse: () => {'id': bookId, 'name': bookId.toUpperCase(), 'chapters': 1});
            _currentChapter = chapterNumber;
          });
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao carregar versículos: $e';
        _isLoading = false;
        _currentVerses = [
          {'number': 1, 'text': 'Erro: $e'},
        ];
      });
    }
  }
  
  void _checkVersesLoadingStatus() {
    if (!mounted || !_isLoading) return;
    
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final statusResult = js.context.callMethod('checkBibleVersesStatus');
        
        if (statusResult != null) {
          final status = json.decode(statusResult.toString());
          
          if (status['status'] == 'ready') {
            setState(() {
              _currentVerses = status['verses'];
              _isLoading = false;
            });
          } else if (_isLoading) {
            // Ainda carregando, verificar novamente
            _checkVersesLoadingStatus();
          }
        } else if (_isLoading) {
          // Continuar verificando
          _checkVersesLoadingStatus();
        }
      } catch (e) {
        // Se ocorrer um erro, tenta novamente
        if (_isLoading) {
          _checkVersesLoadingStatus();
        }
      }
    });
  }

  void _navigateToNextChapter() {
    if (_currentBook == null || _currentChapter == null) return;
    
    if (_currentChapter! < _currentBook!['chapters']) {
      // Próximo capítulo do mesmo livro
      _loadChapter(_currentBook!['id'], _currentChapter! + 1);
    } else {
      // Primeiro capítulo do próximo livro
      final currentIndex = _books.indexWhere((b) => b['id'] == _currentBook!['id']);
      if (currentIndex < _books.length - 1) {
        final nextBook = _books[currentIndex + 1];
        _loadChapter(nextBook['id'], 1);
      }
    }
  }

  void _navigateToPreviousChapter() {
    if (_currentBook == null || _currentChapter == null) return;
    
    if (_currentChapter! > 1) {
      // Capítulo anterior do mesmo livro
      _loadChapter(_currentBook!['id'], _currentChapter! - 1);
    } else {
      // Último capítulo do livro anterior
      final currentIndex = _books.indexWhere((b) => b['id'] == _currentBook!['id']);
      if (currentIndex > 0) {
        final prevBook = _books[currentIndex - 1];
        _loadChapter(prevBook['id'], prevBook['chapters']);
      }
    }
  }

  void _searchBooks(String query) {
    if (query.isEmpty) {
      _filterBooksByTestament();
      return;
    }
    
    setState(() {
      final lowerQuery = query.toLowerCase().trim();
      if (_isOldTestament) {
        _filteredBooks = _books
            .where((book) => 
                book['testament'] == 'Antigo' && 
                book['name'].toLowerCase().contains(lowerQuery))
            .toList();
      } else {
        _filteredBooks = _books
            .where((book) => 
                book['testament'] == 'Novo' && 
                book['name'].toLowerCase().contains(lowerQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    
    // Se estiver usando a visualização Glorify, retorná-la
    if (_useGlorifyView && !_isLoading && _books.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bíblia Glorify', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.view_list),
              onPressed: () {
                setState(() {
                  _useGlorifyView = false;
                });
              },
              tooltip: 'Voltar para interface padrão',
            ),
          ],
        ),
        body: GlorifyBibleView(books: _books),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bíblia', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Antigo Testamento'),
            Tab(text: 'Novo Testamento'),
          ],
        ),
        actions: [
          // Adicionar botão para alternar visualização
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              setState(() {
                _useGlorifyView = true;
              });
            },
            tooltip: 'Alternar para interface Glorify',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Buscar livro'),
                  content: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Digite o nome do livro',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _searchBooks,
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        _filterBooksByTestament();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_statusMessage),
                ],
              ),
            )
          : isDesktop 
              ? _buildDesktopLayout() 
              : _buildMobileLayout(),
      drawer: isDesktop ? null : _buildDrawer(),
    );
  }
  
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Lista de livros (25% da largura)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: _buildBooksList(),
        ),
        
        // Divisor vertical
        const VerticalDivider(width: 1),
        
        // Conteúdo do capítulo (75% da largura)
        Expanded(
          child: _currentBook == null
              ? const Center(
                  child: Text(
                    'Selecione um livro e capítulo para começar',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : _buildChapterView(),
        ),
      ],
    );
  }
  
  Widget _buildMobileLayout() {
    return _currentBook == null
        ? _buildBooksList()
        : _buildChapterView();
  }
  
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.book, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Bíblia Sagrada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versão: Almeida Revista e Corrigida',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBooksList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBooksList() {
    if (_books.isEmpty) {
      return const Center(child: Text('Nenhum livro disponível'));
    }
    
    return Column(
      children: [
        // Campo de busca
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar livro...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            onChanged: _searchBooks,
          ),
        ),
        
        // Lista de livros
        Expanded(
          child: ListView.builder(
            itemCount: _filteredBooks.length,
            itemBuilder: (context, index) {
              final book = _filteredBooks[index];
              final isCurrentBook = _currentBook != null && _currentBook!['id'] == book['id'];
              
              return ExpansionTile(
                title: Text(
                  book['name'],
                  style: TextStyle(
                    fontWeight: isCurrentBook ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: book['testament'] == 'Novo'
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.amber.withOpacity(0.2),
                  child: Text(
                    book['name'].substring(0, 1),
                    style: TextStyle(
                      color: book['testament'] == 'Novo'
                          ? Colors.blue.shade800
                          : Colors.amber.shade800,
                    ),
                  ),
                ),
                initiallyExpanded: isCurrentBook,
                children: List.generate(
                  book['chapters'],
                  (chapterNum) {
                    final chapterNumber = chapterNum + 1;
                    final isCurrentChapter = isCurrentBook && _currentChapter == chapterNumber;
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32.0),
                      title: Text('Capítulo $chapterNumber'),
                      selected: isCurrentChapter,
                      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      onTap: () {
                        _loadChapter(book['id'], chapterNumber);
                        // Fechar o drawer em telas móveis
                        if (MediaQuery.of(context).size.width < 800) {
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildChapterView() {
    return Column(
      children: [
        // Cabeçalho do capítulo
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _navigateToPreviousChapter,
                tooltip: 'Capítulo anterior',
              ),
              Column(
                children: [
                  Text(
                    _currentBook?['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Capítulo $_currentChapter',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _navigateToNextChapter,
                tooltip: 'Próximo capítulo',
              ),
            ],
          ),
        ),
        
        // Versículos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _currentVerses.length,
            itemBuilder: (context, index) {
              final verse = _currentVerses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${verse['number']} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      TextSpan(
                        text: verse['text'],
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.5,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}