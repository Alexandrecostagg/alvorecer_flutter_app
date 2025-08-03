import 'dart:convert';
import 'dart:io';

/// Caminho da pasta com os arquivos da NVI
const biblePath = 'lib/data/bible';

/// Caminho do JSON final
const outputJsonPath = 'assets/data/bible/nvi_bible.json';

/// Função principal
void main() async {
  final dir = Directory(biblePath);

  if (!dir.existsSync()) {
    print('❌ Pasta $biblePath não encontrada.');
    return;
  }

  // Lista todos os arquivos .dart da pasta
  final dartFiles = dir
      .listSync()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

  print('📚 Encontrados ${dartFiles.length} livros da NVI.');

  final Map<String, dynamic> bibleData = {};

  for (var file in dartFiles) {
    final fileName = file.uri.pathSegments.last;
    final bookName = fileName
        .replaceAll('nvi_', '')
        .replaceAll('.dart', '')
        .replaceAll('_', ' ');

    // Lê o conteúdo do arquivo
    final content = File(file.path).readAsStringSync();

    // Extrai o texto simulando JSON por enquanto (pode ser adaptado)
    bibleData[bookName] = {
      "file": fileName,
      "content": content,
    };
  }

  // Gera o JSON final
  final jsonFile = File(outputJsonPath);
  jsonFile.createSync(recursive: true);
  jsonFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(bibleData));

  print('✅ JSON único gerado em: $outputJsonPath');
}