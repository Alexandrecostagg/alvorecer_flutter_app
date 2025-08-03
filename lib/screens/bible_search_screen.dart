import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/bible_service.dart';
import '../services/bible_search_service.dart';

class BibleSearchScreen extends StatefulWidget {
  final BibleService bibleService;
  final String initialQuery;
  final String version;
  
  const BibleSearchScreen({
    super.key,
    required this.bibleService,
    this.initialQuery = '',
    this.version = 'ARC',
  });
  
  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final BibleSearchService _searchService;
  
  List<SearchResult> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  String? _selectedTestament;
  String? _selectedBookId;
  String _currentVersion = 'ARC';
  Book? _selectedBook;
  
  @override
  void initState() {
    super.initState();
    _searchService = BibleSearchService(widget.bibleService);
    _searchController.text = widget.initialQuery;
    _currentVersion = widget.version;
    _loadRecentSearches();
    
    // Se houver uma consulta inicial, executar a pesquisa
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadRecentSearches() async {
    final recentSearches = await _searchService.getRecentSearches();
    setState(() {
      _recentSearches = recentSearches;
    });
  }
  
  Future<void> _selectBook() async {
    final books = await widget.bibleService.getBooks();
    
    final book = await showModalBottomSheet<Book>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Selecionar Livro',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'ANTIGO'),
                  Tab(text: 'NOVO'),
                ],
                labelColor: Colors.blue,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Antigo Testamento
                    ListView.builder(
                      itemCount: books.where((b) => b.testament == 'Antigo').length,
                      itemBuilder: (context, index) {
                        final book = books.where((b) => b.testament == 'Antigo').toList()[index];
                        return ListTile(
                          title: Text(book.name),
                          onTap: () {
                            Navigator.pop(context, book);
                          },
                        );
                      },
                    ),
                    
                    // Novo Testamento
                    ListView.builder(
                      itemCount: books.where((b) => b.testament == 'Novo').length,
                      itemBuilder: (context, index) {
                        final book = books.where((b) => b.testament == 'Novo').toList()[index];
                        return ListTile(
                          title: Text(book.name),
                          onTap: () {
                            Navigator.pop(context, book);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    
    if (book != null) {
      setState(() {
        _selectedBook = book;
        _selectedBookId = book.id;
        _selectedTestament = book.testament;
      });
      
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      }
    }
  }
  
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final results = await _searchService.search(
        query: query,
        testament: _selectedTestament,
        bookId: _selectedBookId,
        version: _currentVersion,
      );
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      
      // Atualizar pesquisas recentes
      await _loadRecentSearches();
    } catch (e) {
      print('Erro ao pesquisar: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao realizar pesquisa: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar na Bíblia'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_recent') {
                _searchService.clearRecentSearches();
                setState(() {
                  _recentSearches = [];
                });
              } else if (value == 'clear_cache') {
                _searchService.clearSearchCache();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache de pesquisa limpo')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_recent',
                child: Text('Limpar pesquisas recentes'),
              ),
              const PopupMenuItem(
                value: 'clear_cache',
                child: Text('Limpar cache de pesquisa'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar na Bíblia...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (value) {
                      _performSearch(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterOptions,
                ),
              ],
            ),
          ),
          
          // Filtros ativos
          if (_selectedBook != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(_selectedBook!.name),
                    onDeleted: () {
                      setState(() {
                        _selectedBook = null;
                        _selectedBookId = null;
                        
                        // Manter apenas o testamento
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          
          // Divisor
          const Divider(height: 1),
          
          // Resultados de pesquisa ou pesquisas recentes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isNotEmpty
                    ? _buildSearchResults()
                    : _buildRecentSearches(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contagem de resultados
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${_searchResults.length} resultado${_searchResults.length == 1 ? '' : 's'} encontrado${_searchResults.length == 1 ? '' : 's'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        
        // Lista de resultados
        Expanded(
          child: ListView.separated(
            itemCount: _searchResults.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              
              return ListTile(
                title: Text('${result.book.name} ${result.chapter}:${result.verse.number}'),
                subtitle: _buildHighlightedText(result.highlightedText),
                onTap: () {
                  // Navegar para o versículo específico
                  _navigateToVerse(result);
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildHighlightedText(String highlightedText) {
    // Processar texto com marcações ##texto##
    final parts = highlightedText.split('##');
    
    List<TextSpan> textSpans = [];
    
    for (int i = 0; i < parts.length; i++) {
      // Texto destacado (posições ímpares)
      if (i % 2 == 1) {
        textSpans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            backgroundColor: Colors.yellow.shade200,
            fontWeight: FontWeight.bold,
          ),
        ));
      } 
      // Texto normal (posições pares)
      else if (parts[i].isNotEmpty) {
        textSpans.add(TextSpan(text: parts[i]));
      }
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        children: textSpans,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhuma pesquisa recente',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Digite algo para pesquisar na Bíblia',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Pesquisas recentes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(search),
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.call_made, size: 16),
                  onPressed: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Filtros de pesquisa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Selecionar livro específico'),
              onTap: () {
                Navigator.pop(context);
                _selectBook();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.filter_alt),
              title: const Text('Filtrar por testamento'),
              trailing: DropdownButton<String?>(
                value: _selectedTestament,
                hint: const Text('Todos'),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Todos'),
                  ),
                  DropdownMenuItem(
                    value: 'Antigo',
                    child: Text('Antigo Testamento'),
                  ),
                  DropdownMenuItem(
                    value: 'Novo',
                    child: Text('Novo Testamento'),
                  ),
                ],
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedTestament = value;
                    // Limpar filtro de livro se mudar o testamento
                    if (_selectedBook != null && _selectedBook!.testament != value) {
                      _selectedBook = null;
                      _selectedBookId = null;
                    }
                  });
                  
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                },
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text('Versão da Bíblia'),
              trailing: DropdownButton<String>(
                value: _currentVersion,
                items: widget.bibleService.versions.keys.map((version) {
                  return DropdownMenuItem(
                    value: version,
                    child: Text(version),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    Navigator.pop(context);
                    setState(() {
                      _currentVersion = value;
                    });
                    
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  }
                },
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Limpar todos os filtros'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedTestament = null;
                  _selectedBookId = null;
                  _selectedBook = null;
                  _currentVersion = widget.version;
                });
                
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
              },
            ),
            
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
  
  void _navigateToVerse(SearchResult result) {
    Navigator.pop(context, result);
  }
}