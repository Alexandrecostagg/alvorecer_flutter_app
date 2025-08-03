// verse_comparison_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bible_version_service.dart';
import '../models/bible_verse.dart';
import 'dart:convert';
import 'dart:js_util';
import 'dart:html' show window;
import 'package:flutter/services.dart';

class VerseComparisonWidget extends StatefulWidget {
  final String bookId;
  final int chapter;
  final int verse;

  const VerseComparisonWidget({
    Key? key,
    required this.bookId,
    required this.chapter,
    required this.verse,
  }) : super(key: key);

  @override
  _VerseComparisonWidgetState createState() => _VerseComparisonWidgetState();
}

class _VerseComparisonWidgetState extends State<VerseComparisonWidget> {
  Map<String, BibleVerse> versesInDifferentVersions = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    final versionService = Provider.of<BibleVersionService>(context, listen: false);
    final versions = versionService.availableVersions;
    
    try {
      // Carrega todas as versões em paralelo
      final futures = versions.map((version) => _loadVerseForVersion(version));
      await Future.wait(futures);
      
      if (versesInDifferentVersions.isEmpty) {
        setState(() {
          errorMessage = 'Não foi possível carregar nenhuma versão deste versículo.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar versículos: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadVerseForVersion(String version) async {
    try {
      // Adaptar para usar seu BibleManager.js
      final jsCode = '''
        (async function() {
          try {
            const chapterData = await window.bibleManager.getChapter("${widget.bookId}", ${widget.chapter}, "${version}");
            const verseData = chapterData.verses.find(v => v.number === ${widget.verse});
            if (!verseData) {
              throw new Error("Versículo ${widget.verse} não encontrado");
            }
            
            // Adiciona a referência completa ao versículo
            verseData.reference = "${widget.bookId} ${widget.chapter}:${widget.verse}";
            
            return verseData;
          } catch (error) {
            console.error("Erro ao carregar versículo:", error);
            return null;
          }
        })();
      ''';

      final result = await promiseToFuture(
        callMethod(window, 'eval', [jsCode])
      );
      
      if (result != null) {
        final verseData = Map<String, dynamic>.from(dartify(result) as Map);
        final verse = BibleVerse.fromJson(verseData);
        
        setState(() {
          versesInDifferentVersions[version] = verse;
        });
      }
    } catch (e) {
      print('Erro ao carregar verso na versão $version: $e');
      // Não definimos errorMessage aqui para permitir que outras versões carreguem
    }
  }

  // Método para compartilhar um versículo
  void _shareVerse(BibleVerse verse, String versionName) {
    final textToShare = '${verse.text} (${verse.reference} - $versionName)';
    
    Clipboard.setData(ClipboardData(text: textToShare));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Versículo copiado para a área de transferência')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final versionService = Provider.of<BibleVersionService>(context);
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVerses,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.compare_arrows, color: theme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Comparação de Versões',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Divider(thickness: 1, color: theme.dividerColor),
        Expanded(
          child: versesInDifferentVersions.isEmpty
            ? Center(
                child: Text(
                  'Nenhum versículo encontrado para comparação.',
                  style: TextStyle(color: theme.disabledColor),
                ),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: versionService.availableVersions.map((version) {
                  final verse = versesInDifferentVersions[version];
                  if (verse == null) {
                    return const SizedBox.shrink();
                  }

                  final bool isCurrentVersion = version == versionService.currentVersion;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    elevation: isCurrentVersion ? 3 : 1,
                    color: isCurrentVersion ? theme.primaryColor.withOpacity(0.1) : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            versionService.getVersionFullName(version),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCurrentVersion ? theme.primaryColor : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copiar versículo',
                                onPressed: () => _shareVerse(
                                  verse, 
                                  versionService.getVersionFullName(version)
                                ),
                              ),
                              if (isCurrentVersion)
                                const Icon(Icons.check_circle, color: Colors.green)
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            verse.text,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Limpeza de recursos se necessário
    super.dispose();
  }
}