// lib/models/bible_mark.dart

import 'package:flutter/material.dart';

class BibleMark {
  final String id;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final Color color;
  final String markType; // 'highlight', 'bookmark', 'note'
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  BibleMark({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.color = Colors.yellow,
    this.markType = 'highlight',
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  factory BibleMark.create({
    required String bookId,
    required String bookName,
    required int chapter,
    required int verse,
    required String text,
    Color color = Colors.yellow,
    String markType = 'highlight',
    String note = '',
    bool isFavorite = false,
  }) {
    final now = DateTime.now();
    final id = '${bookId}_${chapter}_${verse}_$markType';
    
    return BibleMark(
      id: id,
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      text: text,
      color: color,
      markType: markType,
      note: note,
      createdAt: now,
      updatedAt: now,
      isFavorite: isFavorite,
    );
  }
  
  BibleMark copyWith({
    String? id,
    String? bookId,
    String? bookName,
    int? chapter,
    int? verse,
    String? text,
    Color? color,
    String? markType,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return BibleMark(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      text: text ?? this.text,
      color: color ?? this.color,
      markType: markType ?? this.markType,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Método para converter BibleMark para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookName': bookName,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'color': color.value.toRadixString(16).padLeft(8, '0'),
      'markType': markType,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  // Método para criar BibleMark a partir de JSON
  factory BibleMark.fromJson(Map<String, dynamic> json) {
    return BibleMark(
      id: json['id'] ?? '',
      bookId: json['bookId'] ?? '',
      bookName: json['bookName'] ?? '',
      chapter: json['chapter'] ?? 1,
      verse: json['verse'] ?? 1,
      text: json['text'] ?? '',
      color: json['color'] is int 
          ? Color(json['color']) 
          : Color(int.parse(json['color'], radix: 16)),
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