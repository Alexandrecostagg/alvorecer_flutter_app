import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:js' as js;
import '../models/bible_verse.dart';
import '../services/bible_version_service.dart';
import '../widgets/bible_version_selector.dart';

class GlorifyBibleView extends StatefulWidget {
  final List<dynamic>? books;

  const GlorifyBibleView({Key? key, this.books}) : super(key: key);

  @override
  _GlorifyBibleViewState createState() => _GlorifyBibleViewState();
}

class _GlorifyBibleViewState extends State<GlorifyBibleView> {
  List<BibleVerse> bibleVerses = [];
  String currentBook = 'Gênesis';
  int currentChapter = 1;
  bool isLoading = true;
  String errorMessage = '';
  
  final ScrollController _scrollController = ScrollController();
  final List<String> booksList = [
    'Gênesis', 'Êxodo', 'Levítico', 'Números', 'Deuteronômio',
    'Josué', 'Juízes', 'Rute', '1 Samuel', '2 Samuel',
    '1 Reis', '2 Reis', '1 Crônicas', '2 Crônicas', 'Esdras',
    'Neemias', 'Ester', 'Jó', 'Salmos', 'Provérbios',
    'Eclesiastes', 'Cânticos', 'Isaías', 'Jeremias', 'Lamentações',
    'Ezequiel', 'Daniel', 'Oseias', 'Joel', 'Amós',
    'Obadias', 'Jonas', 'Miqueias', 'Naum', 'Habacuque',
    'Sofonias', 'Ageu', 'Zacarias', 'Malaquias', 'Mateus',
    'Marcos', 'Lucas', 'João', 'Atos', 'Romanos',
    '1 Coríntios', '2 Coríntios', 'Gálatas', 'Efésios', 'Filipenses',
    'Colossenses', '1 Tessalonicenses', '2 Tessalonicenses', '1 Timóteo', '2 Timóteo',
    'Tito', 'Filemom', 'Hebreus', 'Tiago', '1 Pedro',
    '2 Pedro', '1 João', '2 João', '3 João', 'Judas',
    'Apocalipse'
  ];

  final Map<String, String> bookIdMap = {
    'Gênesis': 'genesis',
    'Êxodo': 'exodo',
    'Levítico': 'leviticus',
    'Números': 'numbers',
    'Deuteronômio': 'deuteronomy',
    'Josué': 'joshua',
    'Juízes': 'judges',
    'Rute': 'ruth',
    '1 Samuel': '1samuel',
    '2 Samuel': '2samuel',
    '1 Reis': '1kings',
    '2 Reis': '2kings',
    '1 Crônicas': '1chronicles',
    '2 Crônicas': '2chronicles',
    'Esdras': 'ezra',
    'Neemias': 'nehemiah',
    'Ester': 'esther',
    'Jó': 'job',
    'Salmos': 'salmos',
    'Provérbios': 'proverbs',
    'Eclesiastes': 'ecclesiastes',
    'Cânticos': 'songofsolomon',
    'Isaías': 'isaiah',
    'Jeremias': 'jeremiah',
    'Lamentações': 'lamentations',
    'Ezequiel': 'ezekiel',
    'Daniel': 'daniel',
    'Oseias': 'hosea',
    'Joel': 'joel',
    'Amós': 'amos',
    'Obadias': 'obadiah',
    'Jonas': 'jonah',
    'Miqueias': 'micah',
    'Naum': 'nahum',
    'Habacuque': 'habakkuk',
    'Sofonias': 'zephaniah',
    'Ageu': 'haggai',
    'Zacarias': 'zechariah',
    'Malaquias': 'malachi',
    'Mateus': 'mateus',
    'Marcos': 'mark',
    'Lucas': 'luke',
    'João': 'joao',
    'Atos': 'acts',
    'Romanos': 'romans',
    '1 Coríntios': '1corinthians',
    '2 Coríntios': '2corinthians',
    'Gálatas': 'galatians',
    'Efésios': 'ephesians',
    'Filipenses': 'philippians',
    'Colossenses': 'colossians',
    '1 Tessalonicenses': '1thessalonians',
    '2 Tessalonicenses': '2thessalonians',
    '1 Timóteo': '1timothy',
    '2 Timóteo': '2timothy',
    'Tito': 'titus',
    'Filemom': 'philemon',
    'Hebreus': 'hebrews',
    'Tiago': 'james',
    '1 Pedro': '1peter',
    '2 Pedro': '2peter',
    '1 João': '1john',
    '2 João': '2john',
    '3 João': '3john',
    'Judas': 'jude',
    'Apocalipse': 'revelation',
  };

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  Future<void> _loadChapter() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final bookId = bookIdMap[currentBook] ?? 'genesis';
      print('🔍 Carregando $currentBook (ID: $bookId) capítulo $currentChapter');
      
      // CORREÇÃO PRINCIPAL: Usar dart:convert em vez de js.context
      if (js.context.hasProperty('getBibleVerses')) {
        final result = js.context.callMethod('getBibleVerses', [bookId, currentChapter]);
        
        if (result != null) {
          // Aguardar se for uma Promise
          await Future.delayed(Duration(milliseconds: 500));
          
          try {
            // Converter resultado para string e fazer parse com dart:convert
            final String jsonString = result.toString();
            final Map<String, dynamic> data = jsonDecode(jsonString);
            
            if (data['verses'] != null) {
              final Map<String, dynamic> versesMap = data['verses'];
              
              final verses = versesMap.entries.map<BibleVerse>((entry) {
                return BibleVerse(
                  verse: int.tryParse(entry.key) ?? 1,
                  text: entry.value.toString(),
                  reference: '$currentBook $currentChapter:${entry.key}',
                );
              }).toList();

              // Ordenar por número do versículo
              verses.sort((a, b) => a.verse.compareTo(b.verse));

              setState(() {
                bibleVerses = verses;
                isLoading = false;
              });
              
              print('✅ Carregados ${verses.length} versículos para $currentBook $currentChapter');
              return;
            }
          } catch (parseError) {
            print('❌ Erro ao fazer parse: $parseError');
          }
        }
      }
      
      // Fallback com dados estáticos
      await _loadFallbackData();
      
    } catch (e) {
      print('❌ Erro geral ao carregar capítulo: $e');
      await _loadFallbackData();
    }
  }

  Future<void> _loadFallbackData() async {
    // Dados de fallback baseados nos dados JavaScript que sabemos que existem
    final Map<String, Map<int, Map<int, String>>> fallbackData = {
      'genesis': {
        1: {
          1: "No princípio criou Deus os céus e a terra.",
          2: "E a terra era sem forma e vazia; e havia trevas sobre a face do abismo; e o Espírito de Deus se movia sobre a face das águas.",
          3: "E disse Deus: Haja luz; e houve luz.",
        },
        2: {
          1: "Assim os céus, a terra e todo o seu exército foram acabados.",
          2: "E havendo Deus acabado no dia sétimo a obra que fizera, descansou no sétimo dia de toda a sua obra, que tinha feito.",
        }
      },
      'salmos': {
        1: {
          1: "Bem-aventurado o homem que não anda segundo o conselho dos ímpios, nem se detém no caminho dos pecadores, nem se assenta na roda dos escarnecedores.",
          2: "Antes tem o seu prazer na lei do Senhor, e na sua lei medita de dia e de noite.",
        },
        23: {
          1: "O Senhor é o meu pastor, nada me faltará.",
          2: "Deitar-me faz em verdes pastos, guia-me mansamente a águas quietas.",
        }
      },
      'joao': {
        3: {
          16: "Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça, mas tenha a vida eterna."
        }
      }
    };
    
    final bookId = bookIdMap[currentBook] ?? 'genesis';
    final bookData = fallbackData[bookId];
    final chapterData = bookData?[currentChapter];
    
    if (chapterData != null) {
      final verses = chapterData.entries.map<BibleVerse>((entry) {
        return BibleVerse(
          verse: entry.key,
          text: entry.value,
          reference: '$currentBook $currentChapter:${entry.key}',
        );
      }).toList();

      setState(() {
        bibleVerses = verses;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Capítulo não disponível. Por favor, tente outro capítulo.';
        bibleVerses = [
          BibleVerse(
            verse: 1, 
            text: 'Este capítulo não está disponível no momento.',
            reference: '$currentBook $currentChapter:1',
          ),
        ];
      });
    }
  }

  void _navigateToPreviousChapter() {
    if (currentChapter > 1) {
      setState(() {
        currentChapter--;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
      _loadChapter();
    } else {
      int currentBookIndex = booksList.indexOf(currentBook);
      if (currentBookIndex > 0) {
        setState(() {
          currentBook = booksList[currentBookIndex - 1];
          currentChapter = _getLastChapterOfBook(currentBook);
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        });
        _loadChapter();
      }
    }
  }

  void _navigateToNextChapter() {
    int lastChapter = _getLastChapterOfBook(currentBook);
    if (currentChapter < lastChapter) {
      setState(() {
        currentChapter++;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
      _loadChapter();
    } else {
      int currentBookIndex = booksList.indexOf(currentBook);
      if (currentBookIndex < booksList.length - 1) {
        setState(() {
          currentBook = booksList[currentBookIndex + 1];
          currentChapter = 1;
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        });
        _loadChapter();
      }
    }
  }

  int _getLastChapterOfBook(String book) {
    final Map<String, int> bookChapters = {
      'Gênesis': 50, 'Êxodo': 40, 'Levítico': 27, 'Números': 36, 'Deuteronômio': 34,
      'Josué': 24, 'Juízes': 21, 'Rute': 4, '1 Samuel': 31, '2 Samuel': 24,
      '1 Reis': 22, '2 Reis': 25, '1 Crônicas': 29, '2 Crônicas': 36, 'Esdras': 10,
      'Neemias': 13, 'Ester': 10, 'Jó': 42, 'Salmos': 150, 'Provérbios': 31,
      'Eclesiastes': 12, 'Cânticos': 8, 'Isaías': 66, 'Jeremias': 52, 'Lamentações': 5,
      'Ezequiel': 48, 'Daniel': 12, 'Oseias': 14, 'Joel': 3, 'Amós': 9,
      'Obadias': 1, 'Jonas': 4, 'Miqueias': 7, 'Naum': 3, 'Habacuque': 3,
      'Sofonias': 3, 'Ageu': 2, 'Zacarias': 14, 'Malaquias': 4, 'Mateus': 28,
      'Marcos': 16, 'Lucas': 24, 'João': 21, 'Atos': 28, 'Romanos': 16,
      '1 Coríntios': 16, '2 Coríntios': 13, 'Gálatas': 6, 'Efésios': 6, 'Filipenses': 4,
      'Colossenses': 4, '1 Tessalonicenses': 5, '2 Tessalonicenses': 3, '1 Timóteo': 6, '2 Timóteo': 4,
      'Tito': 3, 'Filemom': 1, 'Hebreus': 13, 'Tiago': 5, '1 Pedro': 5,
      '2 Pedro': 3, '1 João': 5, '2 João': 1, '3 João': 1, 'Judas': 1,
      'Apocalipse': 22
    };
    
    return bookChapters[book] ?? 1;
  }

  void _showBookSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione um Livro'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
              itemCount: booksList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(booksList[index]),
                  onTap: () {
                    setState(() {
                      currentBook = booksList[index];
                      currentChapter = 1;
                    });
                    Navigator.of(context).pop();
                    _loadChapter();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showChapterSelectionDialog() {
    int maxChapter = _getLastChapterOfBook(currentBook);
    List<int> chapters = List.generate(maxChapter, (i) => i + 1);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecione um Capítulo de $currentBook'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      currentChapter = chapters[index];
                    });
                    Navigator.of(context).pop();
                    _loadChapter();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: chapters[index] == currentChapter
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                      child: Text(
                        '${chapters[index]}',
                        style: TextStyle(
                          color: chapters[index] == currentChapter
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Buscar na Bíblia'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Ex: João 3:16',
              labelText: 'Referência Bíblica',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _parseAndNavigateToReference(searchController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Buscar'),
            ),
          ],
        );
      },
    );
  }

  void _parseAndNavigateToReference(String reference) {
    reference = reference.trim();
    RegExp regExp = RegExp(r'([1-3]?\s*[A-Za-zÀ-ú]+)\s+(\d+)(?::(\d+))?');
    Match? match = regExp.firstMatch(reference);
    
    if (match != null) {
      String bookName = match.group(1)?.trim() ?? '';
      int chapter = int.tryParse(match.group(2) ?? '1') ?? 1;
      int? verse = int.tryParse(match.group(3) ?? '');
      
      String normalizedBook = _normalizeBookName(bookName);
      
      if (booksList.contains(normalizedBook)) {
        setState(() {
          currentBook = normalizedBook;
          currentChapter = chapter;
        });
        
        _loadChapter().then((_) {
          if (verse != null) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _scrollToVerse(verse);
            });
          }
        });
      }
    }
  }

  String _normalizeBookName(String bookName) {
    Map<String, String> bookAliases = {
      'gn': 'Gênesis', 'gen': 'Gênesis', 'ex': 'Êxodo', 'exo': 'Êxodo',
      'lv': 'Levítico', 'nm': 'Números', 'dt': 'Deuteronômio', 'js': 'Josué',
      'jz': 'Juízes', 'rt': 'Rute', '1sm': '1 Samuel', '2sm': '2 Samuel',
      '1rs': '1 Reis', '2rs': '2 Reis', '1cr': '1 Crônicas', '2cr': '2 Crônicas',
      'ed': 'Esdras', 'ne': 'Neemias', 'et': 'Ester', 'jó': 'Jó', 'jo': 'Jó',
      'sl': 'Salmos', 'pv': 'Provérbios', 'ec': 'Eclesiastes', 'ct': 'Cânticos',
      'is': 'Isaías', 'jr': 'Jeremias', 'lm': 'Lamentações', 'ez': 'Ezequiel',
      'dn': 'Daniel', 'os': 'Oseias', 'jl': 'Joel', 'am': 'Amós', 'ob': 'Obadias',
      'jn': 'Jonas', 'mq': 'Miqueias', 'na': 'Naum', 'hc': 'Habacuque',
      'sf': 'Sofonias', 'ag': 'Ageu', 'zc': 'Zacarias', 'ml': 'Malaquias',
      'mt': 'Mateus', 'mc': 'Marcos', 'lc': 'Lucas', 'jo': 'João', 'at': 'Atos',
      'rm': 'Romanos', '1co': '1 Coríntios', '2co': '2 Coríntios', 'gl': 'Gálatas',
      'ef': 'Efésios', 'fp': 'Filipenses', 'cl': 'Colossenses', '1ts': '1 Tessalonicenses',
      '2ts': '2 Tessalonicenses', '1tm': '1 Timóteo', '2tm': '2 Timóteo', 'tt': 'Tito',
      'fm': 'Filemom', 'hb': 'Hebreus', 'tg': 'Tiago', '1pe': '1 Pedro', '2pe': '2 Pedro',
      '1jo': '1 João', '2jo': '2 João', '3jo': '3 João', 'jd': 'Judas', 'ap': 'Apocalipse',
    };
    
    if (booksList.contains(bookName)) {
      return bookName;
    }
    
    String lowerCaseName = bookName.toLowerCase().replaceAll(' ', '');
    if (bookAliases.containsKey(lowerCaseName)) {
      return bookAliases[lowerCaseName]!;
    }
    
    for (String book in booksList) {
      if (book.toLowerCase().startsWith(bookName.toLowerCase())) {
        return book;
      }
    }
    
    return bookName;
  }

  void _scrollToVerse(int verse) {
    try {
      int index = bibleVerses.indexWhere((v) => v.verse == verse);
      if (index >= 0 && _scrollController.hasClients) {
        double estimatedPosition = index * 70.0;
        
        _scrollController.animateTo(
          estimatedPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      print('Erro ao rolar para o versículo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleVersionService>(
      builder: (context, versionService, child) {
        return Scaffold(
          appBar: AppBar(
            title: InkWell(
              onTap: _showBookSelectionDialog,
              child: Text('Bíblia - $currentBook $currentChapter'),
            ),
            actions: [
              const BibleVersionSelector(),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _showSearchDialog,
              ),
              IconButton(
                icon: const Icon(Icons.menu_book),
                onPressed: _showChapterSelectionDialog,
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _navigateToPreviousChapter,
                    ),
                    Text(
                      '$currentBook $currentChapter (${versionService.getVersionFullName(versionService.currentVersion)})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _navigateToNextChapter,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, size: 48, color: Colors.orange),
                                SizedBox(height: 16),
                                Text(errorMessage, textAlign: TextAlign.center),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadChapter,
                                  child: Text('Tentar Novamente'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16.0),
                            itemCount: bibleVerses.length,
                            itemBuilder: (context, index) {
                              final verse = bibleVerses[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${verse.verse} ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: verse.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
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
          ),
        );
      },
    );
  }
}