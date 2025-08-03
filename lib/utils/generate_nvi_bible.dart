import 'dart:convert';
import 'dart:io';

void main() async {
  // Substitua pelo caminho do seu arquivo CSV ou TXT da NVI
  final inputFile = File('assets/data/bible/nvi_bible.txt');
  final outputFile = File('assets/data/bible/nvi_bible.json');

  final lines = await inputFile.readAsLines();

  final Map<String, Map<String, List<String>>> bible = {};

  for (var line in lines) {
    // Exemplo de linha: "Gênesis;1;1;No princípio criou Deus os céus e a terra."
    final parts = line.split(';');
    if (parts.length < 4) continue;

    final book = parts[0].trim();
    final chapter = parts[1].trim();
    final verse = parts[2].trim();
    final text = parts.sublist(3).join(';').trim();

    bible.putIfAbsent(book, () => {});
    bible[book]!.putIfAbsent(chapter, () => []);
    bible[book]![chapter]!.add(text);
  }

  await outputFile.writeAsString(const JsonEncoder.withIndent('  ').convert(bible));
  print('✅ nvi_bible.json gerado com sucesso!');
}