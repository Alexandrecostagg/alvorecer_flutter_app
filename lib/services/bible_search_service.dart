import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../models/verse.dart';
import 'bible_service.dart';

class SearchResult {
  final Book book;
  final int chapter;
  final Verse verse;
  final String highlightedText;
  
  SearchResult({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.highlightedText,
  });
}

class BibleSearchService {
  final BibleService _bibleService;
  
  BibleSearchService(this._bibleService);
  
  // Lista de pesquisas recentes
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recent_searches') ?? [];
  }
  
  // Adicionar uma pesquisa recente
  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final recentSearches = prefs.getStringList('recent_searches') ?? [];
    
    // Remover se já existir e adicionar no início
    recentSearches.remove(query.trim());
    recentSearches.insert(0, query.trim());
    
    // Manter apenas as 10 pesquisas mais recentes
    while (recentSearches.length > 10) {
      recentSearches.removeLast();
    }
    
    await prefs.setStringList('recent_searches', recentSearches);
  }
  
  // Limpar pesquisas recentes
  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
  }
  
  // Realizar a pesquisa
  Future<List<SearchResult>> search({
    required String query,
    String? testament,
    String? bookId,
    String version = 'ARC',
    int limit = 100,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }
    
    // Normalizar a consulta (remover acentos, converter para minúsculas)
    final normalizedQuery = _normalizeText(query);
    
    List<SearchResult> results = [];
    
    // Obter todos os livros ou filtrar por testamento/livro específico
    List<Book> books = [];
    if (bookId != null) {
      final allBooks = await _bibleService.getBooks();
      books = allBooks.where((book) => book.id.toLowerCase() == bookId.toLowerCase()).toList();
    } else if (testament != null) {
      final booksByTestament = await _bibleService.getBooksByTestament();
      books = booksByTestament[testament] ?? [];
    } else {
      books = await _bibleService.getBooks();
    }
    
    // Salvar a consulta nas pesquisas recentes
    await addRecentSearch(query);
    
    // Verificar se há cache para esta pesquisa
    final cachedResults = await _getCachedSearch(
      query: normalizedQuery,
      testament: testament,
      bookId: bookId,
      version: version
    );
    
    if (cachedResults.isNotEmpty) {
      return cachedResults;
    }
    
    // Percorrer cada livro
    for (final book in books) {
      // Percorrer cada capítulo
      for (int chapter = 1; chapter <= book.chapters; chapter++) {
        try {
          final verses = await _bibleService.getVerses(book.id, chapter, version);
          
          // Filtrar versículos que correspondem à consulta
          for (final verse in verses) {
            final normalizedText = _normalizeText(verse.text);
            
            if (normalizedText.contains(normalizedQuery)) {
              // Criar texto com destaque
              final highlightedText = _highlightMatches(verse.text, query);
              
              results.add(SearchResult(
                book: book,
                chapter: chapter,
                verse: verse,
                highlightedText: highlightedText,
              ));
              
              // Limitar o número de resultados
              if (results.length >= limit) {
                // Salvar no cache e retornar
                await _cacheSearchResults(
                  results,
                  normalizedQuery,
                  testament,
                  bookId,
                  version
                );
                return results;
              }
            }
          }
        } catch (e) {
          // Ignorar erros e continuar com o próximo capítulo
          print('Erro ao pesquisar em ${book.name} $chapter: $e');
          continue;
        }
      }
    }
    
    // Salvar resultados no cache
    await _cacheSearchResults(
      results,
      normalizedQuery,
      testament,
      bookId,
      version
    );
    
    return results;
  }
  
  // Normalizar texto para pesquisa
  String _normalizeText(String text) {
    return text.toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ç', 'c');
  }
  
  // Destacar correspondências no texto
  String _highlightMatches(String text, String query) {
    if (query.trim().isEmpty) return text;
    
    String result = text;
    
    // Substituir mantendo maiúsculas e minúsculas
    final regex = RegExp(query, caseSensitive: false);
    
    // Criar string de destaque com marcadores especiais
    result = result.replaceAllMapped(regex, (match) {
      return '##${match.group(0)}##';
    });
    
    return result;
  }
  
  // Cache de resultados de pesquisa
  Future<void> _cacheSearchResults(
    List<SearchResult> results,
    String normalizedQuery,
    String? testament,
    String? bookId,
    String version
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Criar chave de cache
      final cacheKey = 'search_${normalizedQuery}_${testament ?? "all"}_${bookId ?? "all"}_$version';
      
      // Converter resultados em JSON
      final resultsJson = results.map((result) => {
        'book': {
          'id': result.book.id,
          'name': result.book.name,
          'chapters': result.book.chapters,
          'testament': result.book.testament,
        },
        'chapter': result.chapter,
        'verse': {
          'number': result.verse.number,
          'text': result.verse.text,
          'bookId': result.verse.bookId,
          'chapter': result.verse.chapter,
          'version': result.verse.version,
        },
        'highlightedText': result.highlightedText,
      }).toList();
      
      // Salvar no cache
      await prefs.setString(cacheKey, jsonEncode(resultsJson));
    } catch (e) {
      print('Erro ao salvar cache de pesquisa: $e');
    }
  }
  
  // Obter resultados do cache
  Future<List<SearchResult>> _getCachedSearch(
    {required String query,
    String? testament,
    String? bookId,
    required String version}
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Criar chave de cache
      final cacheKey = 'search_${query}_${testament ?? "all"}_${bookId ?? "all"}_$version';
      
      // Verificar se existe cache
      if (!prefs.containsKey(cacheKey)) {
        return [];
      }
      
      // Obter dados do cache
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData == null) return [];
      
      // Converter de volta para objetos
      final List<dynamic> resultsJson = jsonDecode(cachedData);
      
      return resultsJson.map((json) {
        final bookJson = json['book'];
        final verseJson = json['verse'];
        
        return SearchResult(
          book: Book(
            id: bookJson['id'],
            name: bookJson['name'],
            chapters: bookJson['chapters'],
            testament: bookJson['testament'],
          ),
          chapter: json['chapter'],
          verse: Verse(
            number: verseJson['number'],
            text: verseJson['text'],
            bookId: verseJson['bookId'],
            chapter: verseJson['chapter'],
            version: verseJson['version'],
          ),
          highlightedText: json['highlightedText'],
        );
      }).toList();
    } catch (e) {
      print('Erro ao obter cache de pesquisa: $e');
      return [];
    }
  }
  
  // Limpar cache de pesquisa
  Future<void> clearSearchCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('search_'));
      
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Erro ao limpar cache de pesquisa: $e');
    }
  }
}