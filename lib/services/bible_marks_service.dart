// lib/services/bible_marks_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bible_mark.dart';

class BibleMarksService extends ChangeNotifier {
  List<BibleMark> _marks = [];
  bool _isLoaded = false;
  
  static const String _storageKey = 'bible_marks';
  
  List<BibleMark> get marks => _marks;
  
  // Inicializar o serviço e carregar marcações
  Future<void> initialize() async {
    if (_isLoaded) return;
    await loadMarks();
  }
  
  // Carregar marcações do armazenamento
  Future<void> loadMarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? marksJson = prefs.getString(_storageKey);
      
      if (marksJson != null) {
        final List<dynamic> decoded = json.decode(marksJson);
        _marks = decoded.map((item) {
          try {
            // Adicionar conversão de cor
            if (item['color'] is String) {
              item['color'] = _stringToColor(item['color']);
            }
            return BibleMark.fromJson(item);
          } catch (e) {
            debugPrint('Erro ao converter marcação: $e');
            return null;
          }
        }).whereType<BibleMark>().toList();
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar marcações: $e');
      _marks = [];
      _isLoaded = true;
      notifyListeners();
    }
  }
  
  // Salvar marcações no armazenamento
  Future<void> _saveMarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _marks.map((mark) {
        final json = {
          'id': mark.id,
          'bookId': mark.bookId,
          'bookName': mark.bookName,
          'chapter': mark.chapter,
          'verse': mark.verse,
          'text': mark.text,
          'color': _colorToString(mark.color),
          'markType': mark.markType,
          'note': mark.note,
          'createdAt': mark.createdAt.toIso8601String(),
          'updatedAt': mark.updatedAt.toIso8601String(),
          'isFavorite': mark.isFavorite,
        };
        return json;
      }).toList();
      
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Erro ao salvar marcações: $e');
    }
  }

  // Converter cores para strings para armazenamento
  String _colorToString(Color color) {
    return color.value.toRadixString(16).padLeft(8, '0');
  }

  Color _stringToColor(String colorString) {
    return Color(int.parse(colorString, radix: 16));
  }
  
  // Adicionar uma nova marcação
  Future<BibleMark> addMark({
    required String bookId,
    required String bookName,
    required int chapter,
    required int verse,
    required String text,
    Color color = Colors.yellow,
    String markType = 'highlight',
    String note = '',
  }) async {
    // Verificar se já existe uma marcação do mesmo tipo
    final existingMarkIndex = _marks.indexWhere((m) => 
        m.bookId == bookId && 
        m.chapter == chapter && 
        m.verse == verse && 
        m.markType == markType);
    
    if (existingMarkIndex >= 0) {
      // Atualizar marcação existente
      final updatedMark = _marks[existingMarkIndex].copyWith(
        color: color,
        note: note.isNotEmpty ? note : _marks[existingMarkIndex].note,
        updatedAt: DateTime.now(),
      );
      
      _marks[existingMarkIndex] = updatedMark;
      await _saveMarks();
      notifyListeners();
      
      return updatedMark;
    } else {
      // Criar nova marcação
      final newMark = BibleMark.create(
        bookId: bookId,
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
        color: color,
        markType: markType,
        note: note,
      );
      
      _marks.add(newMark);
      await _saveMarks();
      notifyListeners();
      
      return newMark;
    }
  }
  
  // Atualizar uma marcação existente
  Future<void> updateMark({
    required String markId,
    Color? color,
    String? note,
    bool? isFavorite,
  }) async {
    final index = _marks.indexWhere((m) => m.id == markId);
    if (index < 0) return;
    
    _marks[index] = _marks[index].copyWith(
      color: color,
      note: note,
      isFavorite: isFavorite,
      updatedAt: DateTime.now(),
    );
    
    await _saveMarks();
    notifyListeners();
  }
  
  // Excluir uma marcação
  Future<void> deleteMark(String markId) async {
    _marks.removeWhere((m) => m.id == markId);
    await _saveMarks();
    notifyListeners();
  }
  
  // Obter marcações para um versículo específico
  List<BibleMark> getMarksForVerse(String bookId, int chapter, int verse) {
    return _marks.where((m) => 
        m.bookId == bookId && 
        m.chapter == chapter && 
        m.verse == verse).toList();
  }
  
  // Obter marcações por tipo
  List<BibleMark> getMarksByType(String markType) {
    return _marks.where((m) => m.markType == markType).toList();
  }
  
  // Obter marcações favoritas
  List<BibleMark> getFavorites() {
    return _marks.where((m) => m.isFavorite).toList();
  }
  
  // Obter marcações com notas
  List<BibleMark> getNotesOnly() {
    return _marks.where((m) => m.note.isNotEmpty).toList();
  }
  
  // Obter marcações por livro
  List<BibleMark> getMarksByBook(String bookId) {
    return _marks.where((m) => m.bookId == bookId).toList();
  }
  
  // Limpar todas as marcações (cuidado!)
  Future<void> clearAllMarks() async {
    _marks = [];
    await _saveMarks();
    notifyListeners();
  }
  
  // Exportar todas as marcações como JSON
  String exportMarksAsJson() {
    final List<Map<String, dynamic>> jsonList = _marks.map((mark) {
      final json = {
        'id': mark.id,
        'bookId': mark.bookId,
        'bookName': mark.bookName,
        'chapter': mark.chapter,
        'verse': mark.verse,
        'text': mark.text,
        'color': _colorToString(mark.color),
        'markType': mark.markType,
        'note': mark.note,
        'createdAt': mark.createdAt.toIso8601String(),
        'updatedAt': mark.updatedAt.toIso8601String(),
        'isFavorite': mark.isFavorite,
      };
      return json;
    }).toList();
    
    return json.encode(jsonList);
  }
  
  // Importar marcações de JSON
  Future<void> importMarksFromJson(String jsonString) async {
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      final List<BibleMark> importedMarks = decoded.map((item) {
        try {
          // Adicionar conversão de cor
          if (item['color'] is String) {
            item['color'] = _stringToColor(item['color']);
          }
          return BibleMark.fromJson(item);
        } catch (e) {
          debugPrint('Erro ao converter marcação importada: $e');
          return null;
        }
      }).whereType<BibleMark>().toList();
      
      // Adicionar marcações importadas às existentes
      for (var mark in importedMarks) {
        // Verificar se já existe
        final existingIndex = _marks.indexWhere((m) => m.id == mark.id);
        if (existingIndex >= 0) {
          _marks[existingIndex] = mark; // Substituir existente
        } else {
          _marks.add(mark); // Adicionar nova
        }
      }
      
      await _saveMarks();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao importar marcações: $e');
      throw Exception('Falha ao importar marcações: $e');
    }
  }
  
  // Método auxiliar para completar o modelo BibleMark
  BibleMark fromJson(Map<String, dynamic> json) {
    return BibleMark(
      id: json['id'] ?? '',
      bookId: json['bookId'] ?? '',
      bookName: json['bookName'] ?? '',
      chapter: json['chapter'] ?? 1,
      verse: json['verse'] ?? 1,
      text: json['text'] ?? '',
      color: _stringToColor(json['color'] ?? 'ffff0000'),
      markType: json['markType'] ?? 'highlight',
      note: json['note'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}