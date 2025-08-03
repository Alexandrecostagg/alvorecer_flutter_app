// lib/services/favorites_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final Set<String> _favorites = <String>{};
  static const String _favoritesKey = 'bible_favorites';

  Set<String> get favorites => Set.unmodifiable(_favorites);

  Future<void> init() async {
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      _favorites.clear();
      _favorites.addAll(favoritesJson);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar favoritos: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favorites.toList());
    } catch (e) {
      debugPrint('Erro ao salvar favoritos: $e');
    }
  }

  String _generateKey(int book, int chapter, int verse) {
    return '$book:$chapter:$verse';
  }

  bool isFavorite(int book, int chapter, int verse) {
    final key = _generateKey(book, chapter, verse);
    return _favorites.contains(key);
  }

  Future<void> toggleFavorite(int book, int chapter, int verse, String text) async {
    final key = _generateKey(book, chapter, verse);
    
    if (_favorites.contains(key)) {
      _favorites.remove(key);
    } else {
      _favorites.add(key);
    }
    
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> addFavorite(int book, int chapter, int verse, String text) async {
    final key = _generateKey(book, chapter, verse);
    _favorites.add(key);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> removeFavorite(int book, int chapter, int verse) async {
    final key = _generateKey(book, chapter, verse);
    _favorites.remove(key);
    await _saveFavorites();
    notifyListeners();
  }

  int get favoritesCount => _favorites.length;

  List<Map<String, dynamic>> getFavoritesList() {
    return _favorites.map((key) {
      final parts = key.split(':');
      return {
        'book': int.parse(parts[0]),
        'chapter': int.parse(parts[1]),
        'verse': int.parse(parts[2]),
        'key': key,
      };
    }).toList();
  }
}